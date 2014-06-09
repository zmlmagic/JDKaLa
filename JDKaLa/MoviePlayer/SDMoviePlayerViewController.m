//
//  MoviePlayerViewController.m
//  JuKaLa
//
//  Created by 张 明磊 on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDMoviePlayerViewController.h"
#import <MediaPlayer/MPMusicPlayerController.h>
#import <AVFoundation/AVFoundation.h>
#import "NSString+NSString_TimeCategory.h"
#import "SKCustomNavigationBar.h"
#import "UIUtils.h"
#import "MBProgressHUD.h"
#import "MediaProxyGlobal.h"
#import "JDSqlDataBase.h"
#import "JDDataBaseRecordSound.h"
#import "JDSqlDataBaseSongHistory.h"
#import "JDModel_userInfo.h"
#import "CustomAlertView.h"
#import "JDMixerController.h"
#import "JDCircleSlider.h"


#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define JDLINKMOVIEDOWNSTART @"http://ep.iktv.tv/split_songs/"

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


@interface SDMoviePlayerViewController ()

@end

@implementation SDMoviePlayerViewController

@synthesize moviePlayerController;
@synthesize progressSlider;
@synthesize withOutAccompanyPlayer;
@synthesize accompanyPlayer;

#pragma mark -
#pragma mark SDMoiePlayerViewCotroller
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self startProxy];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[self stopProxy];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    IOS7_STATEBAR;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.bool_isSearch = NO;
    _bool_mixViewHave = NO;
    self.bool_moviePlay = YES;
    self.bool_isHUD = NO;
    self.bool_isAlreadyShow = YES;
    //self.bool_isHistoryOrSearchSong = NO;
    mediaProxy = [[MediaProxy alloc] init];
    [mediaProxy startProxy];
    //[self installKDeviceInPlayer];
    advList = [[NSMutableArray alloc]initWithCapacity:10];
    [self generateAdvList];
    curAdvIdx = 0;
    AudioSessionInitialize (NULL, NULL, NULL, NULL);
    //AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioRouteChangeListenerCallback,self);
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

/**
 监听耳机状态回调
 **/
/*void audioRouteChangeListenerCallback (
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
   
}*/

- (void)audioRouteChange:(NSNotification *)note
{
    [self.moviePlayerController play];
}

- (void)installKDeviceInPlayer
{
    /**自动释放类,无需release**/
    [self hiddenMovieController];
    [self.moviePlayerController.view addSubview:_mixController.view];
    [UIUtils addViewWithAnimation:_mixController.view inCenterPoint:CGPointMake(_mixController.view.center.x, 309)];
}

#pragma mark - 
- (void)viewDidUnload
{   
    [super viewDidUnload];
    [advList release];
    // Release any retained subviews of the main view.
}

static  SDMoviePlayerViewController *shareSDMoviePlayNetworkViewController = nil;

+ (SDMoviePlayerViewController *)sharedController
{
    @synchronized(self)
    {
        if(shareSDMoviePlayNetworkViewController == nil)
        {
            shareSDMoviePlayNetworkViewController = [[[self alloc] init] autorelease];
        }
    }
    return shareSDMoviePlayNetworkViewController;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (shareSDMoviePlayNetworkViewController == nil)
        {
            shareSDMoviePlayNetworkViewController = [super allocWithZone:zone];
            return  shareSDMoviePlayNetworkViewController;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (oneway void)release
{
    
}

- (id)autorelease
{
    return self;
}



- (void)dealloc
{
    [mediaProxy destroyProxy];
    [_view_alreadySong release], _view_alreadySong = nil;
    [_HUD release], _HUD = nil;
    [accompanyPlayer release], accompanyPlayer = nil;
    [withOutAccompanyPlayer release], withOutAccompanyPlayer = nil;
    [mediaProxy release], mediaProxy = nil;
    [moviePlayerController release], moviePlayerController = nil;
    [_slider_sound release], _slider_sound = nil;
    [self removeMovieNotificationHandlers];
    [_customControlStyle release], self.customControlStyle = nil;
    [progressSlider release], progressSlider = nil;
    [_bufferProgress release], _bufferProgress = nil;
    [_recordSound release], _recordSound = nil;
    [_view_playerTitle release], _view_playerTitle = nil;
    [_view_K release], _view_K = nil;
    [_song release], _song = nil;
    [_view_searchView release], _view_searchView = nil;
    [_recordedTmpFile release], _recordedTmpFile = nil;
    [_recorder release], _recorder = nil;
    [_song_next release], _song_next = nil;
    [super dealloc];
}

- (UIImage *)didLoadImageNotCached:(NSString *)filename
{
    NSString *imageFile = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], filename];
    return [UIImage imageWithContentsOfFile:imageFile];
}

#pragma mark -
#pragma mark Install Movie Notifications
/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    MPMoviePlayerController *player = [self moviePlayerController];
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(loadStateDidChange:) 
                                                 name:MPMoviePlayerLoadStateDidChangeNotification 
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(moviePlayBackDidFinish:) 
                                                 name:MPMoviePlayerPlaybackDidFinishNotification 
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(mediaIsPreparedToPlayDidChange:) 
                                                 name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification 
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(moviePlayBackStateDidChange:) 
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification 
                                               object:player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioRouteChange:)
                                                 name:@"audioRouteChange"
                                               object:nil];
}

#pragma mark -
#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationHandlers
{    
    MPMoviePlayerController *player = [self moviePlayerController];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"audioRouteChange" object:nil];
}

-(void)deletePlayerAndNotificationObservers
{
    [self removeMovieNotificationHandlers];
    [self setMoviePlayerController:nil];
}

#pragma mark -
#pragma mark Movie Notification Handlers
/*  Notification called when the movie finished playing. */
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    NSNumber *reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
	switch ([reason integerValue])
	{
            /* The end of the movie was reached. */
		case MPMovieFinishReasonPlaybackEnded:
             NSLog(@"1");
        {
            if(playingAdvertise || _bool_didClickBack)
            {
                
                return;
            }
            
            UIButton *button_next = [UIButton buttonWithType:UIButtonTypeCustom];
            [button_next setTag:SDMoviePlayerNext];
            [self didClickButton:button_next];
            
            /*[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            if(_bool_isK)
            {
                [_mixController stopMicphone];
                [_mixController release];
                
                [self KViewHidden];
                
                _bool_isK = NO;
            }
            if(self.bool_isHUD)
            {
                [MBProgressHUD hideHUDForView:self.moviePlayerController.view animated:YES];
                self.bool_isHUD = NO;
            }
            
            if(_bool_recordPlay)
            {
                [recordPlayer stop];
            }
            
            [self.moviePlayerController stop];
            [accompanyPlayer pause];
            [withOutAccompanyPlayer pause];
            [self stopProxy];
            [self removeMovieNotificationHandlers];
            [self dismissViewControllerAnimated:NO completion:nil];*/
        }break;
            /*
             Add your code here to handle MPMovieFinishReasonPlaybackEnded.
             */
			
            
            /* An error was encountered during playback. */
		case MPMovieFinishReasonPlaybackError:
            NSLog(@"2");
            NSLog(@"An error was encountered during playback");
            //[self performSelectorOnMainThread:@selector(displayError:) withObject:[[notification userInfo] objectForKey:@"error"]
            //                   waitUntilDone:NO];
            //[self removeMovieViewFromViewHierarchy];
            //[self removeOverlayView];
            //[self.backgroundView removeFromSuperview];
			break;
            
            /* The user stopped playback. */
		case MPMovieFinishReasonUserExited:
            NSLog(@"3");
            //NSTimer *exitedTime = [self.moviePlayerController ]
            //[self removeMovieViewFromViewHierarchy];
            //[self removeOverlayView];
            //[self.backgroundView removeFromSuperview];
            //[self playMovieGoOn];
			break;
            
		default:
			break;
	}
}

