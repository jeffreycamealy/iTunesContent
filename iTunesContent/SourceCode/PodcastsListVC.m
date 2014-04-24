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

@interface PodcastsListVC ()
{
    NSArray *podcasts;
    UIDynamicAnimator *animator;
    UISnapBehavior *snapBehavior;
    UIAttachmentBehavior *attachmentBehavior;
    Card *card;
}
@end


@implementation PodcastsListVC

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self loadPodcasts];
    [self addCard];
    
    // Animator
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    // Tap Recognizer
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:tapRecognizer];
}


#pragma mark - Private API

- (void)loadPodcasts {
    Server *server = [Server new];
    [[server getTopPodcasts]
     subscribeNext:^(NSArray *somePodcasts) {
         podcasts = somePodcasts;
     } error:^(NSError *error) {
         // TODO: handle error
     }];
}

- (void)addCard {
    card = [[Card alloc] initWithFrame:CGRectMake(10, 10, 200, 300)];
    [self.view addSubview:card];
    
    // Pan Recognizer
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cardPanned:)];
    [card addGestureRecognizer:panRecognizer];
    
    // Swipe Recognizer
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cardSwiped:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    [card addGestureRecognizer:swipeRecognizer];
    
    
    //----------------
    UIOffset attachmentPoint = UIOffsetMake(-25.0, -25.0);
    // By default, an attachment behavior uses the center of a view. By using a
    // small offset, we get a more interesting effect which will cause the view
    // to have rotation movement when dragging the attachment.
    attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:card offsetFromCenter:attachmentPoint attachedToAnchor:CGPointMake(100, 100)];
    [animator addBehavior:attachmentBehavior];
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
    switch (panRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint touchPoint = [panRecognizer locationInView:panRecognizer.view];
            UIOffset cardOffset = UIOffsetMake(touchPoint.x - panRecognizer.view.bounds.size.width/2.0,
                                               touchPoint.y - panRecognizer.view.bounds.size.height/2.0);
            CGPoint anchor = [panRecognizer locationInView:self.view];
            
            attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:panRecognizer.view
                                                           offsetFromCenter:cardOffset
                                                           attachedToAnchor:anchor];
            
            [animator addBehavior:attachmentBehavior];
        } break;
            
        case UIGestureRecognizerStateChanged: {
            CGPoint anchor = [panRecognizer locationInView:self.view];
            attachmentBehavior.anchorPoint = anchor;
        } break;
            
        case UIGestureRecognizerStateEnded: {
            [animator removeBehavior:attachmentBehavior];
            [self snapToPoint];
        } break;
            
        default:
            break;
    }
}

- (void)snapToPoint {
    CGPoint point = CGPointMake(10, 586/2);
    
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

- (void)cardPannedd:(UIPanGestureRecognizer *)gesture
{
    static UIAttachmentBehavior *attachment;
    static CGPoint               startCenter;
    
    // variables for calculating angular velocity
    
    static CFAbsoluteTime        lastTime;
    static CGFloat               lastAngle;
    static CGFloat               angularVelocity;
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        [animator removeAllBehaviors];
        
        startCenter = gesture.view.center;
        
        // calculate the center offset and anchor point
        
        CGPoint pointWithinAnimatedView = [gesture locationInView:gesture.view];
        
        UIOffset offset = UIOffsetMake(pointWithinAnimatedView.x - gesture.view.bounds.size.width / 2.0,
                                       pointWithinAnimatedView.y - gesture.view.bounds.size.height / 2.0);
        
        CGPoint anchor = [gesture locationInView:gesture.view.superview];
        
        // create attachment behavior
        
        attachment = [[UIAttachmentBehavior alloc] initWithItem:gesture.view
                                               offsetFromCenter:offset
                                               attachedToAnchor:anchor];
        
        // code to calculate angular velocity (seems curious that I have to calculate this myself, but I can if I have to)
        
        lastTime = CFAbsoluteTimeGetCurrent();
        lastAngle = [self angleOfView:gesture.view];
        
        attachment.action = ^{
            CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
            CGFloat angle = [self angleOfView:gesture.view];
            if (time > lastTime) {
                angularVelocity = (angle - lastAngle) / (time - lastTime);
                lastTime = time;
                lastAngle = angle;
            }
        };
        
        // add attachment behavior
        
        [animator addBehavior:attachment];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        // as user makes gesture, update attachment behavior's anchor point, achieving drag 'n' rotate
        
        CGPoint anchor = [gesture locationInView:gesture.view.superview];
        attachment.anchorPoint = anchor;
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        [animator removeAllBehaviors];
        
        CGPoint velocity = [gesture velocityInView:gesture.view.superview];
        
        // if we aren't dragging it down, just snap it back and quit
        
        if (fabs(atan2(velocity.y, velocity.x) - M_PI_2) > M_PI_4) {
            UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:gesture.view snapToPoint:startCenter];
            [animator addBehavior:snap];
            
            return;
        }
        
        // otherwise, create UIDynamicItemBehavior that carries on animation from where the gesture left off (notably linear and angular velocity)
        
        UIDynamicItemBehavior *dynamic = [[UIDynamicItemBehavior alloc] initWithItems:@[gesture.view]];
        [dynamic addLinearVelocity:velocity forItem:gesture.view];
        [dynamic addAngularVelocity:angularVelocity forItem:gesture.view];
        [dynamic setAngularResistance:2];
        
        // when the view no longer intersects with its superview, go ahead and remove it
        
        dynamic.action = ^{
            if (!CGRectIntersectsRect(gesture.view.superview.bounds, gesture.view.frame)) {
                [animator removeAllBehaviors];
                [gesture.view removeFromSuperview];
                
                [[[UIAlertView alloc] initWithTitle:nil message:@"View is gone!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        };
        [animator addBehavior:dynamic];
        
        // add a little gravity so it accelerates off the screen (in case user gesture was slow)
        
        UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[gesture.view]];
        gravity.magnitude = 0.7;
        [animator addBehavior:gravity];
    }
}

- (CGFloat)angleOfView:(UIView *)view
{
    // http://stackoverflow.com/a/2051861/1271826
    
    return atan2(view.transform.b, view.transform.a);
}

@end
