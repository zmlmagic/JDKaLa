//
//  JDSqlDataUser.m
//  JDKaLa
//
//  Created by 张明磊 on 13-7-2.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import "JDSqlDataUser.h"
#import <sqlite3.h>
#import "FMDatabase.h"
#import "JDModel_userInfo.h"

#define LOCAL  @"localSong.db"
#define ZERO   0

@implementation JDSqlDataUser

+ (NSString *)reciveDataPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:ZERO];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:LOCAL];
    return path;
}

+ (void)sqlDataInstall
{
    NSString *dbPath = [self reciveDataPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL pathExist = [fileManager fileExistsAtPath:dbPath];
    if(!pathExist)
    {
        NSString *bundleDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:LOCAL];
        BOOL copySuccess = [fileManager copyItemAtPath:bundleDBPath toPath:dbPath error:&error];
        if(copySuccess)
        {
            NSLog(@"数据库拷贝成功");
        }
        else
        {
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
        }
        
    }
    else
    {
        //NSLog(@"数据库已存在");
    }
}

+ (BOOL)reciveDataUser
{
    [self sqlDataInstall];
    NSString *dbpath = [self reciveDataPath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbpath];
    [db open];
    NSString *sql = @"select * from userInfo";
    FMResultSet *result = [db executeQuery:sql];
    while ([result next])
    {
        [JDModel_userInfo sharedModel].string_userID = [result stringForColumn:@"userID"];
        [JDModel_userInfo sharedModel].string_userPass = [result stringForColumn:@"userPass"];
        [JDModel_userInfo sharedModel].string_nickName = [result stringForColumn:@"nickName"];
        [JDModel_userInfo sharedModel].string_signature = [result stringForColumn:@"signature"];
        [JDModel_userInfo sharedModel].string_token = [result stringForColumn:@"token"];
        [JDModel_userInfo sharedModel].string_tempToken = [result stringForColumn:@"tempToken"];
        [JDModel_userInfo sharedModel].string_curPayActionKey = [result stringForColumn:@"curPayActionKey"];
        [JDModel_userInfo sharedModel].string_money = [result stringForColumn:@"money"];
        [JDModel_userInfo sharedModel].integer_sex = [result intForColumn:@"sex"];
    }
    [db close];
    if([[JDModel_userInfo sharedModel].string_userID length] == 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

+ (BOOL)saveUserInfo:(JDModel_userInfo *)userInfo
{
    NSString *dbPath = [self reciveDataPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL pathExist = [fileManager fileExistsAtPath:dbPath];
    if(!pathExist)
    {
        NSString *bundleDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:LOCAL];
        [fileManager copyItemAtPath:bundleDBPath toPath:dbPath error:&error];
    }
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    BOOL success_insert = [db executeUpdate:@"INSERT INTO userInfo (userID,userPass,nickName,signature,sex,curPayActionKey,token,tempToken,money,loginTime) VALUES (?,?,?,?,?,?,?,?,?,?)",userInfo.string_userID,userInfo.string_userPass,userInfo.string_nickName,userInfo.string_signature,[NSNumber numberWithInteger:userInfo.integer_sex],userInfo.string_curPayActionKey,userInfo.string_token,userInfo.string_tempToken,userInfo.string_money,userInfo.string_loginTime];
    [db close];
    return success_insert;
}

+ (BOOL)deleteUserInfo:(JDModel_userInfo *)userInfo;
{
    NSString *dbPath = [self reciveDataPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL pathExist = [fileManager fileExistsAtPath:dbPath];
    if(!pathExist)
    {
        NSString *bundleDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:LOCAL];
        [fileManager copyItemAtPath:bundleDBPath toPath:dbPath error:&error];
    }
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    BOOL success_delete = [db executeUpdate:@"DELETE FROM userInfo WHERE userID = ?",userInfo.string_userID];
    if(success_delete)
    {
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"JDSongStateChange_record" object:nil];
    }
    [db close];
    return success_delete;
}


@end