/* Called when the movie playback state has changed. */
- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
	MPMoviePlayerController *player = notification.object;
	/* Playback is currently stopped. */
	if (player.playbackState == MPMoviePlaybackStateStopped)
	{
        NSLog(@"stop");
	}
	/*  Playback is currently under way. */
	else if (player.playbackState == MPMoviePlaybackStatePlaying)
	{
        if(playingAdvertise)
        {
            return;
        }
        if(_isSeeking)
        {
            sleep(1);   //这里得停一下，否则取到的时间可能不准。
            NSTimeInterval curTime = [moviePlayerController currentPlaybackTime];
            [withOutAccompanyPlayer setCurrentTime:curTime];
            [accompanyPlayer setCurrentTime:curTime];
            _isSeeking = NO;
        }
        else
        {
            //sleep(1);   //这里得停一下，否则取到的时间可能不准。
            /*NSTimeInterval curTime = [moviePlayerController currentPlaybackTime];
             [withOutAccompanyPlayer setCurrentTime:curTime];
             [accompanyPlayer setCurrentTime:curTime];*/
            //[withOutAccompanyPlayer setVolume:0.0];
            if(syncAVTimer != nil)
            {
                [syncAVTimer invalidate];
                syncAVTimer = nil;
            }
            syncAVTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                           target:self
                                                         selector:@selector(syncAV)
                                                         userInfo:nil
                                                          repeats:YES];
        }
        [withOutAccompanyPlayer play];
        //[withOutAccompanyPlayer setVolume:1.0f];
        NSLog(@"play");
        //[self performSelectorInBackground:@selector(checkPlayState) withObject: nil];
        //[self performSelector:@selector(hiddenMovieController) withObject:nil afterDelay:5.0f];
	}
	/* Playback is currently paused. */
	else if (player.playbackState == MPMoviePlaybackStatePaused)
	{
        if(playingAdvertise)
        {
            return;
        }
        NSLog(@"paused");
        //[self.moviePlayerController setCurrentPlaybackTime:accompanyPlayer.currentTime];
	}
	/* Playback is temporarily interrupted, perhaps because the buffer
	 ran out of content. */
	else if (player.playbackState == MPMoviePlaybackStateInterrupted)
	{
        NSLog(@"interrupted");
	}
    else if (player.playbackState == MPMoviePlaybackStateSeekingForward)
    {
        if(!_bool_recordPlay)
        {
            _isSeeking = YES;
        }
        NSLog(@"forward");
    }
}


- (void)checkPlayState
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString    *songMD5 = [[NSString alloc]initWithString:[self.song songMd5]];
    
    sleep(5);
    if([songMD5 isEqualToString:[self.song songMd5]])
    {
        if([self bool_isK])
        {
            [withOutAccompanyPlayer setVolume:0.0];
            [accompanyPlayer setVolume:1.0];
        }
        else
        {
            [withOutAccompanyPlayer setVolume:1.0];
            [accompanyPlayer setVolume:0.0];
        }
    }
    
    /*sleep(3);
    if([songMD5 isEqualToString:[self.song songMd5]])
    {
        NSTimeInterval duration = [moviePlayerController playableDuration];
        NSLog(@"Movie Duration:%f",duration);
        if(duration < 0.1f)
        {
            NSLog(@"Movie Player is wrong state, quit.");
            //[self performSelector:@selector(dissMissController) withObject:nil afterDelay:1.0];
            //[self performSelectorOnMainThread:@selector(dissMissController) withObject:nil waitUntilDone:NO];
            //[self dissMissController];
            //[moviePlayerController stop];
        }
    }*/
    [songMD5 release];
    [pool release];
}

- (void)hiddenMovieController
{
    if(self.bool_isHUD)
    {
        [UIUtils hiddeView:_HUD];
    }
    self.bool_moviePlay = NO;
    [UIUtils hiddeView:_view_K];
    [UIUtils hiddeView:_customControlStyle];
    [UIUtils hiddeView:_view_playerTitle];
    
    if(_bool_isAlreadyShow)
    {
        [UIUtils hiddeView:_view_alreadySong];
    }
}
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


/* Notifies observers of a change in the prepared-to-play state of an object
 conforming to the MPMediaPlayback protocol. */
- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    // Add an overlay view on top of the movie view
}

- (void)loadStateDidChange:(NSNotification *)notification
{
	//MPMoviePlayerController *player = notification.object;
	//MPMovieLoadState loadState = player.loadState;
}

#pragma mark -
#pragma mark Movie Settings
- (void)installControlStyleForController:(MPMoviePlayerController *)controller
{
    [self installSignForButton];
    
    self.view_playerTitle = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 50)] autorelease];
    [self.view addSubview:self.view_playerTitle];
    
    SKCustomNavigationBar *customNavigationBar = [[SKCustomNavigationBar alloc] initWithFrame:CGRectMake(0, 0, 1024, 50)];
    [self.view_playerTitle addSubview:customNavigationBar];
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
    [label_titel setText:_song.songTitle];
    label_movieTitle = label_titel;
    [view_title addSubview:label_titel];
    [label_titel release];
    
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
    //[text_search setBackground:[self didLoadImageNotCached:@"search_field.png"]];
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
    _imageView_Hlight = imageView_row;
    [button_already addSubview:imageView_row];
    [imageView_row release];

    //title
    self.customControlStyle = [[[UIView alloc] initWithFrame:CGRectMake(0, 613, 1024, 155)]autorelease];
    [self.view addSubview:self.customControlStyle];
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
    [self installMoviePlayButton:moviePlayerPlay
                         withTag:SDMoviePlayerPlay];
    [self.customControlStyle addSubview:moviePlayerPlay];
    button_play = moviePlayerPlay;
    
    UIButton *button_again = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_again setFrame:CGRectMake(125, 80, 65, 65)];
    [UIUtils didLoadImageNotCached:@"player_btn_list_replay.png" inButton:button_again withState:UIControlStateNormal];
    [button_again addTarget:self
                          action:@selector(didClickButton:)
                forControlEvents:UIControlEventTouchUpInside];
    [self installMoviePlayButton:button_again
                         withTag:SDMoviePlayerAgain];
    [self.customControlStyle addSubview:button_again];
    
    //UILabel *label_again = [[UILabel alloc] initWithFrame:CGRectMake(137, 120, 50, 30)];
    //[label_again setTextColor:[UIColor whiteColor]];
    //[label_again setBackgroundColor:[UIColor clearColor]];
    //[label_again setFont:[UIFont systemFontOfSize:12.0f]];
    //[label_again setText:@"重播"];
    //[self.customControlStyle addSubview:label_again];
    //[label_again release];

    UIButton *button_next = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_next setFrame:CGRectMake(255, 80, 65, 65)];
    [UIUtils didLoadImageNotCached:@"player_btn_list_skip.png" inButton:button_next withState:UIControlStateNormal];
    [button_next addTarget:self
                          action:@selector(didClickButton:) 
                forControlEvents:UIControlEventTouchUpInside];
    [self installMoviePlayButton:button_next
                         withTag:SDMoviePlayerNext];
    [self.customControlStyle addSubview:button_next];
    
    /*UILabel *label_next = [[UILabel alloc] initWithFrame:CGRectMake(263, 120, 50, 30)];
    [label_next setTextColor:[UIColor whiteColor]];
    [label_next setBackgroundColor:[UIColor clearColor]];
    [label_next setFont:[UIFont systemFontOfSize:12.0f]];
    [label_next setText:@"下一首"];
    [self.customControlStyle addSubview:label_next];
    [label_next release];*/
    
    UIButton *button_K = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_K setFrame:CGRectMake(382, 80, 65, 65)];
    [UIUtils didLoadImageNotCached:@"player_btn_mode_ktv.png" inButton:button_K withState:UIControlStateNormal];
    [button_K addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    [button_K setTag:SDMoviePlayerK];
    [self.customControlStyle addSubview:button_K];
    _button_k = button_K;
    
    /*UILabel *label_K = [[UILabel alloc] initWithFrame:CGRectMake(387, 120, 50, 30)];
    [label_K setTextColor:[UIColor whiteColor]];
    [label_K setBackgroundColor:[UIColor clearColor]];
    [label_K setFont:[UIFont systemFontOfSize:12.0f]];
    [label_K setText:@"K歌模式"];
    [self.customControlStyle addSubview:label_K];
    [label_K release];
    _label_change_K = label_K;*/
    
    UIButton *moviePlayerRepeat = [UIButton buttonWithType:UIButtonTypeCustom];
    [moviePlayerRepeat setFrame:CGRectMake(515, 80, 65, 65)];
    [UIUtils didLoadImageNotCached:@"player_btn_list_mode_loop.png" inButton:moviePlayerRepeat withState:UIControlStateNormal];
    [moviePlayerRepeat addTarget:self
                          action:@selector(didClickButton:)
                forControlEvents:UIControlEventTouchUpInside];
    [self installMoviePlayButton:moviePlayerRepeat
                         withTag:SDMoviePlayerRepeat];
    [self.customControlStyle addSubview:moviePlayerRepeat];
    
    /*UILabel *label_repeat = [[UILabel alloc] initWithFrame:CGRectMake(508, 120, 50, 30)];
    [label_repeat setTextColor:[UIColor whiteColor]];
    [label_repeat setBackgroundColor:[UIColor clearColor]];
    [label_repeat setFont:[UIFont systemFontOfSize:12.0f]];
    [label_repeat setText:@"列表循环"];
    [self.customControlStyle addSubview:label_repeat];
    [label_repeat release];*/
    
    UIButton *button_favorite = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_favorite setFrame:CGRectMake(637,80,65,65)];
    if(_song.songFavoriteTag == 1)
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
    [self installMoviePlayButton:button_favorite 
                         withTag:SDMoviePlayerFavourite];
    [self.customControlStyle addSubview:button_favorite];
    
    /*UILabel *label_favorite = [[UILabel alloc] initWithFrame:CGRectMake(646, 120, 50, 30)];
    [label_favorite setTextColor:[UIColor whiteColor]];
    [label_favorite setBackgroundColor:[UIColor clearColor]];
    [label_favorite setFont:[UIFont systemFontOfSize:12.0f]];
    [label_favorite setText:@"收藏"];
    [self.customControlStyle addSubview:label_favorite];
    [label_favorite release];*/
    
    UIButton *button_sound = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_sound setFrame:CGRectMake(755, 95, 37, 37)];
    [UIUtils didLoadImageNotCached:@"player_btn_mute.png" inButton:button_sound withState:UIControlStateNormal];
    [self.customControlStyle addSubview:button_sound];
    
    [self installProgressSliderStyleForController:controller];
    [self installView_K];
}

