//
//  RBDDetailsController.h
//  ReactiveBeaver
//
//  Created by Yury Lapitsky on 11/6/15.
//  Copyright © 2015 skyylex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RBEpub.h"

static const NSString *RBDDetailsControllerStoryboardId = @"RBDDetailsControllerStoryboardId";

@interface RBDDetailsController : UITableViewController

@property (nonatomic, strong) RBEpub *epub;

@end
