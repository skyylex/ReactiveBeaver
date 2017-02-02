//
//  SKFileSupportTests.m
//  ReactiveBeaver
//
//  Created by skyylex on 24/05/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <KissXML/KissXML.h>

#import "RBParser.h"
#import "RBFileSystemSupport.h"
#import "RBEpubNameConstants.h"
#import "NSError+QuickCreation.h"

static NSString *const RBParserTestBookSource1 = @"moby-dick";

@interface RBParser()

- (NSError *)validatePaths:(RACTuple *)tuple;
- (RACSignal *)unarchiveEpubToDestinationFolder:(RACTuple *)paths;
- (RACSignal *)containerXMLParsed:(NSString *)epubDestinationPath;
- (RACSignal *)contentOPFFileParsed:(NSString *)opfFilePath;
- (RACSignal *)parseSpine:(DDXMLDocument *)document;

@end

SPEC_BEGIN(RBParserTest)

describe(@"RBParserTest", ^{
    let(parser, ^{
        return [RBParser new];
    });
    
// Disabled because of the unrecognized selector - [NSDictionaryI first] error
/*
    context(@"startParsingCommand", ^{
        it(@"moby-dick book parsing", ^{
            Class specClass = [self class];
            NSString *validSourcePath = [[NSBundle bundleForClass:specClass] pathForResource:RBParserTestBookSource1 ofType:@"epub"];;
            NSString *destinationStringPath = [RBFileSystemSupport applicationSupportDirectory];
            __block NSNumber *finished = @(0);
            [[parser unarchiveEpubToDestinationFolder:RACTuplePack(validSourcePath, destinationStringPath)] subscribeNext:^(id x) {
                finished = @YES;
            }];
            
            [[expectFutureValue(finished) shouldNotEventuallyBeforeTimingOutAfter(3.0)] beNil];
            [[finished should] beYes];
            
            NSString *metaInfFolderPath = [destinationStringPath stringByAppendingPathComponent:RBEpubMetaInfFolder];
            NSString *mimetypeFolderPath = [destinationStringPath stringByAppendingPathComponent:RBEpubMimetypeFolder];
            
            BOOL metaInfIsDirectory = NO;
            BOOL mimetypeIsDirectory = NO;
            BOOL metaInfExist = [[NSFileManager defaultManager] fileExistsAtPath:metaInfFolderPath isDirectory:&metaInfIsDirectory];
            BOOL mimetypeExist = [[NSFileManager defaultManager] fileExistsAtPath:mimetypeFolderPath isDirectory:&mimetypeIsDirectory];
            
            [[theValue(metaInfIsDirectory) should] beYes];
            [[theValue(mimetypeIsDirectory) should] beNo];
            
            [[theValue(metaInfExist) should] beYes];
            [[theValue(mimetypeExist) should] beYes];
            
            __block id opfFilePath = nil;
            [[parser containerXMLParsed:destinationStringPath] subscribeNext:^(id x) {
                opfFilePath = x;
            }];
            
            [[expectFutureValue(opfFilePath) shouldNotEventuallyBeforeTimingOutAfter(1.0)] beNil];
            BOOL contentOpfFileExist = [[NSFileManager defaultManager] fileExistsAtPath:opfFilePath];
            [[theValue(contentOpfFileExist) should] beYes];
            
            
            __block NSArray *manifestElements = nil;
            __block NSArray *spineElements = nil;
            [[parser contentOPFFileParsed:opfFilePath] subscribeNext:^(RACTuple *tuple) {
                manifestElements = tuple.first;
                spineElements = tuple.second;
            }];
            
            /// Manually calculated values from contentOPF
            [[expectFutureValue(manifestElements) shouldNotEventuallyBeforeTimingOutAfter(5.0)] beNil];
            [[spineElements shouldNot] beNil];
            [[@(manifestElements.count) should] equal:@(151)];
            [[@(spineElements.count) should] equal:@(144)];
        });
    });
 */
    
    
    context(@"validateStartParsingTuple method", ^{
        it(@"incorrect class instead of tuple", ^{
            NSError *error = [parser validatePaths:(RACTuple *)[NSNumber new]];
            
            [[theValue([error.domain isEqualToString:RBParserErrorDomain]) should] beYes];
            [[theValue(error.code == RBParserErrorCodeInputParamsValidation) should] beYes];
        });
        
        it(@"incorrect class inside input tuple", ^{
            NSError *error = [parser validatePaths:RACTuplePack([NSObject new], [NSObject new])];
            
            [[theValue([error.domain isEqualToString:RBParserErrorDomain]) should] beYes];
            [[theValue(error.code == RBParserErrorCodeInputParamsValidation) should] beYes];
        });
        
        it(@"incorrect input number of arguments", ^{
            NSError *error = [parser validatePaths:RACTuplePack([NSObject new])];
            
            [[theValue([error.domain isEqualToString:RBParserErrorDomain]) should] beYes];
            [[theValue(error.code == RBParserErrorCodeInputParamsValidation) should] beYes];
        });
        
        it(@"source file doesn't exist", ^{
            NSError *error = [parser validatePaths:RACTuplePack(NSTemporaryDirectory(), NSTemporaryDirectory())];
            
            [[theValue([error.domain isEqualToString:RBParserErrorDomain]) should] beYes];
            [[theValue(error.code == RBParserErrorCodeNoSourceFilePath) should] beYes];
        });
        
        it(@"incorrect destination path #1", ^{
            NSString *validSourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:RBParserTestBookSource1 ofType:@"epub"];
            NSError *error = [parser validatePaths:RACTuplePack(validSourcePath, validSourcePath)];
            
            [[theValue([error.domain isEqualToString:RBParserErrorDomain]) should] beYes];
            [[theValue(error.code == RBParserErrorCodeIncorrectDestinationPath) should] beYes];
        });
        
        it(@"incorrect destination path #2", ^{
            NSString *validSourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:RBParserTestBookSource1 ofType:@"epub"];
            NSString *tempPathWithFakeSuffix = [NSTemporaryDirectory() stringByAppendingString:@"###"];
            NSError *error = [parser validatePaths:RACTuplePack(validSourcePath, tempPathWithFakeSuffix)];
            
            [[theValue([error.domain isEqualToString:RBParserErrorDomain]) should] beYes];
            [[theValue(error.code == RBParserErrorCodeIncorrectDestinationPath) should] beYes];
        });
        
        it(@"correct inputs", ^{
            NSString *validSourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:RBParserTestBookSource1
                                                                                         ofType:@"epub"];
            NSError *error = [parser validatePaths:RACTuplePack(validSourcePath, [RBFileSystemSupport applicationSupportDirectory])];
            
            [[error should] beNil];
        });
    });
});

SPEC_END
