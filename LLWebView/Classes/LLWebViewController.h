//
//  LLWebViewController.h
//  LLWebView
//
//  Created by 骆亮 on 2019/12/19.
//

#import <UIKit/UIKit.h>
#import "LLWebView.h"

@interface LLWebViewController : UIViewController

@property (nonatomic, copy) NSString* urlString;

/// 加载网页地址
-(void)loadURLString:(NSString*)urlString;

/// 加载本地 HTML
-(void)loadHTML:(NSString*)html;

/// 添加交互方法
/// @param method 方法名
/// @param handler 触发方法后的回调
-(void)addJSMethod:(NSString*)method handler:(void (^)(NSDictionary* param))handler;

@end

