//
//  JDRecordPlayerViewController.m
//  JDKaLa
//
//  Created by zhangminglei on 6/25/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDRecordPlayerViewController.h"
#import <MediaPlayer/MPMusicPlayerController.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import <AVFoundation/AVFoundation.h>
#import "NSString+NSString_TimeCategory.h"
#import "SKCustomNavigationBar.h"
#import "UIUtils.h"
#import "MBProgressHUD.h"
#import "MediaProxyGlobal.h"
#import "JDSqlDataBase.h"
#import "JDDataBaseRecordSound.h"
#import "JDAudioFilter.h"
#import "JDModel_userInfo.h"
#import "JDMasterViewController.h"

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
    SDMoviePlayerMicrophone                ,
    SDMoviePlayerBackSound                 ,
    
}SDMoviePlayerButtonTag;


@interface JDRecordPlayerViewController ()

@end


@implementation JDRecordPlayerViewController


@synthesize moviePlayerController;
@synthesize customControlStyle = _customControlStyle;
@synthesize progressSlider;
@synthesize recordSound = _recordSound;

#pragma mark -
#pragma mark JDRecordPlayerViewCotroller
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        //Custom initialization
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
    [self stopProxy];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bool_moviePlay = YES;
    self.bool_isHUD = YES;
    
    //进入播放器，停止主界面上的预读
    [[JDMasterViewController sharedController] stopPreread];
    
    mediaProxy = [[MediaProxy alloc] init];
    [mediaProxy startProxy];
    JDAudioFilter *audioFilter = [[JDAudioFilter alloc] init];
    self.audio_mix = audioFilter;
    [audioFilter release];
    //[self installKDeviceInPlayer];
}

#pragma mark -
- (void)viewDidUnload
{
    [super viewDidUnload];
    IOS7_STATEBAR;
    // Release any retained subviews of the main view.
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

static  JDRecordPlayerViewController *shareJDRecordPlayerViewController = nil;

+ (JDRecordPlayerViewController *)sharedController
{
    @synchronized(self)
    {
        if(shareJDRecordPlayerViewController == nil)
        {
            shareJDRecordPlayerViewController = [[[self alloc] init] autorelease];
        }
    }
    return shareJDRecordPlayerViewController;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (shareJDRecordPlayerViewController == nil)
        {
            shareJDRecordPlayerViewController = [super allocWithZone:zone];
            return shareJDRecordPlayerViewController;
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
    //[_song release], _song = nil;
    [_recordedTmpFile release], _recordedTmpFile = nil;
    [_recorder release], _recorder = nil;
    [_audio_mix release], _audio_mix = nil;
    [super dealloc];
}

- (UIImage *)didLoadImageNotCached:(NSString *)filename
{
    NSString *imageFile = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], filename];
    return [UIImage imageWithContentsOfFile:imageFile];
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
            /*
             Add your code here to handle MPMovieFinishReasonPlaybackEnded.
             */
			break;
            
            /* An error was encountered during playback. */
		case MPMovieFinishReasonPlaybackError:
            NSLog(@"An error was encountered during playback");
            //[self performSelectorOnMainThread:@selector(displayError:) withObject:[[notification userInfo] objectForKey:@"error"]
             //                   waitUntilDone:NO];
            //[self removeMovieViewFromViewHierarchy];
            //[self removeOverlayView];
            //[self.backgroundView removeFromSuperview];
			break;
            
            /* The user stopped playback. */
		case MPMovieFinishReasonUserExited:
            
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
        NSLog(@"play");
        //[self performSelector:@selector(hiddenMovieController) withObject:nil afterDelay:5.0f];
	}
	/* Playback is currently paused. */
	else if (player.playbackState == MPMoviePlaybackStatePaused)
	{
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
        NSLog(@"forward");
    }
}

- (void)hiddenMovieController
{
    if(self.bool_isHUD)
    {
        [UIUtils hiddeView:_HUD];
    }
    self.bool_moviePlay = NO;
    [UIUtils hiddeView:_customControlStyle];
    [UIUtils hiddeView:_view_playerTitle];
}

