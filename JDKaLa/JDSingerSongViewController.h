//
//  JDSingerSongViewController.h
//  JDKaLa
//
//  Created by zhangminglei on 4/10/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDSongs.h"
#import "JDSongPayView.h"

@class ClientAgent;

@interface JDSingerSongViewController : UIViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,JDSongPayViewDelegate>
{
    UILabel *label_total;
}

@property (retain, nonatomic) NSMutableArray *array_data;
@property (assign, nonatomic) BOOL bool_buySong;
@property (retain, nonatomic) SDSongs *song_buy;
@property (retain, nonatomic) UITableViewCell *selectCell;
@property (assign, nonatomic) BOOL bool_local;
@property (retain, nonatomic) ClientAgent *agent;
@property (assign, nonatomic) BOOL bool_already;

@property (retain, nonatomic) UIButton *button_select;

@property (assign, nonatomic) UIView *view_pay;

@property (assign, nonatomic) UINavigationController *navigationController_return;

///判断是收藏还是购买点播
///1-点播 2-收藏 3-购买
@property (assign, nonatomic) NSInteger integer_tag;

- (id)initWithTitleString:(NSString *)_string;
- (void)configureTable_data;

@end
