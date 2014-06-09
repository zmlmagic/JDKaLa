//
//  MediaCacher.m
//  TestProxy
//
//  Created by 韩 抗 on 13-4-28.
//  Copyright (c) 2013年 ipvd. All rights reserved.
//

#import "MediaCacher.h"
#import "ASIHTTPRequest.h"
#import "MediaProxyGlobal.h"
#import "DownloadSection.h"

@implementation MediaCacher

#define SCT_VERSION 1
#define RETRY_TIME_LIMIT    5

- (id)initWithURL:(NSString*)url withLocalFile:(NSString*)localFile
{
    self = [super init];
    if(self != nil)
    {
        _fileSize = 0;
        _url = [[NSString alloc] initWithString:url];
        
        _tempFileName = [[NSString alloc] initWithFormat:@"%@.tmp",localFile];
        _localFileName = [[NSString alloc] initWithString:localFile];
        _finishDownload = NO;
        
        mHttpRequest = nil;
        mTempFile = nil;
        mInited = NO;
        sections = [[NSMutableArray alloc] init];
        mCurSection = [[DownloadSection alloc] init];
        mRetryTimes = 0;
        
        [self loadSCT];
    }
    
    return self;
}

- (void)dealloc
{
    [_url release];
    [_tempFileName release];
    [_localFileName release];
    [mTempFile release];
    [mCurSection release];
    [sections release];
    
    if(mHttpRequest != nil)
    {
        [mHttpRequest clearDelegatesAndCancel];
        [mHttpRequest release];
    }
    [super dealloc];
}


//获取URL指向内容的总长度
- (int)getContentLengthWithURL:(NSString*)urlString
{
    int     rtnVal = 0;
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setRequestMethod:@"HEAD"];     //只获取返回的HTTP头，不进行实际下载
    [request startSynchronous];
    
    NSLog(@"Http response code:%d",[request responseStatusCode]);
    NSError *error = [request error];
    
    if (!error && [request responseStatusCode] < 400) {
        NSString * lengthString = [[request responseHeaders] objectForKey:@"Content-Length"];
        rtnVal = [lengthString intValue];
    }
    //[request release];
    return rtnVal;
}

/**
 * 开始下载
 * @param startPos
 * @return YES: 正常启动下载， NO：已经下载完成，不需要下载
 */
- (BOOL)startDownloadWithStartPos:(int)startPos
{
    NSURL *url = [NSURL URLWithString:_url];

    //如果目标文件已经存在，则说明不需要下载，直接返回NO
    if([[NSFileManager defaultManager] fileExistsAtPath:_localFileName])
    {
        _finishDownload = YES;
        NSFileHandle *cacheFile = [NSFileHandle fileHandleForReadingAtPath:_localFileName];
        _fileSize = [cacheFile seekToEndOfFile];
        [cacheFile closeFile];
        return NO;
    }
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:_tempFileName])
    {
        NSString *pathName = [_tempFileName stringByDeletingLastPathComponent];
        [[NSFileManager defaultManager] createDirectoryAtPath:pathName withIntermediateDirectories:YES attributes:nil error:nil];
        [[NSFileManager defaultManager] createFileAtPath:_tempFileName contents:nil attributes:nil];
    }

    if(nil == mTempFile)
    {
        mTempFile = [NSFileHandle fileHandleForUpdatingAtPath:_tempFileName];
        //mTempFile = [NSFileHandle fileHandleForWritingAtPath:fullFileName];
        [mTempFile retain];
    }
    
    if(!mInited)
    {
        if(0 == _fileSize)
        {
            _fileSize = [self getContentLengthWithURL:_url];
            NSLog(@"fileSize:%d", _fileSize);
            [mTempFile truncateFileAtOffset:_fileSize];
        
        }
        mInited = YES;
    }
    else
    {
        [self stopDownload];
    }

    DownloadSection * section = [self getDownloadSectionWithStartPos:startPos];
    if(section == nil && _fileSize != 0)
    {
        //发缓冲完成消息

        //NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        //[nc postNotificationName:NOTI_PREBUFFER_FINISH object:_url];
        return NO;
    }
    else
    {
        startPos = section.startPos;
        mCurPos = startPos;
    }

    mHttpRequest = [ASIHTTPRequest requestWithURL:url];
    [mHttpRequest retain];

    [mHttpRequest setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [mHttpRequest setDelegate:self];
    [mHttpRequest setTimeOutSeconds:5];
    [mHttpRequest setShouldUseRFC2616RedirectBehaviour:YES];
    //[mHttpRequest setNumberOfTimesToRetryOnTimeout:4];
    
    NSString *rangeString = [NSString stringWithFormat:@"bytes=%d-", startPos];
    [mHttpRequest addRequestHeader:@"Range" value:rangeString];
    
    NSLog(@"Request:%@", [mHttpRequest requestHeaders]);
    [mTempFile seekToFileOffset:startPos];
    mCurPos = mOldPos = startPos;
    mCurSectionIdx = 0;
    
    if(startPos > _fileSize)
    {
        return NO;
    }
    
    _finishDownload = NO;
    [mHttpRequest startAsynchronous];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:NOTI_REQUEST_RECEIVE object:@"开始缓冲"];
    return YES;
}