- (void)showMovieController
{
    if(self.bool_isHUD)
    {
        [UIUtils showView:_HUD];
    }
    self.bool_moviePlay = YES;
    [UIUtils showView:_customControlStyle];
    [UIUtils showView:_view_playerTitle];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.bool_moviePlay)
    {
        [self hiddenMovieController];
    }
    else
    {
        [self showMovieController];
        //[self performSelector:@selector(hiddenMovieController) withObject:nil afterDelay:5.0f];
    }
}

/* Notifies observers of a change in the prepared-to-play state of an object
 conforming to the MPMediaPlayback protocol. */
- (void) mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    // Add an overlay view on top of the movie view
}

- (void)loadStateDidChange:(NSNotification *)notification
{
	//MPMoviePlayerController *player = notification.object;
	//MPMovieLoadState loadState = player.loadState;
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
}

-(void)deletePlayerAndNotificationObservers
{
    [self removeMovieNotificationHandlers];
    [self setMoviePlayerController:nil];
}

#pragma mark -
#pragma mark Movie Settings

-(void)applyUserSettingsToMoviePlayer
{
    MPMoviePlayerController *player = [self moviePlayerController];
    if (player)
    {
        [player setScalingMode:MPMovieScalingModeAspectFit];
        [player setControlStyle:MPMovieControlStyleNone];
        [player.backgroundView setBackgroundColor:[UIColor clearColor]];
        [player setRepeatMode:MPMovieRepeatModeNone];
        [player setShouldAutoplay:YES];
        player.allowsAirPlay = YES;
    }
}

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
    [label_titel setText:_recordSound.string_recordName];
    label_movieTitle = label_titel;
    [view_title addSubview:label_titel];
    [label_titel release];
    
    UIButton *button_master = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_master setFrame:CGRectMake(10, 7, 65, 37)];
    [UIUtils didLoadImageNotCached:@"back_btn.png" inButton:button_master withState:UIControlStateNormal];
    [button_master setTag:SDMoviePlayerReturn];
    [customNavigationBar addSubview:button_master];
    [button_master addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    //title
    self.customControlStyle = [[[UIView alloc] initWithFrame:CGRectMake(0, 653, 1024, 155)]autorelease];
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
    [moviePlayerPlay setTag:SDMoviePlayerPlay];
    [self.customControlStyle addSubview:moviePlayerPlay];
    button_play = moviePlayerPlay;
    
    UIButton *button_sound = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_sound setFrame:CGRectMake(755, 75, 37, 37)];
    [UIUtils didLoadImageNotCached:@"player_btn_mute.png" inButton:button_sound withState:UIControlStateNormal];
    [self.customControlStyle addSubview:button_sound];
    
    [self installProgressSliderStyleForController:controller];
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
    //[self updateCurrentTimeForPlayer:self.moviePlayerController];
    progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(65, 45, 940, 9)];
    [progressSlider setUserInteractionEnabled:NO];
    _bufferProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(70, 52, 930, 9)];
    
    [progressSlider setBackgroundColor:[UIColor clearColor]];
    [_bufferProgress setBackgroundColor:[UIColor clearColor]];
    [progressSlider setThumbImage:[self didLoadImageNotCached:@"player_progress_bar_btn.png"] forState:UIControlStateNormal];
    [progressSlider setMinimumTrackImage:[self didLoadImageNotCached:@"player_progress_bar.png"] forState:UIControlStateNormal];
    [progressSlider setMaximumTrackTintColor:[UIColor clearColor]];
    [progressSlider setMaximumTrackImage:[self didLoadImageNotCached:@"player_progress_back_bg.png"] forState:UIControlStateNormal];
    [_bufferProgress setTrackTintColor:[UIColor blackColor]];
    [_bufferProgress setProgressImage:[self didLoadImageNotCached:@"player_progress_bar2.png"]];

    if (updateTimer)
    {
        [updateTimer invalidate];
        updateTimer = nil;
    }
    else
    {
        progressSlider.maximumValue = controller.duration;
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:.1
                                                        target:self
                                                        selector:@selector(updateRecordTime)
                                                     userInfo:self.moviePlayerController
                                                      repeats:YES];
    }
    
    [self.customControlStyle addSubview:_bufferProgress];
    [self.customControlStyle addSubview:progressSlider];
    [progressSlider release];
    [_bufferProgress release];
    
    _slider_sound = [[UISlider alloc] initWithFrame:CGRectMake(800, 80, 200, 25)];
    [_slider_sound setThumbImage:[self didLoadImageNotCached:@"player_progress_bar_btn.png"] forState:UIControlStateNormal];
    [_slider_sound setMinimumTrackImage:[self didLoadImageNotCached:@"player_progress_bar.png"] forState:UIControlStateNormal];
    [_slider_sound setMaximumTrackImage:[self didLoadImageNotCached:@"player_progress_bar_bg.png"] forState:UIControlStateNormal];
    [_slider_sound addTarget:self action:@selector(progressSliderMoved_sound:) forControlEvents:UIControlEventValueChanged];
    
    _slider_sound.maximumValue = 1.0;
    [self.customControlStyle addSubview:_slider_sound];
    [_slider_sound release];
}

