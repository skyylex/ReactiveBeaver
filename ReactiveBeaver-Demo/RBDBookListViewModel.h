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

/// Data
@property (nonatomic, readonly) NSArray *bookNames;

/// Actions from UI
- (void)parseBookWithIndex:(NSUInteger)index;

@end
