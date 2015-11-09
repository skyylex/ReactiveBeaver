//
//  RBParser.m
//  ReactiveBeaver
//
//  Created by skyylex on 14/05/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import "RBParser.h"

#import "zipzap.h"
#import <DDXML.h>
#import "CocoaLumberjack.h"
#import "KSSHA1Stream.h"

#import "RBFileSystemSupport.h"
#import "RBEpubNameConstants.h"
#import "NSError+QuickCreation.h"

#import "RBEpub.h"
#import "RBManifestElement.h"
#import "RBSpineElement.h"


static int ddLogLevel = DDLogLevelError;

@interface RBParser()

@property (nonatomic, strong) NSString *sourcePath;
@property (nonatomic, strong) NSString *destinationPath;

@property (nonatomic, strong) RACCommand *startParsingCommand;

@end

@implementation RBParser

#pragma mark - Creation

+ (instancetype)parserWithSourcePath:(nonnull NSString *)sourcePath destinationPath:(nonnull NSString *)destinationPath {
    NSAssert(sourcePath != nil, @"source path is nil. [Assert works in DEBUG mode]");
    NSAssert(destinationPath != nil, @"destination path is nil. [Assert works in DEBUG mode]");
    
    RBParser *parser = nil;
    
    /// TODO: add validation of the source/destination paths
    BOOL validSourcePath = [[NSFileManager defaultManager] fileExistsAtPath:sourcePath];
    BOOL validDestinationPath = [[NSFileManager defaultManager] fileExistsAtPath:destinationPath];
    
    if (validSourcePath == YES && validDestinationPath == YES) {
        parser = [RBParser new];
        parser.sourcePath = sourcePath;
        parser.destinationPath = destinationPath;
    }
    return parser;
}

#pragma mark - ObjC default API

- (void)startParsingWithCompletionBlock:(RBParserResultCompletion)completion {
    NSAssert(self.sourcePath != nil, @"source path is nil.");
    NSAssert(self.destinationPath != nil, @"destination path is nil.");
    
    NSArray *inputs = @[self.sourcePath, self.destinationPath];
    
    RACSignal *executionSignal = [self.startParsingCommand.executionSignals take:1];
    [executionSignal subscribeNext:^(RACSignal *signal) {
        [signal subscribeNext:^(RBEpub *epub) {
            completion(epub, nil);
        }];
    }];
    
    [self.startParsingCommand.errors subscribeNext:^(NSError *error) {
        completion(nil, error);
    }];
    [self.startParsingCommand execute:[RACTuple tupleWithObjectsFromArray:inputs]];
}

#pragma mark - RACCommand

- (RACCommand *)startParsingCommand {
    if (_startParsingCommand == nil) {
        @weakify(self);
        _startParsingCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *paths) {
            @strongify(self);
            return [[self unarchiveEpubToDestinationFolder:paths] flattenMap:^RACStream *(NSString *epubDigest) {
                @strongify(self);
                NSString *destinationPath = paths.second;
                return [[self containerXMLParsed:destinationPath] flattenMap:^RACStream *(NSString *opfFilePath) {
                    @strongify(self);
                    return [[self contentOPFFileParsed:opfFilePath] flattenMap:^RACStream *(NSDictionary *collectedInfo) {
                        
                        RBEpub *epub = [RBEpub new];
                        epub.sha1 = epubDigest;
                        epub.manifestElements = collectedInfo[RBEpubContentOPFManifestElement];
                        epub.spineElements = collectedInfo[RBEpubContentOPFSpineElement];
                        epub.metadata = collectedInfo[RBEpubContentOPFMetadataElement];
                        epub.sourceEpubPath = paths.first;
                        epub.destinationEpubPath = paths.second;
                        
                        return [RACSignal return:epub];
                    }];
                }];
            }];
        }];
    }
    
    return _startParsingCommand;
}

#pragma mark - Parse

