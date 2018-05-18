//
//  XJRACRequestTests.m
//  XJNetworking_Tests
//
//  Created by xujie on 2018/5/18.
//  Copyright © 2018年 m17600026862@163.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "XJNetworking.h"
#import "XJRequestProvider+RAC.h"

#define XCExpectation(_ref)  XCTestExpectation *expectation = [self expectationWithDescription:@"test Async requset"];\
                            _ref\
                            [self waitForExpectationsWithTimeout:15.f handler:nil];

@interface XJRACRequestTests : XCTestCase

@property (nonatomic,strong)XJRequestProvider *provider;
@property (nonatomic,strong)NSMutableArray *commonSourceMocks;
@property (nonatomic,strong)RACCommand *requestCommand;
@property (nonatomic,strong)NSArray *methodNames;

@end

@implementation XJRACRequestTests

- (void)setUp {
    [super setUp];
    
    self.provider = [XJRequestProvider defaultProvider];
    
    // mock XJRequestProviderCommonSource
    self.commonSourceMocks = [NSMutableArray array];
    self.methodNames = @[@"delay/5",@"delay/2",@"uuid"];
    
    [_methodNames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id apiMock = OCMProtocolMock(@protocol(XJRequestProviderCommonSource));
        OCMStub([apiMock baseURL]).andReturn(@"https://httpbin.org");
        OCMStub([apiMock methodname]).andReturn(obj);
        OCMStub([apiMock parameters]).andReturn(@{});
        OCMStub([apiMock plugins]).andReturn(@[]);
        OCMStub([apiMock taskType]).andReturn(XJRequestProviderTaskTypeRequest);
        OCMStub([apiMock requestSerialization]).andReturn([AFHTTPRequestSerializer serializer]);
        OCMStub([apiMock responseSerialization]).andReturn([AFJSONRequestSerializer serializer]);
        [self.commonSourceMocks addObject:apiMock];
    }];
}

- (void)tearDown {
    [super tearDown];
    
    self.commonSourceMocks = nil;
    self.provider = nil;
    self.requestCommand = nil;
    self.methodNames = nil;
}

- (void)testRACRequest
{
    XCExpectation(
        self.requestCommand = [self.provider rac_requestWithSource:self.commonSourceMocks.firstObject from:self];
        [[self.requestCommand execute:nil] subscribeNext:^(id  _Nullable x) {
            XCTAssertTrue([x isKindOfClass:[XJURLResponse class]],@"call back type must be XJURLResponse type");
            [expectation fulfill];
        }];
    )
}

- (void)testSequenceRequest
{
    XCExpectation(
        self.requestCommand = [self.provider rac_sequenceRequestWithSources:self.commonSourceMocks from:self];
        
        __block NSInteger i = 0;
        [[self.requestCommand execute:nil] subscribeNext:^(XJURLResponse *  _Nullable x) {
            XCTAssertTrue([x.request.URL.path containsString:self.methodNames[i]],@"Callbacks must be in order");
            if(++i == self.methodNames.count){
                [expectation fulfill];
            }
        }];
    )
}

- (void)testUnifiedRequest
{
    XCExpectation(
        self.requestCommand = [self.provider rac_zipResponseRequestWithSources:self.commonSourceMocks from:self];
        [[self.requestCommand execute:nil] subscribeNext:^(id  _Nullable x) {
            XCTAssertTrue([x isKindOfClass:[RACTuple class]],@"call back type must be RACTuple type");
            RACTuple *tuple = x;
            [self.methodNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                XJURLResponse *response = tuple[idx];
                XCTAssertTrue([response.request.URL.path containsString:obj],@"");
            }];
            [expectation fulfill];
        }];
    )
}

- (NSURLRequest *)mock_willSendApiWithRequest:(NSURLRequest *)request
{
    return request;
}

@end
