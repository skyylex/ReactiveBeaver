//
//  SKFileSupportTests.m
//  SKEPParser
//
//  Created by skyylex on 24/05/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import "Kiwi.h"
#import "SKFileSystemSupport.h"

static NSString *const SKFileSystemSupportTestFolderName = @"SKFileSystemSupportTestFolderName";

SPEC_BEGIN(SKFileSystemSupportTest)

describe(@"SKFileSystemSupport", ^{
    context(@"addSkipBackupAttributeToItemAtPath", ^{
        it(@"empty folder path", ^{
            RACSignal *disableBackupSignal = [SKFileSystemSupport addSkipBackupAttributeToItemAtPath:@""];
            
            __block BOOL disableBackupFinished = NO;
            __block NSError *disableBackupError = nil;
            [disableBackupSignal subscribeNext:^(id x) {
                disableBackupError = nil;
                disableBackupFinished = YES;
            }];
            [disableBackupSignal subscribeError:^(NSError *error) {
                disableBackupError = error;
                disableBackupFinished = YES;
            }];
            
            [[expectFutureValue(disableBackupError) shouldNotEventuallyBeforeTimingOutAfter(0.5)] beNil];
            [[theValue([disableBackupError.domain isEqualToString:SKFileSystemSupportErrorDomain]) should] beYes];
            [[theValue(disableBackupError.code == SKFileSystemSupportErrorCodeNoFileOrDirectory) should] beYes];
            [[theValue(disableBackupFinished) should] beYes];
        });
        
        it(@"valid folder path", ^{
            /// Preparation
            
            NSString *folderPath = [[SKFileSystemSupport applicationSupportDirectory] stringByAppendingPathComponent:SKFileSystemSupportTestFolderName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
                NSError *removeFolderError = nil;
                [[NSFileManager defaultManager] removeItemAtPath:folderPath error:&removeFolderError];
            }
            
            [SKFileSystemSupport createDirectoryIfNeeded:folderPath];
            
            RACSignal *disableBackupSignal = [SKFileSystemSupport addSkipBackupAttributeToItemAtPath:folderPath];
            
            __block BOOL disableBackupFinished = NO;
            __block NSError *disableBackupError = nil;
            [disableBackupSignal subscribeNext:^(id x) {
                disableBackupError = nil;
                disableBackupFinished = YES;
            }];
            [disableBackupSignal subscribeError:^(NSError *error) {
                disableBackupError = error;
                disableBackupFinished = YES;
            }];
            
            [[expectFutureValue(disableBackupError) shouldNotEventuallyBeforeTimingOutAfter(0.5)] beNil];
            [[theValue([disableBackupError.domain isEqualToString:SKFileSystemSupportErrorDomain]) should] beYes];
            [[theValue(disableBackupError.code == SKFileSystemSupportErrorCodeNoFileOrDirectory) should] beYes];
            [[theValue(disableBackupFinished) should] beYes];
        });
     });
});

SPEC_END