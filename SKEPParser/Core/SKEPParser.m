//
//  SKEPParser.m
//  SKEPParser
//
//  Created by skyylex on 14/05/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import "SKEPParser.h"
#import "SKFileSystemSupport.h"
#import "zipzap.h"
#import <DDXML.h>
#import "SKEpubNameConstants.h"
#import "SKEPSpineElement.h"
#import "NSError+QuickCreation.h"
#import "SKEPManifestElement.h"
#import "CocoaLumberjack.h"

static int ddLogLevel = DDLogLevelError;

@implementation SKEPParser

#pragma marl - RACCommand

- (RACCommand *)startParsingCommand {
    if (_startParsingCommand == nil) {
        @weakify(self);
        _startParsingCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *paths) {
            @strongify(self);
            return [self unarchiveEpubToDestinationFolder:paths];
        }];
    }
    
    return _startParsingCommand;
}

- (RACSignal *)parseManifest:(DDXMLDocument *)document {
    /// TODO: implement
    RACSignal *manifestSectionSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (document != nil) {
            NSArray *manifestElements = [document.rootElement elementsForName:SKEPEpubContentOPFManifestElement];
            if (manifestElements.count == 1) {
                DDXMLElement *manifest = manifestElements.firstObject;
                [subscriber sendNext:manifest];
                [subscriber sendCompleted];
            } else {
                /// TODO: fix error code
                [subscriber sendError:[NSError parserErrorWithCode:0]];
            }
        } else {
            /// TODO: fix error code
            [subscriber sendError:[NSError parserErrorWithCode:0]];
        }
        
        return nil;
    }];
    
    return [manifestSectionSignal flattenMap:^RACStream *(DDXMLElement *manifestElement) {
        return [manifestElement.children.rac_sequence.signal flattenMap:^RACStream *(id xmlObject) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                SKEPManifestElement *manifestElement = nil;
                if ([xmlObject isKindOfClass:[DDXMLElement class]]) {
                    DDXMLElement *element = (DDXMLElement *)xmlObject;
                    manifestElement = [SKEPManifestElement new];
                    manifestElement.identifier = [element attributeForName:SKEPManifestElementIdentifierKey].stringValue;
                    manifestElement.href = [element attributeForName:SKEPManifestElementHrefKey].stringValue;
                    manifestElement.mediaType = [element attributeForName:SKEPManifestElementMediaTypKey].stringValue;
                    [subscriber sendNext:manifestElement];
                } else if ([xmlObject isKindOfClass:[DDXMLNode class]]) {
                    /// TODO: investigate what to do here with unspecified objects
                    DDLogWarn(@"Unknown element: %@", xmlObject);
                }
                
                [subscriber sendCompleted];
                
                return nil;
            }];
        }].collect;
    }];
}

- (RACSignal *)parseSpine:(DDXMLDocument *)document {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (document != nil) {
            NSArray *spineElements = [document.rootElement elementsForName:SKEPEpubContentOPFSpineElement];
            if (spineElements != nil && spineElements.count > 0) {
                [subscriber sendNext:spineElements.firstObject];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:[NSError parserErrorWithCode:0]];
            }
        } else {
            [subscriber sendError:[NSError parserErrorWithCode:0]];
        }
        
        return nil;
    }] flattenMap:^RACStream *(DDXMLElement *element) {
        return [element.children.rac_sequence.signal flattenMap:^RACStream *(DDXMLElement *spineItem) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                SKEPSpineElement *spineElement = [SKEPSpineElement new];
                DDXMLNode *idRefNode = [spineItem attributeForName:@"idref"];
                if (idRefNode != nil) {
                    spineElement.idRef = idRefNode.stringValue;
                    [subscriber sendNext:spineElement];
                    [subscriber sendCompleted];
                } else {
                    [subscriber sendError:[NSError parserErrorWithCode:0]];
                }
                
                return nil;
            }];
        }];
    }].collect;
}

- (RACSignal *)contentOPFFileParsed:(NSString *)opfFilePath {
    @weakify(self);
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        if (opfFilePath != nil) {
            NSData *data = [NSData dataWithContentsOfFile:opfFilePath];
            if (data != nil) {
                DDXMLDocument *document = [[DDXMLDocument alloc] initWithData:data options:kNilOptions error:&error];
                if (error == nil) {
                    [subscriber sendNext:document];
                    [subscriber sendCompleted];
                }
            } else {
                /// TODO: improve error code
                [subscriber sendError:[NSError parserErrorWithCode:0]];
            }
        } else {
            /// TODO: improve error code
            [subscriber sendError:[NSError parserErrorWithCode:0]];
        }
        
        return nil;
    }] flattenMap:^RACStream *(DDXMLDocument *document) {
        @strongify(self);
        RACSignal *manifestParsedTrigger = [self parseManifest:document];
        RACSignal *spineParsedTrigger = [self parseSpine:document];
        return [manifestParsedTrigger combineLatestWith:spineParsedTrigger];;
    }];
}

- (NSString *)containerXMLPath:(NSString *)epubUnzippedPath {
    NSString *metaFolder = [epubUnzippedPath stringByAppendingPathComponent:SKEPEpubMetaInfFolder];
    NSString *containerXMLPath = [metaFolder stringByAppendingPathComponent:SKEPEpubContainerXMLName];
    return containerXMLPath;
}

