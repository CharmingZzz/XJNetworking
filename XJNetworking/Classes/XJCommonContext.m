//
//  XJCommonContext.m
//  XJNetworking
//
//  Created by xujie on 2018/4/10.
//

#import "XJCommonContext.h"

@implementation XJCommonContext

+ (instancetype)shareInstance
{
    static XJCommonContext *context_;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context_ = [[XJCommonContext alloc]init];
    });
    return context_;
}

@end
