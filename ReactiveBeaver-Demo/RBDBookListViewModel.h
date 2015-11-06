//
//  RBDBookListViewModel.h
//  ReactiveBeaver
//
//  Created by Yury Lapitsky on 08.10.15.
//  Copyright © 2015 skyylex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RBParser.h"

@interface RBDBookListViewModel : NSObject

/// Triggers
@property (nonatomic, readonly) RACSignal *parsingEndTrigger;
@property (nonatomic, readonly) RACSignal *parsingStartTrigger;

/// Data
@property (nonatomic, readonly) NSArray *bookNames;

/// Actions from UI
- (void)parseBookWithIndex:(NSUInteger)index;

@end
