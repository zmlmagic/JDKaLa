//
//  JDAudioFilter.m
//  TestMixer
//
//  Created by 韩 抗 on 13-7-30.
//  Copyright (c) 2013年 ipvd. All rights reserved.
//

#import "JDAudioFilter.h"

#define DEFAULT_WETDRY                  80.f
#define DEFAULT_GAIN                    0.f
#define DEFAULT_MIN_DELAY_TIME          0.008f
#define DEFAULT_MAX_DELAY_TIME          0.05f
#define DEFAULT_DECAY_TIME_AT_0HZ       1.0f
#define DEFAULT_DECAY_TIME_AT_NYQUIST   0.5f

@implementation JDAudioFilter

- (void)CheckError:(OSStatus)state ErrMsg:(NSString*) msg
{
    if(state != noErr)
    {
        NSLog(@"Error:(%ld) %@", state, msg);
    }
}

- (id)init
{
    self = [super init];
    if(self != nil)
    {
        _graph = nil;
        effectAU = nil;
        eqAU = nil;
        _isGraphWorking = NO;
    }
    return self;
}

/**
 * 初始化AudioSession, 为麦克风回放用
 */
- (void)initAudioSession
{
    OSStatus status;
    
    [self CheckError: AudioSessionInitialize(NULL, NULL, NULL, (__bridge void*)self) ErrMsg:@"Init AudioSession failed"];
    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
    status = AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,
                                      sizeof (sessionCategory),
                                      &sessionCategory);
    
    if (status != kAudioSessionNoError)
    {
        if (status == kAudioServicesUnsupportedPropertyError) {
            NSLog(@"AudioSessionInitialize failed: unsupportedPropertyError");
        }else if (status == kAudioServicesBadPropertySizeError) {
            NSLog(@"AudioSessionInitialize failed: badPropertySizeError");
        }else if (status == kAudioServicesBadSpecifierSizeError) {
            NSLog(@"AudioSessionInitialize failed: badSpecifierSizeError");
        }else if (status == kAudioServicesSystemSoundUnspecifiedError) {
            NSLog(@"AudioSessionInitialize failed: systemSoundUnspecifiedError");
        }else if (status == kAudioServicesSystemSoundClientTimedOutError) {
            NSLog(@"AudioSessionInitialize failed: systemSoundClientTimedOutError");
        }else {
            NSLog(@"AudioSessionInitialize failed! %ld", status);
        }
    }
    
    AudioSessionSetActive(TRUE);
}

/**
 * 为播放文件初始化AUGraph
 */
