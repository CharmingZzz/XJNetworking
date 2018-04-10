//
//  XJRequestProvider.h
//  XJNetworking
//
//  Created by xujie on 2018/4/9.
//  Copyright © 2018年 XuJie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

#import "XJRequestSender.h"


typedef NS_ENUM(NSUInteger, XJRequestProviderRequestType) {
    XJRequestProviderRequestTypeGet,
    XJRequestProviderRequestTypePost,
};

typedef NS_ENUM(NSUInteger, XJRequestProviderTaskType) {
    XJRequestProviderTaskTypeRequest,
    XJRequestProviderTaskTypeUpload,
    XJRequestProviderTaskTypeDownload,
};

@protocol XJRequestProviderCommonSource <NSObject>

@required
// 与baseURL组成完整连接
- (NSString *)methodname;
// 参数
- (NSDictionary *)parameters;

@optional
- (NSString *)baseURL;
// 请求类型 get or post
- (XJRequestProviderRequestType)requestType;
// 任务类型
- (XJRequestProviderTaskType)taskType;
- (id <AFURLRequestSerialization>)requestSerialization;
- (id <AFURLResponseSerialization>)responseSerialization;

@end

@protocol XJRequestProviderSourcePlugin

@optional
- (BOOL)shouldSendApiWithParams:(NSDictionary *)params caller:(id)caller;
- (void)afterSendApiWithParams:(NSDictionary *)params caller:(id)caller;

- (BOOL)beforeApiSuccessWithResponse:(XJURLResponse *)response caller:(id)caller;
- (void)afterApiSuccessWithResponse:(XJURLResponse *)response caller:(id)caller;

- (BOOL)beforeApiFailureWithResponse:(XJURLResponse *)response caller:(id)caller;
- (void)afterApiFailureWithResponse:(XJURLResponse *)response caller:(id)caller;

@end


@interface XJRequestProvider: NSObject

+ (instancetype)defaultProvider;

- (void)requestWithSource:(id <XJRequestProviderCommonSource>)source from:(id)caller;

- (void)requestWithSource:(id <XJRequestProviderCommonSource>)source from:(id)caller success:(successCallBack)callBack failure:(failureCallBack)failCallBack;

- (void)cancelAllRequest;
- (void)cancelRequestWithID:(NSString *)identifier;

@end
