//
//  AccountMasterViewController.h
//  JDKaLa
//
//  Created by 韩 抗 on 13-4-15.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarqueeLabel.h"

@class ClientAgent;

@interface AccountMasterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *tableCellPix;
    NSArray *tableCellActivePix;
    int     curMenuIdx;
}
@property (assign, nonatomic) BOOL bool_isOpen;
@property (retain, nonatomic) UITableView *table_master;
@property (assign, nonatomic) BOOL bool_firstConfigure;
@property (retain, nonatomic) UILabel *label_KCoin;
@property (retain, nonatomic) NSMutableArray *array_data_record;

@property (assign, nonatomic) UILabel *label_nickName;
@property (assign, nonatomic) UIImageView *imageView_portrait;

@property (assign, nonatomic) UIButton *button_before;
@property (assign, nonatomic) UIButton *button_first;
@property (assign, nonatomic) NSTimer *timer_check;
@property (assign, nonatomic) ClientAgent *agent;

@property (assign, nonatomic) MarqueeLabel *label_state;
@property (assign, nonatomic) UIImageView *imageView_vip;

+ (AccountMasterViewController *)sharedController;

/**
 刷新K余额
 **/
- (void)reloadPortrait;
- (void)reloadNickName;

/**
 刷新欢唱卡状态
 **/
- (void)reloadState;

/**
 刷新点击了的图标
 **/
- (void)checkRechargeResult;

- (void)stopTimerCheck;

/**
 刷新按钮
 **/
- (void)reloadButtonIndex;

/**
 上传头像
 **/
- (void)upLoadPortraitInBackground:(NSString *)fileName;

@end
