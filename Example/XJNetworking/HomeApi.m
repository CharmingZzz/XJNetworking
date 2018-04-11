//
//  HomeApi.m
//  XJNetworking_Example
//
//  Created by xujie on 2018/4/10.
//  Copyright © 2018年 m17600026862@163.com. All rights reserved.
//

#import "HomeApi.h"

@interface HomeApi()

@end

@implementation HomeApi

- (NSString *)baseURL
{
    return @"";
}

- (NSString *)methodname
{
    return @"home";
}

- (NSDictionary *)parameters
{
    return @{@"test":@"testPams"};
}

- (NSArray<id<XJRequestProviderSourcePlugin>> *)plugins
{
    return @[self.plugin];
}


@end
