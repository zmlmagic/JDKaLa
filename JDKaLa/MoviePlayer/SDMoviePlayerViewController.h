//
//  MoviePlayerViewController.h
//  JuKaLa
//
//  Created by 张 明磊 on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPMoviePlayerController.h>

#import "SDRecordSound.h"
#import "SDSongs.h"
#import "MediaProxy.h"
#import "JDAlreadySongView.h"
#import "JDSearchTableView.h"

@class MPMoviePlayerController;
@class MBProgressHUD;
@class JDMixerController;


@interface SDMoviePlayerViewController : UIViewController<UIAlertViewDelegate,UITextFieldDelegate>
{
    AVAudioPlayer*              withOutAccompanyPlayer;
    AVAudioPlayer*              accompanyPlayer;
    AVAudioPlayer*              recordPlayer;
    
    MPMoviePlayerController*    moviePlayerController;
    BOOL                        signForPlayOrStop;
    BOOL                        signForRecordOrStop;
    BOOL                        signForAccompanyOrOriginal;
    UISlider                    *progressSlider;
    UILabel                     *startLable;
    UILabel                     *endLable;
    NSTimer                     *updateTimer;
    UITextField                 *textFirld_inputRecordName;
    
    BOOL        prebufferForPlay;
    BOOL        playingAdvertise;
    BOOL        waitForPlay;        //是否等待广告播完后开启正片
    int         curPlayIdx;
    int         curPreadIdx;
    int         curAdvIdx;          //当前广告视频的序号
    MediaProxy  *mediaProxy;
    MediaDownloader         *AdvertiseDownloader;
    NSTimer                 *syncAVTimer;
    NSMutableArray     *playlist;
    NSMutableArray     *audioList;
    NSMutableArray      *advList;       //广告视频列表
    UILabel *label_movieTitle;
    UIButton *button_play;
}

@property (retain, nonatomic) SDSongs *song_nowPlay;



@property (retain, nonatomic) MPMoviePlayerController *moviePlayerController;

@property (assign, nonatomic) AVAudioPlayer *withOutAccompanyPlayer;
@property (assign, nonatomic) AVAudioPlayer *accompanyPlayer;

@property (retain, nonatomic) UIView                  *customControlStyle;
@property (retain, nonatomic) UISlider                *progressSlider;
@property (retain, nonatomic) UIProgressView          *bufferProgress;
@property (retain, nonatomic) SDRecordSound           *recordSound;
@property (retain, nonatomic) UIView *view_playerTitle;
@property (retain, nonatomic) SDSongs *song;
@property (retain, nonatomic) UISlider *slider_sound;
@property (assign, nonatomic) BOOL bool_moviePlay;
@property (retain, nonatomic) UIView *view_K;
@property (assign, nonatomic) BOOL isSeeking;
@property (assign, nonatomic) BOOL bool_isDragging;
@property (assign, nonatomic) BOOL bool_isK;
@property (assign, nonatomic) BOOL bool_isSearch;
@property (assign, nonatomic) UILabel *label_change_K;
@property (retain, nonatomic) JDAlreadySongView *view_alreadySong;
@property (retain, nonatomic) JDSearchTableView *view_searchView;
@property (retain, nonatomic) MBProgressHUD *HUD;
@property (assign, nonatomic) BOOL bool_isHUD;
@property (assign, nonatomic) BOOL bool_isAlreadyShow;
@property (assign, nonatomic) UIImageView *imageView_Hlight;
@property (retain, nonatomic) AVAudioRecorder *recorder;
@property (retain, nonatomic) NSURL *recordedTmpFile;
@property (assign, nonatomic) BOOL bool_recordPlay;
@property (assign, nonatomic) BOOL bool_isAbjust;     ///判断是否需要进行校准
@property (assign, nonatomic) BOOL bool_isTure;       ///判断获取的视频进度是不是真实进度
@property (assign, nonatomic) float last_time;

@property (assign, nonatomic) BOOL bool_audioMix;
@property (retain, nonatomic) SDSongs *song_next;
@property (assign, nonatomic) BOOL bool_isHistoryOrSearchSong; ///判断歌曲是否在播放列表
@property (assign, nonatomic) BOOL bool_touch;///管理触屏

@property (assign, nonatomic) JDMixerController *mixController;
@property (assign, nonatomic) BOOL bool_currentAlready;
@property (assign, nonatomic) BOOL bool_mixViewHave;
@property (assign, nonatomic) NSInteger integer_mixTag;

@property (assign, nonatomic) UIButton *button_k;

@property (assign, nonatomic) float floatprogress_one;
@property (assign, nonatomic) float floatprogress_two;

@property (assign, nonatomic) BOOL bool_didClickBack;

@property (assign, nonatomic) UINavigationController *navigationController_return;

- (void)playMovieWithLink:(NSString *)link;
+ (SDMoviePlayerViewController *)sharedController;
- (void)moviePlayerChangeState;
//- (void)stopProxy;
- (void)showMovieController;

///调整顺序后,调整缓存顺序
- (void)songTabelMoveReload;

@end
