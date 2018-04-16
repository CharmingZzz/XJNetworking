//
//  XJRequestProvider.h
//  XJNetworking
//
//  Created by xujie on 2018/4/9.
//  Copyright © 2018年 XuJie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XJNetworkingProtocol.h"

@class XJRequestCancellable;

@interface XJRequestProvider: NSObject

+ (instancetype)defaultProvider;
- (void)cancelAllRequest;

- (XJRequestCancellable *)requestWithSource:(id <XJRequestProviderCommonSource>)source from:(id)caller;
- (XJRequestCancellable *)requestWithSource:(id <XJRequestProviderCommonSource>)source from:(id)caller success:(successCallBack)callBack failure:(failureCallBack)failCallBack;

@end

@interface XJRequestCancellable: NSObject

@property (nonatomic,assign,readonly)BOOL isCancelled;
- (void)cancel;

@end
