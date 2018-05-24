//
//  XJSenderBridge.m
//  XJNetworking
//
//  Created by xujie on 2018/4/11.
//  Copyright © 2018年 XuJie. All rights reserved.

#import "XJSenderBridge.h"
#import "XJCommonContext.h"
#import "XJURLResponse.h"
#import "NSURLRequest+XJNetworking.h"
#import "NSArray+XJNetworking.h"

@interface XJSenderBridge()

@property (nonatomic, strong, readwrite)AFHTTPSessionManager *manager;
@property (nonatomic, strong, readwrite)NSMutableDictionary <NSNumber *,NSURLSessionDataTask *>*taskTable;
@property (nonatomic, strong, readwrite)NSMutableDictionary <NSNumber *,XJTaskInfo *>*taskInfoTable;
@property (nonatomic, strong)NSMutableDictionary <NSString *,__kindof XJSenderBridge *>*senderTable;
@property (nonatomic, strong)AFHTTPRequestSerializer *requestSerializer;
@property (nonatomic, strong)AFJSONResponseSerializer *responseSerializer;

@end

static NSString *RequestType[2] = {
    [XJRequestProviderRequestTypeGet] = @"GET",
    [XJRequestProviderRequestTypePost] = @"POST"
};

static NSString *TaskType[3] = {
    [XJRequestProviderTaskTypeRequest] = @"XJRequestSender",
    [XJRequestProviderTaskTypeUpload] = @"XJUploadSender",
    [XJRequestProviderTaskTypeDownload] = @"XJDownloadSender",
};

@implementation XJSenderBridge

#pragma mark - public method

+ (instancetype)shareInstance
{
    static XJSenderBridge *sender_;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sender_ = [[XJSenderBridge alloc]init];
    });
    return sender_;
}

