//
//  MediaProxy.m
//  TestProxy
//
//  Created by 韩 抗 on 13-4-27.
//  Copyright (c) 2013年 ipvd. All rights reserved.
//


#import "MediaProxy.h"
#import "MediaProxyGlobal.h"
#import "UIUtils.h"

#define SERVER_PORT 9000

@implementation MediaProxy

bool isRunning = NO;//判断当前socket是否已经开始监听socket请求

- (void)startProxy
{
    if(!isRunning)
    {
        NSError *error = nil;
        if (![_listener acceptOnPort:SERVER_PORT error:&error]) {
            return;
        }
        NSLog(@"开始监听");
    }
    else
    {
        NSLog(@"重新监听");
        [_listener disconnect];
        for (int i = 0; i < [connectionSockets count]; i++) {
            [[connectionSockets objectAtIndex:i] disconnect];
        }
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(handleAudioDownloadFinish:)
               name:NOTI_MEDIA_DOWNLOAD_FINISH
             object:nil];
    [nc addObserver:self
           selector:@selector(handleGetFileHeaderSuccess:)
               name:NOTI_GET_FILE_HEADER_SUCCESS
             object:nil];
    [nc addObserver:self
           selector:@selector(handleGetFileHeaderFailed:)
               name:NOTI_GET_FILE_HEADER_FAILED
             object:nil];
    
    isRunning = YES;
}

/**
 * 销毁代理服务器
 */
- (void)destroyProxy
{
    if(isRunning)
    {
        isRunning = NO;
        NSLog(@"Stop proxy.");
        
        [self stopPreread];
        [self stopPrebuffer];
        
        [_listener disconnect];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self
                   name:NOTI_MEDIA_DOWNLOAD_FINISH
                 object:nil];
        [nc removeObserver:self
                      name:NOTI_GET_FILE_HEADER_FAILED
                    object:nil];
        [nc removeObserver:self
                      name:NOTI_GET_FILE_HEADER_SUCCESS
                    object:nil];
    }
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        _listener=[[AsyncSocket alloc] initWithDelegate:self];
    
        //初始化连接socket的个数
        connectionSockets=[[NSMutableArray alloc]init];
    
        cacher = nil;
        prereadCacher = nil;
        localHost = [[NSString alloc] initWithString:@"127.0.0.1"];
        audioDownloaders = nil;
        prereadAudioDownloaders = nil;
        clientAgent = nil;
        fileHeader = nil;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"connectSocket Retain Count:%d", [connectionSockets retainCount]);
    [connectionSockets release];
    [_listener release];
    [_videoUrl release];
    [_audioUrls release];
    [_audioLocalFiles release];
    [_videoLocalFile release];
    [self stopPrebuffer];
    [self stopPreread];
    [localHost release];
    [remoteHost release];
    [audioDownloaders release];
    [prereadAudioDownloaders release];
    [clientAgent release];
    [fileHeader release];
    [super dealloc];
}

#pragma mark socket delegate

//连接socket出错时调用
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"AsyncSocket Error Code: %d %@",[err code],[err description]);
    
//    if([err description] != nil)
//    {
//        //发缓存失败消息
//        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//        [nc postNotificationName:NOTI_CACHE_FAILED object:_videoUrl];
//    }
}

//收到新的socket连接时调用
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    //NSLog(@"New socket accept");
    [newSocket retain];
    [connectionSockets addObject:newSocket];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    //[sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:0];  // 这句话仅仅接收\r\n的数据
    
    //NSLog(@"didWriteDataWithTag");
    //[sock readDataWithTimeout: -1 tag: 0];
}

