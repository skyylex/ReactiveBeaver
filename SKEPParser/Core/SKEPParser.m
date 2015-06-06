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

NSString *const SKEPParserErrorDomain = @"SKEPParserErrorDomain";

@implementation SKEPParser

#pragma marl - RACCommand

- (RACCommand *)startParsingCommand {
    if (_startParsingCommand == nil) {
        @weakify(self);
        _startParsingCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *paths) {
            @strongify(self);
            return [self startParsing:paths];
        }];
    }
    
    return _startParsingCommand;
}

- (RACSignal *)startParsing:(RACTuple *)paths {
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
