//
//  XJPagePlugin.m
//  XJNetworking_Example
//
//  Created by xujie on 2018/4/17.
//  Copyright © 2018年 XuJie. All rights reserved.
//

#import "XJPagePlugin.h"

NSString * const XJPagePluginPageIndexKey = @"kXJPagePluginPageIndexKey";
NSString * const XJPagePluginPageSizeKey = @"kXJPagePluginPageSizeKey";
NSString * const XJPagePluginPageIndexDefultValue = @"kXJPagePluginPageIndexDefultValue";
NSString * const XJPagePluginPageSizeDefultValue = @"kXJPagePluginPageSizeDefultValue";

@interface XJPagePlugin()

@property (nonatomic, assign, readwrite)BOOL hasNextPage;
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
    if(![dict.allKeys containsObject:XJPagePluginPageIndexKey]){
        muDict[XJPagePluginPageIndexKey] = defaultPageIndexKey;
    }
    if(![dict.allKeys containsObject:XJPagePluginPageSizeKey]){
        muDict[XJPagePluginPageSizeKey] = defaultPageSizeKey;
    }
    if(![dict.allKeys containsObject:XJPagePluginPageIndexDefultValue]){
        muDict[XJPagePluginPageIndexDefultValue] = @"1";
    }
    if(![dict.allKeys containsObject:XJPagePluginPageSizeDefultValue]){
        muDict[XJPagePluginPageSizeDefultValue] = @"20";
    }
    plugin.ColumnDict = muDict;
    plugin.pageIndex = [plugin.ColumnDict[XJPagePluginPageIndexDefultValue] integerValue];
    plugin.pageSize = [plugin.ColumnDict[XJPagePluginPageSizeDefultValue] integerValue];
    return plugin;
}

- (NSDictionary *)willSendApiWithParams:(NSDictionary *)params
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
    self.rollbackPageIndex = self.pageIndex;
    if(self.pageType == XJRequestProviderPageTypeNewest){
        self.pageIndex = [self.ColumnDict[XJPagePluginPageIndexDefultValue] integerValue];
    }else if (self.pageType == XJRequestProviderPageTypeMore){
        self.pageIndex++;
    }
    [dict setObject:[NSString stringWithFormat:@"%zd",self.pageIndex] forKey:self.ColumnDict[XJPagePluginPageIndexKey]];
    [dict setObject:[NSString stringWithFormat:@"%zd",self.pageSize] forKey:self.ColumnDict[XJPagePluginPageSizeKey]];
    return [dict copy];
}

- (void)afterApiSuccessWithResponse:(XJURLResponse *)response caller:(id)caller
{
    // subclass to implement
}

- (void)afterApiFailureWithError:(NSError *)error caller:(id)caller
{
    self.pageIndex = self.rollbackPageIndex;
}

@end
