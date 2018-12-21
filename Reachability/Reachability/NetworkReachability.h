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


/**
 通过默认路由地址初始化

 @return NetworkReachability
 */
+ (instancetype)reachabilityForInternetConnection;

/**
 指定服务器域名初始化

 @param hostName 服务器域名
 @return NetworkReachability
 */
+ (instancetype)reachabilityWithHostName:(NSString *)hostName;

/**
 指定服务器 IP 初始化

 @param hostAddress IP 地址
 @return NetworkReachability
 */
+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;


/**
 开启监听

 @return 是否监听成功
 */
- (BOOL)startNotifier;

/**
 关闭监听
 */
- (void)stopNotifier;


/**
 获取当前网络连接状态

 @return 当前网络连接状态
 */
- (NetworkReachabilityStatus)currentReachabilityStatus;


@end

NS_ASSUME_NONNULL_END
