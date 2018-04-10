//
//  XJRequestSender.h
//  XJNetworking
//
//  Created by xujie on 2018/4/10.
//

#import <Foundation/Foundation.h>

#import "XJURLResponse.h"

typedef void(^successCallBack)(XJURLResponse *response);
typedef void(^failureCallBack)(NSError *error);

@interface XJRequestSender : NSObject

+ (instancetype)defaultSender;
- (NSUInteger)sendRequest:(successCallBack)callBack failure:(failureCallBack)failCallBack;

@end
