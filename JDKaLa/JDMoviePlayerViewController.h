//
//  JDMoviePlayerViewController.h
//  JDKaLa
//
//  Created by 张明磊 on 10/11/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDSongs;
@class JDMixerController;
@class AVAudioPlayer;
@class MPMoviePlayerController;
@class MediaProxy;
@class JDAlreadySongView;
@class AVAudioRecorder;
@class SDRecordSound;
@class MBProgressHUD;
@class JDSearchTableView;

@interface JDMoviePlayerViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate>

/**视频播放器**/
@property (assign, nonatomic) MPMoviePlayerController *moviePlayer_main;
/**静音音轨**/
@property (assign, nonatomic) AVAudioPlayer *silentPlayer;
/**有原唱音轨**/
@property (assign, nonatomic) AVAudioPlayer *originalPlayer;
/**录音器**/
@property (assign, nonatomic) AVAudioRecorder *recorder;
/**混音控制器**/
@property (assign, nonatomic) JDMixerController *mixController;
/**代理器**/
@property (assign, nonatomic) MediaProxy  *mediaProxy;
/**广告组**/
@property (retain, nonatomic) NSMutableArray *array_advList;
/**视频组**/
@property (retain, nonatomic) NSMutableArray *array_playList;
/**音频组**/
@property (retain, nonatomic) NSMutableArray *array_audioList;


/**标示播放或停止**/
@property (assign, nonatomic) BOOL bool_playOrStop;
/**原伴唱切换标示**/
@property (assign, nonatomic) BOOL bool_silentOrOriginal;
/**判断是否录音**/
@property (assign, nonatomic) BOOL bool_recordOrStop;
/**判断歌曲是否在播放列表**/
@property (assign, nonatomic) BOOL bool_isHistoryOrSearchSong;
/**广告标示**/
@property (assign, nonatomic) BOOL bool_playingAdvertise;
/**缓存标示**/
@property (assign, nonatomic) BOOL bool_prebufferForPlay;
/**跳转标示**/
@property (assign, nonatomic) BOOL bool_isSeeking;
/**是否点击返回按钮**/
@property (assign, nonatomic) BOOL bool_didClickBack;
/**是否处于K歌状态**/
@property (assign, nonatomic) BOOL bool_isK;
/**是否有等待提示**/
@property (assign, nonatomic) BOOL bool_isHUD;
/**是否正在播放**/
@property (assign, nonatomic) BOOL bool_moviePlay;
/**是否有混响界面**/
@property (assign, nonatomic) BOOL bool_mixViewHave;
/**是否存在点歌列表**/
@property (assign, nonatomic) BOOL bool_isAlreadyShow;
/**拖动进度条**/
@property (assign, nonatomic) BOOL bool_isDragging;
/**管理触屏**/
@property (assign, nonatomic) BOOL bool_touch;
/**搜索管理**/
@property (assign, nonatomic) BOOL bool_isSearch;
/**是否等待播放**/
@property (assign, nonatomic) BOOL bool_waitForPlay;


/**同步定时器**/
@property (assign, nonatomic) NSTimer *timer_syncAVTimer;
/**K歌界面**/
@property (assign, nonatomic) UIView *view_K;
/**点歌列表**/
@property (assign, nonatomic) JDAlreadySongView *view_alreadySong;
/**HUD指示**/
@property (retain, nonatomic) MBProgressHUD *HUD;
/**title界面**/
@property (assign, nonatomic) UIView *view_playerTitle;
/**控制器界面**/
@property (assign, nonatomic) UIView *customControlStyle;
/**歌曲搜索界面**/
@property (retain, nonatomic) JDSearchTableView *view_searchView;


/**遮挡播控界面**/
@property (assign, nonatomic) UIButton *button_advback;
/**歌曲对象模型**/
@property (retain, nonatomic) SDSongs *song_nowPlay;
/**录音对象模型**/
@property (retain, nonatomic) SDRecordSound *recordSound;
/**混音强度标示**/
@property (assign, nonatomic) NSInteger integer_mixTag;
/**当前广告视频的序号**/
@property (assign, nonatomic) NSInteger integer_curAdvIndex;
/**当前播放视频的序号**/
@property (assign, nonatomic) NSInteger integer_curPlayIndex;
/**当前缓冲视频序号**/
@property (assign, nonatomic) NSInteger integer_curPreadIndex;
/**两条音轨下载进度**/
@property (assign, nonatomic) float floatprogress_one;
@property (assign, nonatomic) float floatprogress_two;



/**播放按钮**/
@property (assign, nonatomic) UIButton *button_play;
/**K歌按钮**/
@property (assign, nonatomic) UIButton *button_soundChange;
/**标题**/
@property (assign, nonatomic) UILabel *label_moveTitle;
/**起始时间**/
@property (assign, nonatomic) UILabel *startLable;
/**结束时间**/
@property (assign, nonatomic) UILabel *endLable;
/**视频进度控制器**/
@property (assign, nonatomic) UISlider *slider_progress;
/**音量调节器**/
@property (assign, nonatomic) UISlider *slider_sound;
/**视频进度条**/
@property (assign, nonatomic) UIProgressView *progress_buffer;
/**三角箭头**/
@property (assign, nonatomic) UIImageView *imageView_hlight;
/**更新进度时间**/
@property (assign, nonatomic) NSTimer *timer_updateTimer;



/**压栈器**/
@property (assign, nonatomic) UINavigationController *navigationController_return;
/**
 开始播放
 **/
- (void)playBegin;

/**
 初始化
 **/
- (id)initWithSong:(SDSongs *)song;

/**
 切歌
 **/
- (void)changePlaySong:(SDSongs *)song;

/**
 排序
 **/
- (void)songTabelMoveReload;

/**
 展示隐藏
 **/
- (void)showMovieController;
@end
