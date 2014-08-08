//
//  AppDelegate.m
//  PinchNavExample
//
//  Created by Justin Poliachik on 7/14/14.
//  Copyright (c) 2014 justinpoliachik. All rights reserved.
//

#import "AppDelegate.h"
#import "PinchNavExampleViewController.h"
#import "PinchNavSecondViewController.h"

@interface AppDelegate() <PinchNavigationDelegate>
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Create the window
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // for app-wide PinchNav menu access, init it here
    PinchNavigationButtonView *button1 = [[PinchNavigationButtonView alloc] initWithTitle:@"Item1" color:[UIColor redColor] diameter:80];
    PinchNavigationButtonView *button2 = [[PinchNavigationButtonView alloc] initWithTitle:@"Item2" color:[UIColor redColor] diameter:80];
    PinchNavigationButtonView *button3 = [[PinchNavigationButtonView alloc] initWithTitle:@"Item3" color:[UIColor redColor] diameter:80];
    PinchNavigationButtonView *button4 = [[PinchNavigationButtonView alloc] initWithTitle:@"Item4" color:[UIColor redColor] diameter:80];
    PinchNavigationButtonView *button5 = [[PinchNavigationButtonView alloc] initWithTitle:@"Item5" color:[UIColor redColor] diameter:80];
    NSArray *buttonArray = @[button1, button2, button3, button4, button5];
    self.pinchNav = [[PinchNavigationViewController alloc] initWithSuperview:self.window withButtonArray:buttonArray];
    self.pinchNav.delegate = self;
    
    // init the sample view controller
    PinchNavExampleViewController *vc = [[PinchNavExampleViewController alloc] init];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)shouldTransitionToButton:(PinchNavigationButtonView *)selectedButton
{
    // init the sample view controller
    PinchNavSecondViewController *vc = [[PinchNavSecondViewController alloc] init];
//    self.window.rootViewController = vc;
}

@end
