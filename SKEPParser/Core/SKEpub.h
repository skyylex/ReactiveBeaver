//
//  SKEpub.h
//  SKEPParser
//
//  Created by skyylex on 14/05/15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKEpub : NSObject

@property (nonatomic, copy) NSString *sha1;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *author;

@property (nonatomic, strong) NSArray *chapters;
@property (nonatomic, strong) NSArray *navPoints;

@property (nonatomic, readonly) NSString *sourceEpubPath;
@property (nonatomic, readonly) NSString *destinationEpubPath;

- (void)initWithSourcePath:(NSString *)epubSource
           destinationPath:(NSString *)destination
                     error:(NSError *__autoreleasing*)error;

@end
