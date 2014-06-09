//
//  JDRecordPlayerViewController.h
//  JDKaLa
//
//  Created by zhangminglei on 6/25/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.

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
@class JDAudioFilter;

#define SPECTRUM_BAR_WIDTH 4

#ifndef CLAMP
#define CLAMP(min,x,max) (x < min ? min : (x > max ? max : x))
#endif

typedef enum aurioTouchDisplayMode
{
	aurioTouchDisplayModeOscilloscopeWaveform,
	aurioTouchDisplayModeOscilloscopeFFT,
	aurioTouchDisplayModeSpectrum
} aurioTouchDisplayMode;

typedef struct SpectrumLinkedTexture {
	GLuint							texName;
	struct SpectrumLinkedTexture	*nextTex;
} SpectrumLinkedTexture;

inline double linearInterp(double valA, double valB, double fract)
{
	return valA + ((valB - valA) * fract);
}

@interface JDRecordPlayerViewController : UIViewController<UIAlertViewDelegate,UITextFieldDelegate>
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
    MediaProxy  *mediaProxy;
    MediaDownloader         *AdvertiseDownloader;
    NSTimer                 *syncAVTimer;
    NSMutableArray     *playlist;
    NSMutableArray     *audioList;
    UILabel *label_movieTitle;
    UIButton *button_play;
}

@property (retain, nonatomic)   MPMoviePlayerController *moviePlayerController;
@property (retain, nonatomic)   UIView                  *customControlStyle;
@property (retain, nonatomic)   UISlider                *progressSlider;
@property (retain, nonatomic)   UIProgressView          *bufferProgress;
@property (retain, nonatomic)   SDRecordSound           *recordSound;
@property (retain, nonatomic)   UIView *view_playerTitle;
//@property (retain, nonatomic)   SDSongs *song;
@property (retain, nonatomic)   UISlider *slider_sound;
@property (assign, nonatomic)   BOOL bool_moviePlay;
@property (assign, nonatomic)   UILabel *label_change_K;
@property (retain, nonatomic)   MBProgressHUD *HUD;
@property (assign, nonatomic)   BOOL bool_isHUD;
@property (assign, nonatomic)   UIImageView *imageView_Hlight;
@property (retain, nonatomic)   AVAudioRecorder *recorder;
@property (retain, nonatomic)   NSURL *recordedTmpFile;
@property (assign, nonatomic)   BOOL bool_recordPlay;
@property (assign, nonatomic)   BOOL bool_isAbjust;     ///判断是否需要进行校准
@property (assign, nonatomic)   BOOL bool_isTure;       ///判断获取的视频进度是不是真实进度
@property (assign, nonatomic)   float last_time;
@property (retain, nonatomic)   JDAudioFilter *audio_mix;

- (void)play_movieWithRecord:(SDRecordSound *)_record;
+ (JDRecordPlayerViewController *)sharedController;


@end


