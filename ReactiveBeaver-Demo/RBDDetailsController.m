//
//  RBDDetailsController.m
//  ReactiveBeaver
//
//  Created by Yury Lapitsky on 11/6/15.
//  Copyright © 2015 skyylex. All rights reserved.
//

#import "RBDDetailsController.h"
#import "RBSpineElement.h"
#import "RBManifestElement.h"

typedef NS_ENUM(NSUInteger, DetailSection) {
    DetailSectionSpineElements = 0,
    DetailSectionManifestElements,
    DetailSectionCount
};

static const NSString *cellIdentifier = @"RBDBookCellId";

@implementation RBDDetailsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:(NSString *)cellIdentifier];
}

#pragma mark - TableView data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerTitle = nil;
    switch (section) {
        case DetailSectionSpineElements:{
            headerTitle = @"Spine elements";
            break;
        }
            
        case DetailSectionManifestElements: {
            headerTitle = @"Manifest elements";
            break;
        }
            
        default:
            break;
    }
    
    return headerTitle;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger rowsAmount = 0;
    switch (section) {
        case DetailSectionManifestElements: {
            rowsAmount = self.epub.manifestElements.count;
            break;
        }
        case DetailSectionSpineElements: {
            rowsAmount = self.epub.spineElements.count;
            break;
        }
        default:
            break;
    }
    
    return rowsAmount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return DetailSectionCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:(NSString *)cellIdentifier];
    switch (indexPath.section) {
        case DetailSectionSpineElements: {
            RBSpineElement *element = self.epub.spineElements[indexPath.row];
            cell.textLabel.text = element.idRef;
            cell.detailTextLabel.text = element.fileName;
            break;
        }
        case DetailSectionManifestElements: {
            RBManifestElement *element = self.epub.manifestElements[indexPath.row];
            cell.textLabel.text = element.identifier;
            cell.detailTextLabel.text = element.href;
            break;
        }
        default:
            break;
    }
    
    return cell;
}

@end