//与服务器建立连接时调用(连接成功)
- (void) onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    //NSLog(@"Socket connect. host:%@",host);
    
    curSock = sock;
    
    //NSString *returnMessage=@"Welcome To Socket Test Server!";
    //将NSString转换成为NSData类型
    //NSData *data=[returnMessage dataUsingEncoding:NSUTF8StringEncoding];
    //向当前连接服务器的客户端发送连接成功信息
    //[sock writeData:data withTimeout:-1 tag:0];
    [sock readDataWithTimeout: 3 tag: 0];
}

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 读取客户端发送来的信息(收到socket信息时调用)
 **/
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //NSString *msg = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];

    //NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    //[nc postNotificationName:NOTI_REQUEST_RECEIVE object:msg];
    //[msg release];
    
    NSRange range = [self getRequestRange:data];
    
    //如果Head没有下载完成，则直接退出
    if(!DONT_WIPE_MEDIA_HEAD && fileHeader == nil)
    {
        return;
    }
    
    //如果当前歌曲仍然需要进行远程下载，则先取消掉对下一个歌曲的预读
    //if([cacher getDownloadSectionWithStartPos:range.location] != nil)
    //{
    //    [self stopPreread];
    //}
    
    NSFileHandle    *cacheFile = nil;
    BOOL            switchDownloadPos = NO;
    //NSLog(@"StartPos:%d", range.location);
    
    
    //切换下载点
    if(range.location != 0)
    {
        switchDownloadPos = [cacher switchToPos:range.location];
    }

    //如果cacher的finishDownload是YES，说明此文件已全部下载完成，此时已经没有.tmp文件。
    if([cacher finishDownload])
    {
        cacheFile = [NSFileHandle fileHandleForReadingAtPath:[cacher localFileName]];
    }
    else
    {
        cacheFile = [NSFileHandle fileHandleForReadingAtPath:[cacher tempFileName]];
    }
    [cacheFile retain];
    
    [cacheFile seekToFileOffset:range.location];
    
    //发送Http response header 给Player
    NSString *responseHead = [self mkHttpReponseHeader:range];
    NSData *dataResponse=[responseHead dataUsingEncoding:NSUTF8StringEncoding];
    [sock writeData:dataResponse withTimeout:3 tag:0];
    //NSLog(@"ResponseHead: %@",responseHead);
    
    DownloadSection *section = [[DownloadSection alloc]init];
    int	fileSize = [cacher fileSize];
    int curPos = range.location;
    int endPos = range.length == -1 ? fileSize - 1 : range.location + range.length - 1;
 
    const int       BUF_SIZE = 102400;

    //NSLog(@"curPos:%d  endPos:%d sockets:%d", curPos, endPos, [connectionSockets count]);
    while(curPos < endPos)
    {
        section.startPos = curPos;
        section.endPos = curPos + BUF_SIZE >= endPos ? endPos : curPos + BUF_SIZE - 1;
        
        //如果数据还没有下载好，或用户关闭了代理，则中断连接。
        //此处不可用while循环等待数据，否则下载进程会被阻塞住
        if(![cacher isSectionValid:section] || !isRunning)
        {
            //NSLog(@"wait for data...");
            if(switchDownloadPos)
                sleep(2);
            [sock disconnectAfterWriting];
            //NSLog(@"Debug: Break writing");
            break;
        }
        
        NSData * readBuf = [cacheFile readDataOfLength:[section length]];
        
        if(0 == [readBuf length])
        {
            [sock disconnectAfterWriting];
            //NSLog(@"Read buf is empty.");
            break;
        }
        
        if(section.startPos < EMPTY_HEAD_SIZE && !DONT_WIPE_MEDIA_HEAD)
        {
            int headerLength = EMPTY_HEAD_SIZE - section.startPos;
            
            if(headerLength > section.endPos)
            {
                headerLength = section.endPos - section.startPos + 1;
            }
            
            Byte buffer[headerLength];
            [fileHeader getBytes:buffer range:NSMakeRange(section.startPos, headerLength)];
            NSMutableData *fixedBuf = [[NSMutableData alloc]initWithBytes:buffer length:headerLength];
            
            int remainLength = [readBuf length] - headerLength;
            if(remainLength > 0 && headerLength < section.endPos + 1)
            {
                Byte buffer2[remainLength];
                [readBuf getBytes:buffer2 range:NSMakeRange(EMPTY_HEAD_SIZE, remainLength)];
                [fixedBuf appendBytes:buffer2 length:remainLength];
            }
            [sock writeData:fixedBuf withTimeout:3 tag:0];
            [fixedBuf release];
            //NSLog(@"Debug: Write fixedBuf. curPos:%d endPos:%d length:%d", curPos, endPos, [fixedBuf length]);
        }
        else
        {
            [sock writeData:readBuf withTimeout:3 tag:0];
        }
        //[sock readDataWithTimeout: -1 tag: 0];

        curPos += [readBuf length];
        //NSLog(@"Write data:%d %d", curPos, endPos);
    }
    [sock readDataWithTimeout: -1 tag: 0];
    //NSLog(@"Debug: Write finish.");
    [section release];
    [cacheFile closeFile];
    [cacheFile release];
}


- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    //NSLog(@"Disconnect sock");
    NSLog(@"OnDisconnect RetainCount:%d", [connectionSockets retainCount]);
    [connectionSockets removeObject:sock];
}


