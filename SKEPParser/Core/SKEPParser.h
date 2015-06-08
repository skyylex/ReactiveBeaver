//
//  SKEPParser.h
//  SKEPParser
//
//  Created by skyylex on 14/05/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

extern NSString *const SKEPParserErrorDomain;

/// TODO: remove duplicates
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

@interface SKEPParser : NSObject

/// input value needs to get RACTuple(sourcePath, destinationPath)
@property (nonatomic, strong) RACCommand *startParsingCommand;

- (RACSignal *)epubParsingTrigger;
- (RACSignal *)errorDuringParsingTrigger;

@end
