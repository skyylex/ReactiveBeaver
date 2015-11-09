//
//  RBFileSystemSupport.m
//  ReactiveBeaver
//
//  Created by skyylex on 12/05/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import "RBFileSystemSupport.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <KSCrypto/KSSHA1Stream.h>
#import <ZipZap/ZipZap.h>

NSString *const RBFileSystemSupportErrorDomain = @"RBFileSystemSupportErrorDomain";

@implementation RBFileSystemSupport

+ (RACSignal *)backupSupportIsDisabledForDirectory:(NSString *)directoryPath {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        BOOL directoryExist = [[NSFileManager defaultManager] fileExistsAtPath:directoryPath];
        
        if (directoryExist == YES) {
            NSURL *URL = [NSURL fileURLWithPath:directoryPath];
            id value = nil;
            [URL getResourceValue:&value forKey:NSURLIsExcludedFromBackupKey error:&error];
            
            if (error != nil) {
                [subscriber sendError:error];
            } else {
                [subscriber sendNext:value];
                [subscriber sendCompleted];
            }
        } else {
            error = [NSError errorWithDomain:RBFileSystemSupportErrorDomain
                                        code:RBFileSystemSupportErrorCodeNoFileOrDirectory
                                    userInfo:nil];
            [subscriber sendError:error];
        }
        
        return nil;
    }];
}

+ (RACSignal *)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:filePathString];
        
        if (fileExist == YES) {
            NSURL *URL = [NSURL fileURLWithPath:filePathString];
            [URL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
        } else {
            error = [NSError errorWithDomain:RBFileSystemSupportErrorDomain
                                        code:RBFileSystemSupportErrorCodeNoFileOrDirectory
                                    userInfo:nil];
        }
        
        if (error != nil) {
            [subscriber sendError:error];
        } else {
            [subscriber sendNext:@YES];
            [subscriber sendCompleted];
        }
        
        return nil;
    }];
}

+ (RACSignal *)createDirectoryIfNeeded:(NSString *)directoryPath {
    RACSignal *needToCreateFolderTrigger = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        BOOL isDirectory = NO;
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:directoryPath
                                                          isDirectory:&isDirectory];
        
        if (exist == YES && isDirectory == NO) {
            error = [NSError errorWithDomain:RBFileSystemSupportErrorDomain
                                        code:RBFileSystemSupportErrorCodePathLeadToFile
                                    userInfo:nil];
            [subscriber sendError:error];
        } else {
            [subscriber sendNext:@(exist)];
            [subscriber sendCompleted];
        }
        return nil;
    }];
    
    return [needToCreateFolderTrigger flattenMap:^RACStream *(NSNumber *exist) {
        RACSignal *resultSignal = nil;
        if (exist.boolValue == YES) {
            resultSignal = [RACSignal return:@YES];
        } else {
            resultSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                NSError *folderCreationError = nil;
                [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:&folderCreationError];
                
                if (folderCreationError == nil) {
                    [subscriber sendNext:@YES];
                    [subscriber sendCompleted];
                } else {
                    [subscriber sendError:folderCreationError];
                }
                
                return nil;
            }];
        }
        
        return resultSignal;
    }];
}

+ (void)createDirectory:(NSString *)directoryPath {
    NSParameterAssert(directoryPath);

}

+ (NSString *)applicationSupportDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = (paths.count > 0) ? paths.firstObject : nil;
    return basePath;
}

+ (RACSignal *)saveFileURLDataToTheTempFolder:(NSString *)sourceURLString {
    NSParameterAssert(sourceURLString != nil);
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURL *bookURL = [NSURL fileURLWithPath:sourceURLString];
        NSData *bookData = [NSData dataWithContentsOfURL:bookURL];
        NSString *resultTempPath = nil;
        if (bookData != nil) {
            NSString *sha1String = [bookData ks_SHA1DigestString];
            NSString *epubFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:sha1String];
            BOOL savingResult = [bookData writeToFile:epubFilePath atomically:YES];
            if (savingResult == YES) {
                resultTempPath = epubFilePath;
            }
        }
        
        if (resultTempPath != nil) {
            [subscriber sendNext:resultTempPath];
            [subscriber sendCompleted];
        } else {
            NSError *error = [NSError errorWithDomain:RBFileSystemSupportErrorDomain
                                                 code:RBFileSystemSupportErrorCodeSavingToTempFolderFail
                                             userInfo:nil];
            [subscriber sendError:error];
        }
        
        return nil;
    }];
}

+ (RACSignal *)unarchiveFile:(NSString *)filePath toDestinationFolder:(NSString *)destinationFolder {
    RACSignal *resultSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURL *path = [NSURL fileURLWithPath:destinationFolder];
        ZZArchive *archive = [ZZArchive archiveWithURL:[NSURL fileURLWithPath:filePath] error:nil];
        
        NSError *resultError = nil;
        for (ZZArchiveEntry *entry in archive.entries) {
            NSURL *targetPath = [path URLByAppendingPathComponent:entry.fileName];
            
            NSError *error = nil;
            if (entry.fileMode & S_IFDIR) {
                // check if directory bit is set
                [[NSFileManager defaultManager] createDirectoryAtURL:targetPath withIntermediateDirectories:YES attributes:nil error:&error];
                if (error != nil) {
                    resultError = error;
                    break;
                }
            } else {
                // Some archives don't have a separate entry for each directory
                // and just include the directory's name in the filename.
                // Make sure that directory exists before writing a file into it.
                [[NSFileManager defaultManager] createDirectoryAtURL:[targetPath URLByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error];
                if (error == nil) {
                    [[entry newDataWithError:&error] writeToURL:targetPath atomically:NO];
                    if (error != nil) {
                        resultError = error;
                        break;
                    }
                } else {
                    resultError = error;
                }
            }
            
            if (resultError != nil) {
                [subscriber sendError:resultError];
            } else {
                [subscriber sendNext:@YES];
                [subscriber sendCompleted];
            }
        }
        
        return nil;
    }];
    
    return resultSignal;
}

@end