- (void)didClickAlreadyButton:(id)sender
{
    if(_bool_isAlreadyShow)
    {
        [UIUtils didLoadImageNotCached:@"row_songList_down.png" inImageView:_imageView_Hlight];
        [UIUtils animationWhirlWith:_imageView_Hlight withPointMake:CGPointMake(27, 18) andRemovedOnCompletion:NO andDirection:1];
        [UIUtils removeViewWithAnimation:_view_alreadySong inCenterPoint:CGPointMake(_view_alreadySong.center.x, -346) withBoolRemoveView:NO];
    }
    else
    {
        [UIUtils didLoadImageNotCached:@"row_songList_up.png" inImageView:_imageView_Hlight];
        [UIUtils animationWhirlWith:_imageView_Hlight withPointMake:CGPointMake(27, 18) andRemovedOnCompletion:NO andDirection:-1];
        [UIUtils removeViewWithAnimation:_view_alreadySong inCenterPoint:CGPointMake(_view_alreadySong.center.x, 346) withBoolRemoveView:NO];
    }
    _bool_isAlreadyShow = !_bool_isAlreadyShow;
}


- (void)installProgressSliderStyleForController:(MPMoviePlayerController *)controller
{
    startLable = [[UILabel alloc] initWithFrame:CGRectMake(85, 25, 40, 30)];
    [startLable setBackgroundColor:[UIColor clearColor]];
    [startLable setTextColor:[UIColor whiteColor]];
    [startLable setFont:[UIFont systemFontOfSize:12.0f]];
    [self.customControlStyle addSubview:startLable];
    [startLable release];
    endLable = [[UILabel alloc] initWithFrame:CGRectMake(115, 25, 40, 30)];
    [endLable setTextColor:[UIColor whiteColor]];
    [endLable setBackgroundColor:[UIColor clearColor]];
    [endLable setFont:[UIFont systemFontOfSize:12.0f]];
    [self.customControlStyle addSubview:endLable];
    [endLable release];
    [self updateCurrentTimeForPlayer:self.moviePlayerController];
    
    if(IOS7_VERSION)
    {
        progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(65, 38, 940, 9)];
    }
    else
    {
        progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(65, 48, 940, 9)];
    }
    
    _bufferProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(70, 54, 930, 10)];
   
    [progressSlider setBackgroundColor:[UIColor clearColor]];
    [_bufferProgress setBackgroundColor:[UIColor clearColor]];
    [progressSlider setThumbImage:[self didLoadImageNotCached:@"player_progress_bar_btn.png"] forState:UIControlStateNormal];
    [progressSlider setMinimumTrackImage:[self didLoadImageNotCached:@"player_progress_bar.png"] forState:UIControlStateNormal];
    [progressSlider setMaximumTrackTintColor:[UIColor clearColor]];
    [progressSlider setMaximumTrackImage:[self didLoadImageNotCached:@"player_progress_back_bg.png"] forState:UIControlStateNormal];
    [_bufferProgress setTrackTintColor:[UIColor blackColor]];
    [_bufferProgress setProgressImage:[self didLoadImageNotCached:@"player_progress_bar2.png"]];
    [progressSlider addTarget:self action:@selector(progressSliderMoved:) forControlEvents:UIControlEventValueChanged];
    [progressSlider addTarget:self action:@selector(progressSliderMoved_finish) forControlEvents:UIControlEventTouchUpInside];
    [progressSlider addTarget:self action:@selector(progressSliderMoved_finish) forControlEvents:UIControlEventTouchUpOutside];
    
    if (updateTimer)
    {
        [updateTimer invalidate];
        updateTimer = nil;
    }
    else
    {
        progressSlider.maximumValue = controller.duration;
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:.01
                                                           target:self
                                                         selector:@selector(updateCurrentTime) userInfo:self.moviePlayerController repeats:YES];
    }
    
    [self.customControlStyle addSubview:_bufferProgress];
    [self.customControlStyle addSubview:progressSlider];
    [progressSlider release];
    [_bufferProgress release];
    
    _slider_sound = [[UISlider alloc] initWithFrame:CGRectMake(800, 100, 200, 25)];
    [_slider_sound setThumbImage:[self didLoadImageNotCached:@"player_progress_bar_btn.png"] forState:UIControlStateNormal];
    [_slider_sound setMinimumTrackImage:[self didLoadImageNotCached:@"player_progress_bar.png"] forState:UIControlStateNormal];
    [_slider_sound setMaximumTrackImage:[self didLoadImageNotCached:@"player_progress_bar_bg.png"] forState:UIControlStateNormal];
    [_slider_sound addTarget:self action:@selector(progressSliderMoved_sound:) forControlEvents:UIControlEventValueChanged];

    _slider_sound.maximumValue = 1.0;
    [self.customControlStyle addSubview:_slider_sound];
    [_slider_sound release];
    
    _view_alreadySong = [[JDAlreadySongView alloc] init];
    [_view_alreadySong setSong_current:_song];
    [_view_alreadySong configureView_table];
    [self.view addSubview:_view_alreadySong];
    [_view_alreadySong setAlpha:0.0f];
    [_view_alreadySong release];
}


- (void)updateCurrentTime
{
	[self updateCurrentTimeForPlayer:self.moviePlayerController];
}


-(void)updateCurrentTimeForPlayer:(MPMoviePlayerController *)p
{
    NSString *current = [NSString stringWithFormat:@"%d:%02d", (int)p.currentPlaybackTime / 60, (int)p.currentPlaybackTime % 60, nil];
    NSString *dur = [NSString stringWithFormat:@"/%d:%02d", (int)((int)(p.duration)) / 60, (int)((int)(p.duration)) % 60, nil];
	//NSString *dur = [NSString stringWithFormat:@"/%d:%02d", (int)((int)(p.duration - p.currentPlaybackTime)) / 60, (int)((int)(p.duration - p.currentPlaybackTime)) % 60, nil];
	startLable.text = current;
    endLable.text = dur;
    progressSlider.maximumValue = p.duration;
    if(_bool_isDragging)
    {
        return;
    }
	else
    {
        progressSlider.value = p.currentPlaybackTime;
    }
}

