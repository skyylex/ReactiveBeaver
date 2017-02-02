//
//  RBFileSupportTests.m
//  ReactiveBeaver
//
//  Created by skyylex on 24/05/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "RBFileSystemSupport.h"

static NSString *const RBFileSystemSupportTestFolderName = @"SKFileSystemSupportTestFolderName";

SPEC_BEGIN(RBFileSystemSupportTest)

describe(@"RBFileSystemSupport", ^{
    context(@"addSkipBackupAttributeToItemAtPath", ^{
        it(@"empty folder path", ^{
            RACSignal *disableBackupSignal = [RBFileSystemSupport addSkipBackupAttributeToItemAtPath:@""];
            
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
            [[theValue([disableBackupError.domain isEqualToString:RBFileSystemSupportErrorDomain]) should] beYes];
            [[theValue(disableBackupError.code == RBFileSystemSupportErrorCodeNoFileOrDirectory) should] beYes];
            [[theValue(disableBackupFinished) should] beYes];
        });
        
        it(@"valid folder path", ^{
            /// Preparation
            
            NSString *folderPath = [[RBFileSystemSupport applicationSupportDirectory] stringByAppendingPathComponent:RBFileSystemSupportTestFolderName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
                NSError *removeFolderError = nil;
                [[NSFileManager defaultManager] removeItemAtPath:folderPath error:&removeFolderError];
            }
            
            [RBFileSystemSupport createDirectoryIfNeeded:folderPath];
            
            RACSignal *disableBackupSignal = [RBFileSystemSupport addSkipBackupAttributeToItemAtPath:folderPath];
            
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
            [[theValue([disableBackupError.domain isEqualToString:RBFileSystemSupportErrorDomain]) should] beYes];
            [[theValue(disableBackupError.code == RBFileSystemSupportErrorCodeNoFileOrDirectory) should] beYes];
            [[theValue(disableBackupFinished) should] beYes];
        });
     });
});

SPEC_END
