//
//  RBDBookListViewModel.m
//  ReactiveBeaver
//
//  Created by Yury Lapitsky on 08.10.15.
//  Copyright © 2015 skyylex. All rights reserved.
//

#import "RBDBookListViewModel.h"

#define MobyDickBook @"moby-dick"

@interface RBDBookListViewModel()

/// Triggers control
@property (nonatomic, strong) RACSubject *parsingStartEndSubject;

/// Workers
@property (nonatomic, strong, readwrite) RBParser *parser;

/// Data
@property (nonatomic, strong, readwrite) NSArray *bookNames;

@end
@implementation RBDBookListViewModel

#pragma mark - NSObject

- (instancetype)init {
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}

#pragma mark - Prepare

- (void)prepare {
    /// Data
    self.bookNames = @[MobyDickBook];
    
    /// RAC
    self.parsingStartEndSubject = [RACSubject subject];
}

#pragma mark - Actions

- (void)parseBookWithIndex:(NSUInteger)index {
    NSString *sourcePath = [self epubSourcePathWithName:self.bookNames[index]];
    NSString *destinationPath = [[[self class] applicationDocumentsDirectory] stringByAppendingPathComponent:self.bookNames[index]];
    BOOL destinationFolderCreated = [[NSFileManager defaultManager] createDirectoryAtPath:destinationPath
                                                              withIntermediateDirectories:YES
                                                                               attributes:nil
                                                                                    error:nil];
    BOOL isDirectory = NO;
    BOOL folderExist = [[NSFileManager defaultManager] fileExistsAtPath:destinationPath isDirectory:&isDirectory];
    if (destinationFolderCreated == YES || (folderExist == YES && isDirectory == YES)) {
        [self.parsingStartEndSubject sendNext:RACTuplePack(@YES, [RACUnit defaultUnit])];
        self.parser = [RBParser new];
        
        [[[self.parser startCommand].executionSignals
          flattenMap:^(RACSignal *parsingSignal) {
              return parsingSignal;
          }]
         subscribeNext:^(id result) {
            [self.parsingStartEndSubject sendNext:RACTuplePack(@NO, result)];
         }
         error:^(NSError *error) {
             [self.parsingStartEndSubject sendNext:RACTuplePack(@NO, [RACUnit defaultUnit])];
         }];
        
        [[self.parser startCommand] execute:RACTuplePack(sourcePath, destinationPath)];
    } else {
        NSLog(@"Cannot create destination folder");
    }
}

#pragma mark - FileSystem Helpers

+ (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    return basePath;
}

- (NSString *)epubSourcePathWithName:(nonnull NSString *)name {
    return [[NSBundle mainBundle] pathForResource:name ofType:@"epub"];
}

#pragma mark - Triggers

- (RACSignal *)parsingEndTrigger {
    return [[self.parsingStartEndSubject filter:^BOOL(RACTuple *tuple) {
        return tuple.first != nil && [tuple.first boolValue] == NO;
    }] map:^id(RACTuple *tuple) {
        return tuple.second;
    }];
}

- (RACSignal *)parsingStartTrigger {
    return [[self.parsingStartEndSubject filter:^BOOL(RACTuple *tuple) {
        return tuple.first != nil && [tuple.first boolValue] == YES;
    }] map:^id(RACTuple *tuple) {
        return tuple.second;
    }];
}


@end
