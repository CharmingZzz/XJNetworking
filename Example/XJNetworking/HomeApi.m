//
//  HomeApi.m
//  XJNetworking_Example
//
//  Created by xujie on 2018/4/10.
//  Copyright © 2018年 m17600026862@163.com. All rights reserved.
//

#import "HomeApi.h"
#import "XJPagePlugin.h"

@interface HomeApi()

@property (nonatomic, strong)XJPagePlugin *pagePlugin;

@end

@implementation HomeApi

- (NSString *)baseURL
{
    return @"https://httpbin.org";
}

- (NSString *)methodname
{
    return @"get";
}

- (NSDictionary *)parameters
{
    return @{};
}

- (NSArray<id<XJRequestProviderSourcePlugin>> *)plugins
{
    return @[self.plugin,self.pagePlugin];
}

- (XJRequestProviderRequestType)requestType
{
    return XJRequestProviderRequestTypeGet;
}

- (XJPagePlugin *)pagePlugin
{
    if(!_pagePlugin){
        _pagePlugin = [XJPagePlugin pluginWithColumnDict:@{
                                                           XJPagePluginPageIndexKey : @"pageIndex",
                                                           XJPagePluginPageSizeKey : @"pageSize",
                                                           XJPagePluginPageIndexDefultValue : @"1",
                                                           XJPagePluginPageSizeDefultValue : @"20",
                                                           }];
    }
    return _pagePlugin;
}

- (BOOL)hasNextPage
{
    return self.pagePlugin.hasNextPage;
}


@end
