//
//  JDDataBaseRecordSound.m
//  JDKaLa
//
//  Created by zhangminglei on 6/17/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDDataBaseRecordSound.h"
#import <sqlite3.h>
#import "FMDatabase.h"

#define LOCAL  @"localSong.db"
#define ZERO   0

@implementation JDDataBaseRecordSound

+ (NSString *)reciveDataPath
{
    NSString *string_path = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    NSString *path_t = [NSString stringWithFormat:@"%@.db",string_path];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:ZERO];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:path_t];
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
        //NSString *string_path = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
        //NSString *path_t = [NSString stringWithFormat:@"%@.db",string_path];
        
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
    NSMutableArray *recordArray = [NSMutableArray arrayWithCapacity:20];
    NSString *dbpath = [self reciveDataPath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbpath];
    [db open];
    NSString *sql = @"select * from recordSound";
    FMResultSet *result = [db executeQuery:sql];
    while ([result next])
    {
        SDRecordSound *record = [[SDRecordSound alloc] init];
        record.string_recordName = [result stringForColumn:@"name"];
        record.string_defaultRecordName = [result stringForColumn:@"defaultName"];
        record.string_recordMD5 = [result stringForColumn:@"md5"];
        record.string_recordStartTime = [result stringForColumn:@"startTime"];
        record.string_recordEndTime = [result stringForColumn:@"endTime"];
        record.string_dateTime = [result stringForColumn:@"dateTime"];
        record.integer_recordSign = [result intForColumn:@"sign"];
        record.integer_mixTag = [result intForColumn:@"mixTag"];
        record.string_videoUrl = [result stringForColumn:@"video_url"];
        record.string_audio0Url = [result stringForColumn:@"audio0_url"];
        record.string_audio1Url = [result stringForColumn:@"audio1_url"];
        [recordArray addObject:record];
        [record release],  record = nil;
    }
    [db close];
    return recordArray;
}

+ (BOOL)saveRecord:(SDRecordSound *)record
{
    NSString *dbPath = [self reciveDataPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL pathExist = [fileManager fileExistsAtPath:dbPath];
    if(!pathExist)
    {
        //NSString *string_path = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
        //NSString *path_t = [NSString stringWithFormat:@"%@.db",string_path];
        
        NSString *bundleDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:LOCAL];
        [fileManager copyItemAtPath:bundleDBPath toPath:dbPath error:&error];
    }
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    BOOL success_insert = [db executeUpdate:@"INSERT INTO recordSound (name,defaultName,md5,startTime,endTime,dateTime,sign,mixTag,video_url,audio0_url,audio1_url) VALUES (?,?,?,?,?,?,?,?,?,?,?)",record.string_recordName,record.string_defaultRecordName,record.string_recordMD5,record.string_recordStartTime,record.string_recordEndTime,record.string_dateTime,[NSNumber numberWithInteger:record.integer_recordSign],[NSNumber numberWithInteger:record.integer_mixTag],record.string_videoUrl,record.string_audio0Url,record.string_audio1Url];
    [db close];
    return success_insert;
}

+ (BOOL)deleteRecord:(SDRecordSound *)record
{
    NSString *dbPath = [self reciveDataPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL pathExist = [fileManager fileExistsAtPath:dbPath];
    if(!pathExist)
    {
        //NSString *string_path = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
       // NSString *path_t = [NSString stringWithFormat:@"%@.db",string_path];
        
        NSString *bundleDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:LOCAL];
        [fileManager copyItemAtPath:bundleDBPath toPath:dbPath error:&error];
    }
    [record retain];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    BOOL success_delete = [db executeUpdate:@"DELETE FROM recordSound WHERE sign = ?",[NSNumber numberWithInteger:record.integer_recordSign]];
    if(success_delete)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JDSongStateChange_record" object:nil];
        NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/recordSound"];
        NSString *songPath = [record.string_recordMD5 stringByAppendingString:[NSString stringWithFormat:@"%d",record.integer_recordSign]];
        NSString *downPath = [documentsPath stringByAppendingPathComponent:songPath];
        [fileManager removeItemAtPath:downPath error:nil];
        [record release];
    }
    [db close];
    return success_delete;
}

+ (NSInteger)countOfRecordTable
{
    [self sqlDataInstall];
    NSString *dbpath = [self reciveDataPath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbpath];
    [db open];
    
    FMResultSet *s = [db executeQuery:@"SELECT COUNT(*) FROM recordSound"];
    if ([s next])
    {
        int totalCount = [s intForColumnIndex:0];
        return totalCount;
    }
    else
    {
        return 0;
    }
}


@end
