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

@property (nonatomic,weak)id <XJRequestProviderCommonSource>source;
@property (nonatomic,strong)NSHashTable *callerTable;
@property (nonatomic,strong)NSMapTable *requestIDTable;

@end

static NSString *callerKey = @"caller";

@implementation XJRequestProvider

+ (instancetype)providerWithSource:(id)source
{
    NSAssert([source conformsToProtocol:@protocol(XJRequestProviderCommonSource)], @"source have to conform XJRequestProviderCommonSource protocol....");
    
    XJRequestProvider *provider = [[XJRequestProvider alloc]init];
    
    provider.source = source;
    
    return provider;
}


#pragma mark - public method

- (void)requestWithCaller:(id)caller
{
    [self insertCallerIntoTable:caller];
    
}

- (void)requestWithCaller:(id)caller success:(successCallBack)callBack failure:(failureCallBack)failCallBack
{
    [self insertCallerIntoTable:caller];
}

#pragma mark - private method

- (void)insertCallerIntoTable:(id)caller
{
    @synchronized (self.callerTable){
        
        if ([self.callerTable containsObject:caller] || !caller) return;
        
        Class classToSwizzle = [caller class];
        
        SEL deallocSelector = sel_registerName("dealloc");
        
        __block void (*originalDealloc)(__unsafe_unretained id, SEL) = NULL;
        
        id newDealloc = ^(__unsafe_unretained id self) {
            
            NSLog(@"----should cancel request-------");
            
            if (originalDealloc == NULL) {
                struct objc_super superInfo = {
                    .receiver = self,
                    .super_class = class_getSuperclass(classToSwizzle)
                };
                void (*msgSend)(struct objc_super *, SEL) = (__typeof__(msgSend))objc_msgSendSuper;
                msgSend(&superInfo, deallocSelector);
            } else {
                originalDealloc(self, deallocSelector);
            }
        };
        
        IMP newDeallocIMP = imp_implementationWithBlock(newDealloc);
        
        if (!class_addMethod(classToSwizzle, deallocSelector, newDeallocIMP, "v@:")) {
            Method deallocMethod = class_getInstanceMethod(classToSwizzle, deallocSelector);
            
            originalDealloc = (__typeof__(originalDealloc))method_getImplementation(deallocMethod);
            
            originalDealloc = (__typeof__(originalDealloc))method_setImplementation(deallocMethod, newDeallocIMP);
        }
        
        [self.callerTable addObject:caller];
    }
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

@end
