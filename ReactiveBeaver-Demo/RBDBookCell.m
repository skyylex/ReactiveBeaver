//
//  RBDBookCell.m
//  ReactiveBeaver
//
//  Created by Yury Lapitsky on 08.10.15.
//  Copyright © 2015 skyylex. All rights reserved.
//

#import "RBDBookCell.h"

@interface RBDBookCell()

@end

@implementation RBDBookCell

#pragma mark - Configuration

- (void)configureWithBookName:(nonnull NSString *)bookName {
    self.textLabel.text = bookName;
}

@end