- (RACSignal *)parseManifest:(DDXMLDocument *)document {
    RACSignal *manifestSectionSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (document != nil) {
            NSArray *manifestElements = [document.rootElement elementsForName:RBEpubContentOPFManifestElement];
            if (manifestElements.count == 1) {
                DDXMLElement *manifest = manifestElements.firstObject;
                [subscriber sendNext:manifest];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:[NSError parserErrorWithCode:RBManifestParseErrorMultipleTags]];
            }
        } else {
            [subscriber sendError:[NSError parserErrorWithCode:RBManifestParseErrorNoDocument]];
        }
        
        return nil;
    }];
    
    return [manifestSectionSignal flattenMap:^RACStream *(DDXMLElement *manifestElement) {
        return [manifestElement.children.rac_sequence.signal flattenMap:^RACStream *(id xmlObject) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                RBManifestElement *manifestElement = nil;
                if ([xmlObject isKindOfClass:[DDXMLElement class]]) {
                    DDXMLElement *element = (DDXMLElement *)xmlObject;
                    manifestElement = [RBManifestElement new];
                    manifestElement.identifier = [element attributeForName:RBManifestElementIdentifierKey].stringValue;
                    manifestElement.href = [element attributeForName:RBManifestElementHrefKey].stringValue;
                    manifestElement.mediaType = [element attributeForName:RBManifestElementMediaTypKey].stringValue;
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

- (RACSignal *)parseMetadata:(DDXMLDocument *)document {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (document != nil) {
            NSArray *metadataElements = [document.rootElement elementsForName:RBEpubContentOPFMetadataElement];
            if (metadataElements != nil && metadataElements.count > 0) {
                [subscriber sendNext:metadataElements.firstObject];
            } else {
                [subscriber sendError:[NSError parserErrorWithCode:RBMetadataParseErrorWrongTagsAmount]];
            }
        } else {
            [subscriber sendError:[NSError parserErrorWithCode:RBMetadataParseErrorNoDocument]];
        }
        
        [subscriber sendCompleted];
        
        return nil;
    }] flattenMap:^RACStream *(DDXMLElement *metadataElement) {
        return [[[metadataElement.children.rac_sequence.signal flattenMap:^RACStream *(id xmlObject) {
            NSDictionary *metaDataPart = nil;
            if ([xmlObject isKindOfClass:[DDXMLElement class]]) {
                DDXMLElement *element = (DDXMLElement *)xmlObject;
                NSString *name = element.name;
                NSString *value = element.stringValue;
                metaDataPart = @{name : value};
            }
            
            return [RACSignal return:metaDataPart];
        }] filter:^BOOL(id value) {
            return value != nil;
        }].collect flattenMap:^RACStream *(NSArray *metaParts) {
            return [metaParts.rac_sequence.signal aggregateWithStart:[NSDictionary dictionary] reduce:^id(NSDictionary *currentMetadata, NSDictionary *nextPath) {
                NSMutableDictionary *mutableMetadata = currentMetadata.mutableCopy;
                NSDictionary *result = currentMetadata;
                BOOL allowedKeys = [RBParser supportedMetadataKey:nextPath.allKeys.firstObject];
                if (allowedKeys == YES) {
                    [mutableMetadata addEntriesFromDictionary:nextPath];
                    result = mutableMetadata.copy;
                }
                return result;
            }];
        }];
    }];
}

+ (BOOL)supportedMetadataKey:(NSString *)key {
    static NSSet *supportedKeys = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *keys = @[@"dc:title",
                          @"dc:creator",
                          @"dc:identifier",
                          @"dc:publisher",
                          @"dc:contributor",
                          @"dc:rights"];
        supportedKeys = [NSSet setWithArray:keys];
    });
    
    NSPredicate *sameStringKeyPredicate = [NSPredicate predicateWithFormat:@"SELF =[cd] %@", key];
    return [supportedKeys filteredSetUsingPredicate:sameStringKeyPredicate].count > 0;
}