#pragma mark - 播放器按钮回调事件 -
/**
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
        case SDMoviePlayerReturn:
        {
            _bool_didClickBack = YES;
            if(_bool_isK)
            {
                [_mixController stopMicphone];
                [_mixController release];
                
                [self KViewHidden];
                
                _bool_isK = NO;
            }
            if(self.bool_isHUD)
            {
                [MBProgressHUD hideHUDForView:self.moviePlayerController.view animated:YES];
                self.bool_isHUD = NO;
            }
            
            if(_bool_recordPlay)
            {
                [recordPlayer stop];
            }
            
            [self.moviePlayerController stop];
            [accompanyPlayer pause];
            [withOutAccompanyPlayer pause];
            [self stopProxy];
            [self removeMovieNotificationHandlers];
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            [self dismissViewControllerAnimated:NO completion:nil];
            //[_navigationController_return popViewControllerAnimated:YES];
            //[UIUtils removeViewWithAnimation:self.view inCenterPoint:CGPointMake(self.view.center.x -1024, self.view.center.y) withBoolRemoveView:NO];
            
        }break;
        case SDMoviePlayerPlay: 
        {
            if(signForPlayOrStop)
            {
                [self.moviePlayerController pause];
                [accompanyPlayer pause];
                [withOutAccompanyPlayer pause];
                [UIUtils didLoadImageNotCached:@"player_btn_play.png" inButton:button withState:UIControlStateNormal];
            }
            else 
            {
                [self.moviePlayerController play];
                [accompanyPlayer play];
                [withOutAccompanyPlayer play];
                [UIUtils didLoadImageNotCached:@"player_btn_pause.png" inButton:button withState:UIControlStateNormal];
            }
            signForPlayOrStop = !signForPlayOrStop;
            break;
        }
            
        case SDMoviePlayerK:
        {
            _bool_isK = !_bool_isK;
            UIButton *button_qiehuan = (UIButton *)[_view_K viewWithTag:SDMoviePlayerQieHuan];
            if(_bool_isK)
            {
                [self view_showProgressHUD:@"k歌模式开启"];
                [withOutAccompanyPlayer setVolume:0.0];
                [accompanyPlayer setVolume:1.0];
                [UIUtils didLoadImageNotCached:@"player_btn_mode_mv.png" inButton:button withState:UIControlStateNormal];
                [self KViewShow];
                JDMixerController *mix = [[JDMixerController alloc] init];
                [mix startMicphone];
                [mix installMiddleK];
                self.mixController = mix;
                [self switchToAccompanyTrack:button_qiehuan];
            }
            else
            {
                [self view_showProgressHUD:@"听歌模式开启"];
                [withOutAccompanyPlayer setVolume:1.0];
                [accompanyPlayer setVolume:0.0];
                [UIUtils didLoadImageNotCached:@"player_btn_mode_ktv.png" inButton:button withState:UIControlStateNormal];
                [_mixController stopMicphone];
                //[_mixController release];
                [self KViewHidden];
                [self switchToOriginalTrack:button_qiehuan];
            }
        }break;
            
        case SDMoviePlayerAgain:
        {
            [self.moviePlayerController setCurrentPlaybackTime:0.0f];
            [withOutAccompanyPlayer setCurrentTime:0.0f];
            [accompanyPlayer setCurrentTime:0.0f];
        }break;
            
        case SDMoviePlayerNext:
        {
            _view_alreadySong.bool_currentAlready = YES;
            
            if([SDMoviePlayerViewController sharedController].bool_isHUD)
            {
                [SDMoviePlayerViewController sharedController].bool_isHUD = NO;
                [MBProgressHUD hideHUDForView:[SDMoviePlayerViewController sharedController].moviePlayerController.view animated:YES];
            }
            
            JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
            NSMutableArray *array_already = [base reciveSongArrayWithTag:2];
            
            BOOL bool_order = NO;
            for (int j = 0; j<[array_already count]; j++)
            {
                SDSongs *tmp = [array_already objectAtIndex:j];
                if([tmp.songMd5 isEqualToString:_song.songMd5])
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
                    tmp = [array_already objectAtIndex:1];  
                }
            }
            else
            {
                if([array_already count] == 0)
                {
                    tmp = _song;
                }
                else
                {
                    tmp = [array_already objectAtIndex:0];
                }
            }

            [self moviePlayerChangeState];
            [self setSong:tmp];
            [self playMovieWithLink:tmp.songMd5];
            
            //JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
            [base changeAlreadySongList_next:tmp];
            [base release];
            
            self.bool_isHistoryOrSearchSong = NO;
            
        }break;
            
        case SDMoviePlayerRecord:
        {
            if(signForRecordOrStop)
            {
                [UIUtils didLoadImageNotCached:@"luyin_pressed.png" inButton:button withState:UIControlStateNormal];
                _recordSound = nil;
                _recordSound = [[SDRecordSound alloc] init];
                _recordSound.integer_recordSign = [[NSString stringWithTimeForSInt:[accompanyPlayer currentTime]] integerValue];
                _recordSound.string_defaultRecordName = _song.songTitle;
                _recordSound.string_recordMD5 = _song.songMd5;
                NSTimeInterval startTime = [moviePlayerController currentPlaybackTime];
                _recordSound.string_recordStartTime = [NSString stringWithTime:startTime];
                [self recordSound_begin];
            }
            else
            {
                [UIUtils didLoadImageNotCached:@"luyin.png" inButton:button withState:UIControlStateNormal];
                _recordSound.string_recordEndTime = nil;
                _recordSound.string_recordEndTime = [NSString stringWithTime:accompanyPlayer.currentTime];
                _recordSound.string_videoUrl = _song.string_videoUrl;
                _recordSound.string_audio0Url = _song.string_audio0Url;
                _recordSound.string_audio1Url = _song.string_audio1Url;
                [self recordSound_finish];
            }
            signForRecordOrStop = !signForRecordOrStop;
        }break;
        
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
            
        case SDMoviePlayerRepeat:
        {
            NSLog(@"repeat");
            break;
        }
        
        case SDMoviePlayerFavourite:
        {
            JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
            [base selectSongandChangeItTag:_song];
            NSString *string_favor = [button titleForState:UIControlStateReserved];
            if([string_favor isEqualToString:@"UIControlStateNormal"])
            {
                [UIUtils didLoadImageNotCached:@"player_btn_favor_added.png" inButton:button withState:UIControlStateNormal];
                [button setTitle:@"UIControlStateHighlighted" forState:UIControlStateReserved];
                _song.songFavoriteTag = 1;
                if([base saveSong:_song withTag:1])
                {
                    [UIUtils view_showProgressHUD:@"已添加至收藏列表" inView:self.view withTime:1.0f];
                }
            }
            else if([string_favor isEqualToString:@"UIControlStateHighlighted"])
            {
                [UIUtils didLoadImageNotCached:@"player_btn_favor.png" inButton:button withState:UIControlStateNormal];
                [button setTitle:@"UIControlStateNormal" forState:UIControlStateReserved];
                [base deleteSongFormLocalSingerWithString:_song withTag:1];
                _song.songFavoriteTag = 0;
                [UIUtils view_showProgressHUD:@"已移出播收藏列表" inView:self.view withTime:1.0f];
            }
            [base release];
        }break;
         
        case SDMoviePlayerMix:
        {
            [UIUtils didLoadImageNotCached:@"hunyin_pressed.png" inButton:button withState:UIControlStateHighlighted];
             //_integer_mixTag = 0;
            [self installKDeviceInPlayer];
            _bool_mixViewHave = YES;
            [self hiddenMovieController];
        }break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark switchAudioTrack

//切换到伴唱
- (void)switchToAccompanyTrack:(UIButton*)button
{
    [UIUtils didLoadImageNotCached:@"qiehuan_pressed.png" inButton:button withState:UIControlStateNormal];
    [button setTitle:@"UIControlStateSelected" forState:UIControlStateReserved];
    signForAccompanyOrOriginal = NO;
}

//切换到原唱
- (void)switchToOriginalTrack:(UIButton*)button
{
    [UIUtils didLoadImageNotCached:@"qiehuan.png" inButton:button withState:UIControlStateNormal];
    [button setTitle:@"UIControlStateNormal" forState:UIControlStateReserved];
    signForAccompanyOrOriginal = YES;
}


#pragma mark -
#pragma mark progressSliderMoved
- (void)progressSliderMoved:(UISlider *)sender
{
    _bool_isDragging = YES;
    [moviePlayerController pause];
    [withOutAccompanyPlayer pause];
    [accompanyPlayer pause];
    self.moviePlayerController.currentPlaybackTime = sender.value;
    accompanyPlayer.currentTime = sender.value;
    withOutAccompanyPlayer.currentTime = sender.value;
}

- (void)progressSliderMoved_finish
{
    _bool_isDragging = NO;
    [moviePlayerController play];
    [withOutAccompanyPlayer play];
    [accompanyPlayer play];
}

- (void)progressSliderMoved_sound:(UISlider *)sender
{
    MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
    mpc.volume = sender.value;
}

#pragma mark - 
#pragma mark InstallView
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

- (void)soundTrackChange
{
    int volume = withOutAccompanyPlayer.volume;
    withOutAccompanyPlayer.volume = accompanyPlayer.volume;
    accompanyPlayer.volume = volume;
}


- (void)installMoviePlayButton:(UIButton *)button withTag:(SDMoviePlayerButtonTag) buttonType
{
    button.tag = buttonType;
}

- (void)installSignForButton
{
    signForPlayOrStop = YES;
    signForRecordOrStop = YES;
    signForAccompanyOrOriginal = YES;    
}

- (void)installView_K
{
    _view_K = [[UIView alloc] initWithFrame:CGRectMake(0, 170, 98, 345)];
    UIImageView *imageView_k = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 98, 345)];
    [imageView_k setImage:[self didLoadImageNotCached:@"player_effect_level1_bg.png"]];
    [_view_K addSubview:imageView_k];
    [imageView_k release];
    
    UIButton *button_record = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_record setFrame:CGRectMake(5, 5, 80, 80)];
    [button_record setBackgroundImage:[self didLoadImageNotCached:@"player_effect_level1_btn_record2.png"] forState:UIControlStateNormal];
    [button_record setTitle:@"UIControlStateNormal" forState:UIControlStateReserved];
    [button_record setUserInteractionEnabled:NO];
    [button_record setTag:SDMoviePlayerRecord];
    [button_record addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    [_view_K addSubview:button_record];
    
    /*UILabel *label_record = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, 83, 30)];
    [label_record setBackgroundColor:[UIColor clearColor]];
    [label_record setTextColor:[UIColor whiteColor]];
    [label_record setFont:[UIFont systemFontOfSize:13.0f]];
    [label_record setText:@"录音中"];
    [label_record setTextAlignment:NSTextAlignmentCenter];
    [_view_K addSubview:label_record];
    [label_record release];*/
    
    UIButton *button_mix = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_mix setFrame:CGRectMake(5, 87.5, 80, 80)];
    [button_mix setUserInteractionEnabled:NO];
    [button_mix setTitle:@"UIControlStateNormal" forState:UIControlStateReserved];
    [button_mix setBackgroundImage:[self didLoadImageNotCached:@"player_effect_level1_btn_mixing2.png"] forState:UIControlStateNormal];
    [button_mix setTag:SDMoviePlayerMix];
    [button_mix addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    [_view_K addSubview:button_mix];
    
    /*UILabel *label_mix = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, 83, 30)];
    [label_mix setBackgroundColor:[UIColor clearColor]];
    [label_mix setTextColor:[UIColor whiteColor]];
    [label_mix setFont:[UIFont systemFontOfSize:13.0f]];
    [label_mix setText:@"音轨切换"];
    [label_mix setTextAlignment:NSTextAlignmentCenter];
    [_view_K addSubview:label_mix];
    [label_mix release];*/
    
    UIButton *button_backSound = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_backSound setFrame:CGRectMake(5, 170, 80, 80)];
    [button_backSound setTitle:@"UIControlStateNormal" forState:UIControlStateReserved];
    [button_backSound setBackgroundImage:[self didLoadImageNotCached:@"player_effect_level1_btn_music2.png"] forState:UIControlStateNormal];
    [button_backSound setUserInteractionEnabled:NO];
    [button_backSound setTag:SDMoviePlayerBackSound];
    [button_backSound addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    [_view_K addSubview:button_backSound];
    
    /*UILabel *label_Microphone = [[UILabel alloc] initWithFrame:CGRectMake(0, 205, 83, 30)];
    [label_Microphone setBackgroundColor:[UIColor clearColor]];
    [label_Microphone setTextColor:[UIColor whiteColor]];
    [label_Microphone setFont:[UIFont systemFontOfSize:13.0f]];
    [label_Microphone setText:@"麦克音量"];
    [label_Microphone setTextAlignment:NSTextAlignmentCenter];
    [_view_K addSubview:label_Microphone];
    [label_Microphone release];*/
    
    UIButton *button_qieHuan = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_qieHuan setFrame:CGRectMake(5, 252.5, 80, 80)];
    [button_qieHuan setTitle:@"UIControlStateNormal" forState:UIControlStateReserved];
    [button_qieHuan setBackgroundImage:[self didLoadImageNotCached:@"qiehuan.png"] forState:UIControlStateNormal];
    [button_qieHuan setTag:SDMoviePlayerQieHuan];
    [button_qieHuan addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    [_view_K addSubview:button_qieHuan];
    
    /*UILabel *label_BackSound = [[UILabel alloc] initWithFrame:CGRectMake(0, 280, 83, 30)];
    [label_BackSound setBackgroundColor:[UIColor clearColor]];
    [label_BackSound setTextColor:[UIColor whiteColor]];
    [label_BackSound setFont:[UIFont systemFontOfSize:13.0f]];
    [label_BackSound setText:@"背景音量"];
    [label_BackSound setTextAlignment:NSTextAlignmentCenter];
    [_view_K addSubview:label_BackSound];
    [label_BackSound release];*/
    
    [self.moviePlayerController.view addSubview:_view_K];
    [_view_K release];
}