- (NSString*)mkHttpReponseHeader:(NSRange)range
{
    //HTTP/1.1 200 OK\r\n
    //HTTP/1.1 206 Partial Content \r\n
    
    NSString    *strTime = [UIUtils getCurrentDateString];
    NSString    *headerFormat = @"HTTP/1.1 206 Partial Content\r\n"
        "Server: nginx/1.0.12\r\n"
        "Date: %@\r\n"
        "Content-Type: application/octet-stream\r\n"
        //"Content-Type: text/html\r\n"
        "Content-Length: %d\r\n"
        "Last-Modified: %@\r\n"
        "Connection: keep-alive\r\n"
        //"Connection: Close\r\n" +
        "Content-Range: bytes %d-%d/%d\r\n\r\n";
    
    if(range.length == -1)
    {
        range.length = [cacher fileSize] - range.location;
    }
    
    NSString *rtn = [[NSString alloc] initWithFormat:headerFormat,
                     strTime,
                     range.length,
                     strTime,
                     range.location,
                     range.location + range.length - 1,
                     [cacher fileSize]];
    //NSLog(@"Response Header:%@", rtn);
    return [rtn autorelease];
}

#pragma mark Prebuffer/Preread operation
- (void)stopPreread
{
    for(MediaDownloader * downloader in prereadAudioDownloaders)
    {
        [downloader pauseDownload];
        //[[NSNotificationCenter defaultCenter] removeObserver:self
        //                                                name:NOTI_MEDIA_DOWNLOAD_FINISH
        //                                              object:downloader];
    }
    
    [prereadAudioDownloaders release];
    prereadAudioDownloaders = nil;
    
    if(prereadCacher != nil)
    {
        [prereadCacher stopDownload];
        [prereadCacher release];
        prereadCacher = nil;
    }
}

- (void)stopPrebuffer
{
    if(cacher != nil)
    {
        [cacher stopDownload];
        [cacher release];
        cacher = nil;
    }
    [self stopDownloadAudio];
}

/**
 * 在播放前对媒体进行缓冲
 * @param urlString
 * @return
 */
- (void)prebufferWithUrl:(NSString*)urlString WithAudioUrls:(NSArray*) audioUrls
{
    [self stopPrebuffer];
        


    //checkSpace(mCacheLimitSize);

    [_videoUrl release];
    _videoUrl = [[NSString alloc]initWithString:urlString];
    
    [_audioUrls release];
    _audioUrls = [[NSArray alloc]initWithArray:audioUrls];
    mFinishAudioCount = 0;
    
    [_videoLocalFile release];
    _videoLocalFile = nil;
    
    [_audioLocalFiles release];
    _audioLocalFiles = [[NSMutableArray alloc]init];
    
    //清除掉fileHead数据
    [fileHeader release];
    fileHeader = nil;

    if(100 != [self getPrereadPercent:_videoUrl])
    {
        [self stopPreread];
    }
    
    audioDownloaders = [[NSMutableArray alloc]init];
    for(NSString *audioUrlString in _audioUrls)
    {
        NSString    *localFileName = [NSString stringWithFormat:@"%@/%@/%@",[UIUtils getDocumentDirName],
                                      MUSIC_BUFFER_PATH,
                                      [audioUrlString lastPathComponent]];
        MediaDownloader *downloader = [[MediaDownloader alloc] initWithURL:audioUrlString WithLocalFileName:localFileName];
        [_audioLocalFiles addObject:localFileName];
        [audioDownloaders addObject:downloader];
        [downloader startDownload];
        [downloader release];
    }
}

/**
 * 重新连接并缓存
 */
- (void)restartPrebuffer
{
    NSString *tempVideoUrl = [[NSString alloc]initWithString:_videoUrl];
    NSArray *tempAudioUrls = [[NSArray alloc]initWithArray:_audioUrls];
    [self prebufferWithUrl:tempVideoUrl WithAudioUrls:tempAudioUrls];
    [tempAudioUrls release];
    [tempVideoUrl release];
}


/**
 * 将远程URL转换成本地代理的URL
 * @return 本地URL
 */
- (NSString*) getLocalURLWithString:(NSString*)urlString
{
    NSURL * targetURL = [NSURL URLWithString:urlString];

    NSString *result = [NSString stringWithFormat:@"http://%@:%d%@",
                        localHost,
                        SERVER_PORT, [targetURL path]];
    // ----获取对应本地代理服务器的链接----//
    [remoteHost release];
    remoteHost = [targetURL host];
    [remoteHost retain];
    NSNumber * tempPort = [targetURL port];
    remotePort = tempPort == nil ? -1 : [tempPort intValue];

    return result;
}

