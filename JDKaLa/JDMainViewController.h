//
//  JDMainViewController.h
//  JDKaLa
//
//  Created by zhangminglei on 3/27/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDAlreadySongView.h"

@interface JDMainViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate, UIWebViewDelegate>
{
    UILabel *label_total;
    UIWebView *webView_theme;
}

@property (assign, nonatomic) BOOL bool_extension;
@property (assign, nonatomic) BOOL bool_already;
@property (assign, nonatomic) BOOL bool_oneTime;

@property (assign, nonatomic) UINavigationController *navigationController_return;

- (void)didCLickButton_noSong;

@end
