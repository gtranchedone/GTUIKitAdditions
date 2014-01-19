//
//  GTAppDelegate.m
//  GTUIKitAdditionsDemo
//
//  Created by Gianluca Tranchedone on 19/01/2014.
//  Copyright (c) 2014 Gianluca Tranchedone. All rights reserved.
//

#import "GTAppDelegate.h"
#import "GTDynamicCollectionViewController.h"

@implementation GTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [GTDynamicCollectionViewController new];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
