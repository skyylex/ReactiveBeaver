#import "Kiwi.h"
#import "SKEPParser.h"

@interface SKEPParser()

- (RACSignal *)validateStartParsingTuple:(RACTuple *)startParsingInput;

@end

SPEC_BEGIN(SKEPParserTest)

describe(@"Validation", ^{
    let(parser, ^{
        return [SKEPParser new];
    });
    
    context(@"validateStartParsingTuple method", ^{
        it(@"validateStartParsingTuple:", ^{
            RACSignal *validationSignal = [parser validateStartParsingTuple:RACTuplePack([NSObject new])];
            __block NSError *error = nil;
            __block BOOL validationFinished = NO;
            
            [validationSignal subscribeCompleted:^{
                
            }];
            [validationSignal subscribeError:^(NSError *validationError) {
                validationFinished = YES;
                error = validationError;
            }];
            
            [[expectFutureValue(error) shouldNotEventuallyBeforeTimingOutAfter(1.0)] beNil];
            [[theValue(validationFinished) should] beYes];
        });
    });
});
       

/// example

/*
describe(@"Initialization", ^{
    it(@"without special init methods", ^{
        SKEPParser *parser = [SKEPParser new];
        
        __block id value = nil;
        
        [[parser.startParsingCommand.executionSignals
          flattenMap:^RACStream *(RACSignal *executing) {
            RACSignal *resultSignal = [executing flattenMap:^RACStream *(id value) {
                return [RACSignal return:[RACUnit defaultUnit]];
            }];
            
            [resultSignal subscribeNext:^(id x) {
                value = x;
            }];
            return resultSignal;
        }]
         subscribeCompleted:^{
            
        }];
        
        [parser.startParsingCommand execute:nil];
        
        [[expectFutureValue(value) shouldNotEventuallyBeforeTimingOutAfter(5)] beNil];
    });
});
 */

SPEC_END