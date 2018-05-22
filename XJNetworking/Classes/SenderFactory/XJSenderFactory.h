//
//  XJSenderFactory.h
//  XJNetworking
//
//  Created by xujie on 2018/4/11.
//  Copyright © 2018年 XuJie. All rights reserved.

#import <Foundation/Foundation.h>
#import "XJNetworkingProtocol.h"

@class XJTaskInfo;

@interface XJSenderFactory : NSObject

@property (nonatomic, strong, readonly)AFHTTPSessionManager *manager;
@property (nonatomic, strong, readonly)NSMutableDictionary <NSNumber *,NSURLSessionDataTask *>*taskTable;
@property (nonatomic, strong, readonly)NSMutableDictionary <NSNumber *,XJTaskInfo *>*taskInfoTable;

+ (instancetype)shareInstance;
- (NSUInteger)sendRequestWithTaskInfo:(XJTaskInfo *)taskInfo progress:(progressCallBack)progressCB success:(successCallBack)callBack failure:(failureCallBack)failCallBack;
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters constructingBodys:(NSArray *)uploadSources;
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request progress:(progressCallBack)progressCB success:(successCallBack)callBack failure:(failureCallBack)failCallBack;
- (void)cancelRequestWithIDs:(NSArray *)identifiers taskType:(XJRequestProviderTaskType)type;

@end


@interface XJTaskInfo : NSObject

@property (nonatomic, strong, readonly)id <XJRequestProviderCommonSource>source;
@property (nonatomic, weak, readonly)id caller;

// will be the right result after call prepareForRequset
@property (nonatomic, copy, readonly)NSString *fullUrl;
@property (nonatomic, copy, readonly)NSDictionary *finalParams;

- (instancetype)initWithSource:(id <XJRequestProviderCommonSource>)source from:(id)caller;
- (NSArray <id <XJRequestProviderSourcePlugin>>*)prepareForRequset;

@end
