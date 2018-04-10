//
//  XJRequestProvider.m
//  XJNetworking
//
//  Created by xujie on 2018/4/9.
//  Copyright © 2018年 XuJie. All rights reserved.
//

#import <objc/message.h>
#import "XJRequestProvider.h"

@interface XJRequestProvider()

@property (nonatomic,strong)NSHashTable *callerTable;
@property (nonatomic,strong)NSMapTable *requestIDTable;

@end

@implementation XJRequestProvider

+ (instancetype)defaultProvider
{
    XJRequestProvider *provider = [[XJRequestProvider alloc]init];
    return provider;
}

#pragma mark - public method

- (void)requestWithSource:(id<XJRequestProviderCommonSource>)source from:(id)caller
{
    
}

- (void)requestWithSource:(id<XJRequestProviderCommonSource>)source from:(id)caller success:(successCallBack)callBack failure:(failureCallBack)failCallBack
{
    
}

#pragma mark - lazy load

- (NSHashTable *)callerTable
{
    if(!_callerTable){
        _callerTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return  _callerTable;
}

- (NSMapTable *)requestIDTable
{
    if(!_requestIDTable){
        _requestIDTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsCopyIn];
    }
    return _requestIDTable;
}

#pragma mark - override method

- (void)dealloc
{
    [self cancelAllRequest];
}


@end