- (void)removeKView
{
    if(_view_K)
    {
        [_view_K removeFromSuperview];
        _view_K = nil;
    }
}


#pragma mark - 
#pragma mark RecordSound
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

- (void)recordSound_finish
{
    signForPlayOrStop = !signForPlayOrStop;
    [UIUtils didLoadImageNotCached:@"player_btn_play.png" inButton:button_play withState:UIControlStateNormal];
    [_recorder stop];
    //[self.moviePlayerController pause];
    //[accompanyPlayer pause];
    //[withOutAccompanyPlayer pause];
    _recordSound.integer_mixTag = _integer_mixTag;
    NSString *string_recordName_tmp = [_recordSound.string_defaultRecordName stringByAppendingString:@"_"];
    _recordSound.string_recordName = [string_recordName_tmp stringByAppendingString:[JDModel_userInfo sharedModel].string_nickName];
    /*_recordSound.string_recordName = [string_recordName_tmp stringByAppendingString:[JDModel_userInfo sharedModel].string_userName];*/
    _recordSound.string_dateTime = [UIUtils getCurrentDateString];
    [JDDataBaseRecordSound saveRecord:_recordSound];
    
    CustomAlertView *alter = [[CustomAlertView alloc] initWithTitle:@"录音已保存" message:@"保存成功" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil];
    
    [alter show];
    [alter release];
}


/*- (void)finishRecord
{
    [self.moviePlayerController stop];
    self.moviePlayerController = nil;
    [accompanyPlayer stop];
    [recordPlayer stop];
    [self dismissViewControllerAnimated:NO completion:nil];
    accompanyPlayer = nil;
}*/

#pragma mark - 视屏启动播放 -
/**
 视屏启动播放
 **/
- (void)playMovieBegin
{
    
}

#pragma mark - 初始化播放器参数 -
//- (void)

#pragma mark - 
#pragma mark PlayMovieInMaster 

/**
 播放视频
 参数:link为歌曲md5
 **/
- (void)playMovieWithLink:(NSString *)link
{
    _bool_touch = NO;
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    //_bool_audioMix = YES;
    _bool_isDragging = NO;
    _bool_isK = NO;
    _bool_recordPlay = NO;
     _bool_didClickBack = NO;
	// mute should be on at launch
    if(!moviePlayerController)
    {
        //[self installKDeviceInPlayer];
        //[self installKDeviceInPlayer_mix];
        moviePlayerController = [[MPMoviePlayerController alloc] init];
        [moviePlayerController setMovieSourceType:MPMovieSourceTypeFile];
        [[moviePlayerController view] setFrame:CGRectMake(0, 0, 1024, 768)];
        [moviePlayerController setControlStyle:MPMovieControlStyleNone];
        [moviePlayerController setFullscreen:YES];
        [[self view]addSubview:[moviePlayerController view]];
        
        [self installControlStyleForController:self.moviePlayerController];
        [self installMovieNotificationObservers];
        
        [self prepareForProxyWithLink:[self linkUrlForMovieWithSong:link]];
        [self proxyPlay];
        [self startProxy];
    }
    else
    {
        [_bufferProgress setProgress:0.0f];
        [progressSlider addTarget:self action:@selector(progressSliderMoved:) forControlEvents:UIControlEventValueChanged];
        [progressSlider addTarget:self action:@selector(progressSliderMoved_finish) forControlEvents:UIControlEventTouchUpInside];
        [self removeMovieNotificationHandlers];
        [self installMovieNotificationObservers];
        
        UIButton *button_favor = (UIButton *)[_customControlStyle viewWithTag:SDMoviePlayerFavourite];
        JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
        [base selectSongandChangeItTag:_song];
        [base release];
        if(_song.songFavoriteTag == 1)
        {
            [UIUtils didLoadImageNotCached:@"player_btn_favor_added.png" inButton:button_favor withState:UIControlStateNormal];
            [button_favor setTitle:@"UIControlStateHighlighted" forState:UIControlStateReserved];
        }
        else
        {
            [UIUtils didLoadImageNotCached:@"player_btn_favor.png" inButton:button_favor withState:UIControlStateNormal];
            [button_favor setTitle:@"UIControlStateNormal" forState:UIControlStateReserved];
        }
        
        
        [label_movieTitle setText:_song.songTitle];
        [_view_alreadySong setSong_current:_song];
        [_view_alreadySong reloadTableView];
        [_view_alreadySong tableScrollToPosition];
        [self prepareForProxyWithLink:[self linkUrlForMovieWithSong:link]];
        [self proxyPlay];
        [self startProxy];
    }
    
    MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
    [_slider_sound setValue:mpc.volume];
}


