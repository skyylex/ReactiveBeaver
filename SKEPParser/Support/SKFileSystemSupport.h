//
//  SKFileSystemSupport.h
//  SKEPParser
//
//  Created by skyylex on 12/05/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface SKFileSystemSupport : NSObject

+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString;

+ (void)createDirectoryIfNeeded:(NSString *)directoryPath;
+ (NSString *)applicationSupportDirectory;
+ (RACSignal *)saveFileURLDataToTheTempFolder:(NSString *)sourceURLString;
+ (RACSignal *)unarchiveFile:(NSString *)filePath toDestinationFolder:(NSString *)destinationFolder;

@end
