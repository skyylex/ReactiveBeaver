//
//  RBEpub.h
//  ReactiveBeaver
//
//  Created by skyylex on 14/05/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RBMetadata.h"

/// TODO: rewrite to apply MTLModel
@interface RBEpub : NSObject

@property (nonatomic, copy) NSString *sha1;

@property (nonatomic, strong) RBMetadata *metadata;

@property (nonatomic, copy) NSString *sourceEpubPath;
@property (nonatomic, copy) NSString *destinationEpubPath;

@property (nonatomic, strong) NSArray *spineElements;
@property (nonatomic, strong) NSArray *manifestElements;

/// TODO:
@property (nonatomic, copy) NSString *coverPath;

@end
