//
//  XJRequestProvider+RAC.h
//  XJNetworking_Example
//
//  Created by xujie on 2018/5/17.
//  Copyright © 2018年 m17600026862@163.com. All rights reserved.
//

#import "XJRequestProvider.h"
#import <ReactiveObjc/ReactiveObjC.h>

@interface XJRequestProvider (RAC)

- (RACCommand *)rac_requestWithSource:(id <XJRequestProviderCommonSource>)source from:(id)caller;
- (RACCommand *)rac_sequenceRequestWithSources:(NSArray <id <XJRequestProviderCommonSource>>*)sources from:(id)caller;
- (RACCommand *)rac_zipResponseRequestWithSources:(NSArray <id <XJRequestProviderCommonSource>>*)sources from:(id)caller;


@end
