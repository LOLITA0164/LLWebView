//
//  LLViewController.m
//  LLWebView
//
//  Created by LOLITA0164 on 12/19/2019.
//  Copyright (c) 2019 LOLITA0164. All rights reserved.
//

#import "LLViewController.h"
#import <LLWebView/LLWebViewController.h>

@interface LLViewController ()
@property (nonatomic, strong) LLWebViewController* webCtrl;
@end

@implementation LLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webCtrl = [LLWebViewController new];
    [self addChildViewController:self.webCtrl];
    [self.view addSubview:self.webCtrl.view];

    NSString* path = [NSBundle.mainBundle pathForResource:@"JSTest" ofType:@"html"];
    NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.webCtrl loadHTML:content];
    
    // 添加交互的部分
    [self.webCtrl addJSMethod:@"copyWeiXinHao" handler:^(NSDictionary *param) {
        NSLog(@"%@",param);
    }];
    [self.webCtrl addJSMethod:@"goToWeiXinApp" handler:^(NSDictionary *param) {
        NSLog(@"跳转微信");
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
