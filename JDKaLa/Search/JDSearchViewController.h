//
//  JDSearchViewController.h
//  JDKaLa
//
//  Created by 韩 抗 on 13-9-27.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDSongs.h"
#import "ClientAgent.h"
#import "JDSongPayView.h"

@interface JDSearchViewController : UIViewController<UITextFieldDelegate, UITableViewDelegate,UITableViewDataSource,JDSongPayViewDelegate>
{
    UILabel *label_total;
    NSMutableArray  *singerIconNames;
    NSMutableArray  *singerResult;
    NSMutableArray  *songResult;
}

@property (retain, nonatomic) UITableView *resultTable;
@property (retain, nonatomic) NSString *keyword;
@property (retain, nonatomic) UITextField *keywordInput;
@property (assign, nonatomic) BOOL bool_already;
@property (retain, nonatomic) SDSongs *song_buy;
@property (retain, nonatomic) UITableViewCell *selectCell;
@property (retain, nonatomic) ClientAgent *agent;

@property (assign, nonatomic) UINavigationController *navigationController_return;

///判断是收藏还是购买点播
///1-点播 2-收藏 3-购买
@property (assign, nonatomic) NSInteger integer_tag;

@property (retain, nonatomic) UIButton *button_select;
@property (assign, nonatomic) UILabel *label_KB;
@property (assign, nonatomic) UIView *view_pay;

- (id)initWithKeyword:(NSString*)keyword;
@end
