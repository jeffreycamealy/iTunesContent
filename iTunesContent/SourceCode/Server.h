//
//  Server.h
//  iTunesContent
//
//  Created by Jeffrey Camealy on 4/23/14.
//  Copyright (c) 2014 bearMountain. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;

@interface Server : NSObject

- (RACSignal *)getTopPodcasts;

@end
