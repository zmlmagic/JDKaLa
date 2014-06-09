//
//  JDThereSongViewController.h
//  JDKaLa
//
//  Created by zhangminglei on 9/6/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDSongs.h"
#import "JDMainViewController.h"
#import "JDSongPayView.h"

@class ClientAgent;
@class JDModel_theme;

@interface JDThereSongViewController : UIViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,JDSongPayViewDelegate>
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

@property (assign, nonatomic) UIView *view_title;
@property (assign, nonatomic) UITableView *table_song;
@property (assign, nonatomic) BOOL bool_up;

@property (retain, nonatomic) JDModel_theme *model_theme;

@property (assign, nonatomic) NSInteger integer_tag;
@property (retain, nonatomic) UIButton *button_select;

@property (assign, nonatomic) UINavigationController *navigationController_return;

@property (assign, nonatomic) JDMainViewController *main;

- (id)initWithTitleFileName:(NSString *)_string;
- (void)configureTable_data;

@end
