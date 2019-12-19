//
//  LLWebViewController.m
//  LLWebView
//
//  Created by 骆亮 on 2019/12/19.
//

#import "LLWebViewController.h"

@interface LLWebViewController() <LLWebViewProtocol>
@property (nonatomic, strong) LLWebView* web;
@end

@implementation LLWebViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.web];
    if (self.urlString.length) {
        [self loadURLString:self.urlString];
    }
}


-(LLWebView *)web{
    if (_web==nil) {
        _web = [[LLWebView alloc] initWithFrame:self.view.bounds];
        _web.delegate = self;
    }
    return _web;
}


/// 加载网页地址
-(void)loadURLString:(NSString*)urlString{
    self.urlString = urlString;
    [self.web loadURL:[NSURL URLWithString:self.urlString]];
}

/// 加载本地 HTML
-(void)loadHTML:(NSString*)content{
    [self.web loadHTML:content];
}


/// 代理方法的回调
-(void)LLWebView:(LLWebView *)view didGetTitle:(NSString *)title{
    self.title = title.length ? title : @"";
}


/// 添加交互方法
-(void)addJSMethod:(NSString*)method handler:(void (^)(NSDictionary* param))handler{
    [self.web addJSMethod:method handler:handler];
}

@end