- (NSString *)linkUrlForMovieWithSong:(NSString *)song
{
    NSString *directory = [song substringToIndex:2];
    NSString *linkMovieDirectory = [directory stringByAppendingString:@"/"];
    linkMovieDirectory = [linkMovieDirectory stringByAppendingString:song];
    NSString *linkMovieDown = [JDLINKMOVIEDOWNSTART stringByAppendingString:linkMovieDirectory];
    linkMovieDown = [linkMovieDown stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return linkMovieDown;
}

#pragma mark - 歌曲切换配置环境切换 -
/**
 歌曲切换配置环境切换
 **/
- (void)moviePlayerChangeState
{
    if(_bool_isK)
    {
        [_mixController stopMicphone];
        [_mixController release];
        [withOutAccompanyPlayer setVolume:1.0];
        [accompanyPlayer setVolume:0.0];
        [UIUtils didLoadImageNotCached:@"player_btn_mode_ktv.png" inButton:_button_k withState:UIControlStateNormal];
        [self KViewHidden];
        [recordPlayer pause];
    }
   
    [self.moviePlayerController pause];
    [accompanyPlayer pause];
    [withOutAccompanyPlayer pause];
    [self stopProxy];
}

#pragma mark - 排序移动位置后回调函数 -
/**
 排序移动位置后回调函数
 **/
- (void)songTabelMoveReload
{
    _view_alreadySong.bool_currentAlready = YES;
    //NSString *string_url = [playlist objectAtIndex:0];
    //int tmp = [mediaProxy getPrereadPercent:string_url];
    //NSLog(@"%d",tmp);
    [playlist removeAllObjects];
    [audioList removeAllObjects];
    //NSString *link = _song.songMd5;
    //playlist = [[NSMutableArray alloc]initWithArray:[self reciveMovieFromLink:link]];
    //audioList = [[NSMutableArray alloc]initWithObjects:[self reciveAudioFromLink:link],nil];
    
    [playlist addObject:_song.string_videoUrl];
    NSArray *array_tmp = [NSArray arrayWithObjects:_song.string_audio0Url,_song.string_audio1Url,nil];
    [audioList addObject:array_tmp];
    
    
    JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
    NSMutableArray *array_already = [base reciveSongArrayWithTag:2];
    
    for (int i = 0; i<[array_already count]; i++)
    {
        SDSongs *song = [array_already objectAtIndex:i];
        [playlist addObject:song.string_videoUrl];
        NSArray *array_tmp = [NSArray arrayWithObjects:song.string_audio0Url,song.string_audio1Url,nil];
        [audioList addObject:array_tmp];
    }
    [base release];
    //[_view_alreadySong reloadTableViewWhenCacheSong];
    //[self performSelector:@selector(reloadCacheList) withObject:nil afterDelay:0.5f];
    
    [self reloadCacheList];
}

- (void)reloadCacheList
{
    /*if(!_view_alreadySong.cacheProgressSlider)
    {
        [_view_alreadySong beginCacheNextSong];
    }*/
    
    int cur = 0;
    [mediaProxy prebufferWithUrl:[playlist objectAtIndex:cur] WithAudioUrls:[audioList objectAtIndex:cur]];
    
    //playingAdvertise = NO;
    //waitForPlay = NO;
    //_isSeeking = NO;
    
    if([mediaProxy isPrebufferFinish])
    {
        if(cur < [playlist count] - 1)
        {
            cur = cur + 1;
            while(cur < [playlist count] &&
                  ![mediaProxy prereadWithURL:[playlist objectAtIndex:cur] WithAudioUrls:[audioList objectAtIndex:cur]])
            {
                cur++;
            }
            //[self addTextToReceiveConsole:@"开始预读下一首歌曲"];
        }
    }
    else 
    {
        return;
    }
}

#pragma mark - 
#pragma mark Proxy
- (void)prepareForProxyWithLink:(NSString *)link
{
    
    prebufferForPlay = NO;
    playingAdvertise = NO;
    
    [playlist removeAllObjects];
    [audioList removeAllObjects];
    
    playlist = [[NSMutableArray alloc]initWithArray:[self reciveMovieFromLink:link]];
    audioList = [[NSMutableArray alloc]initWithObjects:[self reciveAudioFromLink:link],nil];
    
    JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
    NSMutableArray *array_already = [base reciveSongArrayWithTag:2];
    
    for (int i = 0; i<[array_already count]; i++)
    {
        SDSongs *song = [array_already objectAtIndex:i];
        //NSString *directory = [link substringFromIndex:33];
        //NSLog(@"%@",directory);
        
            //NSString *songPath = [[self linkUrlForMovieWithSong:song.songMd5] stringByAppendingString:@"-0"];
            //songPath = [songPath stringByAppendingString:@".mp4"];
            //[playlist addObject:songPath];
        [playlist addObject:song.string_videoUrl];
            
        NSArray *array_tmp = [NSArray arrayWithObjects:song.string_audio0Url,song.string_audio1Url,nil];
            //NSArray *array_tmp = [self reciveAudioFromLink:[self linkUrlForMovieWithSong:song.songMd5]];
        [audioList addObject:array_tmp];
        
    }
    [base release];
   
    withOutAccompanyPlayer = nil;
    accompanyPlayer = nil;
}


- (void)startProxy
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(handleReceiveRequest:)
               name:NOTI_REQUEST_RECEIVE
             object:nil];
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
    /*[nc addObserver:self
           selector:@selector(handleDownloadFinish:)
               name:NOTI_MEDIA_DOWNLOAD_FINISH
             object:nil];*/
    [nc addObserver:self
           selector:@selector(handleDownloadFailed:)
               name:NOTI_MEDIA_DOWNLOAD_FAILED
             object:nil];
    [nc addObserver:self
           selector:@selector(handleCacheFailed:)
               name:NOTI_CACHE_FAILED
             object:nil];
    
    [nc addObserver:self
           selector:@selector(handlePlaybackFinish)
               name:MPMoviePlayerPlaybackDidFinishNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(handleGetHeadFinish)
               name:NOTI_GET_HEAD_FINISH
             object:nil];
    
    [nc addObserver:self
           selector:@selector(handleGetHeadFailed:)
               name:NOTI_GET_HEAD_FAILED
             object:nil];
    
    
    NSLog(@"代理已启动");
}

#pragma mark - 停止代理 -
/**
 停止代理
 **/
- (void)stopProxy
{
    if(syncAVTimer != nil)
    {
        [syncAVTimer invalidate];
        syncAVTimer = nil;
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self
                  name:NOTI_REQUEST_RECEIVE
                object:nil];
    [nc removeObserver:self
                  name:NOTI_CACHE_PROGRESS_CHANGE
                object:nil];
    [nc removeObserver:self
                  name:NOTI_DOWNLOAD_PROGRESS_CHANGE
                object:nil];
    [nc removeObserver:self
                  name:NOTI_PREBUFFER_FINISH
                object:nil];
    //    [nc removeObserver
    //               name:NOTI_MEDIA_DOWNLOAD_FINISH
    //             object:nil];
    [nc removeObserver:self
                  name:NOTI_MEDIA_DOWNLOAD_FAILED
                object:nil];
    [nc removeObserver:self
                  name:NOTI_CACHE_FAILED
                object:nil];
    
    [nc removeObserver:self
                  name:MPMoviePlayerPlaybackDidFinishNotification
                object:nil];
    
    [nc removeObserver:self
                  name:NOTI_GET_HEAD_FINISH
                object:nil];
    
    [nc removeObserver:self
                  name:NOTI_GET_HEAD_FAILED
                object:nil];
    [mediaProxy stopPreread];
    [mediaProxy stopPrebuffer];
    //NSLog(@"代理已停止");
}

