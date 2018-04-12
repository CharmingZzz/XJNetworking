//
//  XJCommonContext.h
//  XJNetworking
//
//  Created by xujie on 2018/4/10.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, XJNetworkReachabilityStatus) {
    XJNetworkReachabilityStatusUnknown          = -1,
    XJNetworkReachabilityStatusNotReachable     = 0,
    XJNetworkReachabilityStatusReachableViaWWAN = 1,
    XJNetworkReachabilityStatusReachableViaWiFi = 2,
};

typedef NS_ENUM(NSUInteger, XJReachabilityWWANStatus) {
    XJReachabilityWWANStatusNone  = 0, ///< Not Reachable vis WWAN
    XJReachabilityWWANStatus2G = 2, ///< 2G
    XJReachabilityWWANStatus3G = 3, ///< 3G
    XJReachabilityWWANStatus4G = 4, ///< 4G
};

@interface XJCommonContext : NSObject

+ (instancetype)shareInstance;

@property (nonatomic, strong)NSDictionary *commonParams;

@property (nonatomic, assign) NSTimeInterval requestTimeoutSeconds;

// Observe to get change
@property (nonatomic, assign, readonly)XJNetworkReachabilityStatus reachabilityStatus;
@property (nonatomic, assign, readonly)XJReachabilityWWANStatus wwanStatus;

@end
