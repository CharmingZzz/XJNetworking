//
//  XJViewController.m
//  XJNetworking
//
//  Created by m17600026862@163.com on 04/09/2018.
//  Copyright (c) 2018 m17600026862@163.com. All rights reserved.
//

#import "XJViewController.h"

#import "XJNetworking.h"
#import "HomeApi.h"

@interface XJViewController ()

@end

@implementation XJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[[HomeApi alloc]init].homeApiProvider requestWithSuccess:^(XJURLResponse *response) {
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
