//
//  NSError+QuickCreation.m
//  ReactiveBeaver
//
//  Created by Yury Lapitsky on 29.08.15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import "NSError+QuickCreation.h"

@implementation NSError (QuickCreation)

+ (instancetype)parserErrorWithCode:(NSInteger)code {
    return [NSError errorWithDomain:RBParserErrorDomain code:code userInfo:nil];
    
}

@end
