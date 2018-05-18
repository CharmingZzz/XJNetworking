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
@property (nonatomic,assign)BOOL pluginTestOpen;

@end

@implementation XJRequestProviderTests

- (void)setUp {
    [super setUp];
    
    self.provider = [XJRequestProvider defaultProvider];
    self.pluginTestOpen = NO;
    
    // mock XJRequestProviderCommonSource
    id apiMock = OCMProtocolMock(@protocol(XJRequestProviderCommonSource));
    OCMStub([apiMock baseURL]).andReturn(@"https://httpbin.org");
    OCMStub([apiMock parameters]).andReturn(@{});
    OCMStub([apiMock taskType]).andReturn(XJRequestProviderTaskTypeRequest);
    OCMStub([apiMock requestSerialization]).andReturn([AFHTTPRequestSerializer serializer]);
    OCMStub([apiMock responseSerialization]).andReturn([AFJSONRequestSerializer serializer]);
    self.commonSourceMock = apiMock;
    
    // mock
    id pluginMock = OCMProtocolMock(@protocol(XJRequestProviderSourcePlugin));
    OCMStub([pluginMock shouldSendApiWithParams:[OCMArg any] caller:[OCMArg any]]).andReturn(YES);
    OCMStub([pluginMock willSendApiWithParams:[OCMArg any]]).andCall(self,@selector(mock_willSendApiWithParams:));
    OCMStub([pluginMock willSendApiWithRequest:[OCMArg any]]).andCall(self,@selector(mock_willSendApiWithRequest:));
    OCMStub([pluginMock afterSendApiWithParams:[OCMArg any] caller:[OCMArg any]]).andCall(self,@selector(mock_afterSendApiWithParams:caller:));
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

- (void)testRequestGet {
    OCMStub([self.commonSourceMock plugins]).andReturn(@[]);
    OCMStub([self.commonSourceMock methodname]).andReturn(@"get");
    [self startRequest:self.commonSourceMock];
}

- (void)testRequestPost {
    OCMStub([self.commonSourceMock plugins]).andReturn(@[]);
    OCMStub([self.commonSourceMock requestType]).andReturn(XJRequestProviderRequestTypePost);
    OCMStub([self.commonSourceMock methodname]).andReturn(@"post");
    [self startRequest:self.commonSourceMock];
}

- (void)testPlugins1 {
    OCMStub([self.commonSourceMock methodname]).andReturn(@"get");
    OCMStub([self.commonSourceMock plugins]).andReturn(@[self.pluginMock]);

    [self startRequest:self.commonSourceMock];

    OCMVerify([self.pluginMock shouldSendApiWithParams:[OCMArg any] caller:[OCMArg any]]);
    OCMVerify([self.pluginMock willSendApiWithParams:[OCMArg any]]);
    OCMVerify([self.pluginMock willSendApiWithRequest:[OCMArg any]]);
    OCMVerify([self.pluginMock afterSendApiWithParams:[OCMArg any] caller:[OCMArg any]]);
    OCMVerify([self.pluginMock beforeApiSuccessWithResponse:[OCMArg any]]);
    OCMVerify([self.pluginMock afterApiSuccessWithResponse:[OCMArg any] caller:[OCMArg any]]);
}

- (void)testPlugins2 {
    OCMStub([self.commonSourceMock methodname]).andReturn(@"get");
    OCMStub([self.commonSourceMock plugins]).andReturn(@[self.pluginMock]);
    
    self.pluginTestOpen = YES;
    
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"test Async requset Plugins"];
    
    [self.provider requestWithSource:self.commonSourceMock from:self
                                                                 success:^(XJURLResponse *response) {
                                                                     XCTAssertEqualObjects(response.request.allHTTPHeaderFields[@"testplugin"], @"testplugin",@"plugin is already add testplugin key to httpheader");
                                                                     NSLog(@"----%@-----",response.request.xj_requestParams);
                                                                     XCTAssertEqualObjects(response.request.xj_requestParams[@"testplugin"], @"testplugin",@"plugin is already add testplugin key to params");
                                                                     [expectation fulfill];
                                                                 } failure:^(NSError *error) {
                                                                     XCTAssertNil(error,@"----request should be success---");
                                                                     [expectation fulfill];
                                                                 }];
    [self waitForExpectationsWithTimeout:8.f handler:nil];
    
}

- (void)testCancelleable1
{
    OCMStub([self.commonSourceMock plugins]).andReturn(@[]);
    OCMStub([self.commonSourceMock methodname]).andReturn(@"get");
    XJRequestCancellable *cancellable = [self startRequest:self.commonSourceMock];
    XCTAssertTrue(cancellable.isCancelled,@"request is already cancel");
}

- (void)testCancelleable2
{
    OCMStub([self.commonSourceMock methodname]).andReturn(@"delay/10");
    OCMStub([self.commonSourceMock plugins]).andReturn(@[self.pluginMock]);

    XCTestExpectation *expectation = [self expectationWithDescription:@"test Async requset Cancelleable"];

    XJRequestCancellable *cancellable = [self.provider requestWithSource:self.commonSourceMock from:self
                                                                 success:^(XJURLResponse *response) {
                                                                     XCTAssertNil(response,@"----request should be failure---");
                                                                     [expectation fulfill];
                                                                 } failure:^(NSError *error) {
                                                                     XCTAssertEqual(error.code, NSURLErrorCancelled,@"error code should be NSURLErrorCancelled");
                                                                     [expectation fulfill];
                                                                 }];;

    [cancellable cancel];
    
    [self waitForExpectationsWithTimeout:8.f handler:nil];
    
    OCMVerify([self.pluginMock beforeApiFailureWithError:[OCMArg any]]);
    OCMVerify([self.pluginMock afterApiFailureWithError:[OCMArg any] caller:[OCMArg any]]);
}

- (NSDictionary *)mock_willSendApiWithParams:(NSDictionary *)params
{
    if(self.pluginTestOpen){
        NSMutableDictionary *muParams = [NSMutableDictionary dictionaryWithDictionary:params];
        [muParams setObject:@"testplugin" forKey:@"testplugin"];
        return [muParams copy];
    }
    return params;
}

- (NSURLRequest *)mock_willSendApiWithRequest:(NSURLRequest *)request
{
    if (self.pluginTestOpen){
        NSMutableURLRequest *muRequest = [request mutableCopy];
        muRequest.allHTTPHeaderFields = @{@"testplugin":@"testplugin"};
        return [muRequest copy];
    }
    return request;
}

- (void)mock_afterSendApiWithParams:(NSDictionary *)params caller:(id)caller
{
    XCTAssertEqualObjects(caller, self,@"caller should be equal to self");
}

- (XJRequestCancellable *)startRequest:(id <XJRequestProviderCommonSource>)source {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"test Async requset"];
    
    XJRequestCancellable *cancellable = [self.provider requestWithSource:source from:self
                             success:^(XJURLResponse *response) {
        NSLog(@"-----%@-----",response.content);
        XCTAssertNotNil(response.request,@"----success request couldn't be nil---");
        [expectation fulfill];
    } failure:^(NSError *error) {
        XCTAssertNil(error,@"----request should be success---");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.f handler:nil];
    return cancellable;
}


@end
