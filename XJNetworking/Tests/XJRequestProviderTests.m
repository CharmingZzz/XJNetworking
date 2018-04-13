//
//  XJRequestProviderTests.m
//  XJNetworking
//
//  Created by xujie on 2018/4/12.
//  Copyright © 2018年 XuJie. All rights reserved.

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "XJNetworking.h"

@interface XJRequestProviderTests : XCTestCase

@property (nonatomic,strong)XJRequestProvider *provider;
@property (nonatomic,strong)id commonSourceMock;
@property (nonatomic,strong)id pluginMock;

@end

@implementation XJRequestProviderTests

- (void)setUp {
    [super setUp];
    
    self.provider = [XJRequestProvider defaultProvider];
    
    // mock XJRequestProviderCommonSource
    id apiMock = OCMProtocolMock(@protocol(XJRequestProviderCommonSource));
    OCMStub([apiMock baseURL]).andReturn(@"https://httpbin.org");
    OCMStub([apiMock methodname]).andReturn(@"ip");
    OCMStub([apiMock parameters]).andReturn(@{});
    OCMStub([apiMock requestType]).andReturn(XJRequestProviderRequestTypeGet);
    OCMStub([apiMock taskType]).andReturn(XJRequestProviderTaskTypeRequest);
    OCMStub([apiMock requestSerialization]).andReturn([AFHTTPRequestSerializer serializer]);
    OCMStub([apiMock responseSerialization]).andReturn([AFJSONRequestSerializer serializer]);
    self.commonSourceMock = apiMock;
    
    // mock
    id pluginMock = OCMProtocolMock(@protocol(XJRequestProviderSourcePlugin));
    OCMStub([pluginMock shouldSendApiWithParams:[OCMArg any] caller:[OCMArg any]]).andReturn(YES);
    OCMStub([pluginMock willSendApiWithParams:[OCMArg any]]).andReturn(@{});
    OCMStub([pluginMock willSendApiWithRequest:[OCMArg any]]).andReturn([NSURLRequest new]);
    OCMStub([pluginMock beforeApiSuccessWithResponse:[OCMArg any]]).andReturn(YES);
    OCMStub([pluginMock afterApiSuccessWithResponse:[OCMArg any] caller:[OCMArg any]]);
    OCMStub([pluginMock beforeApiFailureWithError:[OCMArg any]]).andReturn(YES);
    OCMStub([pluginMock afterApiFailureWithError:[OCMArg any] caller:[OCMArg any]]);
    self.pluginMock = pluginMock;
}

- (void)tearDown {
    [super tearDown];
    
    [self.provider cancelAllRequest];
    self.provider = nil;
    self.commonSourceMock = nil;
    self.pluginMock = nil;
}

- (void)testRequest {

    [self startRequest:self.commonSourceMock];
}

- (void)testPlugins1 {
    
    OCMStub([self.commonSourceMock plugins]).andReturn(@[self.pluginMock]);

    [self startRequest:self.commonSourceMock];

    OCMVerify([self.pluginMock shouldSendApiWithParams:[OCMArg any] caller:[OCMArg any]]);
    OCMVerify([self.pluginMock willSendApiWithParams:[OCMArg any]]);
    OCMVerify([self.pluginMock willSendApiWithRequest:[OCMArg any]]);
    OCMVerify([self.pluginMock beforeApiSuccessWithResponse:[OCMArg any]]);
    OCMVerify([self.pluginMock afterApiSuccessWithResponse:[OCMArg any] caller:[OCMArg any]]);
}

- (void)testCancelleable
{
    XJRequestCancellable *cancellable = [self startRequest:self.commonSourceMock];
    XCTAssertTrue(cancellable.isCancelled,@"request is already cancel");
}


- (XJRequestCancellable *)startRequest:(id <XJRequestProviderCommonSource>)source {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"test Async requset"];
    
    XJRequestCancellable *cancellable = [self.provider requestWithSource:source from:self
                             success:^(XJURLResponse *response) {
        NSLog(@"-----%@-----",response.content);
        XCTAssertNotNil(response.request,@"----success request couldn't be nil---");
        [expectation fulfill];
    } failure:^(NSError *error) {
        XCTAssertNotNil(error,@"----failure error couldn't be nil---");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.f handler:^(NSError * _Nullable error) {
        
    }];
    return cancellable;
}


@end
