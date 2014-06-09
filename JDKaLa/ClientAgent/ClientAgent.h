//
//  ClientAgent.h
//  TestAgent
//
//  Created by 韩 抗 on 13-5-31.
//  Copyright (c) 2013年 ipvd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

#define NOTI_LOGIN_RESULT           @"ClientAgent Login Result"
#define NOTI_LOGOUT_RESULT          @"ClientAgent Logout Result"
#define NOTI_REGISTER_RESULT        @"ClientAgent Register Result"
#define NOTI_UPLOAD_PORTRAIT_RESULT @"ClientAgent Upload Portrait Result"
#define NOTI_VALIDATE_USERNAME_RESULT   @"ClientAgent Validate UserName Result"
#define NOTI_VALIDATE_NICKNAME_RESULT   @"ClientAgent Validate NickName Result"
#define NOTI_MODIFY_INFO_RESULT     @"ClientAgent Modify Info Result"
#define NOTI_GET_TEMP_TOKEN_RESULT  @"ClientAgent Get Temp Token Result"
#define NOTI_BUY_KB_RESULT          @"ClientAgent Buy KB Result"
#define NOTI_BUY_MONTH_RESULT       @"ClientAgent Buy Month Service Result"
#define NOTI_BUY_SONG_RESULT        @"ClientAgent Buy Song Result"
#define NOTI_GET_PERMISSION_RESULT  @"ClientAgent Get Permission Result"
#define NOTI_GET_RECHARGE_LIST_RESULT @"ClientAgent Get Recharge List Result"
#define NOTI_GET_EXCHANGE_LIST_RESULT @"ClientAgent Get Exchange List Result"
#define NOTI_GET_USER_DETAIL_RESULT @"ClientAgent Get User Detail Result"
#define NOTI_GET_FILE_HEADER_SUCCESS @"ClientAgent Get File Header Success"
#define NOTI_GET_FILE_HEADER_FAILED @"ClientAgent Get File Header Failed"
#define NOTI_REPORT_INVALID_PLAY_RESULT @"ClientAgent Report Invalid Play Result"
#define NOTI_GET_CLIENT_DB_RESULT   @"ClientAgent Get Client DB Result"
#define NOTI_VERIFY_RECEIPT_RESULT  @"ClientAgent Verify Receipt Result"
#define NOTI_CHECK_RECHARGE_RESULT  @"ClientAgent Check Recharge Result"
#define NOTI_APPLY_INVITE_CODE_RESULT   @"ClientAgent Apply Invite Code Result"
#define NOTI_BUY_TIME_RESULT        @"ClientAgent Buy Time Result"
#define NOTI_SEND_OPINION_RESULT    @"ClientAgent Opinion Result"
#define NOTI_GET_SONG_LIST_RESULT    @"ClientAgent Get Song List Result"
#define NOTI_GET_TIME_CARD_LIST_RESULT  @"ClientAgent Get Time Card List Result"
#define NOTI_START_TIME_CARD_RESULT @"ClientAgent Start Time Card Result"
#define NOTI_GET_USER_STATUS_RESULT @"ClientAgent Get User Status Result"


@interface ClientAgent : NSObject<ASIHTTPRequestDelegate>
{
    enum CLIENT_STATE
    {
        STATE_NONE,
        STATE_REGISTER,
        STATE_LOGIN,
        STATE_LOGOUT,
        STATE_UPLOAD_PORTRAIT,
        STATE_VALIDATE_USERNAME,
        STATE_VALIDATE_NICKNAME,
        STATE_MODIFY_USERINFO,
        STATE_GET_TEMP_TOKEN,
        STATE_BUY_KB,
        STATE_BUY_MONTH,
        STATE_BUY_SONG,
        STATE_GET_PERMISSION,
        STATE_GET_RECHARGE_LIST,
        STATE_GET_EXCHANGE_LIST,
        STATE_GET_USER_DETAIL,
        STATE_GET_FILE_HEADER,
        STATE_REPORT_INVALID_PLAY,
        STATE_GET_CLIENT_DB,
        STATE_VERIFY_RECEIPT,
        STATE_CHECK_RECHARGE,
        STATE_APPLY_INVITE_CODE,
        STATE_BUY_TIME,
        STATE_SEND_OPINION,
        STATE_GET_SONG_LIST,
        STATE_GET_TIME_CARD_LIST,
        STATE_START_TIME_CARD,
        STATE_GET_USER_STATUS
    };
    
