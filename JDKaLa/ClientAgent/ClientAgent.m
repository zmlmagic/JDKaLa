//
//  ClientAgent.m
//  TestAgent
//
//  Created by 韩 抗 on 13-5-31.
//  Copyright (c) 2013年 ipvd. All rights reserved.
//

#import "ClientAgent.h"
#import "ASIFormDataRequest.h"
#import <CommonCrypto/CommonDigest.h>  

@implementation ClientAgent

#define IPVD_SERVER_ADDRESS     @"http://122.49.30.115:8080/ipvd/"
//#define IPVD_SERVER_ADDRESS     @"http://192.168.1.102/ipvd/"
#define TIMEOUT_SECONDS         5

- (void)dealloc
{
    [responseBody release];
    [super dealloc];
}

/**
 * 登录
 * @param userName: 用户名
 * @param password: 密码
 * @param version: 客户端软件版本号
 * @param devID: 设备标识号
 */
- (void)login:(NSString*) userName Password:(NSString*)password Version:(NSString*)version DevID:(NSString*)devID
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/login.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_LOGIN;
    
    [request setPostValue:userName forKey:@"email"];
    [request setPostValue:password forKey:@"pwd"];
    [request setPostValue:version forKey:@"version"];
    [request setPostValue:devID forKey:@"devno"];

    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
}

/**
 * 退出登录
 * @param userID: 用户编号
 * @param token: 登录时获取的令牌
 */
- (void)logout:(NSString*)userID Token:(NSString*)token
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/logout.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_LOGOUT;
    
    [request setPostValue:userID forKey:@"loginid"];
    [request setPostValue:token forKey:@"token"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
}

/**
 * 注册用户
 * @param userName: 用户名
 * @param passowrd: 密码
 * @param version: 客户端软件版本号
 * @param devID: 设备标识号
 */
- (void)register:(NSString*)userName Password:(NSString*)password Version:(NSString*)version DevID:(NSString*)devID
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/reguser.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_REGISTER;
    
    NSLog(@"Port:%@", [url port]);
    
    [request setPostValue:userName forKey:@"email"];
    [request setPostValue:password forKey:@"pwd"];
    [request setPostValue:password forKey:@"repwd"];
    [request setPostValue:version forKey:@"version"];
    [request setPostValue:devID forKey:@"devno"];

    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
}

/**
 * 注册用户（带邀请码）
 * @param inviteCode: 邀请码
 * @param userName: 用户名
 * @param passowrd: 密码
 * @param version: 客户端软件版本号
 * @param devID: 设备标识号
 */
- (void)registerWithInviteCode:(NSString*)inviteCode UserName:(NSString*)userName Password:(NSString*)password Version:(NSString*)version DevID:(NSString*)devID
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/invitatereguser.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_REGISTER;
    
    [request setPostValue:userName forKey:@"email"];
    [request setPostValue:password forKey:@"pwd"];
    [request setPostValue:password forKey:@"repwd"];
    [request setPostValue:version forKey:@"version"];
    [request setPostValue:devID forKey:@"devno"];
    [request setPostValue:inviteCode forKey:@"invitationcode"];
    
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];

}

/**
 * 上传用户头像
 * @param fileName: 头像的图片文件
 * @param userID: 用户编号
 * @param token: 登录时获取的令牌
 */
- (void)uploadPortrait:(NSString*)fileName UserID:(NSString*)userID Token:(NSString*)token
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/upload.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_UPLOAD_PORTRAIT;
    
    [request setPostFormat:ASIMultipartFormDataPostFormat]; 
    [request setPostValue:userID forKey:@"loginid"];
    [request setPostValue:token forKey:@"token"];
    
    //要上传的图片
    [request setFile:fileName forKey:@"image"];
    
    //上传结果委托
    //[request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];


    //上传进度委托
    //request.uploadProgressDelegate=self;
    //request.showAccurateProgress=YES;
    
    //开始异步上传
    [request startAsynchronous];
}

/**
 * 验证用户名的可用性
 * @param userName: 用户名
 */
- (void)validateUserName:(NSString*)userName
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/validate.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_VALIDATE_USERNAME;
    
    [request setPostValue:userName forKey:@"email"];
    [request setPostValue:@"email" forKey:@"param"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
}

/**
 * 验证昵称的可用性
 * @param nickName: 用户昵称
 */
