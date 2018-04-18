//
//  XJPagePlugin.h
//  XJNetworking_Example
//
//  Created by xujie on 2018/4/17.
//  Copyright © 2018年 XuJie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XJNetworkingProtocol.h"

UIKIT_EXTERN NSString *kXJPagePluginPageIndexKey;
UIKIT_EXTERN NSString *kXJPagePluginPageSizeKey;
UIKIT_EXTERN NSString *kXJPagePluginPageIndexDefultValue;
UIKIT_EXTERN NSString *kXJPagePluginPageSizeDefultValue;

@interface XJPagePlugin : NSObject<XJRequestProviderSourcePlugin>

@property (nonatomic, assign)XJRequestProviderPageType pageType;
@property (nonatomic, assign, readonly)BOOL hasNextPage;
+ (instancetype)pluginWithColumnDict:(NSDictionary <NSString *,NSString *>*)dict;

@end
