//
//  XJPagePlugin.h
//  XJNetworking_Example
//
//  Created by xujie on 2018/4/17.
//  Copyright © 2018年 XuJie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XJNetworkingProtocol.h"

UIKIT_EXTERN NSString * const XJPagePluginPageIndexKey;
UIKIT_EXTERN NSString * const XJPagePluginPageSizeKey;
UIKIT_EXTERN NSString * const XJPagePluginPageIndexDefultValue;
UIKIT_EXTERN NSString * const XJPagePluginPageSizeDefultValue;

@interface XJPagePlugin : NSObject<XJRequestProviderSourcePlugin>

@property (nonatomic, assign)XJRequestProviderPageType pageType;
@property (nonatomic, assign, readonly)BOOL hasNextPage;
+ (instancetype)pluginWithColumnDict:(NSDictionary <NSString *,NSString *>*)dict;

@end