- (void)validateNickName:(NSString*)nickName
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/validate.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_VALIDATE_NICKNAME;
    
    [request setPostValue:nickName forKey:@"nickname"];
    [request setPostValue:@"nickname" forKey:@"param"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
}

/**
 * 修改用户信息
 * @param nickName: 昵称
 * @param sex: 性别 0:女  1:男  2:未知
 * @param signature: 用户签名
 * @param userID: 用户编号
 * @param token: 登录时获取的令牌
 */
- (void)modifyUserInfo:(NSString*)nickName Sex:(int)sex Signature:(NSString*)signature UserID:(NSString*)userID Token:(NSString*)token;
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/updatedetail.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_MODIFY_USERINFO;
    
    [request setPostValue:userID forKey:@"loginid"];
    [request setPostValue:token forKey:@"token"];
    [request setPostValue:nickName forKey:@"nickname"];
    [request setPostValue:signature forKey:@"resume"];
    switch(sex)
    {
        case 0:
        case 1:
        case 2:
            [request setPostValue:[NSString stringWithFormat:@"%d",sex] forKey:@"sex"];
            break;
        default:
            break;
    }
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
}


/**
 * 获取临时Token
 */
- (void)getTempTokenWithKey:(NSString*)key UserID:(NSString*)userID Token:(NSString*)token
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/getTempToken.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_GET_TEMP_TOKEN;
    
    [request setPostValue:key forKey:@"key"];
    [request setPostValue:userID forKey:@"loginid"];
    [request setPostValue:token forKey:@"token"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
}

/**
 * 购买K币
 * @param pid: 购买K币的档次（100，500，1000，2000）
 * @param userID: 用户编号
 * @param token: 登录时获取的令牌
 */
- (void)buyKB:(int)pid UserID:(NSString*)userID Token:(NSString*)token
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/buykb.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_BUY_KB;
    
    [request setPostValue:[NSString stringWithFormat:@"%d",pid] forKey:@"pid"];
    [request setPostValue:userID forKey:@"loginid"];
    [request setPostValue:token forKey:@"token"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
}

/**
 * 购买包月
 * @pararm billSourceID: 购买方式: 1:支付宝  2:App Store  3:财付通  4:其他 
 * @param userID: 用户编号
 * @param token: 登录时获取的令牌
 */
- (void)buyMonthService:(int)billSourceID UserID:(NSString*)userID Token:(NSString*)token
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/bmbc.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_BUY_MONTH;
    
    [request setPostValue:@"7" forKey:@"pid"];
    [request setPostValue:[NSString stringWithFormat:@"%d", billSourceID] forKey:@"billsourceid"];
    [request setPostValue:userID forKey:@"loginid"];
    [request setPostValue:token forKey:@"token"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
}

/**
 * 购买单曲
 * @param md5: 歌曲的MD5
 * @param price: 歌曲价格
 * @param userID: 用户编号
 * @param token: 登录时获取的令牌
 */
- (void)buySong:(NSString*)md5 Price:(int)price UserID:(NSString*)userID Token:(NSString*)token
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/bsbk.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_BUY_SONG;
    
    [request setPostValue:[NSString stringWithFormat:@"%d",price] forKey:@"price"];
    [request setPostValue:md5 forKey:@"md5"];
    [request setPostValue:userID forKey:@"loginid"];
    [request setPostValue:token forKey:@"token"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
}

/**
 * 播放前鉴权（仅返回用户是否有权播放）
 * @param md5: 歌曲的MD5
 * @param userID: 用户编号
 * @param token: 登录时获取的令牌
 */
- (void)getPermission:(NSString*)md5 UserID:(NSString*)userID Token:(NSString*)token
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/mp4headerstatus.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_GET_PERMISSION;
    
    [request setPostValue:md5 forKey:@"md5"];
    [request setPostValue:userID forKey:@"uid"];
    [request setPostValue:token forKey:@"token"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
}

/**
 * 播放前鉴权并获取文件头
 * @param md5: 歌曲MD5
 * @param userID: 用户编号
 * @param token: 登录时获取的令牌
 */
- (void)getFileHeader:(NSString*)md5 UserID:(NSString*)userID Token:(NSString*)token
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/mp4headerdownload.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_GET_FILE_HEADER;
    
    [request setPostValue:md5 forKey:@"md5"];
    [request setPostValue:userID forKey:@"uid"];
    [request setPostValue:token forKey:@"token"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
}

/**
 * 获取充值记录
 * @param page: 记录的页号
 * @param userID: 用户编号
 * @param token: 登录时获取的令牌
 */
