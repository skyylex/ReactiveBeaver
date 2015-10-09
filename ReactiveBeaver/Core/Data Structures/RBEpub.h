//
//  RBEpub.h
//  ReactiveBeaver
//
//  Created by skyylex on 14/05/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RBMetaData.h"
#import "MTLModel.h"

/// TODO: rewrite to apply MTLModel
@interface RBEpub : NSObject

@property (nonatomic, copy) NSString *sha1;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *author;

@property (nonatomic, strong) NSArray *spineElements;
@property (nonatomic, strong) NSArray *manifestElements;

/// TODO:
@property (nonatomic, strong) RBMetaData *metadata;

/// TODO:
@property (nonatomic, readonly) NSString *sourceEpubPath;
@property (nonatomic, readonly) NSString *destinationEpubPath;

/// TODO:
@property (nonatomic, readonly) NSString *coverPath;

- (void)initWithSourcePath:(NSString *)epubSource
           destinationPath:(NSString *)destination
                     error:(NSError *__autoreleasing*)error;

@end
