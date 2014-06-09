//
//  DownloadSection.h
//  TestProxy
//
//  Created by 韩 抗 on 13-5-2.
//  Copyright (c) 2013年 ipvd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadSection : NSObject

@property (assign, nonatomic) int startPos;
@property (assign, nonatomic) int endPos;

- (id) init;
- (id) initWithStartPos:(int)startPos WithEndPos:(int)endPos;
- (int) length;
@end
