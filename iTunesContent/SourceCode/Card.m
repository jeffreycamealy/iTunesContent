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
    UILabel *titleLabel;
}
@end


// **Note: Layout is done manually and with many magic numbers.  In a natural process with more time, this class would be
//         refactored to use autolayout and have all measurments as constants.
@implementation Card

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *brownCardImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cardMarkingsRemoved"]];
        brownCardImageView.frame = self.bounds;
        [self addSubview:brownCardImageView];
    }
    return self;
}

- (void)setPodcast:(Podcast *)aPodcast {
    podcast = aPodcast;
    [self addImage];
    [self addTitle];
    [self addAuthor];
    [self addSummary];
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
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [grayBox addGestureRecognizer:tapRecognizer];
}

- (void)imageTapped:(id)x {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:podcast.itunesPath]];
}

- (void)addTitle {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, self.bounds.size.width-imageWidth-frameWidth*2-rightOffset*2, 50)];
    label.numberOfLines = 0;
    label.font = [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:13];
    label.text = podcast.title;
    [label sizeToFit];
    [self addSubview:label];
    titleLabel = label;
}

- (void)addAuthor {
    UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x,
                                                                    titleLabel.frame.origin.y+titleLabel.frame.size.height,
                                                                     titleLabel.frame.size.width,
                                                                     100)];
    [self addSubview:authorLabel];
    authorLabel.text = podcast.author;
    authorLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:12];
    authorLabel.numberOfLines = 0;
    [authorLabel sizeToFit];
}

- (void)addSummary {
    UILabel *summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 110, self.bounds.size.width-30, 170)];
    [self addSubview:summaryLabel];
    summaryLabel.numberOfLines = 0;
    summaryLabel.text = podcast.summary;
    summaryLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:11];
    [summaryLabel sizeToFit];
    if (summaryLabel.frame.size.height > 170) {
        summaryLabel.frame = CGRectMake(15, 110, self.bounds.size.width-30, 170);
    }
}

@end

































