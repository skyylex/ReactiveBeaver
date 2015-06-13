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

NSString *const SKEPParserErrorDomain = @"SKEPParserErrorDomain";

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
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        return nil;
    }];
}

- (RACSignal *)parseSpine:(DDXMLDocument *)document {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (document != nil) {
            NSArray *spineElements = [document.rootElement elementsForName:SKEPEpubContainerXMLSpineElement];
            if (spineElements != nil && spineElements.count > 0) {
                [subscriber sendNext:spineElements.firstObject];
                [subscriber sendCompleted];
            }
            else {
                NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];
                [subscriber sendError:error];
            }
        }
        else {
            NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];
            [subscriber sendError:error];
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
                }
                else {
                    NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:nil];
                    [subscriber sendError:error];
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
            }
            else {
                /// TODO: improve error code
                NSError *error = [NSError errorWithDomain:SKEPParserErrorDomain code:0 userInfo:nil];
                [subscriber sendError:error];
            }
        }
        else {
            /// TODO: improve error code
            NSError *error = [NSError errorWithDomain:SKEPParserErrorDomain code:0 userInfo:nil];
            [subscriber sendError:error];
        }
        
        return nil;
    }] flattenMap:^RACStream *(DDXMLDocument *document) {
        @strongify(self);
        return [self parseSpine:document];
    }];
}

- (RACSignal *)containerXMLParsed:(NSString *)epubDestinationPath {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        BOOL isDirectory = NO;
        BOOL directoryExist = [[NSFileManager defaultManager] fileExistsAtPath:epubDestinationPath isDirectory:&isDirectory];
        
        if ((isDirectory == YES) && (directoryExist == YES)) {
            NSString *containerXMLPath = [[epubDestinationPath stringByAppendingPathComponent:SKEPEpubMetaInfFolder] stringByAppendingPathComponent:SKEPEpubContainerXMLName];
            NSData *containerXMLData = [NSData dataWithContentsOfFile:containerXMLPath];
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
                                }
                                else {
                                    NSError *error = [NSError errorWithDomain:SKEPParserErrorDomain code:SKEPParserErrorCodeContainerXMLNoFullPathAttribute userInfo:nil];
                                    [subscriber sendError:error];
                                }
                            }
                            else {
                                NSError *error = [NSError errorWithDomain:SKEPParserErrorDomain code:SKEPParserErrorCodeContainerXMLNoRootFileElement userInfo:nil];
                                [subscriber sendError:error];
                            }
                        }
                        else {
                            NSError *error = [NSError errorWithDomain:SKEPParserErrorDomain code:SKEPParserErrorCodeContainerXMLNoRootFilesElement userInfo:nil];
                            [subscriber sendError:error];
                        }
                    }
                    else {
                        NSError *error = [NSError errorWithDomain:SKEPParserErrorDomain code:SKEPParserErrorCodeContainerXMLNoRootFilesElement userInfo:nil];
                        [subscriber sendError:error];
                    }
                }
            }
            else {
                NSError *error = [NSError errorWithDomain:SKEPParserErrorDomain
                                                     code:SKEPParserErrorCodeContainerXMLFileOpening
                                                 userInfo:nil];
                [subscriber sendError:error];
            }
        }
        else {
            NSError *error = [NSError errorWithDomain:SKEPParserErrorDomain
                                                 code:SKEPParserErrorCodeEpubNoDestinationFolder
                                             userInfo:nil];
            [subscriber sendError:error];
        }
        
        return nil;
    }] map:^id(NSString *relativePath) {
        return [epubDestinationPath stringByAppendingPathComponent:relativePath];
    }];
}

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

#pragma makr - Error

- (RACSignal *)errorDuringParsingTrigger {
    /// TODO: implement error signal
    return [RACSignal empty];
}

#pragma mark - Unarchiving

#pragma mark - Validation

- (RACSignal *)validateInputForStartParsing:(RACTuple *)startParsingInput {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        if ([startParsingInput isKindOfClass:[RACTuple class]]) {
            NSString *sourcePath = startParsingInput.first;
            NSString *destinationPath = startParsingInput.second;
            
            if ([sourcePath isKindOfClass:[NSString class]] && [destinationPath isKindOfClass:[NSString class]]) {
                BOOL sourcePathIsDirectory = NO;
                BOOL destinationPathIsDirectory = NO;
                BOOL sourcePathExist = [[NSFileManager defaultManager] fileExistsAtPath:sourcePath isDirectory:&sourcePathIsDirectory];
                if (sourcePathExist == YES && sourcePathIsDirectory == NO) {
                    BOOL destinationPathExist = [[NSFileManager defaultManager] fileExistsAtPath:destinationPath isDirectory:&destinationPathIsDirectory];
                    if (destinationPathExist == YES && destinationPathIsDirectory == YES) {
                        [subscriber sendNext:@YES];
                        [subscriber sendCompleted];
                    }
                    else if (destinationPathExist == NO) {
                        error = [NSError errorWithDomain:SKEPParserErrorDomain code:SKEPParserErrorCodeIncorrectDestinationPath userInfo:nil];
                    }
                    else if (destinationPathExist == YES && destinationPathIsDirectory == NO) {
                        error = [NSError errorWithDomain:SKEPParserErrorDomain code:SKEPParserErrorCodeIncorrectDestinationPath userInfo:nil];
                    }
                }
                else {
                    error = [NSError errorWithDomain:SKEPParserErrorDomain code:SKEPParserErrorCodeNoSourceFilePath userInfo:nil];
                }
            }
            else {
                error = [NSError errorWithDomain:SKEPParserErrorDomain code:SKEPParserErrorCodeInputParamsValidation userInfo:nil];
            }
        }
        else {
            error = [NSError errorWithDomain:SKEPParserErrorDomain code:SKEPParserErrorCodeInputParamsValidation userInfo:nil];
        }
        
        if (error != nil) {
            [subscriber sendError:error];
        }
        
        return nil;
    }];
}

@end
