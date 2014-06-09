//
//  JDMixerController.h
//  JDKaLa
//
//  Created by zhangminglei on 7/24/13.
//  Copyright (c) 2013 张明磊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "JDAudioFilter.h"

@class JDSwitch;
@class JDMoviePlayerViewController;

@interface JDMixerController : UIViewController
{
    JDAudioFilter   *audioFilter;
}

@property (assign, nonatomic) UILabel *label_banZou;
@property (assign, nonatomic) UILabel *label_renSheng;

@property (assign, nonatomic) UILabel *label_ganshibi;
@property (assign, nonatomic) UILabel *label_zengyi;

@property (assign, nonatomic) UIView *view_customMix;
@property (assign, nonatomic) BOOL bool_zero;
@property (assign, nonatomic) NSInteger integer_now;
@property (assign, nonatomic) NSInteger integer_now_semgent;
@property (assign, nonatomic) UILabel *label_model;
@property (assign, nonatomic) UIView *view_viewChange;

@property (assign, nonatomic) UIButton *button_hunxiang;
@property (assign, nonatomic) UIButton *button_junheng;

@property (assign, nonatomic) UITextField *text_a;
@property (assign, nonatomic) UITextField *text_b;
@property (assign, nonatomic) UITextField *text_c;
@property (assign, nonatomic) UITextField *text_d;

@property (assign, nonatomic) JDSwitch *thumbSwitch;

@property (assign, nonatomic) UIView *view_level;

@property (assign, nonatomic) JDMoviePlayerViewController *movePlayer;

- (void)startPlayFile;
- (void)startMicphone;
- (void)stopMicphone;

- (void)onMinDelayTimeChanged:(id)sender;
- (void)onMaxDelayTimeChanged:(id)sender;
- (void)onWetDryChanged:(id)sender;
- (void)onReverbGainChanged:(id)sender;
- (void)onDecayTime1Changed:(id)sender;
- (void)onDecayTime2Changed:(id)sender;

- (void)eq0Changed:(id)sender;
- (void)eq1Changed:(id)sender;
- (void)eq2Changed:(id)sender;
- (void)eq3Changed:(id)sender;
- (void)eq4Changed:(id)sender;
- (void)eq5Changed:(id)sender;
- (void)eq6Changed:(id)sender;
- (void)eq7Changed:(id)sender;
- (void)eq8Changed:(id)sender;
- (void)eq9Changed:(id)sender;
- (void)onVolumeChanged:(id)sender;

- (void)installMiddleK;

@end
