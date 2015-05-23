//
//  SKEPParser.m
//  SKEPParser
//
//  Created by skyylex on 14/05/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import "SKEPParser.h"
#import "SKFileSystemSupport.h"
#import <zipzap.h>

@implementation SKEPParser

#pragma marl - RACCommand

- (RACCommand *)startParsingCommand {
    if (_startParsingCommand == nil) {
        @weakify(self);
        _startParsingCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *paths) {
            @strongify(self);
            RACSignal *validationSignal = [self validateStartParsingTuple:paths];
            return [[validationSignal flattenMap:^RACStream *(NSNumber *validationSuccess) {
                RACSignal *resultSignal = nil;
                if (validationSuccess.boolValue == YES) {
                    NSString *sourceFile = paths.first;
                    resultSignal = [SKFileSystemSupport saveFileURLDataToTheTempFolder:sourceFile];
                }
                else {
                    resultSignal = [RACSignal return:[RACUnit defaultUnit]];
                }
                
                return resultSignal;
            }] flattenMap:^RACStream *(NSString *tempFolderEpubPath) {
                return [RACSignal return:[RACUnit defaultUnit]];
            }];
        }];
    }
    
    return _startParsingCommand;
}

#pragma mark - Unarchiving

#pragma mark - Validation

- (RACSignal *)validateStartParsingTuple:(RACTuple *)startParsingInput {
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
                    BOOL destinationPathExist = [[NSFileManager defaultManager] fileExistsAtPath:sourcePath isDirectory:&destinationPathIsDirectory];
                    if (destinationPathExist == YES && destinationPathIsDirectory == YES) {
                        [subscriber sendNext:@YES];
                        [subscriber sendCompleted];
                    }
                    else if (destinationPathExist == NO) {
                        error = [NSError errorWithDomain:@"destination path doesn't exist" code:0 userInfo:nil];
                    }
                    else if (destinationPathExist == YES && destinationPathIsDirectory == NO) {
                        error = [NSError errorWithDomain:@"destination path cannot be a file" code:0 userInfo:nil];
                    }
                }
                else {
                    error = [NSError errorWithDomain:@"source path doesn't exist or isn't a file" code:0 userInfo:nil];
                }
            }
            else {
                error = [NSError errorWithDomain:@"start parsing tuple must contain NSString paths" code:0 userInfo:nil];
            }
        }
        else {
            error = [NSError errorWithDomain:@"Start parsing input need to be RACTuple class" code:0 userInfo:nil];
        }
        
        if (error != nil) {
            [subscriber sendError:error];
        }
        
        return nil;
    }];
}

@end
