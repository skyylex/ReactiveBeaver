//
//  NSError+QuickCreation.h
//  SKEPParser
//
//  Created by Yury Lapitsky on 29.08.15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const SKEPParserErrorDomain = @"SKEPParserErrorDomain";

/// TODO: remove duplicates
/// TODO: names are too long (fix)
typedef NS_ENUM(NSUInteger, SKEPParserErrorCode) {
    SKEPParserErrorCodeIncorrectDestinationPath = -100,
    SKEPParserErrorCodeNoSourceFilePath = -101,
    SKEPParserErrorCodeInputParamsValidation = -102,
    SKEPParserErrorCodeEpubNoDestinationFolder = -103,
    SKEPParserErrorCodeContainerXMLFileOpening = -104,
    SKEPParserErrorCodeContainerXMLNoFullPathAttribute = -105,
    SKEPParserErrorCodeContainerXMLNoRootFilesElement = -106,
    SKEPParserErrorCodeContainerXMLNoRootFileElement = -107
};

@interface NSError (QuickCreation)

+ (instancetype)parserErrorWithCode:(NSInteger)code;

@end
