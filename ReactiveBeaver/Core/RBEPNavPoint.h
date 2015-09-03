//
//  RBEPNavPoint.h
//  ReactiveBeaver
//
//  Created by skyylex on 07/06/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RBEPNavPoint : NSObject

@property (nonatomic, strong) NSString *level;
@property (nonatomic, strong) RBEPNavPoint *parentElement;
@property (nonatomic, strong) NSArray *childElements;

@end
