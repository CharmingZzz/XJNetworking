//
//  XJCommonContext.h
//  XJNetworking
//
//  Created by xujie on 2018/4/10.
//

#import <Foundation/Foundation.h>

@interface XJCommonContext : NSObject

+ (instancetype)shareInstance;

@property (nonatomic,strong)NSDictionary *commonParams;

@end
