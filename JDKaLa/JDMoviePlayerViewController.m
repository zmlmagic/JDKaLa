//
//  JDMoviePlayerViewController.m
//  JDKaLa
//
//  Created by 张明磊 on 10/11/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDMoviePlayerViewController.h"
#import "UIUtils.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import "JDMixerController.h"
#import "MBProgressHUD.h"
#import "MediaProxyGlobal.h"
#import "MediaProxy.h"
#import "JDAlreadySongView.h"
#import "JDSqlDataBase.h"
#import "JDDataBaseRecordSound.h"
#import "JDSqlDataBaseSongHistory.h"
#import "SDRecordSound.h"
#import "NSString+NSString_TimeCategory.h"
#import "JDModel_userInfo.h"
#import "CustomAlertView.h"
#import "SKCustomNavigationBar.h"
#import "JDCircleSlider.h"
#import "JDSearchTableView.h"
#import "JDMasterViewController.h"

typedef enum
{
    SDMoviePlayerReturn                = 0 ,
    SDMoviePlayerPlay                      ,
    SDMoviePlayerNext                      ,
    SDMoviePlayerAgain                     ,
    SDMoviePlayerK                         ,
    SDMoviePlayerRecord                    ,
    SDMoviePlayerRepeat                    ,
    SDMoviePlayerFavourite                 ,
    SDMoviePlayerMix                       ,
    SDMoviePlayerQieHuan                   ,
    SDMoviePlayerBackSound                 ,
    
}SDMoviePlayerButtonTag;

@implementation JDMoviePlayerViewController
/**
 初始化
 **/
- (id)initWithSong:(SDSongs *)song
{
    self = [super init];
    if(self)
    {
        self.song_nowPlay = song;
        IOS7_STATEBAR;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        
        //进入播放器，停止主界面上的预读
        [[JDMasterViewController sharedController] stopPreread];
        
        MediaProxy *mediaProxy = [[MediaProxy alloc] init];
        _mediaProxy = mediaProxy;
        [_mediaProxy startProxy];
        [self installGenerateAdvList];
        
        AudioSessionInitialize (NULL, NULL, NULL, NULL);
        AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioRouteChangeListenerCallback,self);
        
        [self installMoviePlayer];
        [self installTitleForMoviePlayer];
        [self installControlStyleForMoviePlayer];
        [self installMoviePlayerConfigure];
        
        UIButton *button_backCover = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_backCover setFrame:CGRectMake(0, 768 -155, 1024, 155)];
        [UIUtils didLoadImageNotCached:@"menu_title_bg_back.png" inButton:button_backCover withState:UIControlStateNormal];
        [self.view addSubview:button_backCover];
        _button_advback = button_backCover;
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(volumeChanged:)
                                                     name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                                   object:nil];
    }
    return self;
}

#pragma mark - 切换歌曲 -
/**
 切换歌曲
 **/
- (void)changePlaySong:(SDSongs *)song
{
    if(_bool_isK)
    {
        [_mixController stopMicphone];
        [_mixController release];
        [self KViewHidden];
        _bool_isK = NO;
        if(!_bool_recordOrStop)
        {
            [_recorder stop];
            _recorder = nil;
        }
        
        UIButton *button_k = (UIButton *)[_customControlStyle viewWithTag:SDMoviePlayerK];
        [UIUtils didLoadImageNotCached:@"player_btn_mode_ktv.png" inButton:button_k withState:UIControlStateNormal];
        
    }
    
    if(_button_soundChange)
    {
        [UIUtils didLoadImageNotCached:@"qiehuan.png" inButton:_button_soundChange withState:UIControlStateNormal];
    }
    
    if(_timer_syncAVTimer != nil)
    {
        [_timer_syncAVTimer invalidate];
        _timer_syncAVTimer = nil;
    }

    [_originalPlayer release], _originalPlayer = nil;
    [_silentPlayer release], _silentPlayer = nil;
    [_moviePlayer_main pause];
    
    [_progress_buffer setProgress:0.0f];
    MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
    [_slider_sound setValue:mpc.volume];
    
    UIButton *button_favor = (UIButton *)[_customControlStyle viewWithTag:SDMoviePlayerFavourite];
    JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
    [base selectSongandChangeItTag:song];
    [base release];
    if(song.songFavoriteTag == 1)
    {
        [UIUtils didLoadImageNotCached:@"player_btn_favor_added.png" inButton:button_favor withState:UIControlStateNormal];
        [button_favor setTitle:@"UIControlStateHighlighted" forState:UIControlStateReserved];
    }
    else
    {
        [UIUtils didLoadImageNotCached:@"player_btn_favor.png" inButton:button_favor withState:UIControlStateNormal];
        [button_favor setTitle:@"UIControlStateNormal" forState:UIControlStateReserved];
    }
    
    self.song_nowPlay = song;
    [_label_moveTitle setText:song.songTitle];
    [_view_alreadySong setSong_current:song];
    [_view_alreadySong reloadTableView];
    [_view_alreadySong tableScrollToPosition];
    
    [self installMoviePlayerConfigure];
    [self prepareForProxyForMovie];
    [self startProxyPlay];
}

#pragma marl - 监控系统音量 -
- (void)volumeChanged:(NSNotification *)notification
{
    float volume =
    [[[notification userInfo]
      objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"]
     floatValue];
    _slider_sound.value = volume;
}

- (void)viewWillDisappear:(BOOL)animated
{
    if(_timer_syncAVTimer != nil)
    {
        [_timer_syncAVTimer invalidate];
        _timer_syncAVTimer = nil;
    }
    
    if (_timer_updateTimer)
    {
        [_timer_updateTimer invalidate];
        _timer_updateTimer = nil;
    }
}

- (void)dealloc
{
    [_song_nowPlay release], _song_nowPlay = nil;
    [_recordSound release], _recordSound = nil;
    [_array_advList release], _array_advList = nil;
    [_array_playList release], _array_playList = nil;
    [_array_audioList release], _array_audioList = nil;
    [_moviePlayer_main release], _moviePlayer_main = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                        name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                                 object:nil                                                 ];
    [self removeMovieNotificationHandlers];
    [self stopProxyPlay];
    //[_mediaProxy release];
    [super dealloc];
}

#pragma mark - 状态栏控制 -
/**状态栏控制**/
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleBlackOpaque;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - 初始化播放参数 -
/**
 初始化本类配置参数
 **/
- (void)installMoviePlayerConfigure
{
    _bool_isAlreadyShow = YES;
    _bool_moviePlay = YES;
    _bool_playOrStop = YES;
    _bool_recordOrStop = YES;
    _bool_silentOrOriginal = YES;
    
    _bool_isSearch = NO;
    _bool_mixViewHave = NO;
    _bool_isHUD = NO;
    _bool_touch = NO;
    _bool_isDragging = NO;
    _bool_isK = NO;
    _bool_didClickBack = NO;
    _bool_isSeeking = NO;
    _bool_waitForPlay = NO;
}

#pragma mark - 初始化播放器 -
/**
 初始化播放器
 **/
- (void)installMoviePlayer
{
    MPMoviePlayerController *moviePlay = [[MPMoviePlayerController alloc] init];
    [moviePlay.view setFrame:CGRectMake(0, 0, 1024, 768)];
    [moviePlay setControlStyle:MPMovieControlStyleNone];
    [moviePlay setFullscreen:YES];
    [self.view addSubview:moviePlay.view];
    _moviePlayer_main = moviePlay;
    [self installMoviePlayerNotificationObservers];
}

#pragma mark - 初始化title -
/**
 初始化title
 **/