- (void)proxyPlay
{
    //[moviePlayerController stop];
    [mediaProxy prebufferWithUrl:[playlist objectAtIndex:curPlayIdx] WithAudioUrls:[audioList objectAtIndex:curPlayIdx]];
    
    playingAdvertise = NO;
    waitForPlay = NO;
    _isSeeking = NO;
    
    if([mediaProxy isPrebufferFinish])
    {
        [mediaProxy getHead:_song.songMd5 UserID:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
        //[mediaProxy getHead];
        /*[self prepareAudioPlay];
        NSLog(@"Play:%@", [mediaProxy videoLocalFile]);
        [moviePlayerController setContentURL:[NSURL fileURLWithPath:[mediaProxy videoLocalFile]]];
        [moviePlayerController play];*/
        
        if(curPlayIdx < [playlist count] - 1)
        {
            curPreadIdx = curPlayIdx + 1;
            while(curPreadIdx < [playlist count] &&
                  ![mediaProxy prereadWithURL:[playlist objectAtIndex:curPreadIdx] WithAudioUrls:[audioList objectAtIndex:curPreadIdx]])
            {
                curPreadIdx++;
            }
            //[self addTextToReceiveConsole:@"开始预读下一首歌曲"];
        }
    }
    else if([mediaProxy getPrebufferPercent] > 5)
    {
        [mediaProxy getHead:_song.songMd5 UserID:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
        //[mediaProxy getHead];
        /*[self prepareAudioPlay];
        NSString    *localURL = [mediaProxy getLocalURLWithString:[playlist objectAtIndex:curPlayIdx]];
        [moviePlayerController setContentURL:[NSURL URLWithString:localURL]];
        [moviePlayerController play];*/
    }
    else
    {
        playingAdvertise = YES;
        prebufferForPlay = YES;
        //NSString *advName = [NSString stringWithFormat:@"%@/%@/3.mp4", [UIUtils getDocumentDirName], ADVERTISE_PATH];
        [moviePlayerController setContentURL:[NSURL fileURLWithPath:[advList objectAtIndex:curAdvIdx]]];
        [moviePlayerController play];
        
        _HUD = [MBProgressHUD showHUDAddedTo:moviePlayerController.view animated:YES];
        self.bool_isHUD = YES;
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

/**已点表移动到指定位置**/
- (void)selectReloadAlreadyView
{
    [_view_alreadySong tableScrollToPosition];
    [UIUtils showView:_view_alreadySong];
    _bool_touch = YES;
}


- (void)syncAV
{
    if(moviePlayerController != nil && accompanyPlayer != nil && withOutAccompanyPlayer != nil && [moviePlayerController playbackState] == MPMoviePlaybackStatePlaying && [accompanyPlayer isPlaying])
    {
        NSTimeInterval movieTime = [moviePlayerController currentPlaybackTime];
        NSTimeInterval audioTime = [accompanyPlayer currentTime];
        
        //NSLog(@"movie %f",movieTime);
        //NSLog(@"audio %f",audioTime);
        //NSLog(@"%d",abs(audioTime*10 - movieTime*10));
        
        //解决原伴唱同时音量为0引发的问题
        if( 0 == [accompanyPlayer volume] && 0 == [withOutAccompanyPlayer volume])
        {
            if(signForAccompanyOrOriginal)
            {
                [withOutAccompanyPlayer setVolume:1.0];
            }
            else
            {
                [accompanyPlayer setVolume:1.0];
            }
        }
        
        /**
         当音视频相差超过0.2秒时，重新同步
         **/
        if(abs(audioTime*10 - movieTime*10) > 2)
        {
            [withOutAccompanyPlayer setCurrentTime:movieTime];
            [accompanyPlayer setCurrentTime:movieTime];
            [withOutAccompanyPlayer setVolume:1.0f];
            [withOutAccompanyPlayer play];
            //NSLog(@"纠正音视频同步偏移");
        }
    }
}

/**
 * 准备播放音轨
 */
- (void)prepareAudioPlay
{
    if([[mediaProxy audioLocalFiles] count] > 1)
    {
        if(withOutAccompanyPlayer != nil)
        {
            [withOutAccompanyPlayer stop];
            [withOutAccompanyPlayer release];
        }
        NSURL *url = [NSURL fileURLWithPath:[[mediaProxy audioLocalFiles] objectAtIndex:0]];
        withOutAccompanyPlayer = [[[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil] retain];
        [withOutAccompanyPlayer setVolume:1.0];
        
        if(accompanyPlayer != nil)
        {
            [accompanyPlayer stop];
            [accompanyPlayer release];
        }
        url = [NSURL fileURLWithPath:[[mediaProxy audioLocalFiles] objectAtIndex:1]];
        accompanyPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
        [accompanyPlayer setVolume:0.0];
    }
}


/**
 广告下载
 **/
- (void)initAdvertise
{
    NSString *advPath = [NSString stringWithFormat:@"%@/%@", [UIUtils getDocumentDirName], ADVERTISE_PATH];
    
    //如果广告目录不存在，创建广告目录
    if(![[NSFileManager defaultManager] fileExistsAtPath:advPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:advPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if(AdvertiseDownloader != nil)
    {
        [AdvertiseDownloader startDownload];
        [AdvertiseDownloader release];
    }
    NSString *advLocalName = [NSString stringWithFormat:@"%@/3.mp4",advPath];
    AdvertiseDownloader = [[MediaDownloader alloc]initWithURL:ADVERTISE_URL WithLocalFileName:advLocalName];
    if([AdvertiseDownloader startDownload])
    {
        NSLog(@"开始下载广告");
    }
}

#pragma mark -  
#pragma mark Proxy Notification
- (void)handleReceiveRequest:(NSNotification *)note
{
    //    NSString *msg = (NSString*)[note object];
    //    if(iPhoneLayout)
    //    {
    //        [self addTextToReceiveConsole:msg];
    //    }
    //    else
    //    {
    //        [self addTextToSocketConsole:msg];
    //    }
}

- (void)handlePrebufferFinish:(NSNotification *)note
{
    NSString *url = (NSString*)[note object];
    NSString *msg = [NSString stringWithFormat:@"%@ 已全部缓冲到本地", url];
    
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
    
    
    [_bufferProgress setProgress:100.0f];
    [_view_alreadySong reloadTableViewWhenCacheSong];
    NSLog(@"%@",msg);
    
    //[self addTextToReceiveConsole:msg];
    //[self addTextToReceiveConsole:@"开始预读下一首歌曲"];
    
    NSLog(@"prebuffer finish.");
    
    if(curPreadIdx < [playlist count] - 1)
    {
        curPreadIdx++;
        while(curPreadIdx < [playlist count] &&
              ![mediaProxy prereadWithURL:[playlist objectAtIndex:curPreadIdx] WithAudioUrls:[audioList objectAtIndex:curPreadIdx]])
        {
            curPreadIdx++;
        }
    }
}

/**
 * 下载完成的消息处理
 */
- (void)handleDownloadFinish:(NSNotification *)note
{
    NSString  *url = (NSString*)[note object];
    if([url isEqualToString:ADVERTISE_URL])
    {
        //[self addTextToReceiveConsole:@"广告下载完毕"];
    }
}


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

/**
 * 缓存失败的消息处理
 */
- (void)handleCacheFailed:(NSNotification *)note
{
    NSString    *url = (NSString*)[note object];
    [mediaProxy restartPrebuffer];
    NSLog(@"Cache failed, Check net: %@", url);
}

/**
 * 媒体播放完毕的处理
 */
- (void)handlePlaybackFinish
{
    if(playingAdvertise)
    {
        if(waitForPlay)
        {
            playingAdvertise = NO;

            [self prepareAudioPlay];
            NSString    *localURL = [mediaProxy getLocalURLWithString:[playlist objectAtIndex:curPlayIdx]];
            [moviePlayerController setContentURL:[NSURL URLWithString:localURL]];
            [moviePlayerController play];
            waitForPlay = NO;
            
            [self saveHistorySong];
            //NSLog(@"%d",bool_history);
        }
        else
        {
            curAdvIdx = curAdvIdx < [advList count] - 1 ? curAdvIdx + 1 : 0;
            [moviePlayerController setContentURL:[NSURL fileURLWithPath:[advList objectAtIndex:curAdvIdx]]];
            [moviePlayerController play];
        }
    }
}


- (void)handleReceiveData:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    float             progress = [[state objectForKey:@"progress"] floatValue];
    NSString        *url = [state objectForKey:@"url"];
    float     progressture = (float)progress/100.0;
    NSLog(@"%f",progress);
    
    if([url isEqualToString:[playlist objectAtIndex:curPlayIdx]])
    {
        _bufferProgress.progress = progressture;
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
    }
    else
    {
        if(!_view_alreadySong.cacheProgressSlider)
        {
            NSLog(@"没有circlr");
            //[_view_alreadySong beginCacheNextSong];
        }
        [_view_alreadySong.cacheProgressSlider setProgressWithAngle:progress];
        NSLog(@"视频正在预读");
    }
    //NSLog(@"Cache Progress: %d",progress);
    //NSString *newText = [NSString stringWithFormat:@"缓冲进度：%d%%", progress];
    //[self addTextToReceiveConsole:newText];
    //缓冲大于5%后，开始播放
    if(prebufferForPlay && progress > 6 && [url isEqualToString:[playlist objectAtIndex:curPlayIdx]])
    {
        [MBProgressHUD hideHUDForView:self.moviePlayerController.view animated:YES];
        self.bool_isHUD = NO;
        prebufferForPlay = NO;
        [mediaProxy getHead:_song.songMd5 UserID:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
        //[mediaProxy getHead];
        /*if(playingAdvertise)
        {
            waitForPlay = YES;
            //[self addTextToReceiveConsole:@"等待广告播放完"];
        }
        else
        {
            [self prepareAudioPlay];
            NSString    *localURL = [mediaProxy getLocalURLWithString:[playlist objectAtIndex:curPlayIdx]];
            [moviePlayerController setContentURL:[NSURL URLWithString:localURL]];
            [moviePlayerController play];
        }*/
    }
}

/**
 * 更新音轨/广告下载进度
 */
- (void)handleDownloadProgress:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    int             progress = [[state objectForKey:@"progress"] integerValue];
    int             nAudioIdx = 0;
    int             i;
    NSString        *url = [state objectForKey:@"url"];

    if([url isEqualToString:ADVERTISE_URL])
    {
        NSString *newText = [NSString stringWithFormat:@"广告下载进度：%d%%", progress];
        //[self addTextToReceiveConsole:newText];
        NSLog(@"%@",newText);
    }
    else
    {
        NSArray *audioArray = [audioList objectAtIndex:curPlayIdx];
        
        for(i = 0; i < [audioArray count]; ++i)
        {
            if([url isEqualToString:[audioArray objectAtIndex:i]])
            {
                nAudioIdx = i + 1;
                break;
            }
        }
        float pro = (float)progress;
        NSString *newText;
        
        if(nAudioIdx > 0)
        {
            newText = [NSString stringWithFormat:@"音轨%d下载进度：%d%%", nAudioIdx, progress];
        }
        else
        {
            
            newText = [NSString stringWithFormat:@"预读音轨下载进度：%d%%", progress];
        }
       
        
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
            //[_HUD setProgress:turePro];
        }
        //NSLog(@"%@",newText);
    }
}

- (void)handleGetHeadFinish
{
    if(playingAdvertise)
    {
        waitForPlay = YES;
        //[self addTextToReceiveConsole:@"等待广告播放完"];
    }
    else
    {
        [self prepareAudioPlay];
        NSString    *localURL = [mediaProxy getLocalURLWithString:[playlist objectAtIndex:curPlayIdx]];
        [moviePlayerController setContentURL:[NSURL URLWithString:localURL]];
        [moviePlayerController play];
        /**
         在开始播放视频事件中同步播放音频
         **/
        //[withOutAccompanyPlayer setVolume:1.0f];
        [withOutAccompanyPlayer play];
        [accompanyPlayer play];
        [withOutAccompanyPlayer setVolume:0.0f];
        
        [_bufferProgress setProgress:100.0];
        [self saveHistorySong];
        [self performSelector:@selector(selectReloadAlreadyView) withObject:nil afterDelay:1.0f];
        //[_view_alreadySong tableScrollToPosition];
        //NSLog(@"%d",bool_history);
    }
    [UIUtils view_showProgressHUD:@"歌曲授权成功" inView:self.view withTime:1.0f];
}



- (void)handleGetHeadFailed:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    UIAlertView     *alertDialog;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    if([[state objectForKey:@"result"] length] > 0 && 1 == resultCode)
    {
        alertDialog = [[UIAlertView alloc] initWithTitle:@"失败"
                                                 message:[state objectForKey:@"msg"]
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
        [alertDialog show];
    }
    
    //[UIUtils view_showProgressHUD:@"歌曲授权失败" inView:self.view withTime:1.0f];
    [self performSelector:@selector(dissMissController) withObject:nil afterDelay:2.0f];
}

- (void)dissMissController
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissModalViewControllerAnimated:NO];
}


- (NSArray *)reciveAudioFromLink:(NSString *)link
{
    //NSString *songPath1 = [link stringByAppendingString:@"-0"];
    //songPath1 = [songPath1 stringByAppendingString:@".m4a"];
    
    //NSLog(@"%@",songPath1);
    
    //NSString *songPath2 = [link stringByAppendingString:@"-1"];
    //songPath2 = [songPath2 stringByAppendingString:@".m4a"];
    
    NSArray *array_audio = [NSArray arrayWithObjects:_song.string_audio0Url,_song.string_audio1Url,nil];
    
    //NSLog(@"%@",_song.string_audio0Url);
    //NSLog(@"%@",_song.string_audio1Url);
    
    return array_audio;
}

- (NSArray *)reciveMovieFromLink:(NSString *)link
{
    //NSString *songPath = [link stringByAppendingString:@"-0"];
    //songPath = [songPath stringByAppendingString:@".mp4"];
    NSArray *array_movie = [NSArray arrayWithObjects:_song.string_videoUrl,nil];
    //NSLog(@"%@",_song.string_audio0Url);
    return array_movie;
}


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

/*
#pragma mark - 
#pragma mark Alertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{ 
    if(alertView.tag == 1)
    {
        switch (buttonIndex) 
        {
            case 0:
            {
                
                
            }break;
            default:
                break;
        }
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    if(alertView.tag == 1)
    {
        CGRect frame = alertView.frame;
        frame.origin.y -= 80;
        frame.size.height += 60;
        alertView.frame = frame;
        for(UIView * view in alertView.subviews)
        {
            if(![view isKindOfClass:[UILabel class]])
            {
                if (view.tag == 1)
                {
                    CGRect btnFrame1 =CGRectMake(30, frame.size.height-65, 105, 40);
                    view.frame = btnFrame1;
                    
                } 
                
                else if (view.tag==2)
                {
                    CGRect btnFrame2 =CGRectMake(142, frame.size.height-65, 105, 40);
                    view.frame = btnFrame2; 
                }
            }
        }
        
        UILabel *label_recordName = [[UILabel alloc] initWithFrame:CGRectMake(30,50,60, 30)];
        label_recordName.text=@"录音名:";
        [label_recordName setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:15.0]];
        label_recordName.backgroundColor=[UIColor clearColor];
        label_recordName.textColor=[UIColor whiteColor];
        [alertView addSubview:label_recordName];
        [label_recordName release];
        textFirld_inputRecordName = [[UITextField alloc] initWithFrame: CGRectMake( 85,50,160,30)];
        [textFirld_inputRecordName setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:15.0]];
        textFirld_inputRecordName.placeholder = @"自己取个录音名";
        textFirld_inputRecordName.delegate = self;
        textFirld_inputRecordName.borderStyle = UITextBorderStyleRoundedRect;
        [alertView addSubview:textFirld_inputRecordName];
        [textFirld_inputRecordName release];
    }
}*/

#pragma mark - 
#pragma mark MBProgressHUD
- (void)view_showProgressHUD:(NSString *) _infoContent
{
    MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:[self view] animated:YES];
    [progressHUD setLabelText:_infoContent];
    [progressHUD setLabelFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:20.0f]];
    [progressHUD setRemoveFromSuperViewOnHide:YES];
    [self performSelector:@selector(view_hideProgressHUD) withObject:nil afterDelay:1.0f];
}

- (void)view_hideProgressHUD
{
    [MBProgressHUD hideHUDForView:[self view] animated:YES];
}


#pragma mark - 
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(_view_searchView)
    {
        [_view_searchView removeFromSuperview];
        _view_searchView = nil;
    }
    _view_searchView = [[JDSearchTableView alloc] init];
    [_view_searchView searchSongWithString:[textField text]];
    [self.view addSubview:_view_searchView];
    [_view_searchView release];
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
        //[textField resignFirstResponder];
        self.bool_isSearch = NO;
        return NO;
    }
    return YES;
}

