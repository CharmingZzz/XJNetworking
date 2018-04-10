//
//  XJURLResponse.m
//  XJNetworking
//
//  Created by xujie on 2018/4/9.
//

#import "XJURLResponse.h"
#import "NSURLRequest+XJNetworking.h"

@interface XJURLResponse()

@property (nonatomic, copy, readwrite) NSURLRequest *request;

@property (nonatomic, copy, readwrite) NSURLResponse *response;

@property (nonatomic, copy, readwrite) id content;

@property (nonatomic, copy, readwrite) NSDictionary *requestParams;

@end

@implementation XJURLResponse

- (instancetype)initWithRequest:(NSURLRequest *)request
                       response:(NSURLResponse *)response
                 responseObject:(id)responseObject
{
    if(self = [super init]){
        self.request = request;
        self.response = response;
        self.content = responseObject;
        self.requestParams = request.xj_requestParams;
    }
    return self;
}

@end
