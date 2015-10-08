//
//  RBEpub.h
//  ReactiveBeaver
//
//  Created by skyylex on 14/05/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RBEpub : NSObject

@property (nonatomic, copy) NSString *sha1;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *author;

@property (nonatomic, strong) NSArray *spineElements;
@property (nonatomic, strong) NSArray *manifestElements;

@property (nonatomic, readonly) NSString *sourceEpubPath;
@property (nonatomic, readonly) NSString *destinationEpubPath;

/// TODO:
@property (nonatomic, readonly) NSString *coverPath;

- (void)initWithSourcePath:(NSString *)epubSource
           destinationPath:(NSString *)destination
                     error:(NSError *__autoreleasing*)error;

@end
