//
//  AppDelegate.m
//  Reachability
//
//  Created by 孙浩 on 2018/12/19.
//  Copyright © 2018 RongCloud. All rights reserved.
//

#import "AppDelegate.h"
#import "NetworkReachability.h"

@interface AppDelegate ()< NetworkReachabilityDelegate>

@property (nonatomic) NetworkReachability *reachability;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.reachability = [NetworkReachability reachabilityForInternetConnection];
    [self.reachability startNotifier];

    self.reachability.networkStatusChange = ^(NetworkReachabilityStatus status) {
        switch (status) {
            case NetworkReachabilityStatusNotReachable:
                NSLog(@"Block -- 没网");
                break;
            case NetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"Block -- 数据");
                break;
            case NetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"Block -- WIFI");
                break;
            case NetworkReachabilityStatusUnknown:
                NSLog(@"Block -- 未知网络");
                break;
        }
    };
    
    self.reachability.delegate = self;
    
    return YES;
}

- (void)networkStatusChangeToStatus:(NetworkReachabilityStatus)status {
    
    switch (status) {
        case NetworkReachabilityStatusNotReachable:
            NSLog(@"delegate -- 没网");
            break;
        case NetworkReachabilityStatusReachableViaWWAN:
            NSLog(@"delegate -- 数据");
            break;
        case NetworkReachabilityStatusReachableViaWiFi:
            NSLog(@"delegate -- WIFI");
            break;
        case NetworkReachabilityStatusUnknown:
            NSLog(@"delegate -- 未知网络");
            break;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