- (void)progressSliderMoved_sound:(UISlider *)sender
{
    MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
    mpc.volume = sender.value;
}

- (void)updateRecordTime
{
    [self updateCurrentTimeForRecord:self.moviePlayerController];
}

-(void)updateCurrentTimeForRecord:(MPMoviePlayerController *)p
{
    NSTimeInterval duration = [_recordSound.string_recordEndTime timeValue] - [_recordSound.string_recordStartTime timeValue];
    NSTimeInterval start = [_recordSound.string_recordStartTime timeValue];
    NSString *current = [NSString stringWithFormat:@"%d:%02d", (int)(p.currentPlaybackTime - start)/ 60, (int)(p.currentPlaybackTime - start) % 60, nil];
    NSString *dur = [NSString stringWithFormat:@"/%d:%02d", (int)((int)(duration)) / 60, (int)((int)(duration)) % 60, nil];
    if((int)[_recordSound.string_recordEndTime timeValue] == (int)p.currentPlaybackTime)
    {
        [self finishRecordPlay];
    }
    if((int)(p.currentPlaybackTime - start) >= 0)
    {
        startLable.text = current;
        progressSlider.value = p.currentPlaybackTime - start;
    }
    else
    {
        progressSlider.value = 0;
    }
    endLable.text = dur;
    progressSlider.maximumValue = duration;
    
    if(p.currentPlaybackTime > 0 && _bool_recordPlay && p.duration > 0 && _bool_isAbjust)
    {
        float time_ture = (float)p.currentPlaybackTime;
        float time_target = (float)[_recordSound.string_recordStartTime timeValue];
        if(time_ture < time_target)
        {
            if(time_target - time_ture < 0.2)
            {
                [accompanyPlayer play];
                [self playRecord];
                _bool_isAbjust = NO;
                [moviePlayerController.view setAlpha:1.0];
                [UIUtils hiddeView:_HUD];
                self.bool_isHUD = NO;
                [button_play setUserInteractionEnabled:YES];
                return;
            }
        }
        
        else if(time_ture > time_target)
        {
            if(time_ture - time_target < 0.2)
            {
                [accompanyPlayer play];
                [self playRecord];
                _bool_isAbjust = NO;
                [moviePlayerController.view setAlpha:1.0];
                [UIUtils hiddeView:_HUD];
                self.bool_isHUD = NO;
                [button_play setUserInteractionEnabled:YES];
                return;
            }
            p.currentPlaybackTime = time_target - 1;
        }
    }
}

