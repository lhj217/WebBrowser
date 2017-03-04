//
//  BrowserBottomToolBar.m
//  WebBrowser
//
//  Created by 钟武 on 2016/11/6.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "BrowserBottomToolBar.h"

@interface BrowserBottomToolBar () 

@property (nonatomic, weak) UIBarButtonItem *refreshOrStopItem;
@property (nonatomic, weak) UIBarButtonItem *backItem;
@property (nonatomic, weak) UIBarButtonItem *forwardItem;
@property (nonatomic, assign) BOOL isRefresh;

@end

@implementation BrowserBottomToolBar

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initializeView];
        [[DelegateManager sharedInstance] registerDelegate:self forKey:DelegateManagerWebView];
        [Notifier addObserver:self selector:@selector(handletabSwitch:) name:kWebTabSwitch object:nil];
    }
    
    return self;
}

- (void)initializeView{
    self.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *backItem = [self createBottomToolBarButtonWithImage:TOOLBAR_BUTTON_BACK_STRING tag:BottomToolBarBackButtonTag];
    self.backItem = backItem;
    
    UIBarButtonItem *forwardItem = [self createBottomToolBarButtonWithImage:TOOLBAR_BUTTON_FORWARD_STRING tag:BottomToolBarForwardButtonTag];
    self.forwardItem = forwardItem;
    
    UIBarButtonItem *refreshOrStopItem = [self createBottomToolBarButtonWithImage:TOOLBAR_BUTTON_STOP_STRING tag:BottomToolBarRefreshOrStopButtonTag];
    self.isRefresh = NO;
    refreshOrStopItem.width = 30;
    self.refreshOrStopItem = refreshOrStopItem;
    
    UIBarButtonItem *multiWindowItem = [self createBottomToolBarButtonWithImage:TOOLBAR_BUTTON_MULTIWINDOW_STRING tag:BottomToolBarMultiWindowButtonTag];
    
    UIBarButtonItem *settingItem = [self createBottomToolBarButtonWithImage:TOOLBAR_BUTTON_MORE_STRING tag:BottomToolBarMoreButtonTag];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    flexibleItem.tag = BottomToolBarFlexibleButtonTag;
    
    [self setItems:@[backItem,flexibleItem,forwardItem,flexibleItem,refreshOrStopItem,flexibleItem,multiWindowItem,flexibleItem,settingItem] animated:YES];
    
}

- (UIBarButtonItem *)createBottomToolBarButtonWithImage:(NSString *)imageName tag:(NSInteger)tag{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(handleBottomToolBarButtonClicked:)];
    item.tag = tag;
    
    return item;
}

- (void)handleBottomToolBarButtonClicked:(UIBarButtonItem *)item{
    BottomToolBarButtonTag tag;
    
    if (item.tag == BottomToolBarRefreshOrStopButtonTag)
    {
        tag = self.isRefresh ? BottomToolBarRefreshButtonTag : BottomToolBarStopButtonTag;
        [self setToolBarButtonRefreshOrStop:!_isRefresh];
    }
    else
        tag = item.tag;
    
    if ([self.browserButtonDelegate respondsToSelector:@selector(browserBottomToolBarButtonClickedWithTag:)]) {
        [self.browserButtonDelegate browserBottomToolBarButtonClickedWithTag:tag];
    }
}

- (void)setToolBarButtonRefreshOrStop:(BOOL)isRefresh{
    NSString *imageName = isRefresh ? TOOLBAR_BUTTON_REFRESH_STRING : TOOLBAR_BUTTON_STOP_STRING;
    self.isRefresh = isRefresh;
    
    self.refreshOrStopItem.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

#pragma mark - WebViewDelegate

- (void)webViewForMainFrameDidFinishLoad:(BrowserWebView *)webView{
    [self setToolBarButtonRefreshOrStop:YES];
    
    [self.backItem setEnabled:[webView canGoBack]];
    [self.forwardItem setEnabled:[webView canGoForward]];
}

- (void)webViewForMainFrameDidCommitLoad:(BrowserWebView *)webView{
    [self setToolBarButtonRefreshOrStop:NO];
}

#pragma mark - kWebTabSwitch notification handler

- (void)handletabSwitch:(NSNotification *)notification{
    BrowserWebView *webView = [notification.userInfo objectForKey:@"webView"];
    if ([webView isKindOfClass:[BrowserWebView class]]) {
        [self.backItem setEnabled:[webView canGoBack]];
        [self.forwardItem setEnabled:[webView canGoForward]];
    }
}

#pragma mark - Dealloc

- (void)dealloc{
    [Notifier removeObserver:self name:kWebTabSwitch object:nil];
}

@end
