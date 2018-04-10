//
//  XJViewController.m
//  XJNetworking
//
//  Created by m17600026862@163.com on 04/09/2018.
//  Copyright (c) 2018 m17600026862@163.com. All rights reserved.
//

#import "XJViewController.h"
#import "XJHomeViewController.h"

@interface XJViewController ()

@end

@implementation XJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self presentViewController:[XJHomeViewController new] animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