- (void)finishRecordPlay
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.moviePlayerController stop];
    [accompanyPlayer pause];
    [recordPlayer pause];
    [self stopProxy];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didClickButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger tag = button.tag;
    switch (tag)
    {
        case SDMoviePlayerReturn:
        {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            if(self.bool_isHUD)
            {
                [MBProgressHUD hideHUDForView:self.moviePlayerController.view animated:YES];
                self.bool_isHUD = NO;
            }
            [self.moviePlayerController stop];
            [accompanyPlayer pause];
            [recordPlayer pause];
            [self.audio_mix stopGraph];
            [self.audio_mix stopAudioSession];
            [self stopProxy];
            [self dismissViewControllerAnimated:NO completion:nil];
            
            //退出播放器，恢复主界面上的预读
            [[JDMasterViewController sharedController] startPreread];
            
        }break;
        case SDMoviePlayerPlay:
        {
            if(signForPlayOrStop)
            {
                [self.moviePlayerController pause];
                [accompanyPlayer pause];
                [recordPlayer pause];
                [UIUtils didLoadImageNotCached:@"player_btn_play.png" inButton:button withState:UIControlStateNormal];
            }
            else
            {
                [self.moviePlayerController play];
                [accompanyPlayer play];
                [recordPlayer play];
                [UIUtils didLoadImageNotCached:@"player_btn_pause.png" inButton:button withState:UIControlStateNormal];
            }
            signForPlayOrStop = !signForPlayOrStop;
        }break;
        default:
            break;
    }
}

- (void)installSignForButton
{
    signForPlayOrStop = YES;
}

#pragma mark -
#pragma mark PlayMovieInMaster
- (NSString *)linkUrlForMovieWithSong:(NSString *)song
{
    NSString *directory = [song substringToIndex:2];
    NSString *linkMovieDirectory = [directory stringByAppendingString:@"/"];
    linkMovieDirectory = [linkMovieDirectory stringByAppendingString:song];
    NSString *linkMovieDown = [JDLINKMOVIEDOWNSTART stringByAppendingString:linkMovieDirectory];
    linkMovieDown = [linkMovieDown stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return linkMovieDown;
}


- (void)play_movieWithRecord:(SDRecordSound *)_record
{
    self.recordSound = _record;

    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    //_isSeeking = NO;
    _bool_isTure = NO;
    _bool_isAbjust = YES;
    _bool_recordPlay = YES;
    _last_time = (float)[_recordSound.string_recordStartTime timeValue];
	// mute should be on at launch
    
    if(!moviePlayerController)
    {
        moviePlayerController = [[MPMoviePlayerController alloc] init];
        [[moviePlayerController view] setFrame:CGRectMake(0, 0, 1024, 768)];
        [moviePlayerController setControlStyle:MPMovieControlStyleNone];
        [moviePlayerController setFullscreen:YES];
        [[self view]addSubview:[moviePlayerController view]];
        [self installControlStyleForController:self.moviePlayerController];
        [self installMovieNotificationObservers];
        [label_movieTitle setText:_record.string_recordName];
        [self prepareForProxyWithLink:[self linkUrlForMovieWithSong:_record.string_recordMD5]];
        [self proxyPlay];
        [self startProxy];
    }
    else
    {
        [moviePlayerController release];
        moviePlayerController = nil;
        moviePlayerController = [[MPMoviePlayerController alloc] init];
        [[moviePlayerController view] setFrame:CGRectMake(0, 0, 1024, 768)];
        [moviePlayerController setControlStyle:MPMovieControlStyleNone];
        [moviePlayerController setFullscreen:YES];
        [[self view] insertSubview:[moviePlayerController view] belowSubview:_view_playerTitle];
        [self removeMovieNotificationHandlers];
        [self installMovieNotificationObservers];
        [_bufferProgress setProgress:0.0f];
        [progressSlider addTarget:self action:@selector(progressSliderMoved:) forControlEvents:UIControlEventValueChanged];
        [progressSlider addTarget:self action:@selector(progressSliderMoved_finish) forControlEvents:UIControlEventTouchUpInside];
        [label_movieTitle setText:_record.string_recordName];
        [self prepareForProxyWithLink:[self linkUrlForMovieWithSong:_record.string_recordMD5]];
        [self startProxy];
        [self proxyPlay];
    }
    
    MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
    [_slider_sound setValue:mpc.volume];
    
}

-(NSURL *)localMovieURL:(NSString *)link
{
    NSURL *theMovieURL = nil;
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/preread_buffer"];
    NSString *songPath = [link stringByAppendingString:@"-0"];
    songPath = [songPath stringByAppendingString:@".mp4"];
    NSString *downPath = [documentsPath stringByAppendingPathComponent:songPath];
    theMovieURL = [NSURL fileURLWithPath:downPath];
    return theMovieURL;
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
    
    /*JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
    NSMutableArray *array_already = [base reciveSongArrayWithTag:2];
    for (int i = 0; i<[array_already count]; i++)
    {
        SDSongs *song = [array_already objectAtIndex:i];
        NSString *directory = [link substringFromIndex:33];
        NSLog(@"%@",directory);
        if(![song.songMd5 isEqualToString:directory])
        {
            NSString *songPath = [[self linkUrlForMovieWithSong:song.songMd5] stringByAppendingString:@"-0"];
            songPath = [songPath stringByAppendingString:@".mp4"];
            [playlist addObject:songPath];
            
            NSArray *array_tmp = [self reciveAudioFromLink:[self linkUrlForMovieWithSong:song.songMd5]];
            [audioList addObject:array_tmp];
        }
    }
    [base release];*/
    
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
           selector:@selector(handleGetHeadFailed)
               name:NOTI_GET_HEAD_FAILED
             object:nil];
    
    syncAVTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                   target:self
                                                 selector:@selector(syncAV)
                                                 userInfo:nil
                                                  repeats:YES];
    NSLog(@"代理已启动");
}

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
    
    NSLog(@"代理已停止");
}

