//
//  JDMyFavoriteView.h
//  JDKaLa
//
//  Created by zhangminglei on 6/8/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDSongs;

@interface JDMyFavoriteView : UIView<UITableViewDataSource,UITableViewDelegate>

@property (retain, nonatomic) NSMutableArray *array_data;
@property (assign, nonatomic) BOOL bool_buySong;
@property (retain, nonatomic) SDSongs *song_buy;
@property (retain, nonatomic) UITableViewCell *selectCell;
@property (assign, nonatomic) BOOL bool_local;
@property (assign, nonatomic) NSIndexPath *delectCellId;

@property (assign, nonatomic) UINavigationController *navigationController_return;

@end
