//
//  SKEPManifestElement.h
//  SKEPParser
//
//  Created by Yury Lapitsky on 29.08.15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SKEPManifestElementIdentifierKey @"id"
#define SKEPManifestElementHrefKey @"href"
#define SKEPManifestElementMediaTypKey @"media-type"

@interface SKEPManifestElement : NSObject

/// Should be unique inside manifest
@property (nonatomic, strong) NSString *identifier;

/// Relative URI string
@property (nonatomic, strong) NSString *href;

///
@property (nonatomic, strong) NSString *mediaType;


@end
