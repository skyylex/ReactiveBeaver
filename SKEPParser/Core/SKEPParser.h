//
//  SKEPParser.h
//  SKEPParser
//
//  Created by skyylex on 14/05/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

typedef void(^SKEPParserResultCompletion)(NSDictionary *results, NSError *error);

@interface SKEPParser : NSObject

/// Creation of parser instance
/// @param sourcePath NSString path to the epub file (file should exist)
/// @param destinationPath NSString path to the destination folder
/// @return if both params points out to the valid file and folder - new parser instance will be returned, otherwise - nil
+ (instancetype)parserWithSourcePath:(NSString *)sourcePath destinationPath:(NSString *)destinationPath;

@end

/// Default API
@interface SKEPParser(StandartObjC)

- (void)startParsingWithCompletionBlock:(SKEPParserResultCompletion)completion;

@end

/// Alternative API for ReactiveCocoa support
@interface SKEPParser(ReactiveCocoaSupport)

/// @note to begin actual parsing call execute: on returned RACComand object
/// @return RACComand instance
- (RACCommand *)startCommand;

@end
