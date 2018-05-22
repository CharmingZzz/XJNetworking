//
//  XJUploadSender.m
//  XJNetworking_Example
//
//  Created by xujie on 2018/5/22.
//  Copyright © 2018年 m17600026862@163.com. All rights reserved.
//

#import "XJUploadSender.h"
#import "XJURLResponse.h"

@implementation XJUploadSender

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters constructingBodys:(NSArray *)uploadSources
{
    NSError *error = nil;
    NSMutableURLRequest *request = [self.manager.requestSerializer multipartFormRequestWithMethod:method URLString:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (id content in uploadSources){
            if ([content isKindOfClass:[NSString class]]){
                [formData appendPartWithFileURL:content name:@"xxx" error:nil];
            }else if ([content isKindOfClass:[NSData class]]){
                [formData appendPartWithFileData:content name:@"xxx" fileName:@"xxx" mimeType:@""];
            }else {
                NSAssert(false, @"uploadSources item only be NSString or NSData type");
            }
        }
        
    } error:&error];
    return error ? nil : request;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request progress:(progressCallBack)progressCB success:(successCallBack)callBack failure:(failureCallBack)failCallBack
{
    NSURLSessionDataTask *task = nil;
    task = [self.manager uploadTaskWithStreamedRequest:request progress:progressCB completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
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