#pragma mark - 
#pragma mark Sql
/**
 保存歌曲历史记录
 **/
- (void)saveHistorySong
{
    _song.songPlayTime = [UIUtils getCurrentDateString];
    //[JDSqlDataBaseSongHistory deleteSong:_song];
    if([JDSqlDataBaseSongHistory countOfHistoryTable] == 20)
    {
        [JDSqlDataBaseSongHistory deleteSongOnTop];
    }
    [JDSqlDataBaseSongHistory saveSong:_song];
}

/**
 * 枚举广告目录下的文件，生成广告列表
 */
- (void)generateAdvList
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *advPath = [NSString stringWithFormat:@"%@/%@", [UIUtils getDocumentDirName], ADVERTISE_PATH];
    
    for (NSString *fileName in [fileManager enumeratorAtPath:advPath])
    {
        if ([[fileName pathExtension] isEqualToString:@"mp4"] ||
            [[fileName pathExtension] isEqualToString:@"mpg"] ||
            [[fileName pathExtension] isEqualToString:@"wmv"] ||
            [[fileName pathExtension] isEqualToString:@"avi"])
        {
            [advList addObject:[NSString stringWithFormat:@"%@/%@", advPath, fileName]];
            NSLog(@"Adv File: %@", fileName);
        }
    }
}


@end
