//
//  XJRequestSender.h
//  XJNetworking
//
//  Created by xujie on 2018/4/10.
//

#import <Foundation/Foundation.h>

#import "XJNetworkingProtocol.h"

@interface XJRequestSender : NSObject

+ (instancetype)shareInstance;

- (NSUInteger)sendRequestWithSource:(id <XJRequestProviderCommonSource>)source from:(id)caller success:(successCallBack)callBack failure:(failureCallBack)failCallBack;

- (void)cancelRequestWithIDs:(NSArray *)identifiers;

@end
