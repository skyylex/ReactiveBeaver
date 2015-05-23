//
//  SKFileSystemSupport.m
//  SKEPParser
//
//  Created by skyylex on 12/05/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import "SKFileSystemSupport.h"
#import <KSCrypto/KSSHA1Stream.h>
#import <zipzap.h>

@implementation SKFileSystemSupport

+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString {
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:filePathString], @"no file and directory");
    
    NSError *error = nil;
    NSURL *URL = [NSURL fileURLWithPath:filePathString];
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES]
                                  forKey:NSURLIsExcludedFromBackupKey error:&error];
    
    if (success == NO){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    
    return success;
}

+ (void)createDirectoryIfNeeded:(NSString *)directoryPath {
    NSParameterAssert(directoryPath);
    
    BOOL isDirectory = NO;
    BOOL directoryExists = [[NSFileManager defaultManager] fileExistsAtPath:directoryPath
                                                             isDirectory:&isDirectory];
    if (directoryExists == NO) {
        [[self class] createDirectory:directoryPath];
    }
}

+ (void)createDirectory:(NSString *)directoryPath {
    NSParameterAssert(directoryPath);
    
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
        NSLog(@"Create directory error: %@", error);
    }
}

+ (NSString *)applicationSupportDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+ (RACSignal *)saveFileURLDataToTheTempFolder:(NSString *)sourceURLString {
    NSParameterAssert(sourceURLString != nil);
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURL *bookURL = [NSURL fileURLWithPath:sourceURLString];
        NSData *bookData = [NSData dataWithContentsOfURL:bookURL];
        NSString *resultTempPath = nil;
        if (bookData) {
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
        }
        else {
            NSError *error = [NSError errorWithDomain:@"saveFileURLDataToTheTempFolder failed" code:0 userInfo:nil];
            [subscriber sendError:error];
        }
        
        return nil;
    }];
}

+ (RACSignal *)unarchiveFile:(NSString *)filePath toDestinationFolder:(NSString *)destinationFolder {
    RACSignal *resultSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURL *path = [NSURL fileURLWithPath:destinationFolder];
        ZZArchive *archive = [ZZArchive archiveWithURL:[NSURL fileURLWithPath:filePath] error:nil];
        for (ZZArchiveEntry *entry in archive.entries) {
            NSURL *targetPath = [path URLByAppendingPathComponent:entry.fileName];
            
            if (entry.fileMode & S_IFDIR)
                // check if directory bit is set
                [[NSFileManager defaultManager] createDirectoryAtURL:targetPath
                                         withIntermediateDirectories:YES
                                                          attributes:nil
                                                               error:nil];
            else {
                // Some archives don't have a separate entry for each directory
                // and just include the directory's name in the filename.
                // Make sure that directory exists before writing a file into it.
                [[NSFileManager defaultManager] createDirectoryAtURL:[targetPath URLByDeletingLastPathComponent]
                                         withIntermediateDirectories:YES
                                                          attributes:nil
                                                               error:nil];
                
                [[entry newDataWithError:nil] writeToURL:targetPath
                                              atomically:NO];
            }
        }
        
        return nil;
    }];
    
    return resultSignal;
}

@end