//取消下载
- (void)stopDownload
{
    if(mHttpRequest != nil)
    {
        NSLog(@"stopDownload");
        [mHttpRequest setDelegate:nil];
        [mHttpRequest cancel];
        [mHttpRequest release];
        mHttpRequest = nil;
        mCurPos = mOldPos = 0;
        if([self isFullDownload])
        {
            _finishDownload = YES;
            [self renameDownloadFile];
        }
        else
        {
            [self saveSCT];
        }
    }
}

/**
 * 重试下载（一般用于Timeout时）
 */
- (BOOL)retryDownload:(int)startPos
{
    [self stopDownload];
    NSLog(@"RetryStartPos:%d", startPos);
    
    NSURL *url = [NSURL URLWithString:_url];
    DownloadSection * section = [self getDownloadSectionWithStartPos:startPos];
    if(section == nil && _fileSize != 0)
    {
        return NO;
    }
    else
    {
        //startPos = section.startPos;
        mCurPos = startPos;
    }
    
    mHttpRequest = [ASIHTTPRequest requestWithURL:url];
    [mHttpRequest retain];
    
    [mHttpRequest setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [mHttpRequest setDelegate:self];
    [mHttpRequest setTimeOutSeconds:5];
    [mHttpRequest setShouldUseRFC2616RedirectBehaviour:YES];
    //[mHttpRequest setNumberOfTimesToRetryOnTimeout:4];
    
    NSString *rangeString = [NSString stringWithFormat:@"bytes=%d-", startPos];
    [mHttpRequest addRequestHeader:@"Range" value:rangeString];
    
    NSLog(@"Request:%@", [mHttpRequest requestHeaders]);
    [mTempFile seekToFileOffset:startPos];
    mCurPos = mOldPos = startPos;
    mCurSectionIdx = 0;
    
    if(startPos > _fileSize)
    {
        return NO;
    }
    
    _finishDownload = NO;
    [mHttpRequest startAsynchronous];
    
    return YES;
}

/**
 * 切换从指定的位置开始下载
 */
- (BOOL)switchToPos:(int)startPos
{
    if(!mInited || _finishDownload)
        return NO;

    DownloadSection * section = [self getDownloadSectionWithStartPos:startPos];

    if(section == nil)
        return NO;
    
    DownloadSection * nextSection = [self getNextSection:section.startPos];
    
    //如果没有找到需要下载的区间或者当前下载点已经超越指定下载开始点，则不需要再切换下载点
    if(section.startPos > startPos && (nextSection == nil || mCurPos < nextSection.startPos))
    {
        return NO;
    }
    
    [self stopDownload];
    
    if(nil == mTempFile)
    {
        NSLog(@"Reopen file.");
        mTempFile = [NSFileHandle fileHandleForUpdatingAtPath:_tempFileName];
        [mTempFile retain];
    }
    
    NSURL *url = [NSURL URLWithString:_url];
    mHttpRequest = [ASIHTTPRequest requestWithURL:url];
    [mHttpRequest retain];
    
    [mHttpRequest setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [mHttpRequest setDelegate:self];
    [mHttpRequest setTimeOutSeconds:5];
    [mHttpRequest setShouldUseRFC2616RedirectBehaviour:YES];
    
    NSString *rangeString = [NSString stringWithFormat:@"bytes=%d-", section.startPos];
    [mHttpRequest addRequestHeader:@"Range" value:rangeString];
    
    //NSLog(@"Request:%@", [mHttpRequest requestHeaders]);
    [mTempFile seekToFileOffset:section.startPos];
    mCurPos = mOldPos = section.startPos;
    
    _finishDownload = NO;
    [mHttpRequest startAsynchronous];
    NSLog(@"Switch download pos: %d.", section.startPos);
    return YES;

}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    //mCurPos = mOldPos = 0;
    
    [mHttpRequest setDelegate:nil];
    [mHttpRequest cancel];
    [mHttpRequest release];
    mHttpRequest = nil;
    
    if(mTempFile != nil)
    {
        [mTempFile closeFile];
        [mTempFile release];
        mTempFile = nil;
    }

    
    if([self isFullDownload])
    {
        _finishDownload = YES;
        [self renameDownloadFile];
    }
    else
    {
        [self saveSCT];
    }
    
    //发缓冲完成消息
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:NOTI_PREBUFFER_FINISH object:_url];
}