- (RACSignal *)parseSpine:(DDXMLDocument *)document {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (document != nil) {
            NSArray *spineElements = [document.rootElement elementsForName:RBEpubContentOPFSpineElement];
            if (spineElements != nil && spineElements.count > 0) {
                [subscriber sendNext:spineElements.firstObject];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:[NSError parserErrorWithCode:RBSpineParseErrorNoSpineElements]];
            }
        } else {
            [subscriber sendError:[NSError parserErrorWithCode:RBSpineParseErrorNoDocument]];
        }
        
        return nil;
    }] flattenMap:^RACStream *(DDXMLElement *element) {
        return [element.children.rac_sequence.signal flattenMap:^RACStream *(DDXMLElement *spineItem) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                RBSpineElement *spineElement = [RBSpineElement new];
                DDXMLNode *idRefNode = [spineItem attributeForName:SpineElementIDRefKey];
                if (idRefNode != nil) {
                    spineElement.idRef = idRefNode.stringValue;
                    [subscriber sendNext:spineElement];
                    [subscriber sendCompleted];
                } else {
                    [subscriber sendError:[NSError parserErrorWithCode:RBSpineParseErrorNoElementByIDRef]];
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
                } else {
                    [subscriber sendError:error];
                }
            } else {
                [subscriber sendError:[NSError parserErrorWithCode:RBOPFParseErrorNoFileAtPath]];
            }
        } else {
            [subscriber sendError:[NSError parserErrorWithCode:RBOPFParseErrorWrongArguments]];
        }
        
        return nil;
    }] flattenMap:^RACStream *(DDXMLDocument *document) {
        @strongify(self);
        RACSignal *manifestParsedTrigger = [self parseManifest:document];
        RACSignal *spineParsedTrigger = [self parseSpine:document];
        RACSignal *metadataParsedTrigger = [self parseMetadata:document];
        RACSignal *collectedInfoTrigger = [[[metadataParsedTrigger flattenMap:^RACStream *(NSDictionary *metadataInfo) {
            
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                NSError *error = nil;
                RBMetadata *metadata = [MTLJSONAdapter modelOfClass:[RBMetadata class] fromJSONDictionary:metadataInfo error:&error];
                if (error != nil) {
                    [subscriber sendError:error];
                } else {
                    [subscriber sendNext:@{RBEpubContentOPFMetadataElement: metadata}];
                    [subscriber sendCompleted];
                }
                
                return nil;
            }];
        }] flattenMap:^RACStream *(NSDictionary *collectedInfo) {
            return [spineParsedTrigger flattenMap:^RACStream *(NSArray *spineElements) {
                NSMutableDictionary *collectedInfoMutable = collectedInfo.mutableCopy;
                [collectedInfoMutable setObject:spineElements forKey:RBEpubContentOPFSpineElement];
                return [RACSignal return:collectedInfoMutable.copy];
            }];
        }] flattenMap:^RACStream *(NSDictionary *collectedInfo) {
            return [manifestParsedTrigger flattenMap:^RACStream *(NSArray *manifestElements) {
                NSMutableDictionary *collectedInfoMutable = collectedInfo.mutableCopy;
                [collectedInfoMutable setObject:manifestElements forKey:RBEpubContentOPFManifestElement];
                return [RACSignal return:collectedInfoMutable.copy];
            }];
        }];
        
        return collectedInfoTrigger;
    }];
}

