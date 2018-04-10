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

@interface XJHomeViewController ()

@property (nonatomic,strong)XJRequestProvider *homeApiProvider;

@end

@implementation XJHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
    [self.homeApiProvider requestWithSource:[[HomeApi alloc]init] from:self success:^(XJURLResponse *response) {
        
    } failure:^(NSError *error) {
        
    }];
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
