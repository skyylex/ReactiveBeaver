//
//  SKFileSystemSupport.h
//  SKEPParser
//
//  Created by skyylex on 12/05/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

extern NSString *const SKFileSystemSupportErrorDomain;

typedef NS_ENUM(NSUInteger, SKFileSystemSupportErrorCode) {
    SKFileSystemSupportErrorCodeNoFileOrDirectory = 110,
    SKFileSystemSupportErrorCodePathLeadToFile = 111,
    SKFileSystemSupportErrorCodeSavingToTempFolderFail = 112,
};

@interface SKFileSystemSupport : NSObject

+ (NSString *)applicationSupportDirectory;

+ (RACSignal *)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString;
+ (RACSignal *)createDirectoryIfNeeded:(NSString *)directoryPath;
+ (RACSignal *)saveFileURLDataToTheTempFolder:(NSString *)sourceURLString;
+ (RACSignal *)unarchiveFile:(NSString *)filePath toDestinationFolder:(NSString *)destinationFolder;

@end