- (NSString *)containerXMLPath:(NSString *)epubUnzippedPath {
    NSString *metaFolder = [epubUnzippedPath stringByAppendingPathComponent:RBEpubMetaInfFolder];
    NSString *containerXMLPath = [metaFolder stringByAppendingPathComponent:RBEpubContainerXMLName];
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
                NSArray *rootFiles = [document.rootElement elementsForName:RBEpubContainerXMLParentNodeName];
                if (rootFiles.count > 0) {
                    DDXMLElement *rootFilesElement = rootFiles.firstObject;
                    NSArray *rootFileElements = [rootFilesElement elementsForName:RBEpubContainerXMLTargetNodeName];
                    if (rootFileElements != nil && rootFileElements.count > 0) {
                        DDXMLElement *rootFileElement = rootFileElements.firstObject;
                        if (rootFileElement != nil) {
                            DDXMLNode *node = [rootFileElement attributeForName:RBEpubContainerXMLFullPathAttribute];
                            NSString *fullPathValue = node.stringValue;
                            if (fullPathValue != nil) {
                                [subscriber sendNext:fullPathValue];
                            } else {
                                [subscriber sendError:[NSError parserErrorWithCode:RBParserErrorCodeContainerXMLNoFullPathAttribute]];
                            }
                        } else {
                            [subscriber sendError:[NSError parserErrorWithCode:RBParserErrorCodeContainerXMLNoRootFileElement]];
                        }
                    } else {
                        [subscriber sendError:[NSError parserErrorWithCode:RBParserErrorCodeContainerXMLNoRootFilesElement]];
                    }
                } else {
                    [subscriber sendError:[NSError parserErrorWithCode:RBParserErrorCodeContainerXMLNoRootFilesElement]];
                }
            }
        } else {
            [subscriber sendError:[NSError parserErrorWithCode:RBParserErrorCodeContainerXMLFileOpening]];
        }
        
        return nil;
    }] map:^id(NSString *relativePath) {
        return [epubDestinationPath stringByAppendingPathComponent:relativePath];
    }];
}

#pragma mark - Error

- (RACSignal *)errorDuringParsingTrigger {
    /// TODO: implement error signal
    return [RACSignal empty];
}

#pragma mark - Unarchive

- (RACSignal *)unarchiveEpubToDestinationFolder:(RACTuple *)paths {
    RACSignal *validationSignal = [self validateInputForStartParsing:paths];
    return [[validationSignal flattenMap:^RACStream *(NSNumber *validationSuccess) {
        RACSignal *resultSignal = nil;
        if (validationSuccess.boolValue == YES) {
            NSString *sourceFile = paths.first;
            resultSignal = [RBFileSystemSupport saveFileURLDataToTheTempFolder:sourceFile];
        }
        else {
            /// TODO: undefined what to return if validation failed
            resultSignal = [RACSignal return:@NO];
        }
        
        return resultSignal;
    }] flattenMap:^RACStream *(NSString *tempFolderEpubPath) {
        NSString *destinationPath = paths.second;
        NSData *epubRawData = [NSData dataWithContentsOfFile:tempFolderEpubPath];
        NSString *epubDigest = [NSData ks_stringFromSHA1Digest:epubRawData];
        return [[RBFileSystemSupport unarchiveFile:tempFolderEpubPath toDestinationFolder:destinationPath] map:^id(id _) {
            return epubDigest;
        }];
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
                        error = [NSError parserErrorWithCode:RBParserErrorCodeIncorrectDestinationPath];
                    } else if (destinationPathExist == YES && destinationPathIsDirectory == NO) {
                        error = [NSError parserErrorWithCode:RBParserErrorCodeIncorrectDestinationPath];
                    }
                } else {
                    error = [NSError parserErrorWithCode:RBParserErrorCodeNoSourceFilePath];
                }
            } else {
                error = [NSError parserErrorWithCode:RBParserErrorCodeInputParamsValidation];
            }
        } else {
            error = [NSError parserErrorWithCode:RBParserErrorCodeInputParamsValidation];
        }
        
        if (error != nil) {
            [subscriber sendError:error];
        }
        
        return nil;
    }];
}

@end

@implementation RBParser(ReactiveCocoaSupport)

- (RACCommand *)startCommand {
    return self.startParsingCommand;
}

@end