- (void)installTitleForMoviePlayer
{
    UIView *view_title_tmp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 50)];
    [self.view addSubview:view_title_tmp];
    [view_title_tmp release];
    _view_playerTitle = view_title_tmp;
    
    SKCustomNavigationBar *customNavigationBar = [[SKCustomNavigationBar alloc] initWithFrame:CGRectMake(0, 0, 1024, 50)];
    [_view_playerTitle addSubview:customNavigationBar];
    [customNavigationBar release];
    
    UIView *view_title = [[UIView alloc] initWithFrame:CGRectMake(300, 0, 700, 50)];
    [view_title setBackgroundColor:[UIColor clearColor]];
    [view_title setTag:70];
    [customNavigationBar addSubview:view_title];
    [view_title release];
    
    UILabel *label_titel = [[UILabel alloc]initWithFrame:CGRectMake(90, 0, 230, 50)];
    [label_titel setBackgroundColor:[UIColor clearColor]];
    [label_titel setTextAlignment:NSTextAlignmentCenter];
    [label_titel setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:25.0f]];
    [label_titel setTextColor:[UIColor whiteColor]];
    [label_titel setText:_song_nowPlay.songTitle];
    [view_title addSubview:label_titel];
    [label_titel release];
    _label_moveTitle = label_titel;
    
    UIButton *button_master = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_master setFrame:CGRectMake(10, 7, 65, 37)];
    [UIUtils didLoadImageNotCached:@"back_btn.png" inButton:button_master withState:UIControlStateNormal];
    [button_master setTag:SDMoviePlayerReturn];
    [customNavigationBar addSubview:button_master];
    [button_master addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageView_text = [[UIImageView alloc] initWithFrame:CGRectMake(455, 11, 250, 28)];
    [UIUtils didLoadImageNotCached:@"search_field.png" inImageView:imageView_text];
    [view_title addSubview:imageView_text];
    [imageView_text release];
    
    UITextField *text_search = [[UITextField alloc] initWithFrame:CGRectMake(460, 14, 245, 25)];
    [text_search setTextColor:[UIColor grayColor]];
    [text_search setFont:[UIFont systemFontOfSize:15.0f]];
    [text_search setDelegate:self];
    [text_search setClearButtonMode:UITextFieldViewModeAlways];
    [text_search setPlaceholder:@"请输入关键字"];
    [text_search setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [text_search setReturnKeyType:UIReturnKeySearch];
    [view_title addSubview:text_search];
    [text_search release];
    
    UIButton *button_already = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_already setFrame:CGRectMake(412, 13, 37, 28)];
    [UIUtils didLoadImageNotCached:@"image.png" inButton:button_already withState:UIControlStateNormal];
    [button_already addTarget:self action:@selector(didClickAlreadyButton:) forControlEvents:UIControlEventTouchUpInside];
    [view_title addSubview:button_already];
    
    UIImageView *imageView_row = [[UIImageView alloc] initWithFrame:CGRectMake(15, 6, 24, 24)];
    [UIUtils didLoadImageNotCached:@"row_songList_down.png" inImageView:imageView_row];
    [button_already addSubview:imageView_row];
    [imageView_row release];
    _imageView_hlight = imageView_row;
}


#pragma mark - 初始化控制器 -
/**
 初始化控制器
 **/
- (void)installControlStyleForMoviePlayer
{
    UIView *view_control = [[UIView alloc] initWithFrame:CGRectMake(0, 613, 1024, 155)];
    [self.view addSubview:view_control];
    [view_control release];
    _customControlStyle = view_control;
    
    UIImageView *imageView_background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 155)];
    [UIUtils didLoadImageNotCached:@"player_bg.png" inImageView:imageView_background];
    [self.customControlStyle addSubview:imageView_background];
    [imageView_background release];

    UIButton *moviePlayerPlay = [UIButton buttonWithType:UIButtonTypeCustom];
    [moviePlayerPlay setFrame:CGRectMake(26, 8, 53, 53)];
    [UIUtils didLoadImageNotCached:@"player_btn_pause.png" inButton:moviePlayerPlay withState:UIControlStateNormal];
    [moviePlayerPlay addTarget:self
                        action:@selector(didClickButton:)
              forControlEvents:UIControlEventTouchUpInside];
    [moviePlayerPlay setTag:SDMoviePlayerPlay];
    [view_control addSubview:moviePlayerPlay];
    _button_play = moviePlayerPlay;
    
    UIButton *button_again = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_again setFrame:CGRectMake(125, 80, 65, 65)];
    [UIUtils didLoadImageNotCached:@"player_btn_list_replay.png" inButton:button_again withState:UIControlStateNormal];
    [button_again addTarget:self
                     action:@selector(didClickButton:)
           forControlEvents:UIControlEventTouchUpInside];
    [button_again setTag:SDMoviePlayerAgain];
    [view_control addSubview:button_again];
    
    UIButton *button_next = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_next setFrame:CGRectMake(255, 80, 65, 65)];
    [UIUtils didLoadImageNotCached:@"player_btn_list_skip.png" inButton:button_next withState:UIControlStateNormal];
    [button_next addTarget:self
                    action:@selector(didClickButton:)
          forControlEvents:UIControlEventTouchUpInside];
    [button_next setTag:SDMoviePlayerNext];
    [self.customControlStyle addSubview:button_next];
    
    UIButton *button_K = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_K setFrame:CGRectMake(382, 80, 65, 65)];
    [UIUtils didLoadImageNotCached:@"player_btn_mode_ktv.png" inButton:button_K withState:UIControlStateNormal];
    [button_K addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    [button_K setTag:SDMoviePlayerK];
    [self.customControlStyle addSubview:button_K];
    
    UIButton *moviePlayerRepeat = [UIButton buttonWithType:UIButtonTypeCustom];
    [moviePlayerRepeat setFrame:CGRectMake(515, 80, 65, 65)];
    [UIUtils didLoadImageNotCached:@"player_btn_list_mode_loop.png" inButton:moviePlayerRepeat withState:UIControlStateNormal];
    [moviePlayerRepeat addTarget:self
                          action:@selector(didClickButton:)
                forControlEvents:UIControlEventTouchUpInside];
    [moviePlayerRepeat setTag:SDMoviePlayerRepeat];
    [self.customControlStyle addSubview:moviePlayerRepeat];
    
    UIButton *button_favorite = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_favorite setFrame:CGRectMake(637,80,65,65)];
    if(_song_nowPlay.songFavoriteTag == 1)
    {
        [UIUtils didLoadImageNotCached:@"player_btn_favor_added.png" inButton:button_favorite withState:UIControlStateNormal];
        [button_favorite setTitle:@"UIControlStateHighlighted" forState:UIControlStateReserved];
    }
    else
    {
        [UIUtils didLoadImageNotCached:@"player_btn_favor.png" inButton:button_favorite withState:UIControlStateNormal];
        [button_favorite setTitle:@"UIControlStateNormal" forState:UIControlStateReserved];
    }
    
    [button_favorite addTarget:self
                        action:@selector(didClickButton:)
              forControlEvents:UIControlEventTouchUpInside];
    [button_favorite setTag:SDMoviePlayerFavourite];
    [self.customControlStyle addSubview:button_favorite];
    
    UIButton *button_sound = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_sound setFrame:CGRectMake(755, 95, 37, 37)];
    [UIUtils didLoadImageNotCached:@"player_btn_mute.png" inButton:button_sound withState:UIControlStateNormal];
    [_customControlStyle addSubview:button_sound];
    
    [self installProgressSliderStyleForController];
    [self installView_K];
}

#pragma mark - 初始化控制器进度条 -
/**
 初始化控制器进度条
 **/
- (void)installProgressSliderStyleForController
{
    UILabel *startLable = [[UILabel alloc] initWithFrame:CGRectMake(85, 25, 40, 30)];
    [startLable setBackgroundColor:[UIColor clearColor]];
    [startLable setTextColor:[UIColor whiteColor]];
    [startLable setFont:[UIFont systemFontOfSize:12.0f]];
    [self.customControlStyle addSubview:startLable];
    [startLable release];
    _startLable = startLable;
    
    UILabel *endLable = [[UILabel alloc] initWithFrame:CGRectMake(115, 25, 40, 30)];
    [endLable setTextColor:[UIColor whiteColor]];
    [endLable setBackgroundColor:[UIColor clearColor]];
    [endLable setFont:[UIFont systemFontOfSize:12.0f]];
    [self.customControlStyle addSubview:endLable];
    [endLable release];
    _endLable = endLable;
    
    [self updateCurrentTimeForPlayer];
    
    UIProgressView *bufferProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(70, 54, 930, 20)];
    [bufferProgress setBackgroundColor:[UIColor clearColor]];
    [bufferProgress setTrackTintColor:[UIColor blackColor]];
    [bufferProgress setProgressImage:[UIUtils didLoadImageNotCached:@"player_progress_bar2.png"]];
    [_customControlStyle addSubview:bufferProgress];
    [bufferProgress release];
    _progress_buffer = bufferProgress;
    
    UISlider *progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(65, 48, 940, 9)];
    [_customControlStyle addSubview:progressSlider];
    [progressSlider release];
    _slider_progress = progressSlider;
    
    [_slider_progress setBackgroundColor:[UIColor clearColor]];
    [_slider_progress setThumbImage:[UIUtils didLoadImageNotCached:@"player_progress_bar_btn.png"] forState:UIControlStateNormal];
    [_slider_progress setMinimumTrackImage:[UIUtils didLoadImageNotCached:@"player_progress_bar.png"] forState:UIControlStateNormal];
    [_slider_progress setMaximumTrackTintColor:[UIColor clearColor]];
    [_slider_progress setMaximumTrackImage:[UIUtils didLoadImageNotCached:@"player_progress_back_bg.png"] forState:UIControlStateNormal];
    [_slider_progress addTarget:self action:@selector(progressSliderMoved:) forControlEvents:UIControlEventValueChanged];
    [_slider_progress addTarget:self action:@selector(progressSliderMoved_finish) forControlEvents:UIControlEventTouchUpInside];
    [_slider_progress addTarget:self action:@selector(progressSliderMoved_finish) forControlEvents:UIControlEventTouchUpOutside];
    
    if (_timer_updateTimer)
    {
        [_timer_updateTimer invalidate];
        _timer_updateTimer = nil;
    }
    else
    {
        _slider_progress.maximumValue = _moviePlayer_main.duration;
        NSTimer *updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                       target:self
                                                     selector:@selector(updateCurrentTimeForPlayer)
                                                     userInfo:_moviePlayer_main repeats:YES];
        _timer_updateTimer = updateTimer;
    }
    
    
    UISlider *slider_sound = [[UISlider alloc] initWithFrame:CGRectMake(800, 100, 200, 25)];
    if(IOS7_VERSION)
    {
        [slider_sound setFrame:CGRectMake(800, 95, 200, 25)];
    }
    [slider_sound setThumbImage:[UIUtils didLoadImageNotCached:@"player_progress_bar_btn.png"] forState:UIControlStateNormal];
    [slider_sound setMinimumTrackImage:[UIUtils didLoadImageNotCached:@"player_progress_bar.png"] forState:UIControlStateNormal];
    [slider_sound setMaximumTrackImage:[UIUtils didLoadImageNotCached:@"player_progress_bar_bg.png"] forState:UIControlStateNormal];
    [slider_sound addTarget:self action:@selector(progressSliderMoved_sound:) forControlEvents:UIControlEventValueChanged];
    slider_sound.maximumValue = 1.0;
    [_customControlStyle addSubview:slider_sound];
    [slider_sound release];
    _slider_sound = slider_sound;
    
    MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
    [_slider_sound setValue:mpc.volume];
    
    JDAlreadySongView *view_alreadySong = [[JDAlreadySongView alloc] initWithMoviePlayer:self];
    [view_alreadySong setSong_current:_song_nowPlay];
    [view_alreadySong configureView_table];
    [self.view addSubview:view_alreadySong];
    [view_alreadySong setAlpha:0.0f];
    [view_alreadySong release];
    _view_alreadySong = view_alreadySong;
}

