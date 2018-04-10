//
//  XJRequestSender.m
//  XJNetworking
//
//  Created by xujie on 2018/4/10.
//

#import "XJRequestSender.h"
#import <AFNetworking/AFNetworking.h>
#import "NSURLRequest+XJNetworking.h"
#import "NSArray+XJNetworking.h"
#import "XJCommonContext.h"

@interface XJRequestSender()

@property (nonatomic,strong)AFHTTPSessionManager *manager;
@property (nonatomic, strong)NSMutableDictionary <NSNumber *,NSURLSessionDataTask *>*taskTable;

@end

static NSString *RequestType[2] = {
    [XJRequestProviderRequestTypeGet] = @"GET",
    [XJRequestProviderRequestTypePost] = @"POST"
};

@implementation XJRequestSender

#pragma mark - public method

+ (instancetype)shareInstance
{
    static XJRequestSender *sender_;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sender_ = [[XJRequestSender alloc]init];
    });
    return sender_;
}

- (NSUInteger)sendRequestWithSource:(id<XJRequestProviderCommonSource>)source from:(id)caller success:(successCallBack)callBack failure:(failureCallBack)failCallBack
{
    self.manager.requestSerializer = [source respondsToSelector:@selector(requestSerializer)] ? source.requestSerialization : [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [source respondsToSelector:@selector(responseSerialization)] ? source.responseSerialization :[AFJSONResponseSerializer serializer];
    
    NSString *url = [source.baseURL stringByAppendingPathComponent:source.methodname];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:source.parameters];
    [params addEntriesFromDictionary:[XJCommonContext shareInstance].commonParams];
    
    NSError *error = nil;
    NSUInteger type = [source respondsToSelector:@selector(requestType)] ? source.requestType : XJRequestProviderRequestTypePost;
    
    
    BOOL shouldSend = [source.plugins xj_any:
                       ^BOOL(id<XJRequestProviderSourcePlugin> obj) {
        if([obj respondsToSelector:@selector(shouldSendApiWithParams:caller:)]){
            if(![obj shouldSendApiWithParams:params caller:caller]){
                return YES;
            }
        }
        return NO;
    }];
    
    if (!shouldSend){
        NSMutableURLRequest *request = [self.manager.requestSerializer requestWithMethod:RequestType[type] URLString:url parameters:params error:&error];
        request.xj_requestParams = params;
        
        __block NSURLRequest *urlRequest = [request copy];
        
        [source.plugins enumerateObjectsUsingBlock:
                                                    ^(id<XJRequestProviderSourcePlugin>  _Nonnull obj,
                                                     NSUInteger idx,
                                                     BOOL * _Nonnull stop) {
            if([obj respondsToSelector:@selector(willSendApiWithRequest:)]){
                urlRequest = [obj willSendApiWithRequest:urlRequest];
            }
        }];
        
        __block NSURLSessionDataTask *task = nil;
        task = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response,
                                                                             id  _Nullable responseObject, NSError * _Nullable error) {
            
            [self.taskTable removeObjectForKey:@(task.taskIdentifier)];
            
            if(error){
                BOOL beforeFail = [source.plugins xj_any:
                                   ^BOOL(id<XJRequestProviderSourcePlugin> obj) {
                    if([obj respondsToSelector:@selector(beforeApiFailureWithError:caller:)]){
                        if(![obj beforeApiFailureWithError:error caller:caller]){
                            return YES;
                        }
                    }
                    return NO;
                }];
                if(!beforeFail){!failCallBack ? :failCallBack(error);}
                [source.plugins xj_makeObjectsPerformSelector:@selector(afterApiFailureWithError:caller:),error,caller];
            }else{
                XJURLResponse *urlRes = [[XJURLResponse alloc]initWithRequest:urlRequest response:response responseObject:responseObject];
                
                BOOL beforeSuccess = [source.plugins xj_any:
                                      ^BOOL(id<XJRequestProviderSourcePlugin> obj) {
                    if([obj respondsToSelector:@selector(beforeApiSuccessWithResponse:caller:)]){
                        if(![obj beforeApiSuccessWithResponse:urlRes caller:caller]){
                            return YES;
                        }
                    }
                    return NO;
                }];
                if(!beforeSuccess){!callBack ? :callBack(urlRes);}
                [source.plugins xj_makeObjectsPerformSelector:@selector(afterApiSuccessWithResponse:caller:),urlRes,caller];
            }
        }];

        self.taskTable[@(task.taskIdentifier)] = task;

        [task resume];

        [source.plugins xj_makeObjectsPerformSelector:@selector(afterSendApiWithParams:caller:),urlRequest.xj_requestParams,caller];
        
        return task.taskIdentifier;
    }
    
    return NSNotFound;
}

- (void)cancelRequestWithIDs:(NSArray *)identifiers
{
    for (NSNumber *identifier in identifiers){
        [self.taskTable enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key,
                                                            NSURLSessionDataTask * _Nonnull obj,
                                                            BOOL * _Nonnull stop) {
            if (identifier.unsignedIntegerValue == key.unsignedIntegerValue){
                [obj cancel];
                [self.taskTable removeObjectForKey:key];
            }
        }];
    }
}

#pragma mark - lazy load

- (AFHTTPSessionManager *)manager
{
    if(!_manager){
        _manager = [AFHTTPSessionManager manager];
    }
    return _manager;
}

- (NSMutableDictionary<NSNumber *,NSURLSessionDataTask *> *)taskTable
{
    if(!_taskTable){
        _taskTable = [NSMutableDictionary dictionary];
    }
    return _taskTable;
}

@end
