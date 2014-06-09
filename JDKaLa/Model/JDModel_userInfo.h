//
//  JDModel_userInfo.h
//  JDKaLa
//
//  Created by zhangminglei on 6/27/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDModel_userInfo : NSObject

@property (retain, nonatomic) NSString *string_userName;
@property (retain, nonatomic) NSString *string_userID;
@property (retain, nonatomic) NSString *string_userPass;
@property (retain, nonatomic) NSString *string_nickName;
@property (retain, nonatomic) NSString *string_signature;
@property (retain, nonatomic) NSString *string_tourist;
@property (assign, nonatomic) NSInteger integer_sex;
@property (retain, nonatomic) NSString *string_curPayActionKey;
@property (retain, nonatomic) NSString *string_token;
@property (retain, nonatomic) NSString *string_tempToken;
@property (retain, nonatomic) NSString *string_money;
@property (retain, nonatomic) NSString *string_loginTime;
@property (assign, nonatomic) BOOL     bool_hasMaster;///菜单展开


/**
 是否按home键
 **/
@property (assign, nonatomic) BOOL bool_homeBack;

/**
 设备号Device
 **/
@property (retain, nonatomic) NSString *string_device;

/**
 版本号Version
 **/
@property (retain, nonatomic) NSString *string_version;

@property (retain, nonatomic) NSString *string_portrait;

+ (JDModel_userInfo *)sharedModel;
- (void)configureDataWithUser;
- (void)configureDataWithTourist;

@end