//
//  XJCommonContext.m
//  XJNetworking
//
//  Created by xujie on 2018/4/10.
//

#import "XJCommonContext.h"
#import <AFNetworking/AFNetworking.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>


@interface XJCommonContext()

@property (nonatomic, assign, readwrite)XJNetworkReachabilityStatus reachabilityStatus;
@property (nonatomic, assign, readwrite)XJReachabilityWWANStatus wwanStatus;
@property (nonatomic, strong)CTTelephonyNetworkInfo *netWorkInfo;

@end

@implementation XJCommonContext

+ (instancetype)shareInstance
{
    static XJCommonContext *context_;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context_ = [[XJCommonContext alloc]init];
        context_.requestTimeoutSeconds = 30.f;
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [context_ wwanStatusCheck];
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            NSInteger s = status;
            [context_ willChangeValueForKey:@"reachabilityStatus"];
            context_.reachabilityStatus = s;
            [context_ didChangeValueForKey:@"reachabilityStatus"];
        }];
    });
    return context_;
}

- (void)wwanStatusCheck
{
    self.netWorkInfo = [[CTTelephonyNetworkInfo alloc]init];
    self.wwanStatus = [self getWWanStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wwanStatusChange:) name:CTRadioAccessTechnologyDidChangeNotification object:nil];
}

-(void)wwanStatusChange:(NSNotification *)noti
{
    if(!self.netWorkInfo.currentRadioAccessTechnology){return;}
    [self willChangeValueForKey:@"wwanStatus"];
    self.wwanStatus = [self getWWanStatus];
    [self didChangeValueForKey:@"wwanStatus"];
}

- (XJReachabilityWWANStatus)getWWanStatus {
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = @{CTRadioAccessTechnologyGPRS : @(XJReachabilityWWANStatus2G),
                CTRadioAccessTechnologyEdge : @(XJReachabilityWWANStatus2G),
                CTRadioAccessTechnologyWCDMA : @(XJReachabilityWWANStatus3G),
                CTRadioAccessTechnologyHSDPA : @(XJReachabilityWWANStatus3G),
                CTRadioAccessTechnologyHSUPA : @(XJReachabilityWWANStatus3G),
                CTRadioAccessTechnologyCDMA1x : @(XJReachabilityWWANStatus3G),
                CTRadioAccessTechnologyCDMAEVDORev0 : @(XJReachabilityWWANStatus3G),
                CTRadioAccessTechnologyCDMAEVDORevA : @(XJReachabilityWWANStatus3G),
                CTRadioAccessTechnologyCDMAEVDORevB : @(XJReachabilityWWANStatus3G),
                CTRadioAccessTechnologyeHRPD : @(XJReachabilityWWANStatus3G),
                CTRadioAccessTechnologyLTE : @(XJReachabilityWWANStatus4G)};
    });
    NSNumber *num = dic[self.netWorkInfo.currentRadioAccessTechnology];
    if (num) {
        return num.unsignedIntegerValue;
    }else {
        return XJReachabilityWWANStatusNone;
    }
}

@end
