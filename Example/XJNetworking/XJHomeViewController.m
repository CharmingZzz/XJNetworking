//
//  XJHomeViewController.m
//  XJNetworking_Example
//
//  Created by xujie on 2018/4/10.
//  Copyright © 2018年 m17600026862@163.com. All rights reserved.
//

#import "XJHomeViewController.h"

#import "HomeApi.h"

@interface XJHomeViewController ()<XJRequestProviderSourcePlugin>

@property (nonatomic,strong)XJRequestProvider *homeApiProvider;
@property (nonatomic,strong)HomeApi *homeApi;

@end

@implementation XJHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];

    
    [self.homeApiProvider requestWithSource:[[HomeApi alloc]init] from:self success:^(XJURLResponse *response) {
        NSLog(@"----%@---",response.content);
    } failure:^(NSError *error) {
        NSLog(@"----%@---",error.description);
    }];
}



- (void)request
{
    [self.homeApiProvider requestWithSource:self.homeApi from:self success:^(XJURLResponse *response) {
        NSLog(@"----%@---",response.content);
    } failure:^(NSError *error) {
        NSLog(@"----%@---",error.description);
    }];
}

#pragma mark - XJRequestProviderSourcePlugin

- (BOOL)shouldSendApiWithParams:(NSDictionary *)params caller:(id)caller
{
    NSLog(@"----%s---%@",__func__,caller);
    return YES;
}

- (NSDictionary *)willSendApiWithParams:(NSDictionary *)params
{
    NSLog(@"-----%@-----",params);
    return params;
}

- (NSURLRequest *)willSendApiWithRequest:(__kindof NSURLRequest *)request
{
    NSLog(@"----%s---",__func__);
    return [NSURLRequest new];
}

- (void)afterSendApiWithParams:(NSDictionary *)params caller:(id)caller
{
    NSLog(@"----%s---",__func__);
}

- (BOOL)beforeApiFailureWithError:(NSError *)error
{
    NSLog(@"----%s---",__func__);
    return YES;
}

- (void)afterApiFailureWithError:(NSError *)error caller:(id)caller
{
    NSLog(@"----%s---%@",__func__,caller);
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (XJRequestProvider *)homeApiProvider
{
    if(!_homeApiProvider){
        _homeApiProvider = [XJRequestProvider defaultProvider];
    }
    return _homeApiProvider;
}

- (HomeApi *)homeApi
{
    if(!_homeApi){
        _homeApi = [[HomeApi alloc]init];
        _homeApi.plugin = self;
    }
    return _homeApi;
}

- (void)dealloc
{
    NSLog(@"----dealloc---");
}


@end
