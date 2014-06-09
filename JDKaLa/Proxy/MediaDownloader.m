//
//  MediaDownloader.m
//  TestProxy
//
//  Created by 韩 抗 on 13-5-9.
//  Copyright (c) 2013年 ipvd. All rights reserved.
//

#import "MediaDownloader.h"
#import "MediaProxyGlobal.h"

@implementation MediaDownloader

- (id)initWithURL:(NSString *)url WithLocalFileName:(NSString*)localFileName
{
    self = [super init];
    if(self)
    {
        if(url != nil && localFileName != nil)
        {
            _url = [[NSString alloc]initWithString:url];
            _localFileName = [[NSString alloc]initWithString:localFileName];
            _tmpFileName = [[NSString alloc]initWithFormat:@"%@.tmp",localFileName]; 
        }
        else
        {
            _url = nil;
            _localFileName = nil;
            _tmpFileName = nil;
        }
        
        NSString *pathName = [_localFileName stringByDeletingLastPathComponent];
        [[NSFileManager defaultManager] createDirectoryAtPath:pathName withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return self;
}

- (id)init
{
    return [self initWithURL:nil WithLocalFileName:nil];
}

- (void)dealloc
{
    [_url release];
    [_localFileName release];
    [_tmpFileName release];
    [_asiRequest clearDelegatesAndCancel];
    [_asiRequest release], _asiRequest = nil;
    [super dealloc];
}

/**
 * 开始下载
 * @return YES:正常开始下载  NO:无法下载或已不需要下载
 */
- (BOOL)startDownload
{
    if(_url == nil || _localFileName == nil)
    {
        return NO;
    }
    
    //如果文件已经存在，说明已经下载完成了
    if([[NSFileManager defaultManager] fileExistsAtPath:_localFileName])
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:NOTI_MEDIA_DOWNLOAD_FINISH object:self];
        return NO;
    }


    _curSize = 0;
    mOldSize = 0;
    _totalSize = 0;
    isResumeDownload = NO;
        
    _asiRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:_url]];
    [_asiRequest setDelegate:self];
    [_asiRequest setDownloadProgressDelegate:self];
    [_asiRequest setShowAccurateProgress:YES];
    [_asiRequest setDownloadDestinationPath:_localFileName];
    [_asiRequest setTemporaryFileDownloadPath:_tmpFileName];
    [_asiRequest setAllowResumeForFileDownloads:YES];
    [_asiRequest setShouldUseRFC2616RedirectBehaviour:YES];
    [_asiRequest setNumberOfTimesToRetryOnTimeout:3];
        
    _downloadStatus = Downloading;
    [_asiRequest startAsynchronous];
    return YES;
}

/**
 * 暂停下载
 */
- (void)pauseDownload
{
    if(_asiRequest != nil)
    {
        [_asiRequest clearDelegatesAndCancel];
        [_asiRequest release], _asiRequest = nil;
        _downloadStatus = DownloadPause;
    }
}

/**
 * 恢复下载
 */
- (void)resumeDownload
{
    if(_downloadStatus == DownloadPause)
    {
        _curSize = 0;
        mOldSize = 0;
        
        _asiRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:_url]];
        [_asiRequest setDelegate:self];
        [_asiRequest setDownloadProgressDelegate:self];
        [_asiRequest setShowAccurateProgress:YES];
        [_asiRequest setDownloadDestinationPath:_localFileName];
        [_asiRequest setTemporaryFileDownloadPath:_tmpFileName];
        [_asiRequest setAllowResumeForFileDownloads:YES];
        [_asiRequest setShouldUseRFC2616RedirectBehaviour:YES];
        [_asiRequest setNumberOfTimesToRetryOnTimeout:3];
        
        _downloadStatus = Downloading;
        [_asiRequest startAsynchronous];
    }
}

#pragma mark ASIHttpRequest delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    _downloadStatus = DownloadFinish;
    NSLog(@"success Finish Download");
    
    //发下载完成消息
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:NOTI_MEDIA_DOWNLOAD_FINISH object:self];
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    NSLog(@"%@",responseHeaders);
    
    //if (_totalSize == 0)
    {
        NSString * range = [[request responseHeaders]objectForKey:@"Content-Range"];
        if(range == nil)
        {
            //如果是从头下载，Response中没有Content-Range域。此时直接用Content-Length
            _totalSize = request.contentLength;
            isResumeDownload = NO;
        }
        else
        {
            //如果是续传，则从Content-Range中获取文件长度
            _totalSize = [[range lastPathComponent] intValue];
            isResumeDownload = YES;
        }
    }
}

- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    // when resume download, the bytes is the size of the file which had down

    if(isResumeDownload)
    {
        _curSize = bytes;
        isResumeDownload = NO;
    }
    else
    {
        _curSize += bytes;
    }
    //NSLog(@"curSize:%lld", _curSize);
    if(_curSize - mOldSize > _totalSize / 100)
    {
        mOldSize =  _curSize;
        int progress = (int)((float)_curSize / _totalSize * 100);
        [self sendProgressMessage:progress];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"MediaDownloader Failed error : %@", [error localizedDescription]);
    
    _downloadStatus = DownloadFinish;
    [_asiRequest clearDelegatesAndCancel];
    [_asiRequest release];
    _asiRequest = nil;
    
    //发下载失败消息
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:NOTI_MEDIA_DOWNLOAD_FAILED object:_url];
    
    //NSDictionary *resp = [request responseHeaders];
    //NSString *redirectURL = [resp valueForKey:@"Location"];
    //if([request responseStatusCode] == 302 && redirectURL){
    //    [self redirectToDest:redirectURL];
    //}
}

/**
 * 发进度消息
 * @param percent
 */
- (void)sendProgressMessage:(int)percent
{
    NSMutableDictionary *state = [[NSMutableDictionary alloc] init];
    [state setValue:_url forKey:@"url"];
    [state setValue:[NSNumber numberWithInt:percent] forKey:@"progress"];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:NOTI_DOWNLOAD_PROGRESS_CHANGE object:self userInfo: [state autorelease]]; ///auto
}
@end
