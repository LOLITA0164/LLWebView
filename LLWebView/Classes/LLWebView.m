//
//  LLWebView.m
//  LLWebView_Example
//
//  Created by 骆亮 on 2019/12/19.
//  Copyright © 2019 LOLITA0164. All rights reserved.
//

#import "LLWebView.h"
#import <Masonry/Masonry.h>
#import <Reachability/Reachability.h>

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self

@interface LLWebView() <WKNavigationDelegate,WKScriptMessageHandler>

@property (nonatomic, strong) UIProgressView* progress;
@property (nonatomic, copy) NSURL* url;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) LLWeakScriptMessageDelegate* weakJSDelegate;
@property (nonatomic, strong) NSMutableDictionary* jsDic; // 交互的回调字典

@end

@implementation LLWebView

-(instancetype)init{
    self = [self init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup{
    // 设置
    [self insertSubview:self.progress belowSubview:self.wk];
    // 添加一些监听事件
    [self.wk addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    [self.wk addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    // 应用状态信息
    Reachability* reach = [Reachability reachabilityForInternetConnection];
    [reach startNotifier];
    WS(ws);
    [NSNotificationCenter.defaultCenter addObserverForName:kReachabilityChangedNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        Reachability* reach = [note object];
        if ([reach isKindOfClass:Reachability.class]) {
            switch (reach.currentReachabilityStatus) {
                case NotReachable:
                    break;
                default:
                {
                    if (ws.url.absoluteString.length) {
                        [ws loadURL:ws.url];
                        [_timer invalidate];
                    }
                }
                    break;
            }
        }
    }];
    // 开始加载
    if (self.url.absoluteString.length) {
        [self.wk loadRequest:[NSURLRequest requestWithURL:self.url]];
    }
}


-(WKWebView *)wk{
    if (_wk==nil) {
        WKWebViewConfiguration* config = [WKWebViewConfiguration new];
        _wk = [[WKWebView alloc] initWithFrame:self.bounds configuration:config];
        _wk.navigationDelegate = self;
        _wk.opaque = NO;
        _wk.allowsBackForwardNavigationGestures = YES;
        _wk.scrollView.showsVerticalScrollIndicator = NO;
        _wk.scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_wk];
        [_wk mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return _wk;
}

-(UIProgressView *)progress{
    if (_progress==nil) {
        _progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        _progress.trackTintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        _progress.progressTintColor = [UIColor.greenColor colorWithAlphaComponent:0.9];
        [self addSubview:_progress];
        [_progress mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.equalTo(@(1));
        }];
    }
    return _progress;
}

-(NSTimer *)timer{
    if (_timer==nil) {
        _timer = [[NSTimer alloc] initWithFireDate:[NSDate distantFuture] interval:10 target:self selector:@selector(timeOutEvent) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
    return _timer;
}

/// 用于交互的
-(LLWeakScriptMessageDelegate *)weakJSDelegate{
    if (_weakJSDelegate==nil) {
        _weakJSDelegate = [[LLWeakScriptMessageDelegate alloc] initWithDelegate:self];
    }
    return _weakJSDelegate;
}

-(NSMutableDictionary *)jsDic{
    if (_jsDic==nil) {
        _jsDic = [NSMutableDictionary dictionary];
    }
    return _jsDic;
}

#pragma mark - 一些代理事件
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    if ([self.delegate respondsToSelector:@selector(LLWebView:wkWebView:decidePolicyForNavigationAction:decisionHandler:)]) {
        [self.delegate LLWebView:self wkWebView:self.wk decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }
    else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}
/// 开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    if ([self.delegate respondsToSelector:@selector(LLWebView:didStartWKWebView:)]) {
        [self.delegate LLWebView:self didStartWKWebView:self.wk];
    }
    [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

/// 获取到网页内容
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
//    NSLog(@"获取到内容");
}
/// 加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    if ([self.delegate respondsToSelector:@selector(LLWebView:didFinishWKWebView:)]) {
        [self.delegate LLWebView:self didFinishWKWebView:self.wk];
    }
    [self.timer invalidate];
}
/// 加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    if ([self.delegate respondsToSelector:@selector(LLWebView:didFailWKWebView:)]) {
        [self.delegate LLWebView:self didFailWKWebView:self.wk];
    }
    [self.timer invalidate];
}

