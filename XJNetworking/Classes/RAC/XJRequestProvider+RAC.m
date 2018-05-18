//
//  XJRequestProvider+RAC.m
//  XJNetworking_Example
//
//  Created by xujie on 2018/5/17.
//  Copyright © 2018年 m17600026862@163.com. All rights reserved.
//

#import "XJRequestProvider+RAC.h"

@implementation XJRequestProvider (RAC)

- (RACCommand *)rac_requestWithSource:(id<XJRequestProviderCommonSource>)source from:(id)caller
{
    @weakify(self)
    RACCommand *command = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self)
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            [self requestWithSource:source from:caller success:^(XJURLResponse *response) {
                [subscriber sendNext:response];
            } failure:^(NSError *error) {
                [subscriber sendError:error];
            }];
            
            return nil;
        }];
        
    }];
    return command;
}

- (RACCommand *)rac_sequenceRequestWithSources:(NSArray<id<XJRequestProviderCommonSource>> *)sources from:(id)caller
{
    return [self rac_requestWithSources:sources from:caller isSequence:YES];
}


- (RACCommand *)rac_zipResponseRequestWithSources:(NSArray <id <XJRequestProviderCommonSource>>*)sources from:(id)caller
{
    return [self rac_requestWithSources:sources from:caller isSequence:NO];
}

- (RACCommand *)rac_requestWithSources:(NSArray <id <XJRequestProviderCommonSource>>*)sources from:(id)caller isSequence:(BOOL)isOrNo
{
    @weakify(self)
    RACCommand *command = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self)
        
        NSMutableArray *signals = [NSMutableArray array];
        
        [sources enumerateObjectsUsingBlock:^(id<XJRequestProviderCommonSource>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            RACSignal *innerSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                
                [self requestWithSource:obj from:caller success:^(XJURLResponse *response) {
                    [subscriber sendNext:response];
                    [subscriber sendCompleted];
                } failure:^(NSError *error) {
                    [subscriber sendError:error];
                }];
                return nil;
                
            }];
            [signals addObject:innerSignal];
        }];
        
        return isOrNo ? [RACSignal concat:signals] : [RACSignal zip:signals];
        
    }];
    return command;
}

@end