- (void)getRechargeList:(int)page UserID:(NSString*)userID Token:(NSString*)token
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/billlist.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_GET_RECHARGE_LIST;
    
    [request setPostValue:[NSString stringWithFormat:@"%d",page] forKey:@"pgno"];
    [request setPostValue:userID forKey:@"loginid"];
    [request setPostValue:token forKey:@"token"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
}

/**
 * 获取兑换记录
 * @param page: 记录的页号
 * @param userID: 用户编号
 * @param token: 登录时获取的令牌
 */
- (void)getExchangeList:(int)page UserID:(NSString*)userID Token:(NSString*)token
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/recordlist.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_GET_EXCHANGE_LIST;
    
    [request setPostValue:[NSString stringWithFormat:@"%d",page] forKey:@"pgno"];
    [request setPostValue:userID forKey:@"loginid"];
    [request setPostValue:token forKey:@"token"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
}

/**
 * 获取用户详细信息
 * @param userID: 用户编号
 * @param token: 登录时获取的令牌
 */
- (void)getUserDetail:(NSString*)userID Token:(NSString*)token
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/getuserdetail.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_GET_USER_DETAIL;

    [request setPostValue:userID forKey:@"loginid"];
    [request setPostValue:token forKey:@"token"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
}

/**
 * 上报无效播放
 * @param md5: 歌曲的MD5码
 * @param userID: 用户编号
 * @param token: 登录时获取的令牌
 */
- (void)reportInvalidPlay:(NSString*)md5 UserID:(NSString*)userID Token:(NSString*)token
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/setinvalidplay.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_REPORT_INVALID_PLAY;
    
    [request setPostValue:md5 forKey:@"md5"];
    [request setPostValue:userID forKey:@"uid"];
    [request setPostValue:token forKey:@"token"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
 
}

/**
 * 更新客户端数据库
 * @param currentDBName: 当前数据库的文件名（带路径）
 */
- (void)getClientDB:(NSString*)currentDBName
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/getlatestclientdb.k"];
    NSString *md5 = [self getFileMD5:currentDBName];
    
    if(nil == md5)
    {
        return;
    }
  
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_GET_CLIENT_DB;
    
    [request setPostValue:md5 forKey:@"md5"];

    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
}

/**
 * 验证app store的收据
 * @param receipt: app store返回的收据
 * @param userID: 用户编号
 * @param token: 登录时获取的令牌
 */
- (void)verifyReceipt:(NSString*)receipt UserID:(NSString*)userID Token:(NSString*)token
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/payment.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_VERIFY_RECEIPT;
    
    [request setPostValue:receipt forKey:@"receiptdata"];
    [request setPostValue:userID forKey:@"uid"];
    [request setPostValue:token forKey:@"token"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
}

/**
 * 检查购买（充值）的结果
 * @param userID: 用户编号
 * @param token: 登录时获取的令牌
 */
- (void)checkRechargeResult:(NSString*)userID Token:(NSString*)token
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/paymentquery.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_CHECK_RECHARGE;
    
    [request setPostValue:userID forKey:@"uid"];
    [request setPostValue:token forKey:@"token"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
}

/**
 * 申请邀请码
 * @param email: 用户邮箱
 * @param name: 用户实名
 * @param mobile: 用户手机号
 */
- (void)applyInviteCode:(NSString*)email Name:(NSString*)name Mobile:(NSString*)mobile Content:(NSString*)content;
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/applyinvitcode.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_APPLY_INVITE_CODE;
    
    [request setPostValue:name forKey:@"name"];
    [request setPostValue:mobile forKey:@"mobile"];
    [request setPostValue:email forKey:@"email"];
    [request setPostValue:content forKey:@"content"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
}

/**
 * 用K币购买时长
 * @param time 时间码
    TIME_HALF_HOUR,
    TIME_1_HOUR,
    TIME_2_HOUR,
    TIME_1_MONTH
 * @param userID: 用户编号
 * @param token: 登录时获取的令牌
 */
- (void)buyTime:(enum TIME_SERVICE)time UserID:(NSString*)userID Token:(NSString*)token;
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/buytimes.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_BUY_TIME;
    
    switch(time)
    {
        case TIME_1_HOUR:
            [request setPostValue:@"exchange.1hour" forKey:@"pid"];
            break;
        case TIME_4_HOUR:
            [request setPostValue:@"exchange.4hour" forKey:@"pid"];
            break;
        case TIME_1_DAY:
            [request setPostValue:@"exchange.1day" forKey:@"pid"];
            break;
        case TIME_1_MONTH:
            [request setPostValue:@"exchange.1month" forKey:@"pid"];
            break;
    }
    
    [request setPostValue:userID forKey:@"uid"];
    [request setPostValue:token forKey:@"token"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];

}

