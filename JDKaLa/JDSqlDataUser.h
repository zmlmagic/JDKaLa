//
//  JDSqlDataUser.h
//  JDKaLa
//
//  Created by 张明磊 on 13-7-2.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JDModel_userInfo;

@interface JDSqlDataUser : NSObject

+ (BOOL)reciveDataUser;
+ (BOOL)saveUserInfo:(JDModel_userInfo *)userInfo;
+ (BOOL)deleteUserInfo:(JDModel_userInfo *)userInfo;

@end
