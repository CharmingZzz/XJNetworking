//
//  XJNetworkingProtocol.h
//  XJNetworking
//
//  Created by xujie on 2018/4/10.
//  Copyright © 2018年 XuJie. All rights reserved.

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@class XJURLResponse;

typedef void(^successCallBack)(XJURLResponse *response);
typedef void(^failureCallBack)(NSError *error);

typedef NS_ENUM(NSUInteger, XJRequestProviderRequestType) {
    XJRequestProviderRequestTypeGet,
    XJRequestProviderRequestTypePost,
};

typedef NS_ENUM(NSUInteger, XJRequestProviderTaskType) {
    XJRequestProviderTaskTypeRequest,
    XJRequestProviderTaskTypeUpload,
    XJRequestProviderTaskTypeDownload,
};

typedef NS_ENUM(NSUInteger, XJRequestProviderPageType) {
    XJRequestProviderPageTypeNewest,
    XJRequestProviderPageTypeMore,
};

@protocol XJRequestProviderSourcePlugin <NSObject>

@optional
- (BOOL)shouldSendApiWithParams:(NSDictionary *)params caller:(id)caller;
- (NSDictionary *)willSendApiWithParams:(NSDictionary *)params;
- (NSURLRequest *)willSendApiWithRequest:(__kindof NSURLRequest *)request;
- (void)afterSendApiWithParams:(NSDictionary *)params caller:(id)caller;

- (BOOL)beforeApiSuccessWithResponse:(XJURLResponse *)response;
- (void)afterApiSuccessWithResponse:(XJURLResponse *)response caller:(id)caller;

- (BOOL)beforeApiFailureWithError:(NSError *)error;
- (void)afterApiFailureWithError:(NSError *)error caller:(id)caller;

@end

@protocol XJRequestProviderCommonSource <NSObject>

@required
- (NSString *)baseURL;
// 与baseURL组成完整连接
- (NSString *)methodname;
// 参数
- (NSDictionary *)parameters;

@optional
// 请求类型 get or post
- (XJRequestProviderRequestType)requestType;
// 任务类型
- (XJRequestProviderTaskType)taskType;
// 插件
- (NSArray <id <XJRequestProviderSourcePlugin>> *)plugins;
- (id <AFURLRequestSerialization>)requestSerialization;
- (id <AFURLResponseSerialization>)responseSerialization;

@end

@protocol XJRequestProviderPageSource <XJRequestProviderCommonSource>

@required
@property (nonatomic, assign)XJRequestProviderPageType pageType;

@end
