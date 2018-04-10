//
//  NSURLRequest+XJNetworking.h
//  XJNetworking
//
//  Created by xujie on 2018/4/10.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (XJNetworking)

@property (nonatomic, strong, setter = xj_setRequestParams:) NSDictionary *xj_requestParams;

@end