/**
 * 获取HTTP Request中的Content-Range，返回Range的值
 */
- (NSRange)getRequestRange:(NSData*)request
{
    NSString    *header = [[NSString alloc]initWithData:request encoding:NSUTF8StringEncoding];
    NSRange     rtnRange;
    NSRange     findResult = [header rangeOfString:@"Range: bytes="];
    
    if(findResult.location != NSNotFound)
    {
        NSString    *tempStr = [[header substringFromIndex:findResult.location + findResult.length]stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        findResult = [tempStr rangeOfString:@"\n"];
        NSString    *rangeStr = [tempStr substringToIndex:findResult.location];

        findResult = [rangeStr rangeOfString:@"-"];
        NSString    *startStr = [rangeStr substringToIndex:findResult.location];
        
        rtnRange.location = [startStr intValue];
        
        NSString    *endStr = [rangeStr substringFromIndex:findResult.location + 1];

        if([endStr length] > 0)
        {
            rtnRange.length = [endStr intValue] - rtnRange.location + 1;
        }
        else
        {
            rtnRange.length = -1;
        }
    }
    else
    {
        rtnRange.location = 0;
        rtnRange.length = -1;
    }
    [header release];

    return rtnRange;
}

/**
 * 清除所有缓存文件
 */
+ (void)clearCache
{
    NSFileManager   *fm = [NSFileManager defaultManager];
    NSString        *cacheDirName = [NSString stringWithFormat:@"%@/%@/",[UIUtils getDocumentDirName],
                                     MUSIC_BUFFER_PATH];
    if(![fm fileExistsAtPath:cacheDirName])
    {
        return;
    }
    else
    {
        [fm removeItemAtPath:cacheDirName error:nil];
    }
}

/**
 * 对下一个要播放的视频文件进行预读
 * @param urlString
 * @param audioUrls
 * @return YES:正常开始预读，NO：这个URL已经预读完成，不需要再预读了。
 * @throws URISyntaxException
 */
- (BOOL)prereadWithURL:(NSString*)urlString WithAudioUrls:(NSArray*) audioUrls;
{
    [self stopPreread];
    
    //checkSpace(mCacheLimitSize);
    
    NSLog(@"Start preread:%@", urlString);
    
    //预读音频
    prereadAudioDownloaders = [[NSMutableArray alloc]init];
    for(NSString *audioUrlString in audioUrls)
    {
        NSString    *localFileName = [NSString stringWithFormat:@"%@/%@/%@",[UIUtils getDocumentDirName],
                                      MUSIC_BUFFER_PATH,
                                      [audioUrlString lastPathComponent]];
        MediaDownloader *downloader = [[MediaDownloader alloc] initWithURL:audioUrlString WithLocalFileName:localFileName];
        [prereadAudioDownloaders addObject:downloader];
//        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//        [nc addObserver:self
//               selector:@selector(handleAudioDownloadFinish:)
//                   name:NOTI_MEDIA_DOWNLOAD_FINISH
//                 object:downloader];
        [downloader startDownload];
        [downloader release];
        NSLog(@"add audio downloader");
    }

    NSString *fileFullName = [NSString stringWithFormat:@"%@/%@/%@",[UIUtils getDocumentDirName],
                              MUSIC_BUFFER_PATH,
                              [urlString lastPathComponent]];
    
    prereadCacher = [[MediaCacher alloc]initWithURL:urlString withLocalFile:fileFullName];
    
    if(![prereadCacher isFullDownload])
    {
        int startPos = [prereadCacher getFirstSectionSize];
        if(![prereadCacher startDownloadWithStartPos:startPos])
        {
            return NO;
        }
    }
    else
    {
        //发缓冲完成消息
        //NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        //[nc postNotificationName:NOTI_PREBUFFER_FINISH object:urlString];
        return NO;
    }
    
    return YES;
}

/**
 * 当前缓冲的文件是否已经下载完成？
 */
- (BOOL)isPrebufferFinish
{
    return [cacher finishDownload];
}

/**
 * 停止下载音轨
 */
- (void)stopDownloadAudio
{
    for(MediaDownloader * downloader in audioDownloaders)
    {
        [downloader pauseDownload];
//        [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                        name:NOTI_MEDIA_DOWNLOAD_FINISH
//                                                      object:downloader];
    }
    [audioDownloaders release];
    audioDownloaders = nil;
}


/**
 * 开始缓冲视频
 */
- (void)startPrebufferVideo
{
    int	startPos = 0;
    NSString *fileFullName = [NSString stringWithFormat:@"%@/%@/%@",[UIUtils getDocumentDirName],
                              MUSIC_BUFFER_PATH,
                              [_videoUrl lastPathComponent]];
    cacher = [[MediaCacher alloc]initWithURL:_videoUrl withLocalFile:fileFullName];
    
    //如果此URL已经做过预读, 则导入结果
    if(prereadCacher != nil)
    {
        [prereadCacher stopDownload];
        
        if([[prereadCacher url] isEqualToString:_videoUrl])
        {
            startPos = [prereadCacher getFirstSectionSize];
            [cacher importPrereadWithStartPos:startPos FileSize:[prereadCacher fileSize]];
        }
        [prereadCacher release];
        prereadCacher = nil;
    }
    
    if(![cacher finishDownload])
    {
        if(![cacher startDownloadWithStartPos:startPos])
        {
            //发缓冲完成消息
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:NOTI_PREBUFFER_FINISH object:_videoUrl];
        }
    }
    
    _videoLocalFile = [[NSString alloc] initWithString:[cacher localFileName]];
}

