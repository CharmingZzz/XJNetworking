//
//  NSArray+XJNetworking.h
//  XJNetworking
//
//  Created by xujie on 2018/4/10.
//  Copyright © 2018年 XuJie. All rights reserved.

#import <Foundation/Foundation.h>

@interface NSArray<ObjectType> (XJNetworking)

- (NSArray *)xj_map:(id(^)(ObjectType obj, NSUInteger index))block;
- (BOOL)xj_any:(BOOL(^)(ObjectType obj))block;
- (void)xj_makeObjectsPerformSelector:(SEL)selector, ...;

@end