#pragma mark - 初始化左侧K歌栏 -
/**
 初始化左侧K歌栏
 **/
- (void)installView_K
{
    UIView *view_K = [[UIView alloc] initWithFrame:CGRectMake(0, 170, 98, 345)];
    [_moviePlayer_main.view addSubview:view_K];
    [view_K release];
    _view_K = view_K;
    
    UIImageView *imageView_k = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 98, 345)];
    [UIUtils didLoadImageNotCached:@"player_effect_level1_bg.png" inImageView:imageView_k];
    [view_K addSubview:imageView_k];
    [imageView_k release];
    
    UIButton *button_record = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_record setFrame:CGRectMake(5, 5, 80, 80)];
    [UIUtils didLoadImageNotCached:@"player_effect_level1_btn_record2.png" inButton:button_record withState:UIControlStateNormal];
    [button_record setTitle:@"UIControlStateNormal" forState:UIControlStateReserved];
    [button_record setUserInteractionEnabled:NO];
    [button_record setTag:SDMoviePlayerRecord];
    [button_record addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    [_view_K addSubview:button_record];
    
    UIButton *button_mix = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_mix setFrame:CGRectMake(5, 87.5, 80, 80)];
    [button_mix setUserInteractionEnabled:NO];
    [button_mix setTitle:@"UIControlStateNormal" forState:UIControlStateReserved];
    [UIUtils didLoadImageNotCached:@"player_effect_level1_btn_mixing2.png" inButton:button_mix withState:UIControlStateNormal];
    [button_mix setTag:SDMoviePlayerMix];
    [button_mix addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    [_view_K addSubview:button_mix];
    
    UIButton *button_backSound = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_backSound setFrame:CGRectMake(5, 170, 80, 80)];
    [button_backSound setTitle:@"UIControlStateNormal" forState:UIControlStateReserved];
    [UIUtils didLoadImageNotCached:@"player_effect_level1_btn_music2.png" inButton:button_backSound withState:UIControlStateNormal];
    [button_backSound setUserInteractionEnabled:NO];
    [button_backSound setTag:SDMoviePlayerBackSound];
    [button_backSound addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    [_view_K addSubview:button_backSound];

    UIButton *button_qieHuan = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_qieHuan setFrame:CGRectMake(5, 252.5, 80, 80)];
    [button_qieHuan setTitle:@"UIControlStateNormal" forState:UIControlStateReserved];
    [UIUtils didLoadImageNotCached:@"qiehuan.png" inButton:button_qieHuan withState:UIControlStateNormal];
    [button_qieHuan setTag:SDMoviePlayerQieHuan];
    [button_qieHuan addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    [_view_K addSubview:button_qieHuan];
    
    _button_soundChange = button_qieHuan;
}


#pragma mark - 初始化广告目录下的文件,生成广告列表 -
/**
 初始化广告目录下的文件,生成广告列表
 **/
- (void)installGenerateAdvList
{
    NSMutableArray *array_list = [NSMutableArray arrayWithCapacity:10];
    self.array_advList = array_list;
    _integer_curAdvIndex = 0;
    
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    
    [_array_advList addObject:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"introduce-ipad.mp4"]];
    /*NSString *advPath = [NSString stringWithFormat:@"%@/%@", [UIUtils getDocumentDirName], ADVERTISE_PATH];
    
    for (NSString *fileName in [fileManager enumeratorAtPath:advPath])
    {
        if ([[fileName pathExtension] isEqualToString:@"mp4"] ||
            [[fileName pathExtension] isEqualToString:@"mpg"] ||
            [[fileName pathExtension] isEqualToString:@"wmv"] ||
            [[fileName pathExtension] isEqualToString:@"avi"])
        {
            [_array_advList addObject:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], fileName]];
            //NSLog(@"Adv File: %@", fileName);
        }
    }*/
}


#pragma mark - 注册播放器通知 -
/**注册播放器通知**/
- (void)installMoviePlayerNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:_moviePlayer_main];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_moviePlayer_main];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_moviePlayer_main];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_moviePlayer_main];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioRouteChange:)
                                                 name:@"audioRouteChange"
                                               object:nil];
}

#pragma mark - 移除各种通知 -
/**
 移除各种通知
 **/
-(void)removeMovieNotificationHandlers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerLoadStateDidChangeNotification
                                                 object:_moviePlayer_main];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerPlaybackDidFinishNotification
                                                 object:_moviePlayer_main];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                 object:_moviePlayer_main];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                 object:_moviePlayer_main];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"audioRouteChange"
                                                 object:nil];
}

#pragma mark - 初始化K歌环境 -
- (void)installKDeviceInPlayer
{
    /**自动释放类,无需release**/
    [self hiddenMovieController];
    [_moviePlayer_main.view addSubview:_mixController.view];
    [UIUtils addViewWithAnimation:_mixController.view inCenterPoint:CGPointMake(_mixController.view.center.x, 309)];
}


#pragma mark - 播放器消息各种回调 -
/**
 播放器消息各种回调
 **/
#pragma mark - Handle movie load state changes -
- (void)loadStateDidChange:(NSNotification *)notification
{
    MPMoviePlayerController *player = notification.object;
    MPMovieLoadState loadState = player.loadState;
    if (loadState & MPMovieLoadStateUnknown)
    {
        /* The load state is not known at this time. */
        NSLog(@"unknown");
    }
    if (loadState & MPMovieLoadStatePlayable)
    {
        /* The buffer has enough data that playback can begin, but it
         may run out of data before playback finishes. */
        NSLog(@"playable");
    }
    if (loadState & MPMovieLoadStatePlaythroughOK)
    {
        /* Enough data has been buffered for playback to continue uninterrupted. */
        //NSLog(@"playthrough ok");
    }
    if (loadState & MPMovieLoadStateStalled)
    {
        /* The buffering of data has stalled. */
        NSLog(@"stalled");
    }
}

