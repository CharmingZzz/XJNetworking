//
//  XJRequestProvider.m
//  XJNetworking
//
//  Created by xujie on 2018/4/9.
//  Copyright © 2018年 XuJie. All rights reserved.
//

#import <objc/message.h>
#import "XJRequestProvider.h"
#import "XJSenderBridge.h"

@interface XJRequestInnerCancellable: XJRequestCancellable

@property (nonatomic,assign) BOOL isFinished;
@property (nonatomic,assign) XJRequestProviderTaskType taskType;

@end

@implementation XJRequestInnerCancellable

- (void)cancel
{
    if(self.isFinished)return;
    self.isFinished = YES;
    [super cancel];
}

- (BOOL)isCancelled
{
    return self.isFinished;
}

@end

@interface XJRequestCancellable()

@property (nonatomic,assign,readwrite)BOOL isCancelled;

@end

@implementation XJRequestCancellable

- (void)cancel
{
    self.isCancelled = YES;
}

@end


@interface XJRequestProvider()

@property (nonatomic,strong)NSMutableDictionary <NSNumber *,XJRequestCancellable *>*cancelTable;
@property (nonatomic,strong)NSMapTable <id <XJRequestProviderCommonSource>,XJRequestCancellable *>*cancelSourceTable;

@end

static NSString *observerKey = @"isCancelled";

@implementation XJRequestProvider

+ (instancetype)defaultProvider
{
    XJRequestProvider *provider = [[XJRequestProvider alloc]init];
    return provider;
}

#pragma mark - public method

- (XJRequestCancellable *)requestWithSource:(id<XJRequestProviderCommonSource>)source from:(id)caller
{
    return [self requestWithSource:source from:caller success:nil failure:nil];
}

- (XJRequestCancellable *)requestWithSource:(id<XJRequestProviderCommonSource>)source from:(id)caller success:(successCallBack)callBack failure:(failureCallBack)failCallBack
{
    return [self uploadWithSource:source from:caller progress:nil success:callBack failure:failCallBack];
}

- (XJRequestCancellable *)uploadWithSource:(id<XJRequestProviderCommonSource>)source from:(id)caller progress:(progressCallBack)progressCB success:(successCallBack)callBack failure:(failureCallBack)failCallBack
{
    NSAssert(source, @"source can't be nil");
    
    XJRequestCancellable *existcancellable = [self.cancelSourceTable objectForKey:source];
    if(existcancellable && !existcancellable.isCancelled){
        [existcancellable cancel];
    }
    
    XJTaskInfo *info = [[XJTaskInfo alloc]initWithSource:source from:caller];
    XJRequestInnerCancellable *cancellable = [[XJRequestInnerCancellable alloc]init];
    cancellable.taskType = [source respondsToSelector:@selector(taskType)] ? source.taskType : XJRequestProviderTaskTypeRequest;
    [cancellable addObserver:self forKeyPath:observerKey options:NSKeyValueObservingOptionNew context:nil];
    successCallBack cb = ^(XJURLResponse *response) {
        cancellable.isFinished = YES;
        !callBack?:callBack(response);
    };
    failureCallBack fcb = ^(NSError *error) {
        cancellable.isFinished = YES;
        !failCallBack?:failCallBack(error);
    };
    
    NSUInteger identifier = [[XJSenderBridge shareInstance] sendRequestWithTaskInfo:info progress:progressCB success:cb failure:fcb];
    if(identifier == NSNotFound){return nil;}
    
    self.cancelTable[@(identifier)] = cancellable;
    [self.cancelSourceTable setObject:cancellable forKey:source];
    return cancellable;
}

- (void)cancelAllRequest
{
    [self.cancelTable.allValues makeObjectsPerformSelector:@selector(cancel)];
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:observerKey] && [change[NSKeyValueChangeNewKey] boolValue] == YES){
        [self.cancelTable enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key,
                                                              XJRequestCancellable * _Nonnull obj,
                                                              BOOL * _Nonnull stop) {
            if ([object isEqual:obj]){
                [[XJSenderBridge shareInstance] cancelRequestWithIDs:@[key] taskType:((XJRequestInnerCancellable *)obj).taskType];
                *stop = YES;
            }
        }];
    }
}

#pragma mark - lazy load

- (NSMutableDictionary<NSNumber *,XJRequestCancellable *> *)cancelTable
{
    if(!_cancelTable){
        _cancelTable = [NSMutableDictionary dictionary];
    }
    return _cancelTable;
}

- (NSMapTable<id<XJRequestProviderCommonSource>,XJRequestCancellable *> *)cancelSourceTable
{
    if(!_cancelSourceTable){
        _cancelSourceTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsWeakMemory];
    }
    return _cancelSourceTable;
}

#pragma mark - override method

- (void)dealloc
{
    NSLog(@"-----%s-----",__func__);
    
    [self.cancelTable.allValues enumerateObjectsUsingBlock:^(XJRequestCancellable * _Nonnull obj,
                                                             NSUInteger idx,
                                                             BOOL * _Nonnull stop) {
        [obj removeObserver:self forKeyPath:observerKey];
    }];
    [self cancelAllRequest];
}

@end

