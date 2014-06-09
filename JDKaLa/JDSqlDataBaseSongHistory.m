//
//  JDSqlDataBaseSongHistory.m
//  JDKaLa
//
//  Created by 张明磊 on 13-6-30.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import "JDSqlDataBaseSongHistory.h"
#import <sqlite3.h>
#import "FMDatabase.h"


#define LOCAL  @"localSong.db"
#define ZERO   0

@implementation JDSqlDataBaseSongHistory

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

+ (NSMutableArray *)reciveDataBaseFromLocal
{
    [self sqlDataInstall];
    NSMutableArray *songArray = [NSMutableArray arrayWithCapacity:20];
    NSString *dbpath = [self reciveDataPath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbpath];
    [db open];
    NSString *sql = @"select * from historySong";
    FMResultSet *result = [db executeQuery:sql];
    while ([result next])
    {
        SDSongs *song = [[SDSongs alloc] init];
        //song.songId = [result intForColumn:@"id"];
        //song.songNo = [result stringForColumn:@"no"];
        song.songTitle = [result stringForColumn:@"title"];
        song.songSingers = [result stringForColumn:@"singers"];
        song.songMedia_type = [result stringForColumn:@"media_type"];
        song.songMd5 = [result stringForColumn:@"md5"];
        song.songPlayTime = [result stringForColumn:@"time"];
        song.string_videoUrl = [result stringForColumn:@"video_url"];
        song.string_audio0Url = [result stringForColumn:@"audio0_url"];
        song.string_audio1Url = [result stringForColumn:@"audio1_url"];
        [songArray addObject:song];
        [song release],  song = nil;
    }
    [db close];
    return songArray;
}

+ (BOOL)saveSong:(SDSongs *)song
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
    [db executeUpdate:@"DELETE FROM historySong WHERE md5 = ?",song.songMd5];
    
    BOOL success_insert = [db executeUpdate:@"INSERT INTO historySong (no,title,singers,media_type,md5,time,video_url,audio0_url,audio1_url) VALUES (?,?,?,?,?,?,?,?,?)",song.songNo,song.songTitle,song.songSingers,song.songMedia_type,song.songMd5,song.songPlayTime,song.string_videoUrl,song.string_audio0Url,song.string_audio1Url];
    [db close];
    return success_insert;
}

+ (BOOL)deleteSong:(SDSongs *)song
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
    [song retain];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    BOOL success_delete = [db executeUpdate:@"DELETE FROM historySong WHERE md5 = ?",song.songMd5];
    if(success_delete)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JDSongStateChange_order" object:nil];
    }
    [db close];
    return success_delete;
}

+ (BOOL)deleteSongOnTop
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
    BOOL success_delete = [db executeUpdate:@"delete from historySong where md5 = (select md5 from historySong limit 1)"];
    if(success_delete)
    {
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"JDSongStateChange_record" object:nil];
    }
    [db close];
    return success_delete;
}

+ (NSInteger)countOfHistoryTable
{
    [self sqlDataInstall];
    NSString *dbpath = [self reciveDataPath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbpath];
    [db open];
    FMResultSet *s = [db executeQuery:@"SELECT COUNT(*) FROM historySong"];
    if ([s next])
    {
        int totalCount = [s intForColumnIndex:0];
        [db close];
        return totalCount;
    }
    else
    {
        [db close];
        return 0;
    }
}

@end
