//
//  RBFileSystemSupport.h
//  ReactiveBeaver
//
//  Created by skyylex on 12/05/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

extern NSString *const RBFileSystemSupportErrorDomain;

typedef NS_ENUM(NSUInteger, RBFileSystemSupportErrorCode) {
    RBFileSystemSupportErrorCodeNoFileOrDirectory = 110,
    RBFileSystemSupportErrorCodePathLeadToFile = 111,
    RBFileSystemSupportErrorCodeSavingToTempFolderFail = 112,
};

@interface RBFileSystemSupport : NSObject

+ (NSString *)applicationSupportDirectory;

+ (RACSignal *)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString;
+ (RACSignal *)createDirectoryIfNeeded:(NSString *)directoryPath;
+ (RACSignal *)saveFileURLDataToTheTempFolder:(NSString *)sourceURLString;
+ (RACSignal *)unarchiveFile:(NSString *)filePath toDestinationFolder:(NSString *)destinationFolder;

@end
