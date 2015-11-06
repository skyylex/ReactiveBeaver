//
//  RBParser.h
//  ReactiveBeaver
//
//  Created by skyylex on 14/05/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RBEpub.h"

typedef void(^RBParserResultCompletion)(RBEpub * _Nullable epub, NSError * _Nullable error);

@interface RBParser : NSObject

/// Creation of parser instance
/// @param sourcePath NSString path to the epub file (file should exist)
/// @param destinationPath NSString path to the destination folder
/// @return if both params points out to the valid file and folder - new parser instance will be returned, otherwise - nil
+ (instancetype)parserWithSourcePath:(NSString *)sourcePath destinationPath:(NSString * )destinationPath;

@end

/// Default API
@interface RBParser(StandartObjC)

- (void)startParsingWithCompletionBlock:(RBParserResultCompletion)completion;

@end

/// Alternative API for ReactiveCocoa support
@interface RBParser(ReactiveCocoaSupport)

/// @note to begin actual parsing call execute: on returned RACComand object
/// @return RACComand instance
- (RACCommand *)startCommand;

@end