- (RACSignal *)containerXMLParsed:(NSString *)epubDestinationPath {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSString *containerXML = [self containerXMLPath:epubDestinationPath];
        NSData *containerXMLData = [NSData dataWithContentsOfFile:containerXML];
        if (containerXMLData != nil) {
            NSError *documentOpeningError = nil;
            DDXMLDocument *document = [[DDXMLDocument alloc] initWithData:containerXMLData
                                                                  options:kNilOptions
                                                                    error:&documentOpeningError];
            if (document != nil) {
                /// TODO: rewrite with XPath
                NSArray *rootFiles = [document.rootElement elementsForName:SKEPEpubContainerXMLParentNodeName];
                if (rootFiles.count > 0) {
                    DDXMLElement *rootFilesElement = rootFiles.firstObject;
                    NSArray *rootFileElements = [rootFilesElement elementsForName:SKEPEpubContainerXMLTargetNodeName];
                    if (rootFileElements != nil && rootFileElements.count > 0) {
                        DDXMLElement *rootFileElement = rootFileElements.firstObject;
                        if (rootFileElement != nil) {
                            DDXMLNode *node = [rootFileElement attributeForName:SKEPEpubContainerXMLFullPathAttribute];
                            NSString *fullPathValue = node.stringValue;
                            if (fullPathValue != nil) {
                                [subscriber sendNext:fullPathValue];
                            } else {
                                [subscriber sendError:[NSError parserErrorWithCode:SKEPParserErrorCodeContainerXMLNoFullPathAttribute]];
                            }
                        } else {
                            [subscriber sendError:[NSError parserErrorWithCode:SKEPParserErrorCodeContainerXMLNoRootFileElement]];
                        }
                    } else {
                        [subscriber sendError:[NSError parserErrorWithCode:SKEPParserErrorCodeContainerXMLNoRootFilesElement]];
                    }
                } else {
                    [subscriber sendError:[NSError parserErrorWithCode:SKEPParserErrorCodeContainerXMLNoRootFilesElement]];
                }
            }
        } else {
            [subscriber sendError:[NSError parserErrorWithCode:SKEPParserErrorCodeContainerXMLFileOpening]];
        }
        
        return nil;
    }] map:^id(NSString *relativePath) {
        return [epubDestinationPath stringByAppendingPathComponent:relativePath];
    }];
}

#pragma makr - Error

- (RACSignal *)errorDuringParsingTrigger {
    /// TODO: implement error signal
    return [RACSignal empty];
}

#pragma mark - Unarchiving

- (RACSignal *)unarchiveEpubToDestinationFolder:(RACTuple *)paths {
    RACSignal *validationSignal = [self validateInputForStartParsing:paths];
    return [[validationSignal flattenMap:^RACStream *(NSNumber *validationSuccess) {
        RACSignal *resultSignal = nil;
        if (validationSuccess.boolValue == YES) {
            NSString *sourceFile = paths.first;
            resultSignal = [SKFileSystemSupport saveFileURLDataToTheTempFolder:sourceFile];
        }
        else {
            /// TODO: undefined what to return if validation failed
            resultSignal = [RACSignal return:@NO];
        }
        
        return resultSignal;
    }] flattenMap:^RACStream *(NSString *tempFolderEpubPath) {
        NSString *destinationPath = paths.second;
        return [SKFileSystemSupport unarchiveFile:tempFolderEpubPath toDestinationFolder:destinationPath];
    }];
}

#pragma mark - Validation

- (RACSignal *)validateInputForStartParsing:(RACTuple *)startParsingInput {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        if ([startParsingInput isKindOfClass:[RACTuple class]]) {
            NSString *sourcePath = startParsingInput.first;
            NSString *destinationPath = startParsingInput.second;
            
            BOOL validSourceClass = [sourcePath isKindOfClass:[NSString class]];
            BOOL validDestinationClass = [destinationPath isKindOfClass:[NSString class]];
            if (validSourceClass == YES && validDestinationClass == YES) {
                BOOL sourcePathIsDirectory = NO;
                BOOL destinationPathIsDirectory = NO;
                BOOL sourcePathExist = [[NSFileManager defaultManager] fileExistsAtPath:sourcePath isDirectory:&sourcePathIsDirectory];
                if (sourcePathExist == YES && sourcePathIsDirectory == NO) {
                    BOOL destinationPathExist = [[NSFileManager defaultManager] fileExistsAtPath:destinationPath isDirectory:&destinationPathIsDirectory];
                    if (destinationPathExist == YES && destinationPathIsDirectory == YES) {
                        [subscriber sendNext:@YES];
                        [subscriber sendCompleted];
                    } else if (destinationPathExist == NO) {
                        error = [NSError parserErrorWithCode:SKEPParserErrorCodeIncorrectDestinationPath];
                    } else if (destinationPathExist == YES && destinationPathIsDirectory == NO) {
                        error = [NSError parserErrorWithCode:SKEPParserErrorCodeIncorrectDestinationPath];
                    }
                } else {
                    error = [NSError parserErrorWithCode:SKEPParserErrorCodeNoSourceFilePath];
                }
            } else {
                error = [NSError parserErrorWithCode:SKEPParserErrorCodeInputParamsValidation];
            }
        } else {
            error = [NSError parserErrorWithCode:SKEPParserErrorCodeInputParamsValidation];
        }
        
        if (error != nil) {
            [subscriber sendError:error];
        }
        
        return nil;
    }];
}

@end
