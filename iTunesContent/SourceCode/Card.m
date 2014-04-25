//
//  Card.m
//  iTunesContent
//
//  Created by Jeffrey Camealy on 4/24/14.
//  Copyright (c) 2014 bearMountain. All rights reserved.
//

#import "Card.h"
#import "UIImageView+AFNetworking.h"
#import "Podcast.h"

@interface Card () {
    Podcast *podcast;
}
@end


@implementation Card

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *brownCardImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cardGrayscale"]];
        brownCardImageView.frame = self.bounds;
        [self addSubview:brownCardImageView];
    }
    return self;
}

- (void)setPodcast:(Podcast *)aPodcast {
    podcast = aPodcast;
    [self addImage];
    [self addTitle];
}


const float imageWidth = 80;
const float rightOffset = 15;
const float frameWidth = 3;

- (void)addImage {
    NSURL *url = [NSURL URLWithString:podcast.imagePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width-rightOffset-imageWidth,
                                                                           rightOffset,
                                                                           imageWidth,
                                                                           imageWidth)];
    
    [imageView setImageWithURLRequest:request
                     placeholderImage:nil
                              success:nil
                              failure:nil];
    
    UIView *grayBox = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width-rightOffset-imageWidth-frameWidth,
                                                               rightOffset-frameWidth,
                                                               imageWidth+frameWidth*2,
                                                               imageWidth+frameWidth*2)];
    grayBox.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    [self addSubview:grayBox];
    [self addSubview:imageView];
}

- (void)addTitle {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, self.bounds.size.width-imageWidth-frameWidth*2-rightOffset*2, 50)];
    label.numberOfLines = 0;
    label.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:13];
    label.text = podcast.title;
    [label sizeToFit];
    [self addSubview:label];
}

@end

































