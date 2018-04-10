//
//  XJHomeViewController.m
//  XJNetworking_Example
//
//  Created by xujie on 2018/4/10.
//  Copyright © 2018年 m17600026862@163.com. All rights reserved.
//

#import "XJHomeViewController.h"

#import "XJNetworking.h"
#import "HomeApi.h"

@interface XJHomeViewController ()<XJRequestProviderSourcePlugin>

@property (nonatomic,strong)XJRequestProvider *homeApiProvider;

@end

@implementation XJHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
    HomeApi *api = [[HomeApi alloc]init];
    api.plugin = self;
    
    [self.homeApiProvider requestWithSource:api from:self success:^(XJURLResponse *response) {
        
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

- (NSURLRequest *)willSendApiWithRequest:(__kindof NSURLRequest *)request
{
    NSLog(@"----%s---",__func__);
    return request;
}

- (void)afterSendApiWithParams:(NSDictionary *)params caller:(id)caller
{
    NSLog(@"----%s---",__func__);
}

- (BOOL)beforeApiFailureWithError:(NSError *)error caller:(id)caller
{
    NSLog(@"----%s---%@",__func__,caller);
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

- (void)dealloc
{
    NSLog(@"----dealloc---");
}


@end