#pragma mark - 播放结束消息回调 -
- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    NSNumber *reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
	switch ([reason integerValue])
	{
        /* The end of the movie was reached. */
		case MPMovieFinishReasonPlaybackEnded:
        {
            if(_bool_playingAdvertise)
            {
                if(_bool_waitForPlay)/**缓冲完成播放**/
                {
                    _bool_playingAdvertise = NO;
                    [self prepareAudioPlay];
                    NSString *localURL = [_mediaProxy getLocalURLWithString:[_array_playList objectAtIndex:_integer_curPlayIndex]];
                    [_moviePlayer_main setContentURL:[NSURL URLWithString:localURL]];
                    [_moviePlayer_main play];
                    _bool_waitForPlay = NO;
                    [self saveHistorySong];
                }
                else/**缓冲未完循环放广告**/
                {
                    _integer_curAdvIndex = _integer_curAdvIndex < [_array_advList count] - 1 ? _integer_curAdvIndex + 1 : 0;
                    [_moviePlayer_main setContentURL:[NSURL fileURLWithPath:[_array_advList objectAtIndex:_integer_curAdvIndex]]];
                    [_moviePlayer_main play];
                }
                return;
            }
            else if(_bool_didClickBack)
            {
                return;
            }
            
            UIButton *button_next = [UIButton buttonWithType:UIButtonTypeCustom];
            [button_next setTag:SDMoviePlayerNext];
            [self didClickButton:button_next];
            NSLog(@"finishReasonPlaybackEnded");
            /*
             Add your code here to handle MPMovieFinishReasonPlaybackEnded.
             */
        }break;
		case MPMovieFinishReasonPlaybackError:
        {
            /* An error was encountered during playback. */
            NSLog(@"An error was encountered during playback");
            //[self performSelectorOnMainThread:@selector(displayError:) withObject:[[notification userInfo] objectForKey:@"error"]
            //                   waitUntilDone:NO];
            //[self removeMovieViewFromViewHierarchy];
            //[self removeOverlayView];
            //[self.backgroundView removeFromSuperview];
        }break;
		case MPMovieFinishReasonUserExited:
        {
            /* The user stopped playback. */
            NSLog(@"FinishReasonUserExited");
            //NSTimer *exitedTime = [self.moviePlayerController ]
            //[self removeMovieViewFromViewHierarchy];
            //[self removeOverlayView];
            //[self.backgroundView removeFromSuperview];
            //[self playMovieGoOn];
        }break;
            
		default:
			break;
	}
}

#pragma mark - 准备播放完成调用 -
- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    if(_bool_playingAdvertise)
    {
        [_view_K setHidden:YES];
        [_button_advback setHidden:NO];
        [_slider_progress setHidden:YES];
        return;
    }
    else
    {
        if(_timer_syncAVTimer != nil)
        {
            [_timer_syncAVTimer invalidate];
            _timer_syncAVTimer = nil;
        }
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                          target:self
                                                        selector:@selector(syncAV)
                                                        userInfo:nil
                                                         repeats:YES];
        _timer_syncAVTimer = timer;
        [_originalPlayer play];
        [_view_K setHidden:NO];
        [_slider_progress setHidden:NO];
        [_button_advback setHidden:YES];
    }

    NSLog(@"perBackTossssddd");
}

#pragma mark - 播放器状态改变调用 -
- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
	MPMoviePlayerController *player = notification.object;
	if (player.playbackState == MPMoviePlaybackStateStopped)
	{
        NSLog(@"stop");
	}
	else if (player.playbackState == MPMoviePlaybackStatePlaying)
	{
        if(_bool_playingAdvertise)
        {
            return;
        }
        if(_bool_isSeeking)
        {
            sleep(1);   //这里得停一下，否则取到的时间可能不准。
            NSTimeInterval curTime = [_moviePlayer_main currentPlaybackTime];
            [_silentPlayer setCurrentTime:curTime];
            [_originalPlayer setCurrentTime:curTime];
            _bool_isSeeking = NO;
        }
        
        NSLog(@"play");
        //[withOutAccompanyPlayer setVolume:1.0f];
        //[self performSelectorInBackground:@selector(checkPlayState) withObject: nil];
        //[self performSelector:@selector(hiddenMovieController) withObject:nil afterDelay:5.0f];
	}
	else if (player.playbackState == MPMoviePlaybackStatePaused)
	{
        if(_bool_playingAdvertise)
        {
            return;
        }
        NSLog(@"paused");
        //[self.moviePlayerController setCurrentPlaybackTime:accompanyPlayer.currentTime];
	}
    
	else if (player.playbackState == MPMoviePlaybackStateInterrupted)
	{
        NSLog(@"interrupted");
	}
    
    else if (player.playbackState == MPMoviePlaybackStateSeekingForward)
    {
        _bool_isSeeking = YES;
        NSLog(@"forward");
    }
}

#pragma mark - 开始播放 -
/**
 开始播放
 **/
- (void)playBegin
{
    if([[UIUtils applecationNetworkState] isEqualToString:@"no"])
    {
        CustomAlertView *alter = [[CustomAlertView alloc] initWithTitle:@"连接失败" message:@"请检查网络链接" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alter show];
        [alter release];
        return;
    }
    else if([[UIUtils applecationNetworkState] isEqualToString:@"3g"])
    {
        NSString *string_3G = [[NSUserDefaults standardUserDefaults] objectForKey:@"3G"];
        if([string_3G isEqualToString:@"YES"])
        {
            CustomAlertView *alter = [[CustomAlertView alloc] initWithTitle:@"3G开关开启" message:@"当前为3G/2G环境,请注意流量" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
            [alter release];
            [self addProxyNotification];
            [self prepareForProxyForMovie];
            [self startProxyPlay];
            return;
        }
        else if([string_3G isEqualToString:@"NO"])
        {
            CustomAlertView *alter = [[CustomAlertView alloc] initWithTitle:@"3G开关关闭" message:@"当前为3G/2G环境,禁止下载" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alter show];
            [alter release];
            return;
        }
    }
    else if([[UIUtils applecationNetworkState] isEqualToString:@"wifi"])
    {
        [self addProxyNotification];
        [self prepareForProxyForMovie];
        [self startProxyPlay];
        return;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
        {
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
            
        }break;
        default:
            break;
    }
    [_navigationController_return popViewControllerAnimated:YES];
}


#pragma mark - 初始化音轨和视频 -
/**
 初始化音轨和视频
 **/
- (void)prepareForProxyForMovie
{
    _bool_prebufferForPlay = NO;
    _bool_playingAdvertise = NO;
    
    _integer_curPlayIndex = 0;
    _integer_curPreadIndex = 0;
    
    if(_array_playList)
    {
        [_array_playList release];
        _array_playList = nil;
    }
    
    if(_array_audioList)
    {
        [_array_audioList release];
        _array_audioList = nil;
    }
    
    NSMutableArray *array_playList = [NSMutableArray arrayWithObjects:_song_nowPlay.string_videoUrl, nil];
    self.array_playList = array_playList;
    NSArray *array_audio = [NSArray arrayWithObjects:_song_nowPlay.string_audio0Url,_song_nowPlay.string_audio1Url,nil];
    NSMutableArray *array_audioList = [NSMutableArray arrayWithObjects:array_audio,nil];
    self.array_audioList = array_audioList;
    
    JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
    NSMutableArray *array_already = [base reciveSongArrayWithTag:2];
    [base release];
    
    for (int i = 0; i<[array_already count]; i++)
    {
        SDSongs *song = [array_already objectAtIndex:i];
        [_array_playList addObject:song.string_videoUrl];
        NSArray *array_tmp = [NSArray arrayWithObjects:song.string_audio0Url,song.string_audio1Url,nil];
        [_array_audioList addObject:array_tmp];
    }
}

#pragma mark - 准备播放音频 -
/**
 准备播放音频
 **/
- (void)prepareAudioPlay
{
    if([[_mediaProxy audioLocalFiles] count] > 1)
    {
        if(_originalPlayer != nil)
        {
            [_originalPlayer stop];
            [_originalPlayer release];
        }
        NSURL *urlOne = [NSURL fileURLWithPath:[[_mediaProxy audioLocalFiles] objectAtIndex:0]];
        AVAudioPlayer *playerOne = [[AVAudioPlayer alloc]initWithContentsOfURL:urlOne error:nil];
        [playerOne setVolume:0.0];
        _originalPlayer = playerOne;
        
        if(_silentPlayer != nil)
        {
            [_silentPlayer stop];
            [_silentPlayer release];
        }
        NSURL *urlTwo = [NSURL fileURLWithPath:[[_mediaProxy audioLocalFiles] objectAtIndex:1]];
        AVAudioPlayer *playerTwo = [[AVAudioPlayer alloc]initWithContentsOfURL:urlTwo error:nil];
        [playerTwo setVolume:0.0];
        _silentPlayer = playerTwo;
        [_silentPlayer play];
    }
}

#pragma mark - 纠正音频视频同步 -
/**
 纠正音频视频同步
 **/
- (void)syncAV
{
    if([_moviePlayer_main playbackState] == MPMoviePlaybackStatePaused && [_originalPlayer isPlaying] && ![JDModel_userInfo sharedModel].bool_homeBack)
    {
        [_moviePlayer_main play];
    }
    
    if(_moviePlayer_main != nil && _originalPlayer != nil && _silentPlayer != nil && [_moviePlayer_main playbackState] == MPMoviePlaybackStatePlaying && [_originalPlayer isPlaying])
    {
        NSTimeInterval movieTime = [_moviePlayer_main currentPlaybackTime];
        NSTimeInterval audioTime = [_originalPlayer currentTime];
        NSTimeInterval audioTimeTwo = [_silentPlayer currentTime];
        /**解决原伴唱同时音量为0引发的问题**/
        if( 0 == [_originalPlayer volume] && 0 == [_silentPlayer volume])
        {
            if(_bool_silentOrOriginal)
            {
                [_originalPlayer setVolume:1.0];
            }
            else
            {
                [_silentPlayer setVolume:1.0];
            }
        }
        /**当音视频相差超过0.2秒时，重新同步**/
        if(abs(audioTime*10 - movieTime*10) > 2 || abs(audioTime*10 - audioTimeTwo*10) > 1)
        {
            [_silentPlayer setCurrentTime:movieTime];
            [_originalPlayer setCurrentTime:movieTime];
            //[_silentPlayer setVolume:1.0f];
            //[_silentPlayer play];
        }
    }
}

#pragma mark - 代理启动 -
/**代理启动**/
- (void)startProxyPlay
{
    [_mediaProxy prebufferWithUrl:[_array_playList objectAtIndex:_integer_curPlayIndex]
                    WithAudioUrls:[_array_audioList objectAtIndex:_integer_curPlayIndex]];

    if([_mediaProxy isPrebufferFinish])/**缓冲完的**/
    {
        /**播放当前首**/
        [_mediaProxy getHead:_song_nowPlay.songMd5
                      UserID:[JDModel_userInfo sharedModel].string_userID
                       Token:[JDModel_userInfo sharedModel].string_token];
    
        /**缓冲下一首**/
        if(_integer_curPlayIndex < [_array_playList count] - 1)
        {
            _integer_curPreadIndex = _integer_curPlayIndex + 1;
            while(_integer_curPreadIndex < [_array_playList count] &&
                  ![_mediaProxy prereadWithURL:[_array_playList objectAtIndex:_integer_curPreadIndex]
                                 WithAudioUrls:[_array_audioList objectAtIndex:_integer_curPreadIndex]])
            {
                _integer_curPreadIndex ++;
            }
        }
    }
    else if([_mediaProxy getPrebufferPercent] > 5)/**未缓冲完,但满足播放条件**/
    {
        /**开始播放**/
        [_mediaProxy getHead:_song_nowPlay.songMd5
                      UserID:[JDModel_userInfo sharedModel].string_userID
                       Token:[JDModel_userInfo sharedModel].string_token];
    }
    else/**未满足播放条件的**/
    {
        _bool_playingAdvertise = YES;
        _bool_prebufferForPlay = YES;
        
        [self.moviePlayer_main setContentURL:[NSURL fileURLWithPath:[_array_advList objectAtIndex:_integer_curAdvIndex]]];
        [_moviePlayer_main play];
        
        MBProgressHUD *hudPro = [MBProgressHUD showHUDAddedTo:_moviePlayer_main.view animated:YES];
        _HUD = hudPro;
        _bool_isHUD = YES;
        [_HUD setBackgroundColor:[UIColor clearColor]];
        if(IOS7_VERSION)
        {
            [_HUD setMode:MBProgressHUDModeIndeterminate];
        }
        else
        {
            [_HUD setMode:MBProgressHUDModeDeterminate];
        }
        [_HUD setAnimationType:MBProgressHUDAnimationZoom];
        [_HUD setRemoveFromSuperViewOnHide:YES];
        [_HUD setLabelText:@"正在进行缓冲"];
        [self performSelector:@selector(selectReloadAlreadyView) withObject:nil afterDelay:1.0f];
    }
}

#pragma mark - 停止代理 -
/**
 停止代理
 **/
- (void)stopProxyPlay
{
    [_mediaProxy destroyProxy];
    [self removeProxyNotification];
}

#pragma mark - 注册代理消息 -
/**
 注册代理消息
 **/
- (void)addProxyNotification
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(handleReceiveData:)
               name:NOTI_CACHE_PROGRESS_CHANGE
             object:nil];
    [nc addObserver:self
           selector:@selector(handleDownloadProgress:)
               name:NOTI_DOWNLOAD_PROGRESS_CHANGE
             object:nil];
    [nc addObserver:self
           selector:@selector(handlePrebufferFinish:)
               name:NOTI_PREBUFFER_FINISH
             object:nil];
    [nc addObserver:self
           selector:@selector(handleDownloadFailed:)
               name:NOTI_MEDIA_DOWNLOAD_FAILED
             object:nil];
    [nc addObserver:self
           selector:@selector(handleCacheFailed:)
               name:NOTI_CACHE_FAILED
             object:nil];
    [nc addObserver:self
           selector:@selector(handleGetHeadFinish)
               name:NOTI_GET_HEAD_FINISH
             object:nil];
    [nc addObserver:self
           selector:@selector(handleGetHeadFailed:)
               name:NOTI_GET_HEAD_FAILED
             object:nil];
}

