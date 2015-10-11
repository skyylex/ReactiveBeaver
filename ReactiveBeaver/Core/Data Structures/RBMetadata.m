//
//  RBMetadata.m
//  ReactiveBeaver
//
//  Created by Yury Lapitsky on 09.10.15.
//  Copyright © 2015 skyylex. All rights reserved.
//

#import "RBMetadata.h"

@implementation RBMetadata

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"title" : @"dc:title",
             @"creator" : @"dc:creator",
             @"identifier"  : @"dc:identifier",
             @"publisher" : @"dc:publisher",
             @"contributor" : @"dc:contributor",
             @"rights" : @"dc:rights"
             };
}

@end