- (void)initGraphForPlayFile:(NSString*)fileName WetDry:(float)wetDry Gain:(float)gainLevel MinDelay:(float)minDelayTime MaxDelay:(float)maxDelayTime DecayAt0Hz:(float)decayAt0Hz DecayAtNyquist:(float)decayAtNyquist
{
    {
        //create a new AUGraph
        [self CheckError:NewAUGraph(&_graph) ErrMsg:@"NewAUGraph failed"];
        // opening the graph opens all contained audio units but does not allocate any resources yet
        [self CheckError:AUGraphOpen(_graph) ErrMsg: @"AUGraphOpen failed"];
        // now initialize the graph (causes resources to be allocated)
        [self CheckError:AUGraphInitialize(_graph) ErrMsg:@"AUGraphInitialize failed"];
    }
    
    
    AUNode outputNode;
    {
        AudioComponentDescription outputAudioDesc = {0};
        outputAudioDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
        outputAudioDesc.componentType = kAudioUnitType_Output;
        outputAudioDesc.componentSubType = kAudioUnitSubType_RemoteIO;
        // adds a node with above description to the graph
        [self CheckError:AUGraphAddNode(_graph, &outputAudioDesc, &outputNode) ErrMsg:@"AUGraphAddNode[kAudioUnitSubType_DefaultOutput] failed"];
        AUGraphNodeInfo(_graph, outputNode, NULL, &ioAU);
    }
    
    AUNode effectNode;
    {
        AudioComponentDescription effectAudioDesc = {0};
        effectAudioDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
        effectAudioDesc.componentType = kAudioUnitType_Effect;
        effectAudioDesc.componentSubType = kAudioUnitSubType_Reverb2;
        effectAudioDesc.componentFlags = 0;
        effectAudioDesc.componentFlagsMask = 0;
        // adds a node with above description to the graph
        [self CheckError:AUGraphAddNode(_graph, &effectAudioDesc, &effectNode) ErrMsg: @"AUGraphAddNode[kAudioUnitSubType_Reverb2] failed"];
        
        AUGraphNodeInfo(_graph, effectNode, NULL, &effectAU);
        
        AudioUnitSetParameter(effectAU, kReverb2Param_DryWetMix, kAudioUnitScope_Global, 0, wetDry, 0);
        AudioUnitSetParameter(effectAU, kReverb2Param_Gain, kAudioUnitScope_Global, 0, gainLevel, 0);
        AudioUnitSetParameter(effectAU, kReverb2Param_MinDelayTime, kAudioUnitScope_Global, 0, minDelayTime, 0);
        AudioUnitSetParameter(effectAU, kReverb2Param_MaxDelayTime, kAudioUnitScope_Global, 0, maxDelayTime, 0);
        
        AudioUnitSetParameter(effectAU, kReverb2Param_DecayTimeAt0Hz, kAudioUnitScope_Global, 0, decayAt0Hz, 0);
        AudioUnitSetParameter(effectAU, kReverb2Param_DecayTimeAtNyquist, kAudioUnitScope_Global, 0, decayAtNyquist, 0);
    }
    
    AUNode eqNode;
    {
        AudioComponentDescription eqAudioDesc = {0};
        eqAudioDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
        eqAudioDesc.componentType = kAudioUnitType_Effect;
        eqAudioDesc.componentSubType = kAudioUnitSubType_NBandEQ;
        eqAudioDesc.componentFlags = 0;
        eqAudioDesc.componentFlagsMask = 0;
        // adds a node with above description to the graph
        [self CheckError:AUGraphAddNode(_graph, &eqAudioDesc, &eqNode) ErrMsg:@"AUGraphAddNode[kAudioUnitSubType_NBandEQ] failed"];
        
        AUGraphNodeInfo(_graph, eqNode, NULL, &eqAU);
        
        bandArray = @[ @60, @170, @370, @600, @1000, @3000, @6000, @12000, @14000, @16000 ];
        UInt32  numBands = [bandArray count];
        AudioUnitSetProperty(eqAU,
                             kAUNBandEQProperty_NumberOfBands,
                             kAudioUnitScope_Global,
                             0,
                             &numBands,
                             sizeof(numBands));
        
        for (NSUInteger i=0; i<numBands; i++)
        {
            [self CheckError:AudioUnitSetParameter(eqAU,
                                             kAUNBandEQParam_Frequency + i,
                                             kAudioUnitScope_Global,
                                             0,
                                             (AudioUnitParameterValue)[[bandArray objectAtIndex:i] floatValue],
                                             0)
                      ErrMsg:@"Set EQ Bands Failed."];
        }
        
        for (NSUInteger i=0; i<numBands; i++) {
            AudioUnitSetParameter(eqAU,
                                  kAUNBandEQParam_BypassBand+i,
                                  kAudioUnitScope_Global,
                                  0,
                                  (AudioUnitParameterValue)0,
                                  0);
        }
    }
    
    AUNode filePlayerNode;
    {
        AudioComponentDescription fileplayerAudioDesc = {0};
        fileplayerAudioDesc.componentType = kAudioUnitType_Generator;
        fileplayerAudioDesc.componentSubType = kAudioUnitSubType_AudioFilePlayer;
        fileplayerAudioDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
        // adds a node with above description to the graph
        [self CheckError:AUGraphAddNode(_graph, &fileplayerAudioDesc, &filePlayerNode) ErrMsg:@"AUGraphAddNode[kAudioUnitSubType_AudioFilePlayer] failed"];
    }
    
    //Connect the nodes
    {
        // connect the output source of the file player AU to the input source of the output node
        //            CheckError(AUGraphConnectNodeInput(_graph, filePlayerNode, 0, outputNode, 0), "AUGraphConnectNodeInput");
        
        [self CheckError:AUGraphConnectNodeInput(_graph, filePlayerNode, 0, effectNode, 0) ErrMsg:@"AUGraphConnectEffectNode"];
        [self CheckError:AUGraphConnectNodeInput(_graph, effectNode, 0, eqNode, 0) ErrMsg:@"AUGraphConnectEQNode"];
        [self CheckError:AUGraphConnectNodeInput(_graph, eqNode, 0, outputNode, 0) ErrMsg:@"AUGraphConnectOutputNode"];
    }
    
    
    // configure the file player
    // tell the file player unit to load the file we want to play
    {
        //?????
        AudioStreamBasicDescription inputFormat; // input file's data stream description
        AudioFileID inputFile; // reference to your input file
        
        // open the input audio file and store the AU ref in _player
        //CFURLRef songURL = (__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:@"503342" withExtension:@"aif"];
        NSURL *songURL = [NSURL fileURLWithPath:fileName];
        [self CheckError:AudioFileOpenURL((__bridge CFURLRef)songURL, kAudioFileReadPermission, 0, &inputFile) ErrMsg:@"AudioFileOpenURL failed"];
        
        //create an empty MyAUGraphPlayer struct
        AudioUnit fileAU;
        
        // get the reference to the AudioUnit object for the file player graph node
        [self CheckError:AUGraphNodeInfo(_graph, filePlayerNode, NULL, &fileAU) ErrMsg:@"AUGraphNodeInfo failed"];
        
        // get and store the audio data format from the file
        UInt32 propSize = sizeof(inputFormat);
        [self CheckError:AudioFileGetProperty(inputFile, kAudioFilePropertyDataFormat, &propSize, &inputFormat) ErrMsg: @"couldn't get file's data format"];
        
        [self CheckError:AudioUnitSetProperty(fileAU, kAudioUnitProperty_ScheduledFileIDs, kAudioUnitScope_Global, 0, &(inputFile), sizeof((inputFile))) ErrMsg:@"AudioUnitSetProperty[kAudioUnitProperty_ScheduledFileIDs] failed"];
        
        UInt64 nPackets;
        UInt32 propsize = sizeof(nPackets);
        [self CheckError:AudioFileGetProperty(inputFile, kAudioFilePropertyAudioDataPacketCount, &propsize, &nPackets) ErrMsg:@"AudioFileGetProperty[kAudioFilePropertyAudioDataPacketCount] failed"];
        
        // tell the file player AU to play the entire file
        ScheduledAudioFileRegion rgn;
        memset (&rgn.mTimeStamp, 0, sizeof(rgn.mTimeStamp));
        rgn.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
        rgn.mTimeStamp.mSampleTime = 0;
        rgn.mCompletionProc = NULL;
        rgn.mCompletionProcUserData = NULL;
        rgn.mAudioFile = inputFile;
        rgn.mLoopCount = 0;
        rgn.mStartFrame = 0;
        rgn.mFramesToPlay = nPackets * inputFormat.mFramesPerPacket;
        
        [self CheckError:AudioUnitSetProperty(fileAU, kAudioUnitProperty_ScheduledFileRegion, kAudioUnitScope_Global, 0,&rgn, sizeof(rgn)) ErrMsg:@"AudioUnitSetProperty[kAudioUnitProperty_ScheduledFileRegion] failed"];
        
        // prime the file player AU with default values
        UInt32 defaultVal = 0;
        [self CheckError:AudioUnitSetProperty(fileAU, kAudioUnitProperty_ScheduledFilePrime, kAudioUnitScope_Global, 0, &defaultVal, sizeof(defaultVal)) ErrMsg:@"AudioUnitSetProperty[kAudioUnitProperty_ScheduledFilePrime] failed"];
        
        // tell the file player AU when to start playing (-1 sample time means next render cycle)
        AudioTimeStamp startTime;
        memset (&startTime, 0, sizeof(startTime));
        startTime.mFlags = kAudioTimeStampSampleTimeValid;
        startTime.mSampleTime = -1;
        [self CheckError:AudioUnitSetProperty(fileAU, kAudioUnitProperty_ScheduleStartTimeStamp, kAudioUnitScope_Global, 0, &startTime, sizeof(startTime)) ErrMsg:@"AudioUnitSetProperty[kAudioUnitProperty_ScheduleStartTimeStamp]"];
        
        // file duration
        //double duration = (nPackets * _player.inputFormat.mFramesPerPacket) / _player.inputFormat.mSampleRate;
    }
    
    if (_graph) {
        
        OSStatus result;
        // Initialize the audio processing graph.
        result = AUGraphInitialize (_graph);
        NSAssert (result == noErr, @"Unable to initialze AUGraph object. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        // Start the graph
        result = AUGraphStart (_graph);
        NSAssert (result == noErr, @"Unable to start audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        // Print out the graph to the console
        CAShow (_graph);
    }
    _isGraphWorking = YES;
}


/**
 * 为麦克风实时回放初始化AUGraph
 * @Param reverLevel: 混响强度，0-100.
 */
- (void)initGraphForMic:(float)wetDry Gain:(float)gainLevel MinDelay:(float)minDelayTime MaxDelay:(float)maxDelayTime DecayAt0Hz:(float)decayAt0Hz DecayAtNyquist:(float)decayAtNyquist;
{
    AudioUnit   convertAU;
    OSStatus    result = noErr;
    
    {
        //create a new AUGraph
        [self CheckError:NewAUGraph(&_graph) ErrMsg:@"NewAUGraph failed"];
        // opening the graph opens all contained audio units but does not allocate any resources yet
        [self CheckError:AUGraphOpen(_graph) ErrMsg:@"AUGraphOpen failed"];
        // now initialize the graph (causes resources to be allocated)
        [self CheckError:AUGraphInitialize(_graph) ErrMsg:@"AUGraphInitialize failed"];
    }
    
    
    AUNode outputNode;
    {
        AudioComponentDescription outputAudioDesc = {0};
        outputAudioDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
        outputAudioDesc.componentType = kAudioUnitType_Output;
        outputAudioDesc.componentSubType = kAudioUnitSubType_RemoteIO;
        // adds a node with above description to the graph
        [self CheckError:AUGraphAddNode(_graph, &outputAudioDesc, &outputNode) ErrMsg: @"AUGraphAddNode[kAudioUnitSubType_DefaultOutput] failed"];
        
        AUGraphNodeInfo(_graph, outputNode, NULL, &ioAU);
        
        UInt32 flag = 1;
        [self CheckError:AudioUnitSetProperty(ioAU,
                                        kAudioOutputUnitProperty_EnableIO,
                                        kAudioUnitScope_Output,
                                        0,
                                        &flag,
                                        sizeof(flag))
                  ErrMsg:@"EnableIO failed"];
        
        [self CheckError:AudioUnitSetProperty(ioAU,
                                        kAudioOutputUnitProperty_EnableIO,
                                        kAudioUnitScope_Input,
                                        1,
                                        &flag,
                                        sizeof(flag))
                  ErrMsg:@"couldn't enable input on the remote I/O unit"];
        
        
        AudioStreamBasicDescription audioFormat;
        audioFormat.mSampleRate         = 44100.00;
        audioFormat.mFormatID           = kAudioFormatLinearPCM;
        audioFormat.mFormatFlags        = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        audioFormat.mFramesPerPacket    = 1;
        audioFormat.mChannelsPerFrame   = 1;
        audioFormat.mBitsPerChannel     = 16;
        audioFormat.mBytesPerPacket     = 2;
        audioFormat.mBytesPerFrame      = 2;
        
        
        // Apply format
        AudioUnitSetProperty(ioAU,
                             kAudioUnitProperty_StreamFormat,
                             kAudioUnitScope_Output,
                             1,
                             &audioFormat,
                             sizeof(audioFormat));
    }
    
    AUNode mixerNode;
    {
        AudioComponentDescription mixerAudioDesc = {0};
        mixerAudioDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
        mixerAudioDesc.componentType = kAudioUnitType_Mixer;
        mixerAudioDesc.componentSubType = kAudioUnitSubType_MultiChannelMixer;
        mixerAudioDesc.componentFlags = 0;
        mixerAudioDesc.componentFlagsMask = 0;
        // adds a node with above description to the graph
        [self CheckError:AUGraphAddNode(_graph, &mixerAudioDesc, &mixerNode) ErrMsg:@"AUGraphAddNode[kAudioUnitSubType_AU3DMixerEmbedded] failed"];
        AUGraphNodeInfo(_graph, mixerNode, NULL, &mixerAU);

    }
    
    AUNode effectNode;
    {
        AudioComponentDescription effectAudioDesc = {0};
        effectAudioDesc.componentType = kAudioUnitType_Effect;
        effectAudioDesc.componentSubType = kAudioUnitSubType_Reverb2;
        effectAudioDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
        // adds a node with above description to the graph
        [self  CheckError:AUGraphAddNode(_graph, &effectAudioDesc, &effectNode) ErrMsg: @"AUGraphAddNode[kAudioUnitSubType_AudioFilePlayer] failed"];
        
        AUGraphNodeInfo(_graph, effectNode, NULL, &effectAU);
        
        //UInt32 roomType = kReverbRoomType_LargeRoom;
        //CheckError(AudioUnitSetProperty(mixerAU, kAudioUnitProperty_ReverbRoomType,
        //                                kAudioUnitScope_Global, 0, &roomType, sizeof(UInt32)),
        //           @"AudioUnitSetProperty[kAudioUnitProperty_ReverbRoomType] failed");
        AudioUnitSetParameter(effectAU, kReverb2Param_DryWetMix, kAudioUnitScope_Global, 0, wetDry, 0);
        AudioUnitSetParameter(effectAU, kReverb2Param_Gain, kAudioUnitScope_Global, 0, gainLevel, 0);
        AudioUnitSetParameter(effectAU, kReverb2Param_MinDelayTime, kAudioUnitScope_Global, 0, minDelayTime, 0);
        AudioUnitSetParameter(effectAU, kReverb2Param_MaxDelayTime, kAudioUnitScope_Global, 0, maxDelayTime, 0);
        AudioUnitSetParameter(effectAU, kReverb2Param_DecayTimeAt0Hz, kAudioUnitScope_Global, 0, decayAt0Hz, 0);
        AudioUnitSetParameter(effectAU, kReverb2Param_DecayTimeAtNyquist, kAudioUnitScope_Global, 0, decayAtNyquist, 0);
    }
    
    AUNode eqNode;
    {
        AudioComponentDescription eqAudioDesc = {0};
        eqAudioDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
        eqAudioDesc.componentType = kAudioUnitType_Effect;
        eqAudioDesc.componentSubType = kAudioUnitSubType_NBandEQ;
        eqAudioDesc.componentFlags = 0;
        eqAudioDesc.componentFlagsMask = 0;
        // adds a node with above description to the graph
        [self CheckError:AUGraphAddNode(_graph, &eqAudioDesc, &eqNode) ErrMsg:@"AUGraphAddNode[kAudioUnitSubType_NBandEQ] failed"];
        
        AUGraphNodeInfo(_graph, eqNode, NULL, &eqAU);
        
        bandArray = @[@60, @170, @370, @600, @1000, @3000, @6000, @12000, @14000, @16000];
        UInt32  numBands = [bandArray count];
        AudioUnitSetProperty(eqAU,
                             kAUNBandEQProperty_NumberOfBands,
                             kAudioUnitScope_Global,
                             0,
                             &numBands,
                             sizeof(numBands));
        
        int maxBands = [self maxNumberOfBands];
        NSLog(@"Max bands:%d", maxBands);
        
        for (NSUInteger i=0; i<numBands; i++)
        {
            [self CheckError:AudioUnitSetParameter(eqAU,
                                             kAUNBandEQParam_Frequency + i,
                                             kAudioUnitScope_Global,
                                             0,
                                             (AudioUnitParameterValue)[[bandArray objectAtIndex:i] floatValue],
                                             0)
                      ErrMsg:@"Set EQ Bands Failed."];
        }
        
        for (NSUInteger i=0; i<numBands; i++)
        {
            [self CheckError:AudioUnitSetParameter(eqAU,
                                  kAUNBandEQParam_BypassBand+i,
                                  kAudioUnitScope_Global,
                                  0,
                                  (AudioUnitParameterValue)0,
                                  0)
             ErrMsg:@"Set EQ Bypass band Failed."];
        }
    }
    
    AUNode convertNode;
    {
        AudioComponentDescription convertUnitDescription;
        convertUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
        convertUnitDescription.componentType          = kAudioUnitType_FormatConverter;
        convertUnitDescription.componentSubType       = kAudioUnitSubType_AUConverter;
        convertUnitDescription.componentFlags         = 0;
        convertUnitDescription.componentFlagsMask     = 0;
        result = AUGraphAddNode (_graph, &convertUnitDescription, &convertNode);
        NSCAssert (result == noErr, @"Unable to add the converted unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        AUGraphNodeInfo(_graph, convertNode, NULL, &convertAU);
        
        AudioStreamBasicDescription eqStreamFormat;
        UInt32 streamFormatSize = sizeof(eqStreamFormat);
        result = AudioUnitGetProperty(mixerAU, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &eqStreamFormat, &streamFormatSize);
        NSAssert (result == noErr, @"Unable to get mixer output format. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        result = AudioUnitSetProperty(convertAU, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &eqStreamFormat, streamFormatSize);
        NSAssert (result == noErr, @"Unable to set converter input format. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        result = AudioUnitGetProperty(effectAU, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &eqStreamFormat, &streamFormatSize);
        NSAssert (result == noErr, @"Unable to get effect input format. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        result = AudioUnitSetProperty(convertAU, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &eqStreamFormat, streamFormatSize);
        NSAssert (result == noErr, @"Unable to set converter output format. Error code: %d '%.4s'", (int) result, (const char *)&result);
    }
    
    //Connect the nodes
    {
        [self CheckError:AUGraphConnectNodeInput(_graph, outputNode, 1, mixerNode, 0) ErrMsg:@"AUGraphConnectMixerNode"];
        [self CheckError:AUGraphConnectNodeInput(_graph, mixerNode, 0, convertNode, 0) ErrMsg:@"AUGraphConnectConvertNode"];
        [self CheckError:AUGraphConnectNodeInput(_graph, convertNode, 0, eqNode, 0) ErrMsg:@"AUGraphConnectEQNode"];
        [self CheckError:AUGraphConnectNodeInput(_graph, eqNode, 0, effectNode, 0) ErrMsg:@"AUGraphConnectEffectNode"];
        [self CheckError:AUGraphConnectNodeInput(_graph, effectNode, 0, outputNode, 0) ErrMsg:@"AUGraphConnectOutputNode"];
    }
    
    
    if (_graph) {
        
        OSStatus result;
        // Initialize the audio processing graph.
        //result = AUGraphInitialize (_graph);
        //NSAssert (result == noErr, @"Unable to initialze AUGraph object. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        // Start the graph
        result = AUGraphStart (_graph);
        NSAssert (result == noErr, @"Unable to start audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        // Print out the graph to the console
        CAShow (_graph);
    }
    _isGraphWorking = YES;
}

/**
 * 以缺省参数启动播放文件
 */
- (void)initGraphForPlayFile:(NSString*)fileName
{
    [self initGraphForPlayFile:(NSString*)fileName WetDry:DEFAULT_WETDRY Gain:DEFAULT_GAIN MinDelay:DEFAULT_MIN_DELAY_TIME MaxDelay:DEFAULT_MAX_DELAY_TIME DecayAt0Hz:DEFAULT_DECAY_TIME_AT_0HZ DecayAtNyquist:DEFAULT_DECAY_TIME_AT_NYQUIST];
}

/**
 * 以缺省参数启动使用麦克风
 */
- (void)initGraphForMic
{
    [self initGraphForMic:DEFAULT_WETDRY Gain:DEFAULT_GAIN MinDelay:DEFAULT_MIN_DELAY_TIME MaxDelay:DEFAULT_MAX_DELAY_TIME DecayAt0Hz:DEFAULT_DECAY_TIME_AT_0HZ DecayAtNyquist:DEFAULT_DECAY_TIME_AT_NYQUIST];
}

/**
 * 以无混响、无均衡调节的方式启动使用麦克风
 */
- (void)initGraphForMicWithoutEffect
{
    [self initGraphForMic:0.f Gain:DEFAULT_GAIN MinDelay:DEFAULT_MIN_DELAY_TIME MaxDelay:DEFAULT_MAX_DELAY_TIME DecayAt0Hz:DEFAULT_DECAY_TIME_AT_0HZ DecayAtNyquist:DEFAULT_DECAY_TIME_AT_NYQUIST];
    int numBands = [self numBands];
    for(int i = 0; i < numBands; ++i)
    {
        [self setEQGain:0 Band:i];
    }
}

/**
 * 停止AudioSession
 */
- (void)stopAudioSession
{
    AudioSessionSetActive(FALSE);
}

/**
 * 设置干湿度
 * @param level: 干湿度，0-100
 */
- (void)setWetDry:(float)level
{
    if(_isGraphWorking && level >= 0.f && level <= 100.f)
        AudioUnitSetParameter(effectAU, kReverb2Param_DryWetMix, kAudioUnitScope_Global, 0, level, 0);
}

/**
 * 设置混响增益
 * @param level: 增益， -20 - 20
 */
- (void)setReverbGain:(float)level
{
    if(_isGraphWorking && level >= -20.f && level <= 20.f)
        AudioUnitSetParameter(effectAU, kReverb2Param_Gain, kAudioUnitScope_Global, 0, level, 0);
}

/**
 * 设置最小延迟时间
 * @param time: 延迟时间，以秒为单位
 */
- (void)setMinDelayTime:(float)time
{
    if(_isGraphWorking)
        AudioUnitSetParameter(effectAU, kReverb2Param_MinDelayTime, kAudioUnitScope_Global, 0, time, 0);
}

/**
 * 设置最大延迟时间
 * @param time: 延迟时间，以秒为单位
 */
- (void)setMaxDelayTime:(float)time
{
    if(_isGraphWorking)
        AudioUnitSetParameter(effectAU, kReverb2Param_MaxDelayTime, kAudioUnitScope_Global, 0, time, 0);
}

/**
 * 设置0Hz衰减时间
 * @param time: 衰减时间，以秒为单位
 */
- (void)setDecay0HzTime:(float)time
{
    if(_isGraphWorking)
        AudioUnitSetParameter(effectAU, kReverb2Param_DecayTimeAt0Hz, kAudioUnitScope_Global, 0, time, 0);
}

/**
 * 设置Nyquist衰减时间
 * @param time: 衰减时间，以秒为单位
 */
- (void)setDecayNyquistTime:(float)time
{
    if(_isGraphWorking)
        AudioUnitSetParameter(effectAU, kReverb2Param_DecayTimeAtNyquist, kAudioUnitScope_Global, 0, time, 0);
}

/**
 * 设置均衡增益
 * @param gain: Gain value -96 - 24
 * @param bandIdx: The band index, from 0
 */
- (void)setEQGain:(int)gain Band:(int)bandIdx
{
    //如果bandIdx是非法值，直接返回
    if(bandIdx < 0 || bandIdx >= [self getEQBandCount])
        return;
    
    AudioUnitParameterID parameterID = kAUNBandEQParam_Gain + bandIdx;
    
    [self CheckError:AudioUnitSetParameter(eqAU,
                                     parameterID,
                                     kAudioUnitScope_Global,
                                     0,
                                     (AudioUnitParameterValue)gain,
                                     0)
              ErrMsg:@"Set EQ Gain Failed."];
}

/**
 * 设置频宽属性
 * @param octave: 频宽值 0.05 - 5.0 
 * @param bandIdx: The band index, from 0
 */
- (void)setEQBandWidth:(float)octave Band:(int)bandIdx
{
    //如果bandIdx是非法值，直接返回
    if(bandIdx < 0 || bandIdx >= [self getEQBandCount])
        return;
    
    AudioUnitParameterID parameterID = kAUNBandEQParam_Bandwidth + bandIdx;
    
    [self CheckError:AudioUnitSetParameter(eqAU,
                                           parameterID,
                                           kAudioUnitScope_Global,
                                           0,
                                           (AudioUnitParameterValue)octave,
                                           0)
              ErrMsg:@"Set EQ Gain Failed."];
}

/**
 * 停止Graph
 */
- (void)stopGraph
{
    if(_graph)
    {
        AUGraphStop(_graph);
        DisposeAUGraph(_graph);
    }
    _isGraphWorking = NO;
}

/**
 * 获取EQ调节的频率段数
 */
- (int)getEQBandCount
{
    return [bandArray count];
}

/**
 * 获取设备支持的最大频率段数
 */
- (UInt32)maxNumberOfBands
{
    UInt32 maxNumBands = 0;
    UInt32 propSize = sizeof(maxNumBands);
    AudioUnitGetProperty(eqAU,
                        kAUNBandEQProperty_MaxNumberOfBands,
                        kAudioUnitScope_Global,
                        0,
                        &maxNumBands,
                        &propSize);
    
    return maxNumBands;
}

/**
 * 获取当前的频率段数
 */
- (UInt32)numBands
{
    UInt32 numBands;
    UInt32 propSize = sizeof(numBands);
    AudioUnitGetProperty(eqAU,
                        kAUNBandEQProperty_NumberOfBands,
                        kAudioUnitScope_Global,
                        0,
                        &numBands,
                        &propSize);
    
    return numBands;
}


- (void)setVolume:(float)volume
{
    [self CheckError:AudioUnitSetParameter(mixerAU, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, volume, 0)
              ErrMsg:@"Set volume failed."];
}


@end
