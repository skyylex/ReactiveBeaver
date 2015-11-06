//
//  RBDBookCell.h
//  ReactiveBeaver
//
//  Created by Yury Lapitsky on 08.10.15.
//  Copyright © 2015 skyylex. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RBDBookCellId @"RBDBookCellId"

@interface RBDBookCell : UITableViewCell

- (void)configureWithBookName:(nonnull NSString *)bookName;

@end
