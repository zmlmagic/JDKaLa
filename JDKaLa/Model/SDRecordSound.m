//
//  SDRecordSound.m
//  JuKaLa
//
//  Created by 张 明磊 on 10/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDRecordSound.h"

@implementation SDRecordSound


- (void)dealloc
{
    [_string_recordName release], _string_recordName = nil;
    [_string_defaultRecordName release], _string_defaultRecordName = nil;
    [_string_recordMD5 release], _string_recordMD5 = nil;
    [_string_recordStartTime release], _string_recordStartTime = nil;
    [_string_recordEndTime release], _string_recordEndTime = nil;
    [_string_dateTime release], _string_dateTime = nil;
    [_string_videoUrl release], _string_videoUrl = nil;
    [_string_audio0Url release], _string_audio0Url = nil;
    [_string_audio1Url release], _string_audio1Url = nil;
    [super dealloc];
}

@end