/**
 * 发送用户反馈
 * @param content: 反馈内容
 * @param userID: 用户编号
 * @param token: 登录时获取的令牌
 */
- (void)sendOpinion:(NSString*)content UserID:(NSString*)userID Token:(NSString*)token
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/opinion.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_SEND_OPINION;
    
    [request setPostValue:content forKey:@"content"];
    [request setPostValue:userID forKey:@"uid"];
    [request setPostValue:token forKey:@"token"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
}

/**
 * 获取已购买的歌曲的列表
 * @param userID: 用户编号
 * @param token: 登录时获取的令牌
 */
- (void)getBoughtSongList:(NSString*)userID Token:(NSString*)token
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/getsonglist.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_GET_SONG_LIST;
    
    [request setPostValue:userID forKey:@"uid"];
    [request setPostValue:token forKey:@"token"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
}

/**
 * 获取已购买的时长卡的列表
 * @param userID: 用户编号
 * @param token: 登录时获取的令牌
 */
- (void)getTimeCardList:(NSString*)userID Token:(NSString*)token
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/getvalidcardlist.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_GET_TIME_CARD_LIST;
    
    [request setPostValue:userID forKey:@"uid"];
    [request setPostValue:token forKey:@"token"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
}

/**
 * 使用时长卡
 * @param userID: 用户编号
 * @param token: 登录时获取的令牌
 * @param cardID: 时长卡的ID
 */
- (void)startTimeCard:(NSString*)cardID UserID:(NSString*)userID Token:(NSString*)token;
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/startcard.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_START_TIME_CARD;
    
    [request setPostValue:cardID forKey:@"card_id"];
    [request setPostValue:userID forKey:@"uid"];
    [request setPostValue:token forKey:@"token"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];
}

/**
 * 获取用户是否处于时长卡使用状态（如果是，则获取到期时间）
 */