#pragma mark - 移除代理消息 -
/**
 移除代理消息
 **/
- (void)removeProxyNotification
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self
                  name:NOTI_CACHE_PROGRESS_CHANGE
                object:nil];
    [nc removeObserver:self
                  name:NOTI_DOWNLOAD_PROGRESS_CHANGE
                object:nil];
    [nc removeObserver:self
                  name:NOTI_PREBUFFER_FINISH
                object:nil];
    [nc removeObserver:self
                  name:NOTI_MEDIA_DOWNLOAD_FAILED
                object:nil];
    [nc removeObserver:self
                  name:NOTI_CACHE_FAILED
                object:nil];
    [nc removeObserver:self
                  name:NOTI_GET_HEAD_FINISH
                object:nil];
    [nc removeObserver:self
                  name:NOTI_GET_HEAD_FAILED
                object:nil];
}


#pragma mark - 监听耳机状态回调 -
/**
 监听耳机状态回调
 **/
void audioRouteChangeListenerCallback (
                                       void *inUserData,
                                       AudioSessionPropertyID inID,
                                       UInt32 inDataSize,
                                       const void *inData)
{
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    CFStringRef state = nil;
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute
                            ,&propertySize,&state);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"audioRouteChange" object:(NSString *)state];
    
}

- (void)audioRouteChange:(NSNotification *)note
{
    [_moviePlayer_main play];
}


#pragma mark - 播放器按钮回调事件 -
/**人     
 播放器按钮回调事件
 **/
