//
//  XJRequestProvider.h
//  XJNetworking
//
//  Created by xujie on 2018/4/9.
//  Copyright © 2018年 XuJie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

#import "XJURLResponse.h"

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

typedef void(^successCallBack)(XJURLResponse *response);
typedef void(^failureCallBack)(NSError *error);


@interface XJRequestProvider<SourceType> : NSObject

+ (instancetype)providerWithSource:(SourceType)source;

- (void)request;

- (void)requestWithSuccess:(successCallBack)callBack failure:(failureCallBack)failCallBack;


@end
