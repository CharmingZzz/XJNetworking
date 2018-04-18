//
//  HomeApi.h
//  XJNetworking_Example
//
//  Created by xujie on 2018/4/10.
//  Copyright © 2018年 m17600026862@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XJNetworking.h"

@interface HomeApi : NSObject<XJRequestProviderPageSource>

@property (nonatomic, assign)XJRequestProviderPageType pageType;
@property (nonatomic, weak)id <XJRequestProviderSourcePlugin>plugin;

@end