//接收到的Response header
- (void)didReceivedResponseHeaders:(ASIHTTPRequest *)request
{
    NSLog(@"MediaCacher Response Header:%@",[request responseHeaders]);
    mRetryTimes = 0;
    
    if(0 == _fileSize)
    {
        //NSString * lengthString = [[request responseHeaders] objectForKey:@"Content-Length"];
   
        _fileSize = request.contentLength;
        //[lengthString intValue];
        NSLog(@"Length:%d", _fileSize);

        [mTempFile truncateFileAtOffset:_fileSize];
        [mTempFile seekToFileOffset:0];
    }
    else
    {
        NSString    *rangeString = [[request responseHeaders] objectForKey:@"Content-Range"];
        NSRange     findResult = [rangeString rangeOfString:@"bytes "];
        NSString    *tempStr = [rangeString substringFromIndex:findResult.location + findResult.length];
                                
        findResult = [tempStr rangeOfString:@"-"];
        NSString    *startStr = [tempStr substringToIndex:findResult.location];
        
        mCurPos = [startStr intValue];
        mOldPos = mCurPos;
        NSLog(@"FileSeek:%d", mCurPos);
        [mTempFile seekToFileOffset:mCurPos];
    }
}

//接收到下载数据
- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data
{
    //NSLog(@"retain:%d",[data retainCount]);
    mCurSection.startPos = mCurPos;
    mCurSection.endPos = mCurPos + [data length];
    mCurPos += [data length];
    mCurSectionIdx = [self saveSection:mCurSection];
    
    if(DONT_WIPE_MEDIA_HEAD || mCurSection.endPos > EMPTY_HEAD_SIZE)
    {
        [mTempFile writeData:data];
    }
    else
    {
        //对于文件开头的4K，以0填充
        Byte bytes[[data length]];
        memset(bytes, 0, [data length]);
        NSData *emptyData = [NSData dataWithBytes:bytes length:[data length]];
        [mTempFile writeData:emptyData];
    }
    
    //每下载512K发一次进度消息 256 128
    if(mCurPos - mOldPos > 1024 * 64)
    {
        mOldPos = mCurPos;
        float progress = (float)((float)mCurPos / _fileSize * 100);
        [self sendProgressMessage:progress];
        
        //如果合并了原先的下载段，则重新连接，定位新位置
        if([self mergeSectionWithIndex:mCurSectionIdx])
        {
            DownloadSection *section = [self getDownloadSectionWithStartPos:mCurSection.startPos];
            
            //如果合并后发现已缓冲到文件末尾, 则直接退出下载
            if(nil == section)
            {
                [self stopDownload];
                
                //发缓冲完成消息
                NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                [nc postNotificationName:NOTI_PREBUFFER_FINISH object:_url];
            }
            else								//否则，切换到新的下载点
            {
                [self switchToPos:section.startPos];
            }
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request

{
    NSError *error = [request error];
    
    NSLog(@"MediaCacher Error:%@", error);
    if([self isFullDownload])
    {
        _finishDownload = YES;
    }
    
    if(mRetryTimes++ < RETRY_TIME_LIMIT)
    {
        [self retryDownload:mCurPos];
    }
    else
    {
        if(mTempFile != nil)
        {
            [mTempFile closeFile];
            [mTempFile release];
            mTempFile = nil;
        }
        
        //发缓存失败消息
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:NOTI_CACHE_FAILED object:_url];
    }
}

/**
 * 根据指定的起始位置,返回已下载的Section的序号（从0开始），如果指定位置没有下载过，则返回-1
 * @param startPos  下载开始的位置
 * @return 已下载的Section的序号（从0开始），如果指定位置没有下载过，则返回-1
 */
- (int)findSectionWithStartPos:(int) startPos
{
    int	i;
    int	rtn  = -1;
    DownloadSection * section;
    
    for(i = 0; i < [sections count]; ++i)
    {
        section = [sections objectAtIndex:i];
        if(section.startPos <= startPos && section.endPos >= startPos)
        {
            rtn = i;
            break;
        }
    }
    return rtn;
}

/**
 * 保存Section
 * @param section
 */
- (int) saveSection:(DownloadSection*) section
{
    int		i;
    int		rtn = 0;
    BOOL	bNewSection = YES;
    
    for(i = 0; i < [sections count]; ++i)
    {
        DownloadSection *curSection = [sections objectAtIndex:i];
        if(curSection.endPos + 1 >= section.startPos && curSection.startPos <= section.startPos)
        {
            curSection.endPos = MAX(curSection.endPos, section.endPos);
            //Log.d("MediaCacher", "saveSection:"+ sections.size() + ":" + sections.get(i).startPos + ":" + section.endPos);
            bNewSection = NO;
            rtn = i;
            break;
        }
    }
    
    if(bNewSection)
    {
        DownloadSection * newSection = [[DownloadSection alloc]initWithStartPos:section.startPos WithEndPos:section.endPos];
        [sections addObject:newSection];
        [newSection release];
        rtn = [sections count] - 1;
    }
    return rtn;
}

/**
 * 合并和序号为index的Section相重叠的Section，并将更新的结果保存在序号为index的Section中
 * @param index ： 要合并的section的序号
 * @return 是否进行了合并
 */
- (BOOL)mergeSectionWithIndex:(int)index
{
    DownloadSection *section = [sections objectAtIndex:index];
    int		i;
    int		startPos = section.startPos;
    int		endPos = section.endPos;
    BOOL    merged = NO;
    BOOL    needRepeat;
    
    do
    {
        needRepeat = NO;
        for(i = 0; i < [sections count]; ++i)
        {
            if(i != index)
            {
                DownloadSection *tempSection = [sections objectAtIndex:i];
                if((tempSection.startPos < endPos && tempSection.endPos > endPos) ||
                   (tempSection.startPos < startPos && tempSection.endPos > startPos))
                {
                    section.startPos = MIN(tempSection.startPos, startPos);
                    section.endPos = MAX(tempSection.endPos, endPos);
                    startPos = section.startPos;
                    endPos = section.endPos;
                    [sections removeObjectAtIndex:i];
                    if(i < index)
                        index--;
                    merged = YES;
                    needRepeat = YES;
                    break;
                }
            }
        }
    }while(needRepeat);
    
    return merged;
}

/**
 * 根据指定的起始地址,获取实际需要下载的起始地址
 * @param startPos: 以字节为单位的下载起始点
 * @return
 */
- (DownloadSection*)getDownloadSectionWithStartPos:(int)startPos
{
    DownloadSection*	section = [[DownloadSection alloc] init];
    int                 idx = [self findSectionWithStartPos:startPos];
    
    //如果 idx != -1， 则在以前下载过的section基础上继续下载
    //如果 idx == -1，则新开一块下载
    section.startPos = (idx != -1) ? ((DownloadSection*)[sections objectAtIndex:idx]).endPos + 1 : startPos;
    section.endPos = (int) (_fileSize - 1);
    
    //如果起始点大于等于终止点，则说明已经不需要下载，返回nil
    if(section.startPos >= section.endPos)
    {
        [section release];
        return nil;
    }
    else
    {
        return [section autorelease];
    }
}

/**
 * 找到指定位置的下一个section的开始位置
 * 如果指定位置的后面没有已完成的section，则返回nil
 */
- (DownloadSection*)getNextSection:(int)startPos
{
    DownloadSection *curSelSection = nil;
    
    for(DownloadSection *section in sections)
    {
        if(section.startPos > startPos)
        {
            if(nil == curSelSection)
            {
                curSelSection = section;
            }
            else
            {
                //找到最接近与startPos的section
                if(section.startPos < curSelSection.startPos)
                {
                    curSelSection =section;
                }
            }
        }
    }
    return curSelSection;
}

/**
 * 指定区块是否已经下载完成？
 * @param section 指定的区块
 * @return 已完成：true，未完成：false
 */
- (BOOL)isSectionValid:(DownloadSection*)section
{
    if([self finishDownload])
    {
        return YES;
    }
    
    BOOL rtn = NO;
    
    for(int i = 0; i < [sections count]; ++i)
    {
        DownloadSection * tempSection = [sections objectAtIndex:i];
        if(tempSection.startPos <= section.startPos && tempSection.endPos >= section.endPos)
        {
            rtn = YES;
            break;
        }
    }
    return rtn;
}

/**
 * 获取文件已下载的第一段的尺寸（通常为已预读的尺寸）
 * @return 预读尺寸
 */
- (int)getFirstSectionSize
{
    return [sections count] > 0 ? ((DownloadSection*)[sections objectAtIndex:0]).endPos : 0;
}

/**
 * 返回第一个section占全文件的百分比
 * @return 百分比，例如：40表示40%
 */
- (int)getPercentOfCache
{
    if([sections count] > 0 && _fileSize > 0)
    {
        int pos = ((DownloadSection*)[sections objectAtIndex:0]).endPos;
        return ((int)((float)pos / _fileSize * 100));
    }
    else
    {
        return 0;
    }
}

/**
 * 导入预读结果
 * @param startPos 已预读的字节数
 * @param fileSize 文件的总长度
 */
- (void)importPrereadWithStartPos:(int)startPos FileSize:(int)fileSize
{
    DownloadSection *section = [[DownloadSection alloc]initWithStartPos:0 WithEndPos:startPos];
    [sections removeAllObjects];
    [sections addObject:section];
    [section release];
    _fileSize = fileSize;
    if(startPos == fileSize)
    {
        _finishDownload = YES;
    }
}

/**
 * 是否已经完全下载到本地？
 * @return YES 媒体文件已经完全下载到本地;  NO 媒体文件尚未完全下载到本地
 */
- (BOOL)isFullDownload
{
    if(_finishDownload)
        return YES;
    
    BOOL bFullDownload = NO;
 
    if([sections count] > 0)
    {
        //先合并所有Section
        [self mergeSectionWithIndex:0];
        DownloadSection * section = [sections objectAtIndex:0];
        if(section.startPos == 0 && section.endPos == _fileSize)
        {
            bFullDownload = YES;
        }
    }
    return bFullDownload;
}


/**
 * 发进度消息
 * @param percent
 */
- (void)sendProgressMessage:(float)percent
{
    //NSLog(@"percent is %f",percent);
    NSMutableDictionary *state = [[NSMutableDictionary alloc] init];
    [state setValue:_url forKey:@"url"];
    [state setValue:[NSNumber numberWithFloat:percent] forKey:@"progress"];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:NOTI_CACHE_PROGRESS_CHANGE object:self userInfo: state];
    [state release];
}

/**
 * 指定文件是否存在对应的SCT文件？
 * @param fileName 指定的文件名（包含路径）
 * @return
 */
- (BOOL)hasSCTFile:(NSString*)fileName
{
    BOOL   rtn = NO;
    if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@.sct", fileName]])
    {
        rtn = YES;
    }
    return rtn;
}

/**
 * 下载完成后改文件名
 */
- (void)renameDownloadFile
{
    NSString        *sctFileName = [NSString stringWithFormat:@"%@.sct",_localFileName];
    NSFileManager   *fm = [NSFileManager defaultManager];
    
    if([self isFullDownload])
    {
        //将下载的临时文件名改为正式文件名
        [fm moveItemAtPath:_tempFileName toPath:_localFileName error:nil];
        
        //如果存在SCT文件，则删除
        if([fm fileExistsAtPath:sctFileName])
        {
            [fm removeItemAtPath:sctFileName error:nil];
        }
        return;
    }
}

/**
 * 保存SCT文件
 */
- (void)saveSCT
{
    NSString        *sctFileName = [NSString stringWithFormat:@"%@.sct",_localFileName];
    int             i;
    int             version = SCT_VERSION;
    int             sectionCount = [sections count];
    NSMutableData   *sctData = [[NSMutableData alloc]init];
    
    [sctData appendBytes:&version length:sizeof(version)];              //写版本号
    [sctData appendBytes:&_fileSize length:sizeof(_fileSize)];          //写文件长度
    [sctData appendBytes:&sectionCount length:sizeof(sectionCount)];    //写入Section数量
    for(i = 0; i < sectionCount; ++i)                                   //逐个写入Section记录
    {
        DownloadSection *section = [sections objectAtIndex:i];
        int startPos = section.startPos;
        int endPos = section.endPos;
        [sctData appendBytes:&startPos length:sizeof(startPos)];
        [sctData appendBytes:&endPos length:sizeof(endPos)];
    }
    [sctData writeToFile:sctFileName atomically:NO];                    //写入文件
    [sctData release];
}

/**
 * 读取SCT文件
 * @return 如果SCT文件存在并可被读取，返回YES，否则，返回NO
 */
- (BOOL)loadSCT
{
    BOOL			rtn =  NO;
    NSString        *sctFileName = [NSString stringWithFormat:@"%@.sct",_localFileName];
    NSFileManager   *fm = [NSFileManager defaultManager];
    
    //如果SCT文件不存在，返回失败
    if(![fm fileExistsAtPath:sctFileName])
    {
        return rtn;
    }
    
    int     curPos = 0;
    int     version;
    int     sectionCount = 0;
    NSData *sctData = [NSData dataWithContentsOfFile:sctFileName];
    [sctData getBytes:&version range:NSMakeRange(curPos, sizeof(version))];                 //读取版本号
    curPos += sizeof(version);
    
    if(SCT_VERSION == version)                                                              //如果是匹配的版本
    {
        [sctData getBytes:&_fileSize range:NSMakeRange(curPos, sizeof(_fileSize))];         //读取文件长度
        curPos += sizeof(_fileSize);
        [sctData getBytes:&sectionCount range:NSMakeRange(curPos, sizeof(sectionCount))];   //读取Section数量
        curPos += sizeof(sectionCount);
        
        [sections removeAllObjects];
        for(int i = 0; i < sectionCount; ++i)                                               //读取各Section
        {
            int startPos = 0;
            int endPos = 0;
            [sctData getBytes:&startPos range:NSMakeRange(curPos, sizeof(startPos))];
            curPos += sizeof(startPos);
            [sctData getBytes:&endPos range:NSMakeRange(curPos, sizeof(endPos))];
            curPos += sizeof(endPos);
            DownloadSection *section = [[DownloadSection alloc]initWithStartPos:startPos WithEndPos:endPos];
            [sections addObject:section];
            [section release];
        }
        rtn = YES;
    }
    return rtn;
}


@end
