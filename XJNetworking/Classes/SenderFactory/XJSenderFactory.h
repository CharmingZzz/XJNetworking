//
//  XJSenderFactory.h
//  XJNetworking
//
//  Created by xujie on 2018/4/11.
//

#import <Foundation/Foundation.h>
#import "XJNetworkingProtocol.h"

UIKIT_EXTERN NSString *RequestType[2];

@interface XJSenderFactory : NSObject

@property (nonatomic,strong,readonly)AFHTTPSessionManager *manager;
@property (nonatomic,strong,readonly)NSMutableDictionary <NSNumber *,NSURLSessionDataTask *>*taskTable;

+ (instancetype)shareInstance;

- (NSUInteger)sendRequestWithSource:(id <XJRequestProviderCommonSource>)source from:(id)caller success:(successCallBack)callBack failure:(failureCallBack)failCallBack;

- (void)cancelRequestWithIDs:(NSArray *)identifiers;


@end
