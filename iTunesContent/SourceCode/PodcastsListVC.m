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
}
@end


@implementation PodcastsListVC

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self loadPodcasts];
    
    // Animator
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    srand(time(NULL));
    
    [self addTrays];
}


#pragma mark - Private API

- (void)loadPodcasts {
    Server *server = [Server new];
    [[server getTopPodcasts]
     subscribeNext:^(NSArray *somePodcasts) {
         podcasts = somePodcasts;
         [self addCards];
     } error:^(NSError *error) {
         // TODO: handle error
     }];
}

- (void)addCards {
    for (Podcast *podcast in podcasts) {
        Card *card = [[Card alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
        [card setPodcast:podcast];
        CGPoint rootPoint = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
        CGPoint randomOffset = [self randomOffset];
        card.center = CGPointMake(rootPoint.x+randomOffset.x, rootPoint.y+randomOffset.y);
        card.transform = CGAffineTransformMakeRotation([self randomRotation]);
        [self.view addSubview:card];
        
        // Pan Recognizer
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cardPanned:)];
        [card addGestureRecognizer:panRecognizer];
    }
}

- (void)addTrays {
    UIImageView *yesTray = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yesBlock"]];
    yesTray.frame = CGRectMake(265, 60, 220, 450);
    [self.view addSubview:yesTray];
    
    UIImageView *noTray = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noBlock"]];
    noTray.frame = CGRectMake(-173, 55, 230, 470);
    [self.view addSubview:noTray];
}



#pragma mark - Gesture Recognizer

- (void)cardPanned:(UIPanGestureRecognizer *)panRecognizer {
    Card *card = (Card *)panRecognizer.view;
    [self.view bringSubviewToFront:card];
    
    switch (panRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint touchPoint = [panRecognizer locationInView:card];
            UIOffset cardOffset = UIOffsetMake(touchPoint.x - card.bounds.size.width/2.0,
                                               touchPoint.y - card.bounds.size.height/2.0);
            CGPoint anchor = [panRecognizer locationInView:self.view];
            
            attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:card
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
            [self snapCard:card];
        } break;
            
        default:
            break;
    }
}

- (void)snapCard:(Card *)card {
    CGPoint rootPoint;
    if (card.center.x > self.view.bounds.size.width/2) {
        rootPoint = CGPointMake(self.view.bounds.size.width+70, self.view.bounds.size.height/2);
    } else {
        rootPoint = CGPointMake(-70, self.view.bounds.size.height/2);
    }
    
    CGPoint pointOffset = [self randomOffset];
    CGPoint modifiedLeftPoint = CGPointMake(rootPoint.x+pointOffset.x,
                                            rootPoint.y+pointOffset.y);
    
    card.transform = CGAffineTransformIdentity;
    // Remove the previous behavior.
    [animator removeBehavior:snapBehavior];
    
    snapBehavior = [[UISnapBehavior alloc] initWithItem:card snapToPoint:modifiedLeftPoint];
    __weak UIView *weakCard = card;
    
    float r = [self randomRotation];
    snapBehavior.action = ^{
        weakCard.transform = CGAffineTransformRotate(weakCard.transform, r);
    };
    [animator addBehavior:snapBehavior];
}

#pragma mark - Random Generators

const int numberOfRandomAngles = 10;

- (float)randomRotation {
    float r = [self randPlusOrMinusUpTo:numberOfRandomAngles];
    float rotation = M_PI/100.0/r;
    
    return rotation;
}

const int maxPointOffset = 10;

- (CGPoint)randomOffset {
    return CGPointMake([self randPlusOrMinusUpTo:maxPointOffset],
                       [self randPlusOrMinusUpTo:maxPointOffset]);
}

- (float)randPlusOrMinusUpTo:(int)n {
    int x = rand()%(n*2);
    x -= n;
    x = x ?: x+1; // Make sure it's not zero
    return x;
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
