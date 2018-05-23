//
//  XJUploadSender.m
//  XJNetworking_Example
//
//  Created by xujie on 2018/5/22.
//  Copyright © 2018年 m17600026862@163.com. All rights reserved.
//

#import "XJUploadSender.h"
#import "XJURLResponse.h"

NSString * const XJUploadSenderSourceKey = @"XJUploadSenderSourceKey";
NSString * const XJUploadSenderMineTypeKey = @"XJUploadSenderMineTypeKey";
NSString * const XJUploadSenderNameKey = @"XJUploadSenderNameKey";
NSString * const XJUploadSenderFileNameKey = @"XJUploadSenderFileNameKey";
NSString * const XJUploadSenderInputLength = @"XJUploadSenderInputLength";
static NSString *const XJNetworkingUploadName = @"XJNetworkingUploadName";
static NSString *const XJNetworkingUploadFileName = @"XJNetworkingUploadFileName";

@implementation XJUploadSender

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters constructingBodys:(NSArray <NSDictionary *>*)uploadSources
{
    NSError *error = nil;
    NSMutableURLRequest *request = [self.manager.requestSerializer multipartFormRequestWithMethod:method URLString:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (NSDictionary *dict in uploadSources){
            
            id source = dict[XJUploadSenderSourceKey];
            NSString *mineType = dict[XJUploadSenderMineTypeKey];
            NSString *fileName = dict[XJUploadSenderFileNameKey];
            fileName = fileName.length ? fileName : XJNetworkingUploadFileName;
            NSString *name = dict[XJUploadSenderNameKey];
            name = name.length ? name : XJNetworkingUploadName;
            
            if ([source isKindOfClass:[NSString class]]){
                if(mineType.length){
                    [formData appendPartWithFileURL:[NSURL fileURLWithPath:source] name:name fileName:fileName mimeType:mineType error:nil];
                }else {
                    [formData appendPartWithFileURL:[NSURL fileURLWithPath:source] name:name error:nil];
                }
            }else if ([source isKindOfClass:[NSData class]]){
                if(mineType.length){
                    [formData appendPartWithFileData:source name:name fileName:fileName mimeType:mineType];
                }else {
                    [formData appendPartWithFormData:source name:name];
                }
            }else if ([source isKindOfClass:[NSInputStream class]]){
                NSString *inputLength = dict[XJUploadSenderInputLength];
                if(!inputLength.length || !mineType.length){return;}
                [formData appendPartWithInputStream:source name:name fileName:fileName length:inputLength.longLongValue mimeType:mineType];
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
