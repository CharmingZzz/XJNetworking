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

- (NSUInteger)sendRequestWithTaskInfo:(XJTaskInfo *)taskInfo success:(successCallBack)callBack failure:(failureCallBack)failCallBack
{
    if ([taskInfo prepareForRequset]){
        
        id <XJRequestProviderCommonSource>source = taskInfo.source;
        id caller = taskInfo.caller;
        NSArray *plugins = [source respondsToSelector:@selector(plugins)] ? source.plugins : @[];
        
        NSError *error = nil;
        NSUInteger type = [source respondsToSelector:@selector(requestType)] ? source.requestType : XJRequestProviderRequestTypePost;
        NSMutableURLRequest *request = [self.manager.requestSerializer requestWithMethod:RequestType[type] URLString:taskInfo.fullUrl parameters:taskInfo.finalParams error:&error];
        if(error){return NSNotFound;}
        
        request.xj_requestParams = taskInfo.finalParams;
        __block NSURLRequest *urlRequest = [request copy];
        
        [plugins enumerateObjectsUsingBlock:
                        ^(id<XJRequestProviderSourcePlugin>  _Nonnull obj,NSUInteger idx,BOOL * _Nonnull stop) {
             if([obj respondsToSelector:@selector(willSendApiWithRequest:)]){
                 urlRequest = [obj willSendApiWithRequest:urlRequest];
             }
         }];
        
        __block NSURLSessionDataTask *task = nil;
        task = [self.manager dataTaskWithRequest:request completionHandler:
                                                ^(NSURLResponse * _Nonnull response,id  _Nullable responseObject,NSError * _Nullable error) {
            
            [self.taskTable removeObjectForKey:@(task.taskIdentifier)];
            [self.taskInfoTable removeObjectForKey:@(task.taskIdentifier)];
            
            if(error){
                BOOL beforeFail = [plugins xj_any:
                                   ^BOOL(id<XJRequestProviderSourcePlugin> obj) {
                                       if([obj respondsToSelector:@selector(beforeApiFailureWithError:)]){
                                           if(![obj beforeApiFailureWithError:error]){
                                               return YES;
                                           }
                                       }
                                       return NO;
                                   }];
                if(!beforeFail){failCallBack(error);}
                [plugins xj_makeObjectsPerformSelector:@selector(afterApiFailureWithError:caller:),error,caller];
            }else{
                XJURLResponse *urlRes = [[XJURLResponse alloc]initWithRequest:urlRequest response:response responseObject:responseObject];
                
                BOOL beforeSuccess = [plugins xj_any:
                                      ^BOOL(id<XJRequestProviderSourcePlugin> obj) {
                                          if([obj respondsToSelector:@selector(beforeApiSuccessWithResponse:)]){
                                              if(![obj beforeApiSuccessWithResponse:urlRes]){
                                                  return YES;
                                              }
                                          }
                                          return NO;
                                      }];
                if(!beforeSuccess){callBack(urlRes);}
                [plugins xj_makeObjectsPerformSelector:@selector(afterApiSuccessWithResponse:caller:),urlRes,caller];
            }
        }];
        
        self.taskTable[@(task.taskIdentifier)] = task;
        self.taskInfoTable[@(task.taskIdentifier)] = taskInfo;
        [task resume];
        [plugins xj_makeObjectsPerformSelector:@selector(afterSendApiWithParams:caller:),urlRequest.xj_requestParams,caller];
        
        return task.taskIdentifier;
    }
    return NSNotFound;
}

@end
