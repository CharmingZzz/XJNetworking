//
//  XJSenderFactory.m
//  XJNetworking
//
//  Created by xujie on 2018/4/11.
//  Copyright © 2018年 XuJie. All rights reserved.

#import "XJSenderFactory.h"
#import "XJCommonContext.h"
#import "NSArray+XJNetworking.h"

@interface XJSenderFactory()

@property (nonatomic, strong, readwrite)AFHTTPSessionManager *manager;
@property (nonatomic, strong, readwrite)NSMutableDictionary <NSNumber *,NSURLSessionDataTask *>*taskTable;
@property (nonatomic, strong, readwrite)NSMutableDictionary <NSNumber *,XJTaskInfo *>*taskInfoTable;
@property (nonatomic, strong)NSMutableDictionary <NSString *,__kindof XJSenderFactory *>*senderTable;

@end

NSString *RequestType[2] = {
    [XJRequestProviderRequestTypeGet] = @"GET",
    [XJRequestProviderRequestTypePost] = @"POST"
};

static NSString *TaskType[3] = {
    [XJRequestProviderTaskTypeRequest] = @"XJRequestSender",
    [XJRequestProviderTaskTypeUpload] = @"XJUploadSender",
    [XJRequestProviderTaskTypeDownload] = @"XJDownloadSender",
};

@implementation XJSenderFactory

#pragma mark - public method

+ (instancetype)shareInstance
{
    static XJSenderFactory *sender_;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sender_ = [[XJSenderFactory alloc]init];
    });
    return sender_;
}

- (NSUInteger)sendRequestWithTaskInfo:(XJTaskInfo *)taskInfo success:(successCallBack)callBack failure:(failureCallBack)failCallBack
{
    self.manager.requestSerializer = [taskInfo.source respondsToSelector:@selector(requestSerializer)] ? taskInfo.source.requestSerialization : [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [taskInfo.source respondsToSelector:@selector(responseSerialization)] ? taskInfo.source.responseSerialization :[AFJSONResponseSerializer serializer];
    [self.manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    self.manager.requestSerializer.timeoutInterval = [XJCommonContext shareInstance].requestTimeoutSeconds;
    [self.manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    XJRequestProviderTaskType taskType = [taskInfo.source respondsToSelector:@selector(taskType)] ? taskInfo.source.taskType : XJRequestProviderTaskTypeRequest;
   return [[self chooseSender:taskType] sendRequestWithTaskInfo:(XJTaskInfo *)taskInfo success:(successCallBack)callBack failure:(failureCallBack)failCallBack];
}

- (void)cancelRequestWithIDs:(NSArray *)identifiers taskType:(XJRequestProviderTaskType)type
{
    XJSenderFactory *sender = [self chooseSender:type];
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

- (__kindof XJSenderFactory *)chooseSender:(XJRequestProviderTaskType)taskType
{
    NSString *senderClassName = TaskType[taskType];
    XJSenderFactory *sender = self.senderTable[senderClassName];
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

- (NSMutableDictionary<NSNumber *,XJTaskInfo *> *)taskInfoTable
{
    if(!_taskInfoTable){
        _taskInfoTable = [NSMutableDictionary dictionary];
    }
    return _taskInfoTable;
}


- (NSMutableDictionary<NSString *,XJSenderFactory *> *)senderTable
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

- (BOOL)prepareForRequset
{
    self.fullUrl = [self.source.baseURL stringByAppendingPathComponent:self.source.methodname];
    
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
    
    return !shouldSend;
}

@end
