//
//  RBDBookListController.m
//  ReactiveBeaver
//
//  Created by Yury Lapitsky on 08.10.15.
//  Copyright © 2015 skyylex. All rights reserved.
//

/// Imports
#import "RBDBookListController.h"
#import "RBDBookListViewModel.h"
#import "RBDBookCell.h"

/// Constants
#define InitialRowHeight 40.0
@interface RBDBookListController()

@property (nonatomic, strong) RBDBookListViewModel *viewModel;

@end
@implementation RBDBookListController

#pragma mark - UIViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self prepareViewModel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareTableView];
}

#pragma mark - Prepare

- (void)prepareViewModel {
    self.viewModel = [RBDBookListViewModel new];
}

- (void)prepareTableView {
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = InitialRowHeight;
}

#pragma mark - UITableView data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.bookNames.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RBDBookCell *bookCell = [tableView dequeueReusableCellWithIdentifier:RBDBookCellId];
    [bookCell configureWithBookName:self.viewModel.bookNames[indexPath.row]];
    return bookCell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel parseBookWithIndex:indexPath.row];
    
    /// TODO: add HUD
}

@end
