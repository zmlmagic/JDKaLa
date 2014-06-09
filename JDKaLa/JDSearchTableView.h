//
//  JDSearchTableView.h
//  JDKaLa
//
//  Created by zhangminglei on 5/28/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JDMoviePlayerViewController;

@interface JDSearchTableView : UIView<UITableViewDataSource,UITableViewDelegate>

@property (retain, nonatomic) NSMutableArray *array_search_singer;
@property (retain, nonatomic) NSMutableArray *array_search_singer_song;
@property (retain, nonatomic) NSMutableArray *array_search_song;
@property (assign, nonatomic) BOOL bool_isOpen;
@property (retain, nonatomic) NSIndexPath *selectIndex;
@property (assign, nonatomic) UITableView *table_search;
//@property (assign, nonatomic) UIView *view_only;
@property (assign, nonatomic) JDMoviePlayerViewController *moviePlayer;

@property (assign, nonatomic) float float_height;

- (void)searchSongWithString:(NSString*)tag;

@end
