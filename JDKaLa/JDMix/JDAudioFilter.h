//
//  JDAudioFilter.h
//  TestMixer
//
//  Created by 韩 抗 on 13-7-30.
//  Copyright (c) 2013年 ipvd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface JDAudioFilter : NSObject
{
    NSArray     *bandArray;
    AudioUnit   ioAU;
    AudioUnit   eqAU;
    AudioUnit   mixerAU;
    AudioUnit   effectAU;
}
@property(readwrite) AUGraph    graph;
@property(readonly, assign) BOOL isGraphWorking;

- (id)init;
- (void)CheckError:(OSStatus)state ErrMsg:(NSString*) msg;
- (void)initGraphForPlayFile:(NSString*)fileName;
- (void)initGraphForPlayFile:(NSString*)fileName WetDry:(float)wetDry Gain:(float)gainLevel MinDelay:(float)minDelayTime MaxDelay:(float)maxDelayTime DecayAt0Hz:(float)decayAt0Hz DecayAtNyquist:(float)decayAtNyquist;
- (void)initGraphForMic;
- (void)initGraphForMic:(float)wetDry Gain:(float)gainLevel MinDelay:(float)minDelayTime MaxDelay:(float)maxDelayTime DecayAt0Hz:(float)decayAt0Hz DecayAtNyquist:(float)decayAtNyquist;
- (void)initGraphForMicWithoutEffect;

- (void)initAudioSession;
- (void)stopAudioSession;
- (void)stopGraph;

- (void)setWetDry:(float)level;
- (void)setReverbGain:(float)level;
- (void)setMinDelayTime:(float)time;
- (void)setMaxDelayTime:(float)time;
- (void)setDecay0HzTime:(float)time;
- (void)setDecayNyquistTime:(float)time;
- (void)setEQGain:(int)gain Band:(int)bandIdx;
- (void)setEQBandWidth:(float)octave Band:(int)bandIdx;
- (void)setVolume:(float)volume;
- (int)getEQBandCount;

@end