- (NSUInteger)sendRequestWithTaskInfo:(XJTaskInfo *)taskInfo progress:(progressCallBack)progressCB success:(successCallBack)callBack failure:(failureCallBack)failCallBack
{
    self.manager.requestSerializer = [taskInfo.source respondsToSelector:@selector(requestSerializer)] ? taskInfo.source.requestSerialization : self.requestSerializer;
    self.manager.responseSerializer = [taskInfo.source respondsToSelector:@selector(responseSerialization)] ? taskInfo.source.responseSerialization : self.responseSerializer;
    [self.manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    self.manager.requestSerializer.timeoutInterval = [XJCommonContext shareInstance].requestTimeoutSeconds;
    [self.manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    XJRequestProviderTaskType taskType = [taskInfo.source respondsToSelector:@selector(taskType)] ? taskInfo.source.taskType : XJRequestProviderTaskTypeRequest;
    
    NSArray *plugins = [taskInfo prepareForRequset];
    if (plugins){
        
        XJSenderBridge *sender = [self chooseSender:taskType];
        id <XJRequestProviderCommonSource>source = taskInfo.source;
        id caller = taskInfo.caller;
        
        NSUInteger type = [source respondsToSelector:@selector(requestType)] ? source.requestType : XJRequestProviderRequestTypePost;
        NSMutableURLRequest *request = [sender requestWithMethod:RequestType[type] URLString:taskInfo.fullUrl parameters:taskInfo.finalParams constructingBodys:[taskInfo.source respondsToSelector:@selector(uploadSources)] ? taskInfo.source.uploadSources : @[]];
        if(!request){return NSNotFound;}
        
        __block NSURLRequest *urlRequest = [request copy];
        [plugins enumerateObjectsUsingBlock:
         ^(id<XJRequestProviderSourcePlugin>  _Nonnull obj,NSUInteger idx,BOOL * _Nonnull stop) {
             if([obj respondsToSelector:@selector(willSendApiWithRequest:)]){
                 urlRequest = [obj willSendApiWithRequest:urlRequest];
             }
         }];
        urlRequest.xj_requestParams = taskInfo.finalParams;
        
        successCallBack cb = ^(XJURLResponse *response) {
            BOOL beforeSuccess = [plugins xj_any:
                                  ^BOOL(id<XJRequestProviderSourcePlugin> obj) {
                                      if([obj respondsToSelector:@selector(beforeApiSuccessWithResponse:)]){
                                          if(![obj beforeApiSuccessWithResponse:response]){
                                              return YES;
                                          }
                                      }
                                      return NO;
                                  }];
            if(!beforeSuccess){callBack(response);}
            [plugins xj_makeObjectsPerformSelector:@selector(afterApiSuccessWithResponse:caller:),response,caller];
        };
        failureCallBack fcb = ^(NSError *error) {
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
        };
        
        NSURLSessionDataTask *task = [sender dataTaskWithRequest:urlRequest progress:progressCB success:cb failure:fcb];
        sender.taskTable[@(task.taskIdentifier)] = task;
        sender.taskInfoTable[@(task.taskIdentifier)] = taskInfo;
        [task resume];
        [plugins xj_makeObjectsPerformSelector:@selector(afterSendApiWithParams:caller:),urlRequest.xj_requestParams,caller];
        
        return task.taskIdentifier;
    }
    return NSNotFound;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters constructingBodys:(NSArray *)uploadSources
{
    return nil;// subclass to implement
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request progress:(progressCallBack)progressCB success:(successCallBack)callBack failure:(failureCallBack)failCallBack
{
    return nil;// subclass to implement
}

- (void)cancelRequestWithIDs:(NSArray *)identifiers taskType:(XJRequestProviderTaskType)type
{
    XJSenderBridge *sender = [self chooseSender:type];
    for (NSNumber *identifier in identifiers){
        [sender.taskTable enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key,
                                                            NSURLSessionDataTask * _Nonnull obj,
                                                            BOOL * _Nonnull stop) {
            if (identifier.unsignedIntegerValue == key.unsignedIntegerValue){
                [obj cancel];
                [sender.taskTable removeObjectForKey:key];
                [sender.taskInfoTable removeObjectForKey:key];
            }
        }];
    }
}

#pragma mark - private method

- (__kindof XJSenderBridge *)chooseSender:(XJRequestProviderTaskType)taskType
{
    NSString *senderClassName = TaskType[taskType];
    XJSenderBridge *sender = self.senderTable[senderClassName];
    if(!sender){
        sender = [[NSClassFromString(senderClassName) alloc]init];
        self.senderTable[senderClassName] = sender;
    }
    return sender;
}

#pragma mark - lazy load

- (AFHTTPSessionManager *)manager
{
    if(!_manager){
        _manager = [AFHTTPSessionManager manager];
        AFSecurityPolicy *policy = [AFSecurityPolicy defaultPolicy];
        policy.allowInvalidCertificates = YES;
        policy.validatesDomainName = NO;
        _manager.securityPolicy = policy;
    }
    return _manager;
}

- (AFHTTPRequestSerializer *)requestSerializer
{
    if(!_requestSerializer){
        _requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    return _requestSerializer;
}

- (AFJSONResponseSerializer *)responseSerializer
{
    if(!_responseSerializer){
        _responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return _responseSerializer;
}

- (NSMutableDictionary<NSNumber *,NSURLSessionDataTask *> *)taskTable
{
    if(!_taskTable){
        _taskTable = [NSMutableDictionary dictionary];
    }
    return _taskTable;
}

- (NSMutableDictionary<NSNumber *,XJTaskInfo *> *)taskInfoTable
{
    if(!_taskInfoTable){
        _taskInfoTable = [NSMutableDictionary dictionary];
    }
    return _taskInfoTable;
}


- (NSMutableDictionary<NSString *,XJSenderBridge *> *)senderTable
{
    if(!_senderTable){
        _senderTable = [NSMutableDictionary dictionaryWithCapacity:sizeof(TaskType)/sizeof(TaskType[0])];
    }
    return _senderTable;
}

@end


@interface XJTaskInfo()

@property (nonatomic, strong, readwrite)id <XJRequestProviderCommonSource>source;
@property (nonatomic, weak, readwrite)id caller;
@property (nonatomic, copy, readwrite)NSString *fullUrl;
@property (nonatomic, copy, readwrite)NSDictionary *finalParams;

@end

@implementation XJTaskInfo

- (instancetype)initWithSource:(id <XJRequestProviderCommonSource>)source from:(id)caller
{
    if(self = [super init]){
        self.source = source;
        self.caller = caller;
    }
    return self;
}

- (NSArray <id <XJRequestProviderSourcePlugin>>*)prepareForRequset
{
    self.fullUrl = [NSString stringWithFormat:@"%@/%@",self.source.baseURL,self.source.methodname];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.source.parameters];
    [params addEntriesFromDictionary:[XJCommonContext shareInstance].commonParams];
    
    NSArray *plugins = [self.source respondsToSelector:@selector(plugins)] ? self.source.plugins : @[];
    
    BOOL shouldSend = [plugins xj_any:
                       ^BOOL(id<XJRequestProviderSourcePlugin> obj) {
                           if([obj respondsToSelector:@selector(shouldSendApiWithParams:caller:)]){
                               if(![obj shouldSendApiWithParams:params caller:self.caller]){
                                   return YES;
                               }
                           }
                           return NO;
                       }];
    
    if (!shouldSend) {
        __block NSDictionary *pams = [params copy];
        [plugins enumerateObjectsUsingBlock:
                                ^(id<XJRequestProviderSourcePlugin>  _Nonnull obj,NSUInteger idx,BOOL * _Nonnull stop) {
            if([obj respondsToSelector:@selector(willSendApiWithParams:)]){
                pams = [obj willSendApiWithParams:pams];
            }
        }];
        self.finalParams = pams;
    }
    
    if (!shouldSend){return plugins;}
    return nil;
}

@end
