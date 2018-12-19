//
//  NetworkReachability.h
//  Reachability
//
//  Created by 孙浩 on 2018/12/19.
//  Copyright © 2018 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NetworkReachabilityStatus) {
    NetworkReachabilityStatusUnknown = -1,
    NetworkReachabilityStatusNotReachable = 0,
    NetworkReachabilityStatusReachableViaWWAN = 1,
    NetworkReachabilityStatusReachableViaWiFi = 2,
};


@protocol NetworkReachabilityDelegate <NSObject>

- (void)networkStatusChangeToStatus:(NetworkReachabilityStatus)status;

@end

typedef void(^NetworkStatusChange)(NetworkReachabilityStatus status);

NS_ASSUME_NONNULL_BEGIN

@interface NetworkReachability : NSObject

@property (nonatomic, weak) id<NetworkReachabilityDelegate> delegate;

@property (nonatomic, copy) NetworkStatusChange networkStatusChange;

+ (instancetype)reachabilityForInternetConnection;
+ (instancetype)reachabilityWithHostName:(NSString *)hostName;
+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;

// 开启以及关闭监听
- (BOOL)startNotifier;
- (void)stopNotifier;

- (NetworkReachabilityStatus)currentReachabilityStatus;


@end

NS_ASSUME_NONNULL_END
