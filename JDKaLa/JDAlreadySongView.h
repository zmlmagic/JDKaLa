//
//  JDAlreadySongView.h
//  JDKaLa
//
//  Created by zhangminglei on 5/22/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaProxy.h"
#import "JTTableViewGestureRecognizer.h"

@class SDSongs;
@class JDCircleSlider;
@class JDMoviePlayerViewController;

@interface JDAlreadySongView : UIView<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,JTTableViewGestureMoveRowDelegate>

@property (retain, nonatomic) NSMutableArray *array_alreadySong;
@property (retain, nonatomic) NSMutableArray *array_historySong;
@property (retain, nonatomic) SDSongs *song_current;
@property (assign, nonatomic) BOOL bool_kind;
@property (retain, nonatomic) NSIndexPath *scrollIndex;
@property (assign, nonatomic) BOOL bool_currentAlready;

//@property (retain, nonatomic) UITableViewCell *cell_cache;
//@property (assign, nonatomic) UIButton *button_cache;
@property (retain, nonatomic) JDCircleSlider *cacheProgressSlider;
@property (assign, nonatomic) MediaProxy *mediaCacher;

//@property (nonatomic, retain) NSMutableArray *rows;
@property (nonatomic, assign) JTTableViewGestureRecognizer *tableViewRecognizer;
@property (nonatomic, retain) id grabbedObject;

@property (assign, nonatomic) JDMoviePlayerViewController *moviePlayer;
@property (assign, nonatomic) UINavigationController *navigationController_return;

- (id)initWithMoviePlayer:(JDMoviePlayerViewController *)movePlayer;
- (id)initWithFrameK:(CGRect)frame;
- (void)reloadTableView;
- (void)reloadTableViewWhenCacheSong;
- (void)tableScrollToPosition;
- (void)configureView_table;

@end
