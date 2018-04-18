//
//  XJPagePlugin.m
//  XJNetworking_Example
//
//  Created by xujie on 2018/4/17.
//  Copyright © 2018年 XuJie. All rights reserved.
//

#import "XJPagePlugin.h"

NSString *kXJPagePluginPageIndexKey = @"kXJPagePluginPageIndexKey";
NSString *kXJPagePluginPageSizeKey = @"kXJPagePluginPageSizeKey";
NSString *kXJPagePluginPageIndexDefultValue = @"kXJPagePluginPageIndexDefultValue";
NSString *kXJPagePluginPageSizeDefultValue = @"kXJPagePluginPageSizeDefultValue";

@interface XJPagePlugin()

@property (nonatomic, copy)NSDictionary *ColumnDict;
@property (nonatomic, assign)NSInteger pageIndex;
@property (nonatomic, assign)NSInteger pageSize;
@property (nonatomic, assign)NSInteger rollbackPageIndex;

@end

static NSString *const defaultPageIndexKey = @"pageIndex";
static NSString *const defaultPageSizeKey = @"pageSize";

@implementation XJPagePlugin

+ (instancetype)pluginWithColumnDict:(NSDictionary <NSString *,NSString *>*)dict
{
    XJPagePlugin *plugin = [[self alloc]init];
    NSMutableDictionary *muDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    if(![dict.allKeys containsObject:kXJPagePluginPageIndexKey]){
        muDict[kXJPagePluginPageIndexKey] = defaultPageIndexKey;
    }
    if(![dict.allKeys containsObject:kXJPagePluginPageSizeKey]){
        muDict[kXJPagePluginPageSizeKey] = defaultPageSizeKey;
    }
    if(![dict.allKeys containsObject:kXJPagePluginPageIndexDefultValue]){
        muDict[kXJPagePluginPageIndexDefultValue] = @"1";
    }
    if(![dict.allKeys containsObject:kXJPagePluginPageSizeDefultValue]){
        muDict[kXJPagePluginPageSizeDefultValue] = @"20";
    }
    plugin.ColumnDict = muDict;
    plugin.pageIndex = [plugin.ColumnDict[kXJPagePluginPageIndexDefultValue] integerValue];
    plugin.pageSize = [plugin.ColumnDict[kXJPagePluginPageSizeDefultValue] integerValue];
    return plugin;
}

- (NSDictionary *)willSendApiWithParams:(NSDictionary *)params
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
    self.rollbackPageIndex = self.pageIndex;
    if(self.pageType == XJRequestProviderPageTypeNewest){
        self.pageIndex = [self.ColumnDict[kXJPagePluginPageIndexDefultValue] integerValue];
    }else if (self.pageType == XJRequestProviderPageTypeMore){
        self.pageIndex++;
    }
    [dict setObject:[NSString stringWithFormat:@"%zd",self.pageIndex] forKey:self.ColumnDict[kXJPagePluginPageIndexKey]];
    [dict setObject:[NSString stringWithFormat:@"%zd",self.pageSize] forKey:self.ColumnDict[kXJPagePluginPageSizeKey]];
    return [dict copy];
}

- (void)afterApiFailureWithError:(NSError *)error caller:(id)caller
{
    self.pageIndex = self.rollbackPageIndex;
}

@end
