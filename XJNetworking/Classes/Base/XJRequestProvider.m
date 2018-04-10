//
//  XJRequestProvider.m
//  XJNetworking
//
//  Created by xujie on 2018/4/9.
//  Copyright © 2018年 XuJie. All rights reserved.
//

#import "XJRequestProvider.h"

@implementation XJRequestProvider

+ (instancetype)providerWithSource:(id)source
{
    NSAssert([source conformsToProtocol:@protocol(XJRequestProviderCommonSource)], @"source have to conform XJRequestProviderCommonSource protocol....");
    
    XJRequestProvider *provider = [[XJRequestProvider alloc]init];
    
    return provider;
}

- (void)request
{
    
    
    
}

- (void)requestWithSuccess:(successCallBack)callBack failure:(failureCallBack)failCallBack
{
    
}

@end
