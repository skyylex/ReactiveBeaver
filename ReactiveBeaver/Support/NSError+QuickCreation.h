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

typedef NS_ENUM(NSUInteger, RBManifestParseError) {
    RBManifestParseErrorMultipleTags = 200,
    RBManifestParseErrorNoDocument = 201,
};

typedef NS_ENUM(NSUInteger, RBMetadataParseError) {
    RBMetadataParseErrorWrongTagsAmount = 250,
    RBMetadataParseErrorNoDocument = 251,
};

typedef NS_ENUM(NSUInteger, RBOPFParseError) {
    RBOPFParseErrorNoSpineEle = 301,
    RBOPFParseErrorWrongArguments = 302,
};

typedef NS_ENUM(NSUInteger, RBSpineParseError) {
    RBSpineParseErrorNoSpineElements = 351,
    RBSpineParseErrorNoDocument = 352,
    RBSpineParseErrorNoElementByIDRef = 353,
};

@interface NSError (QuickCreation)

+ (instancetype)parserErrorWithCode:(NSInteger)code;

@end