- (void)proxyPlay
{
    [moviePlayerController stop];
    [mediaProxy prebufferWithUrl:[playlist objectAtIndex:curPlayIdx] WithAudioUrls:[audioList objectAtIndex:curPlayIdx]];
    
    playingAdvertise = NO;
    waitForPlay = NO;
    if([mediaProxy isPrebufferFinish])
    {
        [mediaProxy getHead:_recordSound.string_recordMD5 UserID:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
        //[mediaProxy getHead];
        /*[self prepareAudioPlay];
         NSLog(@"Play:%@", [mediaProxy videoLocalFile]);
         [moviePlayerController setContentURL:[NSURL fileURLWithPath:[mediaProxy videoLocalFile]]];
         [moviePlayerController play];*/
        
        if(curPlayIdx < [playlist count] - 1)
        {
            curPreadIdx = curPlayIdx + 1;
            [mediaProxy prereadWithURL:[playlist objectAtIndex:curPreadIdx] WithAudioUrls:[audioList objectAtIndex:curPreadIdx]];
            //[self addTextToReceiveConsole:@"开始预读下一首歌曲"];
        }
    }
    else if([mediaProxy getPrebufferPercent] > 5)
    {
        [mediaProxy getHead:_recordSound.string_recordMD5 UserID:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
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
        NSString *advName = [NSString stringWithFormat:@"%@/%@/3.mp4", [UIUtils getDocumentDirName], ADVERTISE_PATH];
        [moviePlayerController setContentURL:[NSURL fileURLWithPath:advName]];
        [moviePlayerController play];
    }
}

- (void)syncAV
{
    if(moviePlayerController != nil && accompanyPlayer != nil && withOutAccompanyPlayer != nil && [moviePlayerController playbackState] == MPMoviePlaybackStatePlaying && [accompanyPlayer isPlaying])
    {
        NSTimeInterval movieTime = [moviePlayerController currentPlaybackTime];
        NSTimeInterval audioTime = [accompanyPlayer currentTime];
        
        //当音视频相差超过0.2秒时，重新同步
        if(abs(audioTime - movieTime) > 0.2)
        {
            [withOutAccompanyPlayer setCurrentTime:movieTime];
            [accompanyPlayer setCurrentTime:movieTime];
            //NSLog(@"纠正音视频同步偏移");
        }
    }
}

/**
 播放录音
 **/
- (void)playRecord
{
    switch (_recordSound.integer_mixTag)
    {
        case 0:
        {
            [self.audio_mix stopGraph];
            [self.audio_mix initGraphForPlayFile:[self getString_recordPathWithString:_recordSound]];
            //[self.audio_mix initGraphForPlayFile];
            
        }break;
        case 1:
        {
            [self.audio_mix stopGraph];
            [self.audio_mix initGraphForPlayFile:[self getString_recordPathWithString:_recordSound] WetDry:50.0 Gain:-5 MinDelay:0.06 MaxDelay:0.12 DecayAt0Hz:1.5 DecayAtNyquist:1.5];
        }break;
        case 2:
        {
            [self.audio_mix stopGraph];
            [self.audio_mix initGraphForPlayFile:[self getString_recordPathWithString:_recordSound] WetDry:60.0 Gain:0 MinDelay:0.12 MaxDelay:0.48 DecayAt0Hz:2 DecayAtNyquist:4];
        }break;
        case 3:
        {
            
            [self.audio_mix stopGraph];
            [self.audio_mix initGraphForPlayFile:[self getString_recordPathWithString:_recordSound] WetDry:60 Gain:-2 MinDelay:0.045 MaxDelay:0.09 DecayAt0Hz:1.2 DecayAtNyquist:1.2];
            
            [self.audio_mix setEQBandWidth:1.1 Band:2];
            [self.audio_mix setEQGain:5 Band:2];
            
            [self.audio_mix setEQBandWidth:1.0 Band:3];
            [self.audio_mix setEQGain:-3 Band:3];
            
            [self.audio_mix setEQBandWidth:0.9 Band:5];
            [self.audio_mix setEQGain:4 Band:5];
            
            [self.audio_mix setEQBandWidth:1.3 Band:9];
            [self.audio_mix setEQGain:-4 Band:9];
            
        }break;
        case 4:
        {
            [self.audio_mix stopGraph];
            [self.audio_mix initGraphForPlayFile:[self getString_recordPathWithString:_recordSound] WetDry:60 Gain:-2 MinDelay:0.045 MaxDelay:0.09 DecayAt0Hz:1.2 DecayAtNyquist:1.2];
            
            [self.audio_mix setEQBandWidth:2.0 Band:1];
            [self.audio_mix setEQGain:2 Band:1];
            
            [self.audio_mix setEQBandWidth:0.8 Band:2];
            [self.audio_mix setEQGain:-4 Band:2];
            
            [self.audio_mix setEQBandWidth:1.2 Band:5];
            [self.audio_mix setEQGain:2 Band:5];
            
            [self.audio_mix setEQBandWidth:1.3 Band:9];
            [self.audio_mix setEQGain:3 Band:9];
        }break;
        case 5:
        {
            
        }break;
        case 6:
        {
        }break;
        case 7:
        {
        }break;
            
        case 8:
        {
            [self.audio_mix stopGraph];
            [self.audio_mix initGraphForPlayFile:[self getString_recordPathWithString:_recordSound]];
            [self.audio_mix setWetDry:10.0];
        }break;
        case 9:
        {
            [self.audio_mix stopGraph];
            [self.audio_mix initGraphForPlayFile:[self getString_recordPathWithString:_recordSound]];
            [self.audio_mix setWetDry:25.0];
        }break;
        case 10:
        {
            [self.audio_mix stopGraph];
            [self.audio_mix initGraphForPlayFile:[self getString_recordPathWithString:_recordSound]];
            [self.audio_mix setWetDry:50.0];
        }break;
        case 11:
        {
            [self.audio_mix stopGraph];
            [self.audio_mix initGraphForPlayFile:[self getString_recordPathWithString:_recordSound]];
            [self.audio_mix setWetDry:75.0];
        }break;
        case 12:
        {
            [self.audio_mix stopGraph];
            [self.audio_mix initGraphForPlayFile:[self getString_recordPathWithString:_recordSound]];
            [self.audio_mix setWetDry:100.0];
        }break;
        default:
            break;
    }

    /*if(recordPlayer)
    {
        [recordPlayer release];
        recordPlayer = nil;
    }
    recordPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[self get_recordPathWithString:self.recordSound] error:nil];
    [recordPlayer prepareToPlay];
    [recordPlayer play];*/
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
        withOutAccompanyPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
        [withOutAccompanyPlayer setVolume:1.0];
        
        if(accompanyPlayer != nil)
        {
            [accompanyPlayer stop];
            [accompanyPlayer release];
        }
        url = [NSURL fileURLWithPath:[[mediaProxy audioLocalFiles] objectAtIndex:1]];
        accompanyPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
        [accompanyPlayer setVolume:0];
    }
}

- (void)prepareAudioPlay_recordSound
{
    if([[mediaProxy audioLocalFiles] count] > 1)
    {
        if(accompanyPlayer != nil)
        {
            [accompanyPlayer stop];
            [accompanyPlayer release];
        }
        NSURL *url = [NSURL fileURLWithPath:[[mediaProxy audioLocalFiles] objectAtIndex:1]];
        /*if(accompanyPlayer)
        {
            [accompanyPlayer release];
            accompanyPlayer = nil;
        }*/
        accompanyPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
        [accompanyPlayer setCurrentTime:[_recordSound.string_recordStartTime timeValue]];
        [accompanyPlayer setVolume:1.0f];
    }
}



///广告下载
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
    [_bufferProgress setProgress:1.0f];
    NSLog(@"%@",msg);
    
    //[self addTextToReceiveConsole:msg];
    //[self addTextToReceiveConsole:@"开始预读下一首歌曲"];
    
    NSLog(@"prebuffer finish.");
    if(curPreadIdx < [playlist count] - 1)
    {
        curPreadIdx++;
        [mediaProxy prereadWithURL:[playlist objectAtIndex:curPreadIdx] WithAudioUrls:[audioList objectAtIndex:curPreadIdx]];
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
        playingAdvertise = NO;
        if(waitForPlay)
        {
            [self prepareAudioPlay];
            NSString    *localURL = [mediaProxy getLocalURLWithString:[playlist objectAtIndex:curPlayIdx]];
            [moviePlayerController setContentURL:[NSURL URLWithString:localURL]];
            [moviePlayerController play];
            waitForPlay = NO;
        }
    }
    //    {
    //        isSeeking = NO;
    //        [audioPlayer1 stop];
    //        [audioPlayer2 stop];
    //        [self PlayNext:nil];
    //    }
}


