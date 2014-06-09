//
//  JDMasterViewController.h
//  JDKaLa
//
//  Created by zhangminglei on 3/27/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JDMainViewController;
@class JDUserLoginView;
@class ClientAgent;
@class MediaProxy;

@interface JDMasterViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    ClientAgent *clientAgent_resgist;
    MediaProxy  *mediaProxy;
    NSTimer     *prereadTimer;
    NSString    *curPrereadVideoUrl;
}

@property (assign, nonatomic) JDMainViewController *mainViewController_main;
@property (assign, nonatomic) BOOL bool_isOpen;
@property (retain, nonatomic) NSIndexPath *selectIndex;
//@property (assign, nonatomic) NSInteger selectIndex;

@property (retain, nonatomic) UITableView *table_master;
@property (assign, nonatomic) BOOL bool_firstConfigure;
@property (retain, nonatomic) NSMutableArray *array_childList;
@property (assign, nonatomic) UIView *view_user;

@property (assign, nonatomic) JDUserLoginView *userLogin;

@property (retain, nonatomic) UIImageView *imageView_bar_one;
@property (retain, nonatomic) UIImageView *imageView_bar_two;
@property (retain, nonatomic) UIImageView *imageView_bar_three;
@property (retain, nonatomic) UIImageView *imageView_bar_four;

@property (assign, nonatomic) UIImageView *imageView_portrait;

@property (assign, nonatomic) NSInteger imageIndex;

@property (assign, nonatomic) UINavigationController *navigationController_return;

@property (retain, nonatomic) NSMutableArray *array_alreadySong;

/**
 昵称
 **/
@property (assign, nonatomic) UILabel *label_nickName;

+ (JDMasterViewController *)sharedController;

/**
 验证token有效性
 **/
- (void)checkTokenValue;
/**
 刷新点击了的图标
 **/
- (void)reloadViewWhenNext;

/**
 刷新头像
 **/
- (void)reloadImageViewPortrait;

/**
 刷新昵称
 **/
- (void)reloadTextNickName;

/**
 退出登陆,刷新界面
 **/
- (void)loginOutReloadView;

/**
 启动预读
 **/
- (void)startPreread;

/**
 停止预读
 **/
- (void)stopPreread;




@end
