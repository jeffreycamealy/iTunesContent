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
        // Card Back
        self.layer.cornerRadius = 7;
        self.layer.shadowColor = [UIColor colorWithWhite:0.3 alpha:1].CGColor;
        self.layer.shadowOffset = CGSizeMake(2, 3);
        self.layer.shadowRadius = 3;
        self.layer.shadowOpacity = 1;
        self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
        
        
        // Card Color
        const float edgeInset = 7;
        CGRect cardColorRect = CGRectMake(edgeInset, edgeInset,
                                          self.bounds.size.width-edgeInset*2, self.bounds.size.height-edgeInset*2);
        UIView *cardColor = [[UIView alloc] initWithFrame:cardColorRect];
        cardColor.backgroundColor = [UIColor grayColor];
        cardColor.layer.cornerRadius = 8;
        [self addSubview:cardColor];
    }
    return self;
}

@end
