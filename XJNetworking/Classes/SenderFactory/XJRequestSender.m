//
//  XJRequestSender.m
//  XJNetworking
//
//  Created by xujie on 2018/4/10.
//  Copyright © 2018年 XuJie. All rights reserved.

#import "XJRequestSender.h"
#import "XJCommonContext.h"
#import "XJURLResponse.h"
#import "NSURLRequest+XJNetworking.h"
#import "NSArray+XJNetworking.h"

@implementation XJRequestSender

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters constructingBodys:(NSArray *)uploadSources
{
    NSError *error = nil;
    NSMutableURLRequest *request = [self.manager.requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:&error];
    return error ? nil : request;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request progress:(progressCallBack)progressCB success:(successCallBack)callBack failure:(failureCallBack)failCallBack
{
    NSURLSessionDataTask *task = nil;
    task = [self.manager dataTaskWithRequest:request completionHandler:
            ^(NSURLResponse * _Nonnull response,id  _Nullable responseObject,NSError * _Nullable error) {

                [self.taskTable removeObjectForKey:@(task.taskIdentifier)];
                [self.taskInfoTable removeObjectForKey:@(task.taskIdentifier)];

                XJURLResponse *urlRes = [[XJURLResponse alloc]initWithRequest:request response:response responseObject:responseObject];
                if (error){
                    failCallBack(error);
                }else{
                    callBack(urlRes);
                }
            }];
    return task;
}

@end
