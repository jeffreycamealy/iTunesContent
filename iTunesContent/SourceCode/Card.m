//
//  Card.m
//  iTunesContent
//
//  Created by Jeffrey Camealy on 4/24/14.
//  Copyright (c) 2014 bearMountain. All rights reserved.
//

#import "Card.h"

@implementation Card

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 5;
        self.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.85].CGColor;
        self.layer.shadowOffset = CGSizeMake(2, 3);
        self.layer.shadowRadius = 3;
        self.layer.shadowOpacity = 1;
        self.backgroundColor = [UIColor grayColor];
    }
    return self;
}

@end
