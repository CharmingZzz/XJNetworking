//
//  XJURLResponse.h
//  XJNetworking
//
//  Created by xujie on 2018/4/9.
//

#import <Foundation/Foundation.h>

@interface XJURLResponse : NSObject

@property (nonatomic, copy, readonly) NSURLRequest *request;

@property (nonatomic, copy, readonly) NSURLResponse *response;

@property (nonatomic, copy, readonly) id content;

@property (nonatomic, copy, readonly) NSDictionary *requestParams;

- (instancetype)initWithRequest:(NSURLRequest *)request
                              response:(NSURLResponse *)response
                        responseObject:(id)responseObject;

@end
