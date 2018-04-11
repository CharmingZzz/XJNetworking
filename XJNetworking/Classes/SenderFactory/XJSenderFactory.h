//
//  XJSenderFactory.h
//  XJNetworking
//
//  Created by xujie on 2018/4/11.
//

#import <Foundation/Foundation.h>
#import "XJNetworkingProtocol.h"

@class XJTaskInfo;

UIKIT_EXTERN NSString *RequestType[2];

@interface XJSenderFactory : NSObject

@property (nonatomic, strong, readonly)AFHTTPSessionManager *manager;
@property (nonatomic, strong, readonly)NSMutableDictionary <NSNumber *,NSURLSessionDataTask *>*taskTable;

+ (instancetype)shareInstance;

- (NSUInteger)sendRequestWithTaskInfo:(XJTaskInfo *)taskInfo success:(successCallBack)callBack failure:(failureCallBack)failCallBack;

- (void)cancelRequestWithIDs:(NSArray *)identifiers;

@end


@interface XJTaskInfo : NSObject

@property (nonatomic, strong, readonly)id <XJRequestProviderCommonSource>source;
@property (nonatomic, weak, readonly)id caller;

// will be the right result after call prepareForRequset
@property (nonatomic, copy, readonly)NSString *fullUrl;
@property (nonatomic, copy, readonly)NSDictionary *finalParams;

- (instancetype)initWithSource:(id <XJRequestProviderCommonSource>)source from:(id)caller;
- (BOOL)prepareForRequset;

@end
