//
//  MediaCacher.h
//  TestProxy
//
//  Created by 韩 抗 on 13-4-28.
//  Copyright (c) 2013年 ipvd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "DownloadSection.h"

@interface MediaCacher : NSObject<ASIHTTPRequestDelegate>
{
    NSMutableArray  *sections;
    NSFileHandle    *mTempFile;
    ASIHTTPRequest  *mHttpRequest;
    DownloadSection *mCurSection;
    
    int         mCurPos;
    int         mOldPos;
    int         mCurSectionIdx;
    int         mRetryTimes;
    BOOL        mInited;
}

@property (readonly,nonatomic) NSString *url;
@property (readonly,nonatomic) NSString *tempFileName;
@property (readonly,nonatomic) NSString *localFileName;
@property (readonly,nonatomic) int      fileSize;
@property (readonly,nonatomic) BOOL     finishDownload;


- (id)initWithURL:(NSString*)url withLocalFile:(NSString*)localFile;
- (BOOL)startDownloadWithStartPos:(int)startPos;
- (BOOL)switchToPos:(int)startPos;
- (void)stopDownload;
- (DownloadSection*)getDownloadSectionWithStartPos:(int)startPos;
- (BOOL)isSectionValid:(DownloadSection*)section;
- (int)getFirstSectionSize;
- (void)importPrereadWithStartPos:(int)startPos FileSize:(int)fileSize;
- (BOOL)isFullDownload;
- (int)getPercentOfCache;
- (BOOL)retryDownload:(int)startPos;
- (void)saveSCT;

@end
