//
//  RBManifestElement.h
//  ReactiveBeaver
//
//  Created by Yury Lapitsky on 29.08.15.
//  Copyright (c) 2015 skyylex. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RBManifestElementIdentifierKey @"id"
#define RBManifestElementHrefKey @"href"
#define RBManifestElementMediaTypKey @"media-type"

@interface RBManifestElement : NSObject

/// Should be unique inside manifest
@property (nonatomic, strong) NSString *identifier;

/// Relative URI string
@property (nonatomic, strong) NSString *href;

///
@property (nonatomic, strong) NSString *mediaType;


@end