    enum CONTENT_TYPE
    {
        CONTENT_TYPE_JSON,
        CONTENT_TYPE_BINARY
    };
    
    enum TIME_SERVICE
    {
        TIME_1_HOUR,
        TIME_4_HOUR,
        TIME_1_DAY,
        TIME_1_MONTH
    };
    
    NSMutableData       *responseBody;
    BOOL                mBusy;
    enum CLIENT_STATE   mState;
    enum CONTENT_TYPE   mContentType;
}

- (void)login:(NSString*) userName Password:(NSString*)password Version:(NSString*)version DevID:(NSString*)devID;
- (void)logout:(NSString*)userID Token:(NSString*)token;
- (void)register:(NSString*)userName Password:(NSString*)password Version:(NSString*)version DevID:(NSString*)devID;
- (void)registerWithInviteCode:(NSString*)inviteCode UserName:(NSString*)userName Password:(NSString*)password Version:(NSString*)version DevID:(NSString*)devID;
- (void)uploadPortrait:(NSString*)fileName UserID:(NSString*)userID Token:(NSString*)token;
- (void)validateUserName:(NSString*)userName;
- (void)validateNickName:(NSString*)nickName;
- (void)modifyUserInfo:(NSString*)nickName Sex:(int)sex Signature:(NSString*)signature UserID:(NSString*)userID Token:(NSString*)token;
- (void)getTempTokenWithKey:(NSString*)key UserID:(NSString*)userID Token:(NSString*)token;
- (void)buyKB:(int)pid UserID:(NSString*)userID Token:(NSString*)token;
- (void)buyMonthService:(int)billSourceID UserID:(NSString*)userID Token:(NSString*)token;
- (void)buySong:(NSString*)md5 Price:(int)price UserID:(NSString*)userID Token:(NSString*)token;
- (void)buyTime:(enum TIME_SERVICE)time UserID:(NSString*)userID Token:(NSString*)token;
- (void)getPermission:(NSString*)md5 UserID:(NSString*)userID Token:(NSString*)token;
- (void)getRechargeList:(int)page UserID:(NSString*)userID Token:(NSString*)token;
- (void)getExchangeList:(int)page UserID:(NSString*)userID Token:(NSString*)token;
- (void)getUserDetail:(NSString*)userID Token:(NSString*)token;
- (void)getFileHeader:(NSString*)md5 UserID:(NSString*)userID Token:(NSString*)token;
- (void)reportInvalidPlay:(NSString*)md5 UserID:(NSString*)userID Token:(NSString*)token;
- (void)getClientDB:(NSString*)currentDBName;
- (void)verifyReceipt:(NSString*)receipt UserID:(NSString*)userID Token:(NSString*)token;
- (void)checkRechargeResult:(NSString*)userID Token:(NSString*)token;
- (void)applyInviteCode:(NSString*)email Name:(NSString*)name Mobile:(NSString*)mobile Content:(NSString*)content;
- (void)sendOpinion:(NSString*)content UserID:(NSString*)userID Token:(NSString*)token;
- (void)getBoughtSongList:(NSString*)userID Token:(NSString*)token;
- (NSString *)getFileMD5:(NSString*) path;
- (void)getTimeCardList:(NSString*)userID Token:(NSString*)token;
- (void)startTimeCard:(NSString*)cardID UserID:(NSString*)userID Token:(NSString*)token;
- (void)getUserStatus:(NSString*)userID Token:(NSString*)token;

@end
