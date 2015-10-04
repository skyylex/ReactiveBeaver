//
//  RBSpineElement.h
//  ReactiveBeaver
//
//  Created by skyylex on 07/06/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SpineElementIDRefKey @"idref"

@interface RBSpineElement : NSObject

@property (nonatomic, strong) NSNumber *index;
@property (nonatomic, strong) NSString *idRef;
@property (nonatomic, strong) NSString *fileName;

@end
