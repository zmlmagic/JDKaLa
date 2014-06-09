//
//  DownloadSection.m
//  TestProxy
//
//  Created by 韩 抗 on 13-5-2.
//  Copyright (c) 2013年 ipvd. All rights reserved.
//

#import "DownloadSection.h"

@implementation DownloadSection

- (id) init
{
    return [self initWithStartPos:0 WithEndPos:0];
}

- (id) initWithStartPos:(int)startPos WithEndPos:(int)endPos
{
    self = [super init];
    
    if(self != nil)
    {
        _startPos = startPos;
        _endPos = endPos;
    }
    return self;
}

- (int) length
{
    return _endPos - _startPos + 1;
}
@end