- (void)didClickButton:(id)sender
{
    [self showMovieController];
    UIButton *button = (UIButton *)sender;
    NSString *string_title = [button titleForState:UIControlStateReserved];
    NSInteger tag = button.tag;
    switch (tag)
    {
        /**返回按钮**/
        case SDMoviePlayerReturn:
        {
            _bool_didClickBack = YES;
            if(_bool_isK)
            {
                [_mixController stopMicphone];
                [_mixController release];
                [self KViewHidden];
                _bool_isK = NO;
                if(!_bool_recordOrStop)
                {
                    [_recorder stop];
                    _recorder = nil;
                }
            }
            if(_bool_isHUD)
            {
                [MBProgressHUD hideHUDForView:_moviePlayer_main.view animated:YES];
                _bool_isHUD = NO;
            }
            [_moviePlayer_main stop];
            [_originalPlayer pause];
            [_silentPlayer pause];
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            [_navigationController_return popViewControllerAnimated:YES];
            
            //退出播放器，恢复主界面上的预读
            [[JDMasterViewController sharedController] startPreread];
            
        }break;
        /**播放按钮**/
        case SDMoviePlayerPlay:
        {
            if(_bool_playOrStop)
            {
                [_moviePlayer_main pause];
                [_originalPlayer pause];
                [_silentPlayer pause];
                [UIUtils didLoadImageNotCached:@"player_btn_play.png" inButton:button withState:UIControlStateNormal];
            }
            else
            {
                [_moviePlayer_main play];
                [_originalPlayer play];
                [_silentPlayer play];
                [UIUtils didLoadImageNotCached:@"player_btn_pause.png" inButton:button withState:UIControlStateNormal];
            }
            _bool_playOrStop = !_bool_playOrStop;
        }break;
        /**K歌按钮**/
        case SDMoviePlayerK:
        {
            _bool_isK = !_bool_isK;
            UIButton *button_qiehuan = (UIButton *)[_view_K viewWithTag:SDMoviePlayerQieHuan];
            if(_bool_isK)
            {
                [UIUtils view_showProgressHUD:@"k歌模式开启" inView:_moviePlayer_main.view withTime:1.0f];
                [_silentPlayer setVolume:1.0];
                [_originalPlayer setVolume:0.0];
                [UIUtils didLoadImageNotCached:@"player_btn_mode_mv.png" inButton:button withState:UIControlStateNormal];
                [self KViewShow];
                JDMixerController *mix = [[JDMixerController alloc] init];
                mix.movePlayer = self;
                [mix startMicphone];
                [mix installMiddleK];
                _mixController = mix;
                [self switchToAccompanyTrack:button_qiehuan];
            }
            else
            {
                [UIUtils view_showProgressHUD:@"听歌模式开启" inView:_moviePlayer_main.view withTime:1.0f];
                [_silentPlayer setVolume:0.0];
                [_originalPlayer setVolume:1.0];
                [UIUtils didLoadImageNotCached:@"player_btn_mode_ktv.png" inButton:button withState:UIControlStateNormal];
                [_mixController stopMicphone];
                [self KViewHidden];
                [self switchToOriginalTrack:button_qiehuan];
            }
        }break;
        /**重播按钮**/
        case SDMoviePlayerAgain:
        {
            [_moviePlayer_main setCurrentPlaybackTime:0.0f];
            [_silentPlayer setCurrentTime:0.0f];
            [_originalPlayer setCurrentTime:0.0f];
        }break;
        /**下一首按钮**/
        case SDMoviePlayerNext:
        {
            _view_alreadySong.bool_currentAlready = YES;
            JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
            NSMutableArray *array_already = [base reciveSongArrayWithTag:2];
            BOOL bool_order = NO;
            for (int j = 0; j<[array_already count]; j++)
            {
                SDSongs *tmp = [array_already objectAtIndex:j];
                if([tmp.songMd5 isEqualToString:_song_nowPlay.songMd5])
                {
                    bool_order = YES;
                }
            }
            SDSongs *tmp;
            if(bool_order)
            {
                if(_bool_isHistoryOrSearchSong)
                {
                    tmp = [array_already objectAtIndex:0];
                }
                else
                {
                    if([array_already count] == 1)
                    {
                         tmp = [array_already objectAtIndex:0];
                    }
                    else
                    {
                         tmp = [array_already objectAtIndex:1];
                    }
                }
            }
            else
            {
                if([array_already count] == 0)
                {
                    tmp = _song_nowPlay;
                }
                else
                {
                    tmp = [array_already objectAtIndex:0];
                }
            }
            
            [self changePlaySong:tmp];
            [base changeAlreadySongList_next:tmp];
            [base release];
            self.bool_isHistoryOrSearchSong = NO;
            
        }break;
        /**录音按钮**/
        case SDMoviePlayerRecord:
        {
            if(_bool_recordOrStop)
            {
                [UIUtils didLoadImageNotCached:@"luyin_pressed.png" inButton:button withState:UIControlStateNormal];
                _recordSound = nil;
                _recordSound = [[SDRecordSound alloc] init];
                _recordSound.integer_recordSign = [[NSString stringWithTimeForSInt:[_originalPlayer currentTime]] integerValue];
                _recordSound.string_defaultRecordName = _song_nowPlay.songTitle;
                _recordSound.string_recordMD5 = _song_nowPlay.songMd5;
                NSTimeInterval startTime = [_moviePlayer_main currentPlaybackTime];
                _recordSound.string_recordStartTime = [NSString stringWithTime:startTime];
                [self recordSound_begin];
            }
            else
            {
                [UIUtils didLoadImageNotCached:@"luyin.png" inButton:button withState:UIControlStateNormal];
                _recordSound.string_recordEndTime = nil;
                _recordSound.string_recordEndTime = [NSString stringWithTime:_originalPlayer.currentTime];
                _recordSound.string_videoUrl = _song_nowPlay.string_videoUrl;
                _recordSound.string_audio0Url = _song_nowPlay.string_audio0Url;
                _recordSound.string_audio1Url = _song_nowPlay.string_audio1Url;
                [self recordSound_finish];
            }
            _bool_recordOrStop = !_bool_recordOrStop;
        }break;
        /**原伴唱切换**/
        case SDMoviePlayerQieHuan:
        {
            if([string_title isEqualToString:@"UIControlStateNormal"])
            {
                [self switchToAccompanyTrack:button];
            }
            else
            {
                [self switchToOriginalTrack:button];
            }
            [self soundTrackChange];

        }break;
        /**循环模式**/
        case SDMoviePlayerRepeat:
        {
            NSLog(@"repeat");
        }break;
        /**点击收藏**/
        case SDMoviePlayerFavourite:
        {
            JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
            [base selectSongandChangeItTag:_song_nowPlay];
            NSString *string_favor = [button titleForState:UIControlStateReserved];
            if([string_favor isEqualToString:@"UIControlStateNormal"])
            {
                [UIUtils didLoadImageNotCached:@"player_btn_favor_added.png" inButton:button withState:UIControlStateNormal];
                [button setTitle:@"UIControlStateHighlighted" forState:UIControlStateReserved];
                _song_nowPlay.songFavoriteTag = 1;
                if([base saveSong:_song_nowPlay withTag:1])
                {
                    [UIUtils view_showProgressHUD:@"已添加至收藏列表" inView:self.view withTime:1.0f];
                }
            }
            else if([string_favor isEqualToString:@"UIControlStateHighlighted"])
            {
                [UIUtils didLoadImageNotCached:@"player_btn_favor.png" inButton:button withState:UIControlStateNormal];
                [button setTitle:@"UIControlStateNormal" forState:UIControlStateReserved];
                [base deleteSongFormLocalSingerWithString:_song_nowPlay withTag:1];
                _song_nowPlay.songFavoriteTag = 0;
                [UIUtils view_showProgressHUD:@"已移出播收藏列表" inView:self.view withTime:1.0f];
            }
            [base release];
        }break;
        /**混响强度调节**/
        case SDMoviePlayerMix:
        {
            [UIUtils didLoadImageNotCached:@"hunyin_pressed.png" inButton:button withState:UIControlStateHighlighted];
            [self installKDeviceInPlayer];
            _bool_mixViewHave = YES;
            [self hiddenMovieController];
        }break;
        default:
            break;
    }
}

#pragma mark - 点歌表按钮 -
/**
 点歌表按钮
 **/
- (void)didClickAlreadyButton:(id)sender
{
    if(_bool_isAlreadyShow)
    {
        [UIUtils didLoadImageNotCached:@"row_songList_down.png" inImageView:_imageView_hlight];
        [UIUtils animationWhirlWith:_imageView_hlight withPointMake:CGPointMake(27, 18) andRemovedOnCompletion:NO andDirection:1];
        [UIUtils removeViewWithAnimation:_view_alreadySong inCenterPoint:CGPointMake(_view_alreadySong.center.x, -346) withBoolRemoveView:NO];
    }
    else
    {
        [UIUtils didLoadImageNotCached:@"row_songList_up.png" inImageView:_imageView_hlight];
        [UIUtils animationWhirlWith:_imageView_hlight withPointMake:CGPointMake(27, 18) andRemovedOnCompletion:NO andDirection:-1];
        [UIUtils removeViewWithAnimation:_view_alreadySong inCenterPoint:CGPointMake(_view_alreadySong.center.x, 346) withBoolRemoveView:NO];
    }
    _bool_isAlreadyShow = !_bool_isAlreadyShow;
}


#pragma mark - 歌曲切换配置环境切换 -

#pragma mark - 切换到伴唱 -
/**
 切换到伴唱
 **/
- (void)switchToAccompanyTrack:(UIButton*)button
{
    [UIUtils didLoadImageNotCached:@"qiehuan_pressed.png" inButton:button withState:UIControlStateNormal];
    [button setTitle:@"UIControlStateSelected" forState:UIControlStateReserved];
    _bool_silentOrOriginal = NO;
}

#pragma mark - 切换到原唱 -
/**
 切换到原唱
 **/
- (void)switchToOriginalTrack:(UIButton*)button
{
    [UIUtils didLoadImageNotCached:@"qiehuan.png" inButton:button withState:UIControlStateNormal];
    [button setTitle:@"UIControlStateNormal" forState:UIControlStateReserved];
    _bool_silentOrOriginal = YES;
}

#pragma mark - 音轨对调 -
/**
 音轨对调
 **/
- (void)soundTrackChange
{
    int volume = _silentPlayer.volume;
    _silentPlayer.volume = _originalPlayer.volume;
    _originalPlayer.volume = volume;
}

#pragma mark - 隐藏播控界面 -
/**
 隐藏播控界面
 **/
- (void)hiddenMovieController
{
    if(self.bool_isHUD)
    {
        [UIUtils hiddeView:_HUD];
    }
    _bool_moviePlay = NO;
    [UIUtils hiddeView:_view_K];
    [UIUtils hiddeView:_customControlStyle];
    [UIUtils hiddeView:_view_playerTitle];
    
    if(_bool_isAlreadyShow)
    {
        [UIUtils hiddeView:_view_alreadySong];
    }
}

#pragma mark - 显示播控界面 -
/**
 显示播控界面
 **/
- (void)showMovieController
{
    if(self.bool_isHUD)
    {
        [UIUtils showView:_HUD];
    }
    self.bool_moviePlay = YES;
    [UIUtils showView:_view_K];
    [UIUtils showView:_customControlStyle];
    [UIUtils showView:_view_playerTitle];
    if(_bool_isAlreadyShow)
    {
        [UIUtils showView:_view_alreadySong];
    }
}