- (void)getUserStatus:(NSString*)userID Token:(NSString*)token
{
    NSURL *url = [NSURL URLWithString:IPVD_SERVER_ADDRESS @"user/isinduration.k"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    
    if(mBusy)
        return;
    
    mBusy = YES;
    mState = STATE_GET_USER_STATUS;
    
    [request setPostValue:userID forKey:@"uid"];
    [request setPostValue:token forKey:@"token"];
    
    [request setTimeOutSeconds:TIMEOUT_SECONDS];
    [request setDelegate:self];
    [request setDidReceiveResponseHeadersSelector:@selector(didReceivedResponseHeaders:)];
    [request startAsynchronous];

}

#pragma mark ASIHttpRequest delegate
/**
 * 接收到的Response header
 */
- (void)didReceivedResponseHeaders:(ASIHTTPRequest *)request
{
    if(responseBody != nil)
    {
        [responseBody release];
        responseBody = nil;
    }
    responseBody = [[NSMutableData alloc]init];
    
    NSDictionary *header = [request responseHeaders];
    NSString    *contentType = [header valueForKey:@"Content-Type"];
    if([contentType isEqualToString:@"text/json;charset=utf-8"])
    {
        mContentType = CONTENT_TYPE_JSON;
    }
    else
    {
        mContentType = CONTENT_TYPE_BINARY;
    }
    NSLog(@"contentType:%@", contentType);
}

/**
 * 接收到下载数据
 */
- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data
{
    [responseBody appendData:data];
}

/**
 * HTTP请求完成
 */
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *tempStr = [[NSString alloc]initWithData:responseBody encoding:NSUTF8StringEncoding];
    NSLog(@"ResponseFinish:%@",tempStr);
    [tempStr release];
    
    NSDictionary *resultDic = nil;
    if(0 == [responseBody length])
    {
        resultDic = [NSDictionary dictionaryWithObject:@"-1" forKey:@"result"];
    }
    else
    {
        if(mContentType == CONTENT_TYPE_JSON)
        {
            NSError *error;
            resultDic = [NSJSONSerialization JSONObjectWithData:responseBody
                                                        options:NSJSONReadingMutableLeaves error:&error];
        }
    }
    mBusy = NO;

    if(nil == resultDic && mState != STATE_GET_FILE_HEADER)
    {
        return;
    }
    
    //发消息
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    switch(mState)
    {
        case STATE_LOGIN:
            [nc postNotificationName:NOTI_LOGIN_RESULT object:self userInfo: resultDic];
            break;
        case STATE_LOGOUT:
            [nc postNotificationName:NOTI_LOGOUT_RESULT object:self userInfo: resultDic];
            break;
        case STATE_REGISTER:
            [nc postNotificationName:NOTI_REGISTER_RESULT object:self userInfo: resultDic];
            break;
        case STATE_UPLOAD_PORTRAIT:
            [nc postNotificationName:NOTI_UPLOAD_PORTRAIT_RESULT object:self userInfo: resultDic];
            break;
        case STATE_VALIDATE_USERNAME:
            [nc postNotificationName:NOTI_VALIDATE_USERNAME_RESULT object:self userInfo: resultDic];
            break;
        case STATE_VALIDATE_NICKNAME:
            [nc postNotificationName:NOTI_VALIDATE_NICKNAME_RESULT object:self userInfo: resultDic];
            break;
        case STATE_MODIFY_USERINFO:
            [nc postNotificationName:NOTI_MODIFY_INFO_RESULT object:self userInfo: resultDic];
            break;
        case STATE_GET_TEMP_TOKEN:
            [nc postNotificationName:NOTI_GET_TEMP_TOKEN_RESULT object:self userInfo: resultDic];
            break;
        case STATE_BUY_KB:
            [nc postNotificationName:NOTI_BUY_KB_RESULT object:self userInfo: resultDic];
            break;
        case STATE_BUY_MONTH:
            [nc postNotificationName:NOTI_BUY_MONTH_RESULT object:self userInfo: resultDic];
            break;
        case STATE_BUY_SONG:
            [nc postNotificationName:NOTI_BUY_SONG_RESULT object:self userInfo: resultDic];
            break;
        case STATE_GET_PERMISSION:
            [nc postNotificationName:NOTI_GET_PERMISSION_RESULT object:self userInfo: resultDic];
            break;
        case STATE_GET_RECHARGE_LIST:
            [nc postNotificationName:NOTI_GET_RECHARGE_LIST_RESULT object:self userInfo: resultDic];
            break;
        case STATE_GET_EXCHANGE_LIST:
            [nc postNotificationName:NOTI_GET_EXCHANGE_LIST_RESULT object:self userInfo: resultDic];
            break;
        case STATE_GET_USER_DETAIL:
            [nc postNotificationName:NOTI_GET_USER_DETAIL_RESULT object:self userInfo: resultDic];
            break;
        case STATE_GET_FILE_HEADER:
            if(mContentType == CONTENT_TYPE_JSON)
            {
                [nc postNotificationName:NOTI_GET_FILE_HEADER_FAILED object:self userInfo: resultDic];
            }
            else
            {
                resultDic = [NSDictionary dictionaryWithObject:responseBody forKey:@"header"];
                [nc postNotificationName:NOTI_GET_FILE_HEADER_SUCCESS object:self userInfo:resultDic];
            }
            break;
        case STATE_REPORT_INVALID_PLAY:
            [nc postNotificationName:NOTI_REPORT_INVALID_PLAY_RESULT object:self userInfo: resultDic];
            break;
        case STATE_GET_CLIENT_DB:
            [nc postNotificationName:NOTI_GET_CLIENT_DB_RESULT object:self userInfo: resultDic];
            break;
        case STATE_VERIFY_RECEIPT:
            [nc postNotificationName:NOTI_VERIFY_RECEIPT_RESULT object:self userInfo: resultDic];
            break;
        case STATE_CHECK_RECHARGE:
            [nc postNotificationName:NOTI_CHECK_RECHARGE_RESULT object:self userInfo: resultDic];
            break;
        case STATE_APPLY_INVITE_CODE:
            [nc postNotificationName:NOTI_APPLY_INVITE_CODE_RESULT object:self userInfo: resultDic];
            break;
        case STATE_BUY_TIME:
            [nc postNotificationName:NOTI_BUY_TIME_RESULT object:self userInfo: resultDic];
            break;
        case STATE_SEND_OPINION:
            [nc postNotificationName:NOTI_SEND_OPINION_RESULT object:self userInfo: resultDic];
            break;
        case STATE_GET_SONG_LIST:
            [nc postNotificationName:NOTI_GET_SONG_LIST_RESULT object:self userInfo: resultDic];
            break;
        case STATE_GET_TIME_CARD_LIST:
            [nc postNotificationName:NOTI_GET_TIME_CARD_LIST_RESULT object:self userInfo: resultDic];
            break;
        case STATE_START_TIME_CARD:
            [nc postNotificationName:NOTI_START_TIME_CARD_RESULT object:self userInfo: resultDic];
            break;
        case STATE_GET_USER_STATUS:
            [nc postNotificationName:NOTI_GET_USER_STATUS_RESULT object:self userInfo: resultDic];
            break;
        default:
            break;
    }

}


