//
//  MediaHead.m
//  TestProxy
//
//  Created by 韩 抗 on 13-5-28.
//  Copyright (c) 2013年 ipvd. All rights reserved.
//

#import "MediaHead.h"
#import "MediaProxyGlobal.h"

@implementation MediaHead

- (id)initWithURL:(NSString*)url
{
    self = [super init];
    if(self != nil)
    {
        _url = [[NSString alloc] initWithString:url];
        
        _finishDownload = NO;
        _data = nil;
        mHttpRequest = nil;
        mInited = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [_url release];
    [_data release];
    
    if(mHttpRequest != nil)
    {
        [mHttpRequest clearDelegatesAndCancel];
        [mHttpRequest release];
    }
    [super dealloc];
}

- (BOOL)getHead
{
    NSURL *url = [NSURL URLWithString:_url];
    
    if(DONT_WIPE_MEDIA_HEAD)
    {
        //如果设定为不需要验证的模式，则直接发验证完成消息
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:NOTI_GET_HEAD_FINISH object:_url];
        return YES;
    }
    
    if(_finishDownload)
    {
        return NO;
    }
    
    [self cancelGetHead];
    
    if(_data != nil)
        [_data release];
    
    _data = [[NSMutableData alloc]init];
    mCurPos = 0;

    
    mHttpRequest = [ASIHTTPRequest requestWithURL:url];
    [mHttpRequest retain];
    
    [mHttpRequest setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [mHttpRequest setDelegate:self];
    
    NSString *rangeString = [NSString stringWithFormat:@"bytes=0-%d", EMPTY_HEAD_SIZE];
    [mHttpRequest addRequestHeader:@"Range" value:rangeString];
    
    NSLog(@"Get Head Request:%@", [mHttpRequest requestHeaders]);
    
    [mHttpRequest startAsynchronous];
    return YES;
}

//取消获取Head
- (void)cancelGetHead
{
    if(mHttpRequest != nil)
    {
        NSLog(@"cancelGetHead");
        [mHttpRequest setDelegate:nil];
        [mHttpRequest cancel];
        [mHttpRequest release];
        mHttpRequest = nil;
        mCurPos = 0;
    }
}

#pragma mark ASIHTTPRequest Delegate

//接收到的Response header
- (void)didReceivedResponseHeaders:(ASIHTTPRequest *)request
{
    NSLog(@"MediaHead Response:%@",[request responseHeaders]);
}

//接收到下载数据
- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data
{
    //NSLog(@"retain:%d",[data retainCount]);

    mCurPos += [data length];
    [_data appendData:data];    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    //mCurPos = mOldPos = 0;
    
    [mHttpRequest setDelegate:nil];
    [mHttpRequest cancel];
    [mHttpRequest release];
    mHttpRequest = nil;
    
    _finishDownload = YES;
    
//    NSString *fileName = [NSString stringWithFormat:@"%@/%@/head.bin",[UIUtils getDocumentDirName],
//                          MUSIC_BUFFER_PATH];
//    [_data writeToFile:fileName atomically:NO];
    
    //发验证完成消息
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:NOTI_GET_HEAD_FINISH object:_url];
}


- (void)requestFailed:(ASIHTTPRequest *)request

{
    NSError *error = [request error];
    
    NSLog(@"MediaHead Error:%@", error);
    
    //发验证失败消息
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:NOTI_GET_HEAD_FAILED object:_url];
}


@end
