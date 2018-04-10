//
//  XJRequestSender.m
//  XJNetworking
//
//  Created by xujie on 2018/4/10.
//

#import "XJRequestSender.h"

@implementation XJRequestSender

static XJRequestSender *sender_;

+ (instancetype)defaultSender
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sender_ = [[XJRequestSender alloc]init];
    });
    return sender_;
}

@end
