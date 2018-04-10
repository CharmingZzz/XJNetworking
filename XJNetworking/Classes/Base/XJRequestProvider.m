//
//  XJRequestProvider.m
//  XJNetworking
//
//  Created by xujie on 2018/4/9.
//  Copyright © 2018年 XuJie. All rights reserved.
//

#import <objc/message.h>
#import "XJRequestProvider.h"
#import "XJRequestSender.h"

@interface XJRequestProvider()

@property (nonatomic,strong)NSMutableArray <NSNumber *>*requestIDs;
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
    NSUInteger identifier = [[XJRequestSender shareInstance] sendRequestWithSource:source from:caller success:callBack failure:failCallBack];
    
    if(identifier == NSNotFound){return nil;}
    
    [self.requestIDs addObject:@(identifier)];
    
    XJRequestCancellable *cancellable = [[XJRequestCancellable alloc]init];
    [cancellable addObserver:self forKeyPath:observerKey options:NSKeyValueObservingOptionNew context:nil];
    self.cancelTable[@(identifier)] = cancellable;
    
    return cancellable;
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:observerKey] && [change[NSKeyValueChangeNewKey] integerValue] == 1){
        [self.cancelTable enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key,
                                                              XJRequestCancellable * _Nonnull obj,
                                                              BOOL * _Nonnull stop) {
            if ([object isEqual:obj]){
                [[XJRequestSender shareInstance] cancelRequestWithIDs:@[key]];
                *stop = YES;
            }
        }];
    }
}

#pragma mark - lazy load

- (NSMutableArray<NSNumber *> *)requestIDs
{
    if(!_requestIDs){
        _requestIDs = [NSMutableArray array];
    }
    return  _requestIDs;
}

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
    [[XJRequestSender shareInstance] cancelRequestWithIDs:self.requestIDs];
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





