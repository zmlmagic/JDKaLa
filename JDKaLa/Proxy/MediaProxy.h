//
//  MediaProxy.h
//  TestProxy
//
//  Created by 韩 抗 on 13-4-27.
//  Copyright (c) 2013年 ipvd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AsyncSocket.h"
#import "MediaCacher.h"
#import "MediaDownloader.h"
#import "MediaHead.h"
#import "ClientAgent.h"

@interface MediaProxy : NSObject <AsyncSocketDelegate>
{
    
    //AsyncUdpSocket *udpSocket;//不需要即时连接就能通讯
    AsyncSocket     *curSock;
    NSMutableArray *connectionSockets;  //当前请求连接的客户端
    NSMutableArray *audioDownloaders;   //音轨的下载器
    NSMutableArray *prereadAudioDownloaders;//预读音轨的下载器
    MediaCacher *cacher;                //下载缓存器
    MediaCacher *prereadCacher;         //预读下首歌曲的下载缓存器
    //MediaHead   *mediaHead;             //媒体的头部数据（防拷贝缓存用）
    ClientAgent *clientAgent;           //和后台通讯的接口类，主要用于获取媒体4K文件头
    NSString    *remoteHost;            //远程服务器的地址
    NSString    *localHost;             //本地服务器的地址
    int         remotePort;             //远程服务器端口
    int         mCurPos;
    int         mFinishAudioCount;      //已完成下载的音轨的数量
    NSMutableData   *fileHeader;        //歌曲头4K
}

@property (nonatomic, retain)AsyncSocket *listener;     //监听客户端请求
@property (readonly, nonatomic) NSString *videoUrl;     //视频URL
@property (readonly, nonatomic) NSArray  *audioUrls;    //音轨URL
@property (readonly, nonatomic) NSString *videoLocalFile;          //视频本地文件
@property (readonly, nonatomic) NSMutableArray  *audioLocalFiles;  //音轨本地文件

- (void) startProxy;
- (void) destroyProxy;
- (void) stopPreread;
- (BOOL)isPrebufferFinish;
- (void)prebufferWithUrl:(NSString*)urlString WithAudioUrls:(NSArray*) audioUrls;
- (BOOL)prereadWithURL:(NSString*)urlString WithAudioUrls:(NSArray*) audioUrls;;
- (NSString*)getLocalURLWithString:(NSString*)urlString;
- (int)getPrebufferPercent;
- (int)getPrereadPercent:(NSString*)urlString;
- (int)getHead:(NSString*)md5 UserID:(NSString*)userID Token:(NSString*)token;
- (void)restartPrebuffer;
+ (void)clearCache;
- (void)stopPrebuffer;
@end