- (void)handleReceiveData:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    int             progress = [[state objectForKey:@"progress"] integerValue];
    NSString        *url = [state objectForKey:@"url"];
    float     progressture = (float)progress/100;
    if([url isEqualToString:[playlist objectAtIndex:curPlayIdx]])
    {
        _bufferProgress.progress = progressture;

    }
    
    //缓冲大于5%后，开始播放
    if(prebufferForPlay && progress > 5 && [url isEqualToString:[playlist objectAtIndex:curPlayIdx]])
    {
        prebufferForPlay = NO;
        [mediaProxy getHead:_recordSound.string_recordMD5 UserID:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
        //[mediaProxy getHead];
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
        NSArray         *audioArray = [audioList objectAtIndex:curPlayIdx];
        
        for(i = 0; i < [audioArray count]; ++i)
        {
            if([url isEqualToString:[audioArray objectAtIndex:i]])
            {
                nAudioIdx = i + 1;
                break;
            }
        }
        
        NSString *newText;
        
        if(nAudioIdx > 0)
        {
            newText = [NSString stringWithFormat:@"音轨%d下载进度：%d%%", nAudioIdx, progress];
        }
        else
        {
            newText = [NSString stringWithFormat:@"预读音轨下载进度：%d%%", progress];
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
  
        }
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
        [self prepareAudioPlay_recordSound];
        NSString    *localURL = [mediaProxy getLocalURLWithString:[playlist objectAtIndex:curPlayIdx]];
        [moviePlayerController setContentURL:[NSURL URLWithString:localURL]];
        moviePlayerController.initialPlaybackTime = [_recordSound.string_recordStartTime timeValue];
        [moviePlayerController pause];
        [moviePlayerController play];
        [moviePlayerController.view setAlpha:0.0];
    }
    
    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.view insertSubview:_HUD belowSubview:_view_playerTitle];
    [button_play setUserInteractionEnabled:NO];
    
    [_HUD setAnimationType:MBProgressHUDAnimationZoom];
    [_HUD setRemoveFromSuperViewOnHide:YES];
    [_HUD setMode:MBProgressHUDModeIndeterminate];
    [_HUD setLabelText:@"正在准备,请稍后。"];
    [UIUtils showView:_HUD];
}


