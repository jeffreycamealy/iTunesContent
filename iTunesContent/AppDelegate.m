//
//  AppDelegate.m
//  iTunesContent
//
//  Created by Jeffrey Camealy on 4/22/14.
//  Copyright (c) 2014 bearMountain. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupWindow];
    [self setupRootVC];
    return YES;
}

- (void)setupWindow {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
}

- (void)setupRootVC {
    
}

@end
