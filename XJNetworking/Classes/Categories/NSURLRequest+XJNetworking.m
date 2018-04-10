//
//  NSURLRequest+XJNetworking.m
//  XJNetworking
//
//  Created by xujie on 2018/4/10.
//

#import "NSURLRequest+XJNetworking.h"
#import <objc/runtime.h>

@implementation NSURLRequest (XJNetworking)

- (void)xj_setRequestParams:(NSDictionary *)xj_requestParams {
    objc_setAssociatedObject(self, @selector(xj_requestParams), xj_requestParams, OBJC_ASSOCIATION_RETAIN);
}

- (NSDictionary *)xj_requestParams {
    return objc_getAssociatedObject(self, _cmd);
}

@end
