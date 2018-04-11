//
//  XJSenderFactory.m
//  XJNetworking
//
//  Created by xujie on 2018/4/11.
//

#import "XJSenderFactory.h"
#import "XJCommonContext.h"

@interface XJSenderFactory()

@property (nonatomic,strong,readwrite)AFHTTPSessionManager *manager;
@property (nonatomic,strong,readwrite)NSMutableDictionary <NSNumber *,NSURLSessionDataTask *>*taskTable;
@property (nonatomic,strong)NSMutableDictionary <NSString *,__kindof XJSenderFactory *>*senderTable;

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

- (NSUInteger)sendRequestWithSource:(id<XJRequestProviderCommonSource>)source from:(id)caller success:(successCallBack)callBack failure:(failureCallBack)failCallBack
{
    self.manager.requestSerializer = [source respondsToSelector:@selector(requestSerializer)] ? source.requestSerialization : [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [source respondsToSelector:@selector(responseSerialization)] ? source.responseSerialization :[AFJSONResponseSerializer serializer];
    
    XJRequestProviderTaskType taskType = [source respondsToSelector:@selector(taskType)] ? source.taskType : XJRequestProviderTaskTypeRequest;
   return [[self chooseSender:taskType] sendRequestWithSource:source from:caller success:callBack failure:failCallBack];
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

- (NSMutableDictionary<NSString *,XJSenderFactory *> *)senderTable
{
    if(!_senderTable){
        _senderTable = [NSMutableDictionary dictionaryWithCapacity:sizeof(TaskType)/sizeof(TaskType[0])];
    }
    return _senderTable;
}

@end