- (void)handleGetHeadFailed
{
    NSLog(@"授权失败");
    [UIUtils view_showProgressHUD:@"歌曲授权失败" inView:self.view withTime:2.0f];
    [self performSelector:@selector(dissMissController) withObject:nil afterDelay:2.0f];
}

- (void)dissMissController
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissModalViewControllerAnimated:NO];
}

- (void)moviePlayerSetReCordTime:(SDRecordSound *)_record
{
    recordPlayer = nil;
    recordPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[self get_recordPathWithString:_record] error:nil];
    
    [recordPlayer prepareToPlay];
    [recordPlayer play];
}

- (NSArray *)reciveAudioFromLink:(NSString *)link
{
    NSString *songPath1 = [link stringByAppendingString:@"-0"];
    songPath1 = [songPath1 stringByAppendingString:@".m4a"];
    
    NSString *songPath2 = [link stringByAppendingString:@"-1"];
    songPath2 = [songPath2 stringByAppendingString:@".m4a"];
    
    NSArray *array_audio = [NSArray arrayWithObjects:_recordSound.string_audio0Url,_recordSound.string_audio1Url,nil];
    //NSArray *array_audio = [NSArray arrayWithObjects:songPath1,songPath2,nil];
    return array_audio;
}

- (NSArray *)reciveMovieFromLink:(NSString *)link
{
    NSString *songPath = [link stringByAppendingString:@"-0"];
    songPath = [songPath stringByAppendingString:@".mp4"];
    NSArray *array_movie = [NSArray arrayWithObjects:_recordSound.string_videoUrl,nil];
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

- (NSString *)getString_recordPathWithString:(SDRecordSound *)_record
{
    NSString *imageDir = [NSString stringWithFormat:@"%@/Documents/recordSound", NSHomeDirectory()];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    if (!(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //NSURL *theMovieURL = nil;
	NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/recordSound"];
    NSString *songPath = [_record.string_recordMD5 stringByAppendingString:[NSString stringWithFormat:@"%d",_record.integer_recordSign]];
    NSString *downPath = [documentsPath stringByAppendingPathComponent:songPath];
    //theMovieURL = [NSURL fileURLWithPath:downPath];
    return downPath;
}


#pragma mark - MBProgressHUD
- (void)view_showProgressHUD:(NSString *) _infoContent
{
    MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:[self view] animated:YES];
    [progressHUD setLabelText:_infoContent];
    [progressHUD setLabelFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:20.0f]];
    [progressHUD setRemoveFromSuperViewOnHide:YES];
    [self performSelector:@selector(view_hideProgressHUD) withObject:nil afterDelay:2.0f];
}

- (void)view_hideProgressHUD
{
    [MBProgressHUD hideHUDForView:[self view] animated:YES];
}


@end

