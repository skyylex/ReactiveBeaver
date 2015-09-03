//
//  NSError+QuickCreation.h
//  ReactiveBeaver
//
//  Created by Yury Lapitsky on 29.08.15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const RBParserErrorDomain = @"RBParserErrorDomain";

/// TODO: remove duplicates
/// TODO: names are too long (fix)
typedef NS_ENUM(NSUInteger, RBParserErrorCode) {
    RBParserErrorCodeIncorrectDestinationPath = -100,
    RBParserErrorCodeNoSourceFilePath = -101,
    RBParserErrorCodeInputParamsValidation = -102,
    RBParserErrorCodeEpubNoDestinationFolder = -103,
    RBParserErrorCodeContainerXMLFileOpening = -104,
    RBParserErrorCodeContainerXMLNoFullPathAttribute = -105,
    RBParserErrorCodeContainerXMLNoRootFilesElement = -106,
    RBParserErrorCodeContainerXMLNoRootFileElement = -107
};

@interface NSError (QuickCreation)

+ (instancetype)parserErrorWithCode:(NSInteger)code;

@end
