//
//  PodcastsListVC.m
//  iTunesContent
//
//  Created by Jeffrey Camealy on 4/23/14.
//  Copyright (c) 2014 bearMountain. All rights reserved.
//

#import "PodcastsListVC.h"
#import "Server.h"
#import <ReactiveCocoa.h>

@interface PodcastsListVC () {
    UITableView *tableView;
}
@end


@implementation PodcastsListVC

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self loadPodcasts];
}


#pragma mark - Private API

- (void)loadPodcasts {
    Server *server = [Server new];
    [[server getTopPodcasts]
     subscribeNext:^(id x) {
         
     } error:^(NSError *error) {
         
     }];
}


#pragma mark - Tableview DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}


#pragma mark - Tableview Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
