//
//  HomeApi.m
//  XJNetworking_Example
//
//  Created by xujie on 2018/4/10.
//  Copyright © 2018年 m17600026862@163.com. All rights reserved.
//

#import "HomeApi.h"

@interface HomeApi()<XJRequestProviderCommonSource>

@property (nonatomic,strong,readwrite)XJRequestProvider *homeApiProvider;

@end

@implementation HomeApi

- (NSString *)methodname
{
    return @"home";
}

- (NSDictionary *)parameters
{
    return @{};
}

- (XJRequestProvider *)homeApiProvider
{
    if(!_homeApiProvider){
        _homeApiProvider = [XJRequestProvider<HomeApi *> providerWithSource:self];
    }
    return _homeApiProvider;
}

@end
