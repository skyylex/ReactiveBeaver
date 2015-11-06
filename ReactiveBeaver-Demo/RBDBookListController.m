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
#import "MBProgressHUD.h"
#import "RBDDetailsController.h"

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
    
    [[self.viewModel.parsingStartTrigger flattenMap:^RACStream *(id value) {
        return [self showHUDAction];
    }] subscribeNext:^(id x) {}];
    
    @weakify(self);
    [[self.viewModel.parsingEndTrigger flattenMap:^RACStream *(RBEpub *epub) {
        @strongify(self);
        return [[self hideHUDAction] flattenMap:^RACStream *(id _) {
            @strongify(self);
            return [self showDetailsController:epub];
        }];
    }] subscribeNext:^(id x) {}];
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
}

#pragma mark - Actions

- (RACSignal *)showDetailsController:(RBEpub *)epub {
    RACSignal *transportSignal = [RACSignal return:RACTuplePack(self.navigationController, self.storyboard, epub)];
    RACSignal *showAction = [transportSignal flattenMap:^RACStream *(RACTuple *tuple) {
        UINavigationController *presenter = tuple.first;
        UIStoryboard *storyboard = tuple.second;
        
        RBDDetailsController *controller = [storyboard instantiateViewControllerWithIdentifier:(NSString *)RBDDetailsControllerStoryboardId];
        controller.epub = tuple.third;
        
        [presenter pushViewController:controller animated:YES];
        
        return [RACSignal return:[RACUnit defaultUnit]];
    }];
    
    return showAction;
}

- (RACSignal *)showHUDAction {
    RACSignal *currentViewSignal = [RACSignal return:self.tableView];
    return [currentViewSignal flattenMap:^RACStream *(UIView *view) {
        return [[RACSignal return:[RACUnit defaultUnit]].deliverOnMainThread flattenMap:^RACStream *(id value) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                [MBProgressHUD showHUDAddedTo:view animated:YES];
                
                [subscriber sendNext:[RACUnit defaultUnit]];
                [subscriber sendCompleted];
                
                return nil;
            }];
        }];
    }];
}

- (RACSignal *)hideHUDAction {
    RACSignal *currentViewSignal = [RACSignal return:self.tableView];
    return [currentViewSignal flattenMap:^RACStream *(UIView *view) {
        return [[RACSignal return:[RACUnit defaultUnit]].deliverOnMainThread flattenMap:^RACStream *(id value) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                [MBProgressHUD hideAllHUDsForView:view animated:YES];
                
                [subscriber sendNext:[RACUnit defaultUnit]];
                [subscriber sendCompleted];
                
                return nil;
            }];
        }];
    }];
}

@end
