//
//  XJRequestProvider.m
//  XJNetworking
//
//  Created by xujie on 2018/4/9.
//  Copyright © 2018年 XuJie. All rights reserved.
//

#import <objc/message.h>
#import "XJRequestProvider.h"
#import "XJSenderFactory.h"

@interface XJRequestInnerCancellable: XJRequestCancellable

@property (nonatomic,assign) BOOL isFinished;

@end

@implementation XJRequestInnerCancellable

- (void)cancel
{
    if(self.isFinished)return;
    [super cancel];
    self.isFinished = YES;
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
    XJTaskInfo *info = [[XJTaskInfo alloc]initWithSource:source from:caller];

    XJRequestInnerCancellable *cancellable = [[XJRequestInnerCancellable alloc]init];
    [cancellable addObserver:self forKeyPath:observerKey options:NSKeyValueObservingOptionNew context:nil];
    successCallBack cb = ^(XJURLResponse *response) {
        cancellable.isFinished = YES;
        !callBack?:callBack(response);
    };
    failureCallBack fcb = ^(NSError *error) {
        cancellable.isFinished = YES;
        !failCallBack?:failCallBack(error);
    };
    
    NSUInteger identifier = [[XJSenderFactory shareInstance] sendRequestWithTaskInfo:info success:cb failure:fcb];
    
    if(identifier == NSNotFound){return nil;}
    
    self.cancelTable[@(identifier)] = cancellable;
    
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
                [[XJSenderFactory shareInstance] cancelRequestWithIDs:@[key]];
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

