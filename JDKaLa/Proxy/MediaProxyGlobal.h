//
//  MediaProxyGlobal.h
//  TestProxy
//
//  Created by 韩 抗 on 13-4-27.
//  Copyright (c) 2013年 ipvd. All rights reserved.
//

#ifndef TestProxy_MediaProxyGlobal_h
#define TestProxy_MediaProxyGlobal_h

#define NOTI_REQUEST_RECEIVE            @"MediaProxy Request Receive"
#define NOTI_CACHE_PROGRESS_CHANGE      @"MediaProxy Cache Progress Change"
#define NOTI_CACHE_FAILED               @"MediaProxy Cache Failed"
#define NOTI_PREBUFFER_FINISH           @"MediaProxy Prebuffer Finish"
#define NOTI_MEDIA_DOWNLOAD_FINISH      @"MediaProxy Media Download Finish"
#define NOTI_MEDIA_DOWNLOAD_FAILED      @"MediaProxy Media Download Failed"
#define NOTI_DOWNLOAD_PROGRESS_CHANGE   @"MediaProxy Download"
#define NOTI_GET_HEAD_FINISH            @"MediaProxy Get Head Finish"
#define NOTI_GET_HEAD_FAILED            @"MediaProxy Get Head Failed"

#define MUSIC_BUFFER_PATH               @"preread_buffer"
#define ADVERTISE_PATH                  @"advertise"
#define ADVERTISE_URL                   @"http://ep.iktv.tv/advertise_video/3.mp4"

//文件头部的4K空间填0，避免缓存文件直接可以播放
#define EMPTY_HEAD_SIZE     4096

/**
 获取头4k true or false
 **/
#define DONT_WIPE_MEDIA_HEAD    (false)   

#endif
