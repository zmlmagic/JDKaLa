//
//  MediaDownloader.h
//  TestProxy
//
//  Created by 韩 抗 on 13-5-9.
//  Copyright (c) 2013年 ipvd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

enum MediaDownloadStatus {
    DownloadNotStart = 0,
    Downloading,
    DownloadPause,
    DownloadFinish
};

@interface MediaDownloader : NSObject<ASIHTTPRequestDelegate, ASIProgressDelegate>
{
    ASIHTTPRequest  *_asiRequest;
    NSString        *_tmpFileName;
    BOOL            isResumeDownload;
    long long       mOldSize;
    enum MediaDownloadStatus _downloadStatus;
}

@property (readonly, nonatomic) NSString    *url;
@property (readonly, nonatomic) NSString    *localFileName;
@property (readonly, nonatomic) long long   curSize;
@property (readonly, nonatomic) long long   totalSize;

- (id) initWithURL:(NSString *)url WithLocalFileName:(NSString*)localFileName;
- (BOOL)startDownload;
- (void)pauseDownload;
- (void)resumeDownload;
@end
