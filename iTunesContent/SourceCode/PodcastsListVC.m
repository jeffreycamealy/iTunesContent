//
//  PodcastsListVC.m
//  iTunesContent
//
//  Created by Jeffrey Camealy on 4/23/14.
//  Copyright (c) 2014 bearMountain. All rights reserved.
//

#import "PodcastsListVC.h"
#import <ReactiveCocoa.h>
#import "Server.h"
#import "Podcast.h"
#import "Card.h"

@interface PodcastsListVC () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *tableView;
    NSArray *podcasts;
    UIDynamicAnimator *animator;
    UISnapBehavior *snapBehavior;
    Card *card;
}
@end


@implementation PodcastsListVC

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    [self loadPodcasts];
    
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    [self addCard];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:tapRecognizer];
}


#pragma mark - Private API

- (void)loadPodcasts {
    Server *server = [Server new];
    [[server getTopPodcasts]
     subscribeNext:^(id x) {
         podcasts = x;
         [tableView reloadData];
     } error:^(NSError *error) {
         // TODO: handle error
     }];
}

- (void)addCard {
    card = [[Card alloc] initWithFrame:CGRectMake(10, 10, 200, 300)];
    [self.view addSubview:card];
    
    card.backgroundColor = [UIColor grayColor];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cardPanned:)];
    [card addGestureRecognizer:panRecognizer];
}

- (void)viewTapped:(UITapGestureRecognizer *)tapRecognizer {
    CGPoint point = [tapRecognizer locationInView:self.view];
    
    
    card.transform = CGAffineTransformIdentity;
    // Remove the previous behavior.
    [animator removeBehavior:snapBehavior];
    
    snapBehavior = [[UISnapBehavior alloc] initWithItem:card snapToPoint:point];
    __weak UIView *weakCard = card;
    
    const int maxVariance = 10;
    int r = rand()%(maxVariance*2);
    r -= maxVariance;
    r = r ?: r+1; // Make sure it's not zero;
    snapBehavior.action = ^{
        NSLog(@"%i", r);
        weakCard.transform = CGAffineTransformRotate(weakCard.transform, M_PI/100.0/(float)r);
    };
    [animator addBehavior:snapBehavior];
    
}


#pragma mark - Gesture Recognizer

- (void)cardPanned:(UIPanGestureRecognizer *)panRecognizer {
//    CGPoint translation = [panRecognizer translationInView:self.view];
//    panRecognizer.view.center = CGPointMake(panRecognizer.view.center.x + translation.x,
//                                         panRecognizer.view.center.y + translation.y);
//    [panRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
//    UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:panRecognizer.view snapToPoint:CGPointMake(0, 0)];
//    [animator addBehavior:snapBehavior];
//    
//    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[panRecognizer.view]];
//    itemBehavior.elasticity = 0.5;
//    [animator addBehavior:itemBehavior];
}

#pragma mark - Tableview DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return podcasts.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Podcast *podcast = podcasts[indexPath.row];
    
    cell.textLabel.text = podcast.title;
    cell.detailTextLabel.text = podcast.itunesPath;
    
    return cell;
}


#pragma mark - Tableview Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Podcast *podcast = podcasts[indexPath.row];
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:podcast.itunesPath]];
}

@end
