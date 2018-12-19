//
//  NetworkReachability.m
//  Reachability
//
//  Created by 孙浩 on 2018/12/19.
//  Copyright © 2018 RongCloud. All rights reserved.
//

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <CoreFoundation/CoreFoundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "NetworkReachability.h"

NSString *NetworkReachabilityChangedNotification = @"NetworkReachabilityChangedNotification";

static NetworkReachabilityStatus ReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0) ||
                                       ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction =
    (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
    
    NetworkReachabilityStatus status = NetworkReachabilityStatusUnknown;
    if (isNetworkReachable == NO) {
        status = NetworkReachabilityStatusNotReachable;
    }
#if TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        status = NetworkReachabilityStatusReachableViaWWAN;
    }
#endif
    else {
        status = NetworkReachabilityStatusReachableViaWiFi;
    }
    
    return status;
}

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) {
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    NSCAssert([(__bridge NSObject*) info isKindOfClass: [NetworkReachability class]], @"info was wrong class in ReachabilityCallback");
    NetworkReachabilityStatus status = ReachabilityStatusForFlags(flags);
    
    [[NSNotificationCenter defaultCenter] postNotificationName: NetworkReachabilityChangedNotification object: @(status)];
}

@interface NetworkReachability ()

@property (nonatomic) SCNetworkReachabilityRef reachabilityRef;

@end

@implementation NetworkReachability

+ (instancetype)reachabilityWithHostName:(NSString *)hostName {
    NetworkReachability *returnValue = NULL;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    if (reachability != NULL) {
        returnValue= [[self alloc] init];
        if (returnValue != NULL) {
            returnValue->_reachabilityRef = reachability;
        } else {
            CFRelease(reachability);
        }
    }
    return returnValue;
}

+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, hostAddress);
    
    NetworkReachability* returnValue = NULL;
    
    if (reachability != NULL) {
        returnValue = [[self alloc] init];
        if (returnValue != NULL) {
            returnValue->_reachabilityRef = reachability;
        } else {
            CFRelease(reachability);
        }
    }
    return returnValue;
}

+ (instancetype)reachabilityForInternetConnection {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    return [self reachabilityWithAddress: (const struct sockaddr *) &zeroAddress];
}


- (BOOL)startNotifier {
    BOOL returnValue = NO;
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:NetworkReachabilityChangedNotification object:nil];
    
    if (SCNetworkReachabilitySetCallback(_reachabilityRef, ReachabilityCallback, &context)) {
        if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
            returnValue = YES;
        }
    }
    
    return returnValue;
}

- (void)reachabilityChanged:(NSNotification *)note {
    
    int status = [[note object] intValue];
    if ([_delegate respondsToSelector:@selector(networkStatusChangeToStatus:)]) {
        [_delegate networkStatusChangeToStatus:status];
    }
    
    if (self.networkStatusChange) {
        self.networkStatusChange(status);
    }
}


- (void)stopNotifier {
    if (_reachabilityRef != NULL) {
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}


- (void)dealloc {
    [self stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NetworkReachabilityChangedNotification object:nil];
    if (_reachabilityRef != NULL) {
        CFRelease(_reachabilityRef);
    }
}

- (NetworkReachabilityStatus)currentReachabilityStatus {
    NSAssert(_reachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
    NetworkReachabilityStatus returnValue = NetworkReachabilityStatusUnknown;
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
        returnValue = ReachabilityStatusForFlags(flags);
    }
    return returnValue;
}

//- (NetworkReachabilityStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags {
//    
//    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
//        return NetworkReachabilityStatusNotReachable;
//    }
//    
//    NetworkReachabilityStatus returnValue = NetworkReachabilityStatusUnknown;
//    
//    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
//        returnValue = NetworkReachabilityStatusReachableViaWiFi;
//    }
//    
//    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
//         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
//        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
//            returnValue = NetworkReachabilityStatusReachableViaWiFi;
//        }
//    }
//    
//    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
//        returnValue = NetworkReachabilityStatusReachableViaWWAN;
//    }
//    
//    return returnValue;
//}


@end
