//
//  RBMetadata.h
//  ReactiveBeaver
//
//  Created by Yury Lapitsky on 09.10.15.
//  Copyright © 2015 skyylex. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MTLJSONAdapter.h"
#import "MTLModel.h"

@interface RBMetadata : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *creator;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *publisher;
@property (nonatomic, copy) NSString *contributor;
@property (nonatomic, copy) NSString *rights;

@end
