#import "Kiwi.h"
#import "SKEPParser.h"
#import "SKFileSystemSupport.h"


static NSString *const SKEPParserTestBookSource1 = @"moby-dick";

@interface SKEPParser()

- (RACSignal *)validateInputForStartParsing:(RACTuple *)startParsingInput;

@end

SPEC_BEGIN(SKEPParserTest)

describe(@"Validation", ^{
    let(parser, ^{
        return [SKEPParser new];
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