/**
 * HTTP访问失败
 */
- (void)requestFailed:(ASIHTTPRequest *)request
{
    mBusy = NO;
    
    //发消息
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSMutableDictionary *state = [[NSMutableDictionary alloc]init];
    [state setValue:@"2" forKey:@"result"];
    [state setValue:@"连接失败" forKey:@"msg"];
    switch(mState)
    {
        case STATE_LOGIN:
            [nc postNotificationName:NOTI_LOGIN_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_LOGOUT:
            [nc postNotificationName:NOTI_LOGOUT_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_REGISTER:
            [nc postNotificationName:NOTI_REGISTER_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_UPLOAD_PORTRAIT:
            [nc postNotificationName:NOTI_UPLOAD_PORTRAIT_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_VALIDATE_USERNAME:
            [nc postNotificationName:NOTI_VALIDATE_USERNAME_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_VALIDATE_NICKNAME:
            [nc postNotificationName:NOTI_VALIDATE_NICKNAME_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_MODIFY_USERINFO:
            [nc postNotificationName:NOTI_MODIFY_INFO_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_GET_TEMP_TOKEN:
            [nc postNotificationName:NOTI_GET_TEMP_TOKEN_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_BUY_KB:
            [nc postNotificationName:NOTI_BUY_KB_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_BUY_MONTH:
            [nc postNotificationName:NOTI_BUY_MONTH_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_BUY_SONG:
            [nc postNotificationName:NOTI_BUY_SONG_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_GET_PERMISSION:
            [nc postNotificationName:NOTI_GET_PERMISSION_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_GET_RECHARGE_LIST:
            [nc postNotificationName:NOTI_GET_RECHARGE_LIST_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_GET_EXCHANGE_LIST:
            [nc postNotificationName:NOTI_GET_EXCHANGE_LIST_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_GET_USER_DETAIL:
            [nc postNotificationName:NOTI_GET_USER_DETAIL_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_REPORT_INVALID_PLAY:
            [nc postNotificationName:NOTI_REPORT_INVALID_PLAY_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_VERIFY_RECEIPT:
            [nc postNotificationName:NOTI_VERIFY_RECEIPT_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_CHECK_RECHARGE:
            [nc postNotificationName:NOTI_CHECK_RECHARGE_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_APPLY_INVITE_CODE:
            [nc postNotificationName:NOTI_APPLY_INVITE_CODE_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_BUY_TIME:
            [nc postNotificationName:NOTI_BUY_TIME_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_SEND_OPINION:
            [nc postNotificationName:NOTI_SEND_OPINION_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_GET_SONG_LIST:
            [nc postNotificationName:NOTI_GET_SONG_LIST_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_GET_TIME_CARD_LIST:
            [nc postNotificationName:NOTI_GET_TIME_CARD_LIST_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_START_TIME_CARD:
            [nc postNotificationName:NOTI_START_TIME_CARD_RESULT object:self userInfo:[state autorelease]];
            break;
        case STATE_GET_USER_STATUS:
            [nc postNotificationName:NOTI_GET_USER_STATUS_RESULT object:self userInfo:[state autorelease]];
            break;
        default:
            break;
    }
}

- (NSString *)getFileMD5:(NSString*) path
{
    NSFileHandle* handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if(handle == nil)
        return nil;
    CC_MD5_CTX md5_ctx;
    CC_MD5_Init(&md5_ctx);
    NSData* filedata;
    do {
        filedata = [handle readDataOfLength:1024];
        CC_MD5_Update(&md5_ctx, [filedata bytes], [filedata length]);
    }
    while([filedata length]);
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(result, &md5_ctx);
    [handle closeFile];
    return [NSString stringWithFormat:
              @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                result[0], result[1], result[2], result[3],
                result[4], result[5], result[6], result[7],
                result[8], result[9], result[10], result[11],
                result[12], result[13], result[14], result[15]
            ];
}




@end