/// JS 交互的回调
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([self.jsDic.allKeys containsObject:message.name]) {
        void (^handler)(id) = [self.jsDic objectForKey:message.name];
        if (handler) { handler(message.body); } // 将数据回调
    }
}

#pragma mark - kvo监听事件
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // 监听标题
    if ([keyPath isEqualToString:@"title"] && object == self.wk){
        if ([self.delegate respondsToSelector:@selector(LLWebView:didGetTitle:)]) {
            [self.delegate LLWebView:self didGetTitle:self.wk.title];
        }
    }
    
    // 监听进度
    else if ([keyPath isEqualToString:@"estimatedProgress"] && object == self.wk) {
        [self.progress setProgress:self.wk.estimatedProgress animated:YES];
        self.progress.hidden = self.wk.estimatedProgress==1 ? YES : NO;
    }
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


#pragma mark - 其他的一些事件
/// 加载 URL
-(void)loadURL:(NSURL*)url{
    if (url.absoluteString.length == 0) { return; }
    self.url = url;
    [self.wk loadRequest:[NSURLRequest requestWithURL:url]];
}

/// 将在本地 HTML
-(void)loadHTML:(NSString*)html{
    [self.wk loadHTMLString:html baseURL:nil];
}

/// 重新加载
-(void)reload{
    [self.wk reload];
}

/// 执行某种 JS
-(void)evaluateJavaScript:(NSString*)promptCode completionHandler:(void (^)(id, NSError *))completionHandler{
    if (promptCode.length == 0) { return; }
    [self.wk evaluateJavaScript:promptCode completionHandler:completionHandler];
}


/// 添加交互方法
/// @param method 方法名
/// @param hook 触发方法后的回调
-(void)addJSMethod:(NSString*)method handler:(void (^)(id message))handler{
    if (method.length == 0) { return; }
    // 添加交互方法
    [self.wk.configuration.userContentController addScriptMessageHandler:self.weakJSDelegate name:method];
    if (handler) { // 将交互的方法和回调都存储起来
        [self.jsDic setValue:handler forKey:method];
    }
}


/// 清除缓存
-(void)clearCache{
    if (@available(iOS 9, *)) {
        // 选择部分类型删除
        NSSet* websiteDataType = [NSSet setWithArray:@[
            WKWebsiteDataTypeDiskCache,
            WKWebsiteDataTypeMemoryCache,
            WKWebsiteDataTypeCookies,
            WKWebsiteDataTypeIndexedDBDatabases,
            WKWebsiteDataTypeWebSQLDatabases
        ]];
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:0];
        [WKWebsiteDataStore.defaultDataStore removeDataOfTypes:websiteDataType modifiedSince:date completionHandler:^{
            
        }];
    }
    else {
        // 找到 cookies 文件夹，清除所有
        NSString* libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        NSError *errors;
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
    }
}

/// 超时事件
-(void)timeOutEvent{
    [self.wk stopLoading];
    if ([self.delegate respondsToSelector:@selector(LLWebView:timeoutWKWebView:)]) {
        [self.delegate LLWebView:self timeoutWKWebView:self.wk];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"加载超时，是否重试？" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self reload];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
        UIViewController* ctrl = UIApplication.sharedApplication.windows[0].rootViewController;
        [ctrl presentViewController:alert animated:YES completion:nil];
    }
    [self.timer invalidate];
}



-(void)dealloc{
    [self.timer invalidate];
    self.timer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.wk removeObserver:self forKeyPath:@"title"];
    [self.wk removeObserver:self forKeyPath:@"estimatedProgress"];
}



@end







@implementation LLWeakScriptMessageDelegate
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)delegate{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
}
@end