/**
 * 返回视频缓冲完成的比例
 * @return 百分比，例如：40表示40%
 */
- (int)getPrebufferPercent
{
    return [cacher getPercentOfCache];
}

- (int)getHead:(NSString*)md5 UserID:(NSString*)userID Token:(NSString*)token;
{
    [fileHeader release];
    fileHeader = nil;
    [clientAgent release];
    clientAgent = [[ClientAgent alloc]init];
    [clientAgent getFileHeader:md5 UserID:userID Token:token];

    return 0;
}

#pragma handle Notification
- (void)handleAudioDownloadFinish:(NSNotification *)note
{
    NSString    *url = [(MediaDownloader*)[note object] url];
    BOOL        isCorrectAudio = NO;
    
    for(NSString *audioUrl in _audioUrls)
    {
        if([audioUrl isEqualToString:url])
        {
            isCorrectAudio = YES;
        }
    }
    
    if(isCorrectAudio)
    {
        mFinishAudioCount++;
        
        //如果所有音频都下载完成了，则开始缓冲视频
        if(mFinishAudioCount == [_audioUrls count])
        {
            NSLog(@"AudioDownload finish, begin prebuffer video");
            [self startPrebufferVideo];
        }
    }
}

/**
 * 获取歌曲文件头失败的处理
 */
- (void)handleGetFileHeaderFailed:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    
    //发验证失败消息
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:NOTI_GET_HEAD_FAILED object:state];
}

/**
 * 获取歌曲文件头成功的处理
 */
- (void)handleGetFileHeaderSuccess:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    fileHeader = [state objectForKey:@"header"];
    [fileHeader retain];
    
    //发验证完成消息
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:NOTI_GET_HEAD_FINISH object:_videoUrl];
}

/**
 * 获取指定URL的缓存（预读）进度
 */
- (int)getPrereadPercent:(NSString*)urlString
{
    NSString    *fileFullName = [NSString stringWithFormat:@"%@/%@/%@",[UIUtils getDocumentDirName],
                              MUSIC_BUFFER_PATH,
                              [urlString lastPathComponent]];
    
    if(cacher && [urlString isEqualToString:[cacher url]])
    {
        [self savePrebuffer];
    }
    
    if(prereadCacher && [urlString isEqualToString:[prereadCacher url]])
    {
        [self savePreread];
    }

    
    //如果本地文件已经存在，说明整个文件已经缓存到了本地，此时返回100%。
    if([[NSFileManager defaultManager] fileExistsAtPath:fileFullName])
    {
        return 100;
    }
    else
    {
        //如果本地文件不存在，说明没有全部缓存到本地，需要建立一个MediaCacher对象来获取进度
        MediaCacher *tempCacher = [[MediaCacher alloc]initWithURL:urlString withLocalFile:fileFullName];
        int rtnValue = [tempCacher getPercentOfCache];
        [tempCacher release];
        return rtnValue;
    }
}

/**
 * 强制缓冲器保存进度
 */
- (void)savePrebuffer
{
    if(cacher)
    {
        [cacher saveSCT];
    }
}

/**
 * 强制预读器保存进度
 */
- (void)savePreread
{
    if(prereadCacher)
    {
        [prereadCacher saveSCT];
    }
}
@end