#pragma mark - 展示K歌界面 -
/**
 展示K歌界面
 **/
- (void)KViewShow
{
    UIButton *button_record = (UIButton *)[_view_K viewWithTag:SDMoviePlayerRecord];
    [UIUtils didLoadImageNotCached:@"luyin.png" inButton:button_record withState:UIControlStateNormal];
    [button_record setTitle:@"UIControlStateNormal" forState:UIControlStateReserved];
    [button_record setUserInteractionEnabled:YES];
    
    UIButton *button_mic = (UIButton *)[_view_K viewWithTag:SDMoviePlayerMix];
    [UIUtils didLoadImageNotCached:@"hunyin.png" inButton:button_mic withState:UIControlStateNormal];
    [button_mic setTitle:@"UIControlStateNormal" forState:UIControlStateReserved];
    [button_mic setUserInteractionEnabled:YES];
    
    UIButton *button_sound = (UIButton *)[_view_K viewWithTag:SDMoviePlayerBackSound];
    [UIUtils didLoadImageNotCached:@"beijing.png" inButton:button_sound withState:UIControlStateNormal];
    [button_sound setTitle:@"UIControlStateNormal" forState:UIControlStateReserved];
    [button_sound setUserInteractionEnabled:YES];
}

#pragma mark - 隐藏k歌界面 -
/**
 隐藏K歌界面
 **/
- (void)KViewHidden
{
    UIButton *button_record = (UIButton *)[_view_K viewWithTag:SDMoviePlayerRecord];
    [UIUtils didLoadImageNotCached:@"player_effect_level1_btn_record2.png" inButton:button_record withState:UIControlStateNormal];
    [button_record setUserInteractionEnabled:NO];
    
    UIButton *button_mic = (UIButton *)[_view_K viewWithTag:SDMoviePlayerMix];
    [UIUtils didLoadImageNotCached:@"player_effect_level1_btn_mic2.png" inButton:button_mic withState:UIControlStateNormal];
    [button_mic setUserInteractionEnabled:NO];
    
    UIButton *button_sound = (UIButton *)[_view_K viewWithTag:SDMoviePlayerBackSound];
    [UIUtils didLoadImageNotCached:@"player_effect_level1_btn_music2.png" inButton:button_sound withState:UIControlStateNormal];
    [button_mic setUserInteractionEnabled:NO];
}

#pragma mark - 开始录音 -
/**
 开始录音
 **/
- (void)recordSound_begin
{
    [_recorder release];
    _recorder = nil;
    _recorder = [[AVAudioRecorder alloc]initWithURL:[self get_recordPathWithString:_recordSound] settings:nil error:nil];
    [_recorder prepareToRecord];
    [_recorder record];
}

#pragma mark - 停止录音 -
/**
 停止录音
 **/
- (void)recordSound_finish
{
    [UIUtils didLoadImageNotCached:@"player_btn_play.png" inButton:_button_play withState:UIControlStateNormal];
    [_recorder stop];
  
    _recordSound.integer_mixTag = _integer_mixTag;
    NSString *string_recordName_tmp = [_recordSound.string_defaultRecordName stringByAppendingString:@"_"];
    _recordSound.string_recordName = [string_recordName_tmp stringByAppendingString:[JDModel_userInfo sharedModel].string_nickName];
    _recordSound.string_dateTime = [UIUtils getCurrentDateString];
    [JDDataBaseRecordSound saveRecord:_recordSound];
    CustomAlertView *alter = [[CustomAlertView alloc]initWithTitle:@"录音已保存"
                                                           message:@"保存成功"
                                                          delegate:nil
                                                 cancelButtonTitle:@"确认"
                                                 otherButtonTitles:nil];
    [alter show];
    [alter release];
}

#pragma mark - 获取录音保存路径 -
/**
 获取录音保存路径
 **/
- (NSURL *)get_recordPathWithString:(SDRecordSound *)_record
{
    NSString *imageDir = [NSString stringWithFormat:@"%@/Documents/recordSound", NSHomeDirectory()];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    if (!(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSURL *theMovieURL = nil;
	NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/recordSound"];
    NSString *songPath = [_record.string_recordMD5 stringByAppendingString:[NSString stringWithFormat:@"%d",_record.integer_recordSign]];
    NSString *downPath = [documentsPath stringByAppendingPathComponent:songPath];
    theMovieURL = [NSURL fileURLWithPath:downPath];
    return theMovieURL;
}

#pragma mark - 更新进度时间 -
/**
 更新进度时间
 **/
-(void)updateCurrentTimeForPlayer
{
    NSString *current = [NSString stringWithFormat:@"%d:%02d", (int)_moviePlayer_main.currentPlaybackTime / 60, (int)_moviePlayer_main.currentPlaybackTime % 60, nil];
    NSString *dur = [NSString stringWithFormat:@"/%d:%02d", (int)((int)(_moviePlayer_main.duration)) / 60, (int)((int)(_moviePlayer_main.duration)) % 60, nil];
	
	_startLable.text = current;
    _endLable.text = dur;
    
    _slider_progress.maximumValue = _moviePlayer_main.duration;
    if(_bool_isDragging)
    {
        return;
    }
	else
    {
        _slider_progress.value = _moviePlayer_main.currentPlaybackTime;
    }
}

#pragma mark - 开始拖拽进度条 -
/**
 开始拖拽进度条
 **/
- (void)progressSliderMoved:(UISlider *)sender
{
    _bool_isDragging = YES;
    [_moviePlayer_main pause];
    [_silentPlayer pause];
    [_originalPlayer pause];
    _moviePlayer_main.currentPlaybackTime = sender.value;
    _originalPlayer.currentTime = sender.value;
    _silentPlayer.currentTime = sender.value;
}

#pragma mark - 拖拽结束放手 -
/**
 拖拽结束放手
 **/
- (void)progressSliderMoved_finish
{
    _bool_isDragging = NO;
    [_moviePlayer_main play];
    [_silentPlayer play];
    [_originalPlayer play];
}

#pragma mark - 拖拽调节音量 -
/**
 拖拽调节音量
 **/
- (void)progressSliderMoved_sound:(UISlider *)sender
{
    MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
    mpc.volume = sender.value;
}

#pragma mark - 已点表移动到指定位置 -
/**
 已点表移动到指定位置
 **/
- (void)selectReloadAlreadyView
{
    [_view_alreadySong tableScrollToPosition];
    [UIUtils showView:_view_alreadySong];
    _bool_touch = YES;
}

#pragma mark - 缓冲代理回调 -
#pragma mark - 视频接收进度 -
/**
 视频接收进度
 **/
- (void)handleReceiveData:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    float           progress = [[state objectForKey:@"progress"] floatValue];
    NSString        *url = [state objectForKey:@"url"];
    float     progressture = (float)progress/100.0;
    if([url isEqualToString:[_array_playList objectAtIndex:_integer_curPlayIndex]])/**缓冲当前正在播放曲目**/
    {
        _progress_buffer.progress = progressture;
        if(progressture <= 0.06)
        {
            progressture = (progressture/0.06) *0.3f + 0.7f;
            if(_bool_isHUD)
            {
                if(IOS7_VERSION)
                {
                    [_HUD setLabelText:[NSString stringWithFormat:@"缓存进度:%d%%",(int)(progressture * 100)]];
                }
                else
                {
                    self.HUD.progress = progressture;
                }
            }
        }
        if(_bool_prebufferForPlay && progress > 5)
            /**当前播放视频缓冲进度大于5,获取并播放**/
        {
            [MBProgressHUD hideHUDForView:_moviePlayer_main.view animated:YES];
            _bool_isHUD = NO;
            _bool_prebufferForPlay = NO;
            [_mediaProxy getHead:_song_nowPlay.songMd5
                          UserID:[JDModel_userInfo sharedModel].string_userID
                           Token:[JDModel_userInfo sharedModel].string_token];
        }
    }
    else/**正在预读视频**/
    {
        [_view_alreadySong.cacheProgressSlider setProgressWithAngle:progress];
    }
}

#pragma mark - 更新音轨/广告下载进度 -
/**
更新音轨/广告下载进度
 **/
- (void)handleDownloadProgress:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    int             progress = [[state objectForKey:@"progress"] integerValue];
    int             nAudioIdx = 0;
    int             i;
    NSString        *url = [state objectForKey:@"url"];
    
    if([url isEqualToString:ADVERTISE_URL])
    {
        //NSString *newText = [NSString stringWithFormat:@"广告下载进度：%d%%", progress];
    }
    else
    {
        NSArray *audioArray = [_array_audioList objectAtIndex:_integer_curPlayIndex];
        for(i = 0; i < [audioArray count]; ++i)
        {
            if([url isEqualToString:[audioArray objectAtIndex:i]])
            {
                nAudioIdx = i + 1;
                break;
            }
        }
        float pro = (float)progress;
        if(pro < 0)
        {
            pro = 0.0f;
        }
        else
        {
            pro = pro/100.0;
        }
        if(nAudioIdx == 1)
        {
            _floatprogress_one = pro;
        }
        else
        {
            _floatprogress_two = pro;
        }
        float turePro = (_floatprogress_one*0.5+_floatprogress_two*0.5)*0.7;
        if(_bool_isHUD)
        {
            if(IOS7_VERSION)
            {
                [_HUD setLabelText:[NSString stringWithFormat:@"缓存进度:%d%%",(int)(turePro * 100)]];
            }
            else
            {
                [_HUD setProgress:turePro];
            }
        }
    }
}

