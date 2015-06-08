//
//  SKEPNavPoint.h
//  SKEPParser
//
//  Created by skyylex on 07/06/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKEPNavPoint : NSObject

@property (nonatomic, strong) NSString *level;
@property (nonatomic, strong) SKEPNavPoint *parentElement;
@property (nonatomic, strong) NSArray *childElements;

@end
