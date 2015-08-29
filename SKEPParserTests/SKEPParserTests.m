//
//  SKFileSupportTests.m
//  SKEPParser
//
//  Created by skyylex on 24/05/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import "Kiwi.h"
#import "SKEPParser.h"
#import "SKFileSystemSupport.h"
#import "SKEpubNameConstants.h"
#import "DDXML.h"
#import "NSError+QuickCreation.h"

static NSString *const SKEPParserTestBookSource1 = @"moby-dick";

@interface SKEPParser()

- (RACSignal *)unarchiveEpubToDestinationFolder:(RACTuple *)paths;
- (RACSignal *)validateInputForStartParsing:(RACTuple *)startParsingInput;
- (RACSignal *)containerXMLParsed:(NSString *)epubDestinationPath;
- (RACSignal *)contentOPFFileParsed:(NSString *)opfFilePath;
- (RACSignal *)parseSpine:(DDXMLDocument *)document;

@end

SPEC_BEGIN(SKEPParserTest)

describe(@"SKEPParserTest", ^{
    let(parser, ^{
        return [SKEPParser new];
    });
    
    context(@"startParsingCommand", ^{
        it(@"moby-dick book parsing", ^{
            NSString *validSourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:SKEPParserTestBookSource1 ofType:@"epub"];;
            NSString *destinationStringPath = [SKFileSystemSupport applicationSupportDirectory];
            __block NSNumber *finished = nil;
            [[parser unarchiveEpubToDestinationFolder:RACTuplePack(validSourcePath, destinationStringPath)] subscribeNext:^(id x) {
                finished = @YES;
            }];
            
            [[expectFutureValue(finished) shouldNotEventuallyBeforeTimingOutAfter(5.0)] beNil];
            [[finished should] beYes];
            
            NSString *metaInfFolderPath = [destinationStringPath stringByAppendingPathComponent:SKEPEpubMetaInfFolder];
            NSString *mimetypeFolderPath = [destinationStringPath stringByAppendingPathComponent:SKEPEpubMimetypeFolder];
            
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
            
            [[parser contentOPFFileParsed:opfFilePath] subscribeNext:^(RACTuple *tuple) {
                NSArray *manifestElements = tuple.first;
                NSArray *spineElements = tuple.second;
                
                /// Manually calculated values from contentOPF
                [[@(manifestElements.count) should] equal:@(151)];
                [[@(spineElements.count) should] equal:@(144)];
            }];
        });
    });
    
    
    context(@"validateStartParsingTuple method", ^{
        it(@"incorrect class instead of tuple", ^{
            RACSignal *validationSignal = [parser validateInputForStartParsing:(RACTuple *)[NSObject new]];
            __block NSError *error = nil;
            __block BOOL validationFinished = NO;
            
            [validationSignal subscribeCompleted:^{
                
            }];
            [validationSignal subscribeError:^(NSError *validationError) {
                validationFinished = YES;
                error = validationError;
            }];
            
            [[expectFutureValue(error) shouldNotEventuallyBeforeTimingOutAfter(0.5)] beNil];
            [[theValue([error.domain isEqualToString:SKEPParserErrorDomain]) should] beYes];
            [[theValue(error.code == SKEPParserErrorCodeInputParamsValidation) should] beYes];
            [[theValue(validationFinished) should] beYes];
        });
        
        it(@"incorrect class inside input tuple", ^{
            RACSignal *validationSignal = [parser validateInputForStartParsing:RACTuplePack([NSObject new], [NSObject new])];
            __block NSError *error = nil;
            __block BOOL validationFinished = NO;
            
            [validationSignal subscribeCompleted:^{
                
            }];
            [validationSignal subscribeError:^(NSError *validationError) {
                validationFinished = YES;
                error = validationError;
            }];
            
            [[expectFutureValue(error) shouldNotEventuallyBeforeTimingOutAfter(0.5)] beNil];
            [[theValue([error.domain isEqualToString:SKEPParserErrorDomain]) should] beYes];
            [[theValue(error.code == SKEPParserErrorCodeInputParamsValidation) should] beYes];
            [[theValue(validationFinished) should] beYes];
        });
        
        it(@"incorrect input number of arguments", ^{
            RACSignal *validationSignal = [parser validateInputForStartParsing:RACTuplePack([NSObject new])];
            __block NSError *error = nil;
            __block BOOL validationFinished = NO;
            
            [validationSignal subscribeCompleted:^{
                
            }];
            [validationSignal subscribeError:^(NSError *validationError) {
                validationFinished = YES;
                error = validationError;
            }];
            
            [[expectFutureValue(error) shouldNotEventuallyBeforeTimingOutAfter(0.5)] beNil];
            [[theValue([error.domain isEqualToString:SKEPParserErrorDomain]) should] beYes];
            [[theValue(error.code == SKEPParserErrorCodeInputParamsValidation) should] beYes];
            [[theValue(validationFinished) should] beYes];
        });
        
        it(@"source file doesn't exist", ^{
            RACSignal *validationSignal = [parser validateInputForStartParsing:RACTuplePack(NSTemporaryDirectory(), NSTemporaryDirectory())];
            __block NSError *error = nil;
            __block BOOL validationFinished = NO;
            
            [validationSignal subscribeCompleted:^{
                
            }];
            [validationSignal subscribeError:^(NSError *validationError) {
                validationFinished = YES;
                error = validationError;
            }];
            
            [[expectFutureValue(error) shouldNotEventuallyBeforeTimingOutAfter(0.5)] beNil];
            [[theValue([error.domain isEqualToString:SKEPParserErrorDomain]) should] beYes];
            [[theValue(error.code == SKEPParserErrorCodeNoSourceFilePath) should] beYes];
            [[theValue(validationFinished) should] beYes];
        });
        
        it(@"source file doesn't exist", ^{
            RACSignal *validationSignal = [parser validateInputForStartParsing:RACTuplePack(NSTemporaryDirectory(), NSTemporaryDirectory())];
            __block NSError *error = nil;
            __block BOOL validationFinished = NO;
            
            [validationSignal subscribeCompleted:^{
                
            }];
            [validationSignal subscribeError:^(NSError *validationError) {
                validationFinished = YES;
                error = validationError;
            }];
            
            [[expectFutureValue(error) shouldNotEventuallyBeforeTimingOutAfter(0.5)] beNil];
            [[theValue([error.domain isEqualToString:SKEPParserErrorDomain]) should] beYes];
            [[theValue(error.code == SKEPParserErrorCodeNoSourceFilePath) should] beYes];
            [[theValue(validationFinished) should] beYes];
        });
        
        it(@"incorrect destination path #1", ^{
            NSString *validSourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:SKEPParserTestBookSource1 ofType:@"epub"];
            RACSignal *validationSignal = [parser validateInputForStartParsing:RACTuplePack(validSourcePath, validSourcePath)];
            __block NSError *error = nil;
            __block BOOL validationFinished = NO;
            
            [validationSignal subscribeCompleted:^{
                
            }];
            [validationSignal subscribeError:^(NSError *validationError) {
                validationFinished = YES;
                error = validationError;
            }];
            
            [[expectFutureValue(error) shouldNotEventuallyBeforeTimingOutAfter(0.5)] beNil];
            [[theValue([error.domain isEqualToString:SKEPParserErrorDomain]) should] beYes];
            [[theValue(error.code == SKEPParserErrorCodeIncorrectDestinationPath) should] beYes];
            [[theValue(validationFinished) should] beYes];
        });
        
        it(@"incorrect destination path #2", ^{
            NSString *validSourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:SKEPParserTestBookSource1 ofType:@"epub"];
            NSString *tempPathWithFakeSuffix = [NSTemporaryDirectory() stringByAppendingString:@"###"];
            RACSignal *validationSignal = [parser validateInputForStartParsing:RACTuplePack(validSourcePath, tempPathWithFakeSuffix)];
            __block NSError *error = nil;
            __block BOOL validationFinished = NO;
            
            [validationSignal subscribeCompleted:^{
                
            }];
            [validationSignal subscribeError:^(NSError *validationError) {
                validationFinished = YES;
                error = validationError;
            }];
            
            [[expectFutureValue(error) shouldNotEventuallyBeforeTimingOutAfter(0.5)] beNil];
            [[theValue([error.domain isEqualToString:SKEPParserErrorDomain]) should] beYes];
            [[theValue(error.code == SKEPParserErrorCodeIncorrectDestinationPath) should] beYes];
            [[theValue(validationFinished) should] beYes];
        });
        
        it(@"correct inputs", ^{
            NSString *validSourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:SKEPParserTestBookSource1
                                                                                         ofType:@"epub"];
            RACSignal *validationSignal = [parser validateInputForStartParsing:RACTuplePack(validSourcePath, [SKFileSystemSupport applicationSupportDirectory])];
            __block NSError *error = nil;
            __block BOOL validationFinished = NO;
            
            [validationSignal subscribeCompleted:^{
                validationFinished = YES;
                error = nil;
            }];
            [validationSignal subscribeError:^(NSError *validationError) {
                validationFinished = YES;
                error = validationError;
            }];
            
            [[expectFutureValue(error) shouldEventuallyBeforeTimingOutAfter(0.5)] beNil];
            [[theValue(validationFinished) should] beYes];
        });
    });
});

SPEC_END