#pragma mark - 缓存完成回调 -
/**
 缓存完成回调
 **/
- (void)handlePrebufferFinish:(NSNotification *)note
{
    NSString *url = (NSString*)[note object];
    NSMutableArray *array_load = [NSMutableArray arrayWithContentsOfFile:[[UIUtils getDocumentDirName] stringByAppendingPathComponent:@"cacheSongConfigure"]];
    if(array_load)
    {
        BOOL alreadyCache = NO;
        for(NSString *tmp in array_load)
        {
            if([url isEqualToString:tmp])
            {
                alreadyCache = YES;
            }
        }
        if(!alreadyCache)
        {
            [array_load addObject:url];
        }
    }
    else
    {
        array_load = [NSMutableArray arrayWithObject:url];
    }
    [_progress_buffer setProgress:100.0f];
    [_view_alreadySong reloadTableViewWhenCacheSong];
    
    NSLog(@"缓存完成");
    
    if(_integer_curPreadIndex < [_array_playList count] - 1)
        /**开始缓存下一首**/
    {
        _integer_curPreadIndex++;
        while(_integer_curPreadIndex < [_array_playList count] &&
              ![_mediaProxy prereadWithURL:[_array_playList objectAtIndex:_integer_curPreadIndex]
                             WithAudioUrls:[_array_audioList objectAtIndex:_integer_curPreadIndex]])
        {
            _integer_curPreadIndex++;
        }
    }
}

#pragma mark - 下载失败回调 -
/**
 * 下载失败的消息处理
 */
- (void)handleDownloadFailed:(NSNotification *)note
{
    NSString    *url = (NSString*)[note object];
    if([url isEqualToString:ADVERTISE_URL])
    {
        //[self addTextToReceiveConsole:@"广告下载失败，请检查网络环境"];
    }
    else
    {
        //[self addTextToReceiveConsole:[NSString stringWithFormat:@"%@下载失败，请检查网络环境", url]];
    }
}

#pragma mark - 缓存失败消息处理 -
/**
 * 缓存失败的消息处理
 */
- (void)handleCacheFailed:(NSNotification *)note
{
    NSString *url = (NSString *)[note object];
    [_mediaProxy restartPrebuffer];
    /**重新尝试缓存**/
    NSLog(@"Cache failed, Check net: %@", url);
}

#pragma mark - 获取头文件成功 -
/**
 获取头文件成功
 **/
- (void)handleGetHeadFinish
{
    if(_bool_playingAdvertise)
    {
        _bool_waitForPlay = YES;
    }
    else
    {
        [self prepareAudioPlay];
        NSString *localURL = [_mediaProxy getLocalURLWithString:[_array_playList objectAtIndex:_integer_curPlayIndex]];
        [_moviePlayer_main setContentURL:[NSURL URLWithString:localURL]];
        [_moviePlayer_main play];
        /**
         在开始播放视频事件中同步播放音频
         **/
        [_originalPlayer play];
        [_progress_buffer setProgress:100.0];
        [self saveHistorySong];
        [self performSelector:@selector(selectReloadAlreadyView) withObject:nil afterDelay:1.0f];
    }
    [UIUtils view_showProgressHUD:@"歌曲授权成功" inView:_moviePlayer_main.view withTime:0.5f];
}

#pragma mark - 歌曲取头失败 -
/**
 歌曲取头失败
 **/
- (void)handleGetHeadFailed:(NSNotification *)note
{
    //NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    //UIAlertView     *alertDialog;
    //int             resultCode = [[state objectForKey:@"result"] intValue];
    
    /*if([[state objectForKey:@"result"] length] > 0 && 1 == resultCode)
    {
        alertDialog = [[UIAlertView alloc] initWithTitle:@"失败"
                                                 message:[state objectForKey:@"msg"]
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
        [alertDialog show];
    }*/
    [UIUtils view_showProgressHUD:@"歌曲授权失败" inView:self.view withTime:1.0f];
    [self performSelector:@selector(dissMissController) withObject:nil afterDelay:2.0f];
}

#pragma mark - 弹出播放器 -
/**
 弹出播放器
 **/
- (void)dissMissController
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissModalViewControllerAnimated:NO];
}

#pragma mark - 保存歌曲历史记录 -
/**
 保存歌曲历史记录
 **/
- (void)saveHistorySong
{
    _song_nowPlay.songPlayTime = [UIUtils getCurrentDateString];
    if([JDSqlDataBaseSongHistory countOfHistoryTable] == 20)
    {
        [JDSqlDataBaseSongHistory deleteSongOnTop];
    }
    [JDSqlDataBaseSongHistory saveSong:_song_nowPlay];
}

#pragma mark - 搜索歌曲处理 -
/**
 搜索歌曲处理
 **/
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(_view_searchView)
    {
        [_view_searchView removeFromSuperview];
        _view_searchView = nil;
    }
    JDSearchTableView *view_searchView = [[JDSearchTableView alloc] init];
    view_searchView.moviePlayer = self;
    [view_searchView searchSongWithString:[textField text]];
    [self.view addSubview:view_searchView];
    [view_searchView release];
    _view_searchView = view_searchView;
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.bool_isSearch = YES;
    [textField resignFirstResponder];
    if(_view_searchView)
    {
        [_view_searchView removeFromSuperview];
        _view_searchView = nil;
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(self.bool_isSearch)
    {
        self.bool_isSearch = NO;
        return NO;
    }
    return YES;
}

#pragma mark - 排序移动位置后回调函数 -
/**
 排序移动位置后回调函数
 **/
- (void)songTabelMoveReload
{
    _view_alreadySong.bool_currentAlready = YES;
    
    [_array_playList removeAllObjects];
    [_array_audioList removeAllObjects];
    [_array_playList addObject:_song_nowPlay.string_videoUrl];
    NSArray *array_tmp = [NSArray arrayWithObjects:_song_nowPlay.string_audio0Url,_song_nowPlay.string_audio1Url,nil];
    [_array_audioList addObject:array_tmp];
    
    JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
    NSMutableArray *array_already = [base reciveSongArrayWithTag:2];
    [base release];
    for (int i = 0; i<[array_already count]; i++)
    {
        SDSongs *song = [array_already objectAtIndex:i];
        [_array_playList addObject:song.string_videoUrl];
        NSArray *array_tmp = [NSArray arrayWithObjects:song.string_audio0Url,song.string_audio1Url,nil];
        [_array_audioList addObject:array_tmp];
    }
    [self reloadCacheList];
}

- (void)reloadCacheList
{
    _integer_curPlayIndex = 0;
    _integer_curPreadIndex = 0;
    
    [_mediaProxy prebufferWithUrl:[_array_playList objectAtIndex:_integer_curPlayIndex]
                    WithAudioUrls:[_array_audioList objectAtIndex:_integer_curPlayIndex]];
    
    if([_mediaProxy isPrebufferFinish])
    {
        /**缓冲下一首**/
        if(_integer_curPlayIndex < [_array_playList count] - 1)
        {
            _integer_curPreadIndex = _integer_curPlayIndex + 1;
            while(_integer_curPreadIndex < [_array_playList count] &&
                  ![_mediaProxy prereadWithURL:[_array_playList objectAtIndex:_integer_curPreadIndex]
                                 WithAudioUrls:[_array_audioList objectAtIndex:_integer_curPreadIndex]])
            {
                _integer_curPreadIndex ++;
            }
        }
    }
    else
    {
        return;
    }
}

#pragma mark - 点击屏幕控制 -
/**
 点击屏幕控制
 **/
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_bool_mixViewHave)
    {
        return;
    }
    if(_bool_touch)
    {
        if(self.bool_moviePlay)
        {
            if(_view_searchView)
            {
                [_view_searchView removeFromSuperview];
                _view_searchView = nil;
            }
            else
            {
                [self hiddenMovieController];
            }
            
        }
        else
        {
            [self showMovieController];
            //[self performSelector:@selector(hiddenMovieController) withObject:nil afterDelay:5.0f];
        }
    }
}

@end
