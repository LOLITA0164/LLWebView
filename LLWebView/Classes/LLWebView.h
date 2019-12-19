//
//  LLWebView.h
//  LLWebView_Example
//
//  Created by 骆亮 on 2019/12/19.
//  Copyright © 2019 LOLITA0164. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@protocol LLWebViewProtocol;
@interface LLWebView : UIView

@property (nonatomic, strong) WKWebView* wk;
@property (nonatomic, weak) id <LLWebViewProtocol> delegate;

/// 加载 URL
-(void)loadURL:(NSURL*)url;

/// 加载本地 HTML
-(void)loadHTML:(NSString*)html;

/// 重新加载
-(void)reload;

/// 清除缓存
-(void)clearCache;

/// 执行某种 JS
-(void)evaluateJavaScript:(NSString*)promptCode completionHandler:(void (^)(id, NSError * error))completionHandler;

/// 添加交互方法
/// @param method 方法名
/// @param handler 触发方法后的回调
-(void)addJSMethod:(NSString*)method handler:(void (^)(id message))handler;

@end



@protocol LLWebViewProtocol <NSObject>
@optional
/// 这里做一些拦截操作
-(void)LLWebView:(LLWebView*)view wkWebView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;

-(void)LLWebView:(LLWebView*)view didStartWKWebView:(WKWebView*)webView;
-(void)LLWebView:(LLWebView*)view didFinishWKWebView:(WKWebView*)webView;
-(void)LLWebView:(LLWebView*)view didFailWKWebView:(WKWebView*)webView;

/// 获取到网页的标题
-(void)LLWebView:(LLWebView*)view didGetTitle:(NSString*)title;
/// 超时提醒
-(void)LLWebView:(LLWebView*)view timeoutWKWebView:(WKWebView*)webView;

@end






/// 转换，消除 web 的强引用
@interface LLWeakScriptMessageDelegate : NSObject <WKScriptMessageHandler>
@property (nonatomic, weak) id <WKScriptMessageHandler> delegate;
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)delegate;
@end
