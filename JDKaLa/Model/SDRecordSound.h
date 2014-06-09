//
//  SDRecordSound.h
//  JuKaLa
//
//  Created by 张 明磊 on 10/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDRecordSound : NSObject

@property (retain, nonatomic) NSString *string_recordName;
@property (retain, nonatomic) NSString *string_defaultRecordName;
@property (retain, nonatomic) NSString *string_recordMD5;
@property (retain, nonatomic) NSString *string_recordStartTime;
@property (retain, nonatomic) NSString *string_recordEndTime;
@property (retain, nonatomic) NSString *string_dateTime;
@property (assign, nonatomic) NSInteger integer_recordSign;
@property (retain, nonatomic) NSString *string_videoUrl;
@property (retain, nonatomic) NSString *string_audio0Url;
@property (retain, nonatomic) NSString *string_audio1Url;
/**
 录音特效
 **/
@property (assign, nonatomic) NSInteger integer_mixTag;

@end
