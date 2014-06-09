//
//  JDSqlDataBase.m
//  JDKaLa
//
//  Created by zhangminglei on 4/8/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDSqlDataBase.h"
#import <sqlite3.h>
#import "FMDatabase.h"
#import "SDSingers.h"
#import "ClientAgent.h"
#import "ASIHTTPRequest.h"

@implementation JDSqlDataBase

#define MUSIC  @"kod.db"
#define LOCAL  @"localSong.db"
#define ZERO   0

- (id)init
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}


- (void)dealloc
{
    //[_db release];
    [super dealloc];
}


#pragma mark -
#pragma mark MYFUNCTION
#pragma mark -
#pragma mark SqlDatabase

- (NSString *)reciveDataPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:ZERO];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:MUSIC];
    return path;
}

- (NSString *)reciveDataPathWithString:(NSString *)string_db
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:ZERO];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:string_db];
    return path;
}


- (void)sqlDataInstall
{
    NSString *dbPath = [self reciveDataPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL pathExist = [fileManager fileExistsAtPath:dbPath];
    if(!pathExist)
    {
        NSString *bundleDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:MUSIC];
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
        NSLog(@"数据库已存在");
    }
}

- (void)sqlDataInstallInSingerLocal
{
    NSString *string_path = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    NSString *path = [NSString stringWithFormat:@"%@.db",string_path];
    
    NSString *dbPath = [self reciveDataPathWithString:path];
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

#pragma mark - 清空数据库 -
/**
 清空数据库
 **/
- (void)reloadLocalDataBase
{
    NSString *string_path = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    NSString *path = [NSString stringWithFormat:@"%@.db",string_path];
    
    NSString *dbPath = [self reciveDataPathWithString:path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:dbPath error:nil];
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
    [self reloadLocalDataBase];
}

#pragma mark -
#pragma mark KindOfSong
- (NSMutableArray *)reciveDataBaseWithString:(NSString *)string
{
    [self sqlDataInstall];
    NSMutableArray *songArray = [NSMutableArray arrayWithCapacity:20];
    NSString *dbpath = [self reciveDataPath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbpath];
    [db open];
    FMResultSet *result = [db executeQuery:string];
    while ([result next])
    {
        SDSongs *song = [[SDSongs alloc] init];
        song.songId = [result intForColumn:@"id"];
        //song.songNo = [result stringForColumn:@"no"];
        song.songTitle = [result stringForColumn:@"title"];
        //song.songTags = [result stringForColumn:@"tags"];
        //song.songLang = [result stringForColumn:@"lang"];
        //song.songWord_count = [result intForColumn:@"word_count"];
        //song.songIs_karaoke = [result intForColumn:@"is_karaoke"];
        //song.songVocal = [result stringForColumn:@"vocal"];
        song.songSingers = [result stringForColumn:@"singers"];
        //song.songHits = [result intForColumn:@"hits"];
        //song.songIs_new = [result intForColumn:@"is_new"];
        //song.songOriginal_id = [result intForColumn:@"original_id"];
        //song.songPicture_type = [result stringForColumn:@"picture_type"];
        song.songMedia_type = [result stringForColumn:@"media_type"];
        song.songSingers_no = [result stringForColumn:@"singers_no"];
        //song.songCategorise_id = [result stringForColumn:@"categorise_id"];
        song.songMd5 = [result stringForColumn:@"md5"];
        song.string_videoUrl = [result stringForColumn:@"video_url"];
        song.string_audio0Url = [result stringForColumn:@"audio0_url"];
        song.string_audio1Url = [result stringForColumn:@"audio1_url"];
        song.int_price = [result intForColumn:@"price"];
        song.songBuyTag = 0;
        song.songFavoriteTag = 0;
        song.songOrderTag = 0;
        /*if(![song.songMedia_type isEqualToString:@".mkv"] && ![song.songMd5 isEqualToString:@""])
        {
            [songArray addObject:song];
        }*/
        if(![song.songMedia_type isEqualToString:@".mkv"])
        {
            [songArray addObject:song];
        }
        [song release],  song = nil;
    }
    [db close];
    return songArray;
}

- (void)arrangeDataBase
{
    [self sqlDataInstall];
    NSString *dbpath = [self reciveDataPath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbpath];
    [db open];
    FMResultSet *result = [db executeQuery:@"select * from client_singers"];
    while ([result next])
    {
        SDSingers *singer = [[SDSingers alloc] init];
        singer.singerId = [result intForColumn:@"id"];
        singer.singerNo = [result stringForColumn:@"no"];
        singer.singerName = [result stringForColumn:@"name"];
       // singer.singerPhoto_type = [result stringForColumn:@"photo_type"];
        
        NSString *escapeTag = [singer.singerName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
         NSString *sql = [NSString stringWithFormat:@"select *from client_songs where singers = '%@'", escapeTag];
         NSMutableArray *songArray = [self reciveDataBaseWithString:sql];
         if([songArray count] == 0)
         {
             BOOL bool_success = [db executeUpdate:@"DELETE FROM client_singers WHERE name = ?",singer.singerName];
             if(bool_success)
             {
                 NSLog(@"已删除");
             }
         }
        [singer release];
    }
    [db close];
}

- (NSMutableArray *)reciveDataBaseWithStringFromSinger:(NSString *)string
{
    [self sqlDataInstall];
    NSMutableArray *songArray = [NSMutableArray arrayWithCapacity:20];
    NSString *dbpath = [self reciveDataPath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbpath];
    [db open];
    FMResultSet *result = [db executeQuery:string];
    while ([result next])
    {
        SDSingers *singer = [[SDSingers alloc] init];
        singer.singerId = [result intForColumn:@"id"];
        singer.singerNo = [result stringForColumn:@"no"];
        singer.string_portrait = [result stringForColumn:@"photo"];
        //singer.singerTags = [result stringForColumn:@"tags"];
        singer.singerName = [result stringForColumn:@"name"];
        //singer.singerSex = [result intForColumn:@"sex"];
        //singer.singerArea = [result intForColumn:@"area"];
        //singer.singerOriginal_id = [result intForColumn:@"original_id"];
        //singer.singerIs_new = [result intForColumn:@"is_hot"];
        //singer.singerPhoto_type = [result stringForColumn:@"photo_type"];
        
        /*NSString *escapeTag = [singer.singerName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *sql = [NSString stringWithFormat:@"select *from songs where singers = '%@'", escapeTag];
        NSMutableArray *songArray = [self reciveDataBaseWithString:sql];
        if([songArray count] == 0)
        {
            BOOL bool_success = [db executeUpdate:@"DELETE FROM singers WHERE name = ?",singer.singerName];
            if(bool_success)
            {
                NSLog(@"已删除");
            }
        }*/
        
        [songArray addObject:singer];
        [singer release],  singer = nil;
    }
    [db close];
    
    return songArray;
}

- (void)openDataBase
{
    [self sqlDataInstall];
    NSString *dbpath = [self reciveDataPath];
    _db = [FMDatabase databaseWithPath:dbpath];
    [_db open];
}
- (void)closeDataBase
{
    [_db close];
}

- (NSMutableArray *)reciveManyWithString:(NSString *)string
{
    NSMutableArray *songArray = [NSMutableArray arrayWithCapacity:20];
    FMResultSet *result = [_db executeQuery:string];
    while ([result next])
    {
        SDSingers *singer = [[SDSingers alloc] init];
        singer.singerId = [result intForColumn:@"id"];
        singer.singerNo = [result stringForColumn:@"no"];
        singer.singerName = [result stringForColumn:@"name"];
        singer.string_portrait = [result stringForColumn:@"photo"];
        //singer.singerPhoto_type = [result stringForColumn:@"photo_type"];
        [songArray addObject:singer];
        [singer release],  singer = nil;
    }
    return songArray;
}

/// Tag 0-buy 1-favorite 2-order
/// 保存song之前一定要先设置song的三个Tag之一
#pragma mark - saveSong
- (BOOL)saveSong:(SDSongs *)song withTag:(NSInteger)saveTag
{
    NSString *string_path = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    NSString *path = [NSString stringWithFormat:@"%@.db",string_path];
    
    NSString *dbPath = [self reciveDataPathWithString:path];
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
    
    NSString *escapeTag = [song.songMd5 stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *sql = [NSString stringWithFormat:@"select * from alreadySong where md5 = '%@'",escapeTag];
    FMResultSet *result = [db executeQuery:sql];
    BOOL success_have = NO;
    while ([result next])
    {
        success_have = YES;
    }
    if(success_have)
    {
        switch (saveTag)
        {
            case 0:
            {
                BOOL success_update = [db executeUpdate:@"UPDATE alreadySong SET buyTag = ? WHERE md5 = ? ",[NSNumber numberWithInteger:song.songBuyTag],song.songMd5];
                if(success_update)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"JDSongStateChange_buy" object:@"1"];
                }
                [db close];
                return success_update;
            }break;
            case 1:
            {
                BOOL success_update = [db executeUpdate:@"UPDATE alreadySong SET favoriteTag = ? WHERE md5 = ? ",[NSNumber numberWithInteger:song.songFavoriteTag],song.songMd5];
                if(success_update)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"JDSongStateChange_favorite" object:@"1"];
                }
                [db close];
                return success_update;
            }break;
            case 2:
            {
                BOOL success_update = [db executeUpdate:@"UPDATE alreadySong SET orderTag = ? WHERE md5 = ? ",[NSNumber numberWithInteger:song.songOrderTag],song.songMd5];
                if(success_update)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"JDSongStateChange_order" object:@"1"];
                }
                [db close];
                return success_update;
            }break;
            default:
                [db close];
                break;
        }
    }
    else
    {
        BOOL success_insert = [db executeUpdate:@"INSERT INTO alreadySong (no,title,singers,media_type,md5,buyTag,orderTag,favoriteTag,video_url,audio0_url,audio1_url) VALUES (?,?,?,?,?,?,?,?,?,?,?)",song.songNo,song.songTitle,song.songSingers,song.songMedia_type,song.songMd5,[NSNumber numberWithInteger:song.songBuyTag],[NSNumber numberWithInteger:song.songOrderTag],[NSNumber numberWithInteger:song.songFavoriteTag],song.string_videoUrl,song.string_audio0Url,song.string_audio1Url];
        [db close];
        if(success_insert)
        {
            switch (saveTag)
            {
                case 0:
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"JDSongStateChange_buy" object:@"1"];
                    return success_insert;
                }break;
                case 1:
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"JDSongStateChange_favorite" object:@"1"];
                    return success_insert;
                }break;
                case 2:
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"JDSongStateChange_order" object:@"1"];
                    return success_insert;
                }break;
                default:
                    break;
            }
        }
    }
    return NO;
}

- (NSMutableArray *)reciveSongArrayWithTag:(NSInteger )reciveSongTag
{
    NSString *string_path = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    NSString *path = [NSString stringWithFormat:@"%@.db",string_path];
    
    NSString *dbPath = [self reciveDataPathWithString:path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL pathExist = [fileManager fileExistsAtPath:dbPath];
    if(!pathExist)
    {
        NSString *bundleDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:LOCAL];
        [fileManager copyItemAtPath:bundleDBPath toPath:dbPath error:&error];
    }
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    NSMutableArray *songArray = [NSMutableArray arrayWithCapacity:20];
    NSString *sql = nil;
    
    switch (reciveSongTag)
    {
        case 0:
        {
            sql = @"select * from alreadySong where buyTag = 1";
        }break;
        case 1:
        {
            sql = @"select * from alreadySong where favoriteTag = 1";
        }break;
        case 2:
        {
            sql = @"select * from alreadySong where orderTag = 1";
        }break;
        default:
        break;
    }
    
    [db open];
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
        song.songBuyTag = [result intForColumn:@"buyTag"];
        song.songFavoriteTag = [result intForColumn:@"favoriteTag"];
        song.songOrderTag = [result intForColumn:@"orderTag"];
        song.string_videoUrl = [result stringForColumn:@"video_url"];
        song.string_audio0Url = [result stringForColumn:@"audio0_url"];
        song.string_audio1Url = [result stringForColumn:@"audio1_url"];
        [songArray addObject:song];
        [song release],  song = nil;
    }
    [db close];
    return songArray;
}

- (void)selectSongandChangeItTag:(SDSongs *)song 
{
    NSString *string_path = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    NSString *path = [NSString stringWithFormat:@"%@.db",string_path];
    
    NSString *dbPath = [self reciveDataPathWithString:path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL pathExist = [fileManager fileExistsAtPath:dbPath];
    if(!pathExist)
    {
        NSString *bundleDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:LOCAL];
        [fileManager copyItemAtPath:bundleDBPath toPath:dbPath error:&error];
    }
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    NSString *escapeTag = [song.songMd5 stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *sql = [NSString stringWithFormat:@"select * from alreadySong where md5 = '%@'",escapeTag];
    [db open];
    FMResultSet *result = [db executeQuery:sql];
    while ([result next])
    {
        song.songBuyTag = [result intForColumn:@"buyTag"];
        song.songFavoriteTag = [result intForColumn:@"favoriteTag"];
        song.songOrderTag = [result intForColumn:@"orderTag"];
    }
    [db close];
}

- (void)selectSongandChangeItTagWithArray:(NSMutableArray *)array_song
{
    NSString *string_path = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    NSString *path = [NSString stringWithFormat:@"%@.db",string_path];
    
    NSString *dbPath = [self reciveDataPathWithString:path];
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
    
    for (SDSongs *song in array_song)
    {
        NSString *escapeTag = [song.songMd5 stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *sql = [NSString stringWithFormat:@"select * from alreadySong where md5 = '%@'",escapeTag];
       
        FMResultSet *result = [db executeQuery:sql];
        while ([result next])
        {
            song.songBuyTag = [result intForColumn:@"buyTag"];
            song.songFavoriteTag = [result intForColumn:@"favoriteTag"];
            song.songOrderTag = [result intForColumn:@"orderTag"];
        }
    }
    [db close];
}




- (BOOL)deleteSongFormLocalSingerWithString:(SDSongs *)song withTag:(NSInteger)deleteTag
{
    NSString *string_path = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    NSString *path = [NSString stringWithFormat:@"%@.db",string_path];
    
    NSString *dbPath = [self reciveDataPathWithString:path];
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
    
    switch (deleteTag)
    {
        case 0:
        {
            BOOL success_update = [db executeUpdate:@"UPDATE alreadySong SET buyTag = ? WHERE md5 = ? ",[NSNumber numberWithInteger:0],song.songMd5];
            if(success_update)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"JDSongStateChange_buy" object:@"-1"];
            }
            NSString *escapeTag = [song.songMd5 stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *sql = [NSString stringWithFormat:@"select * from alreadySong where md5 = '%@'",escapeTag];
            FMResultSet *result = [db executeQuery:sql];
            SDSongs *song_tmp = [[SDSongs alloc] init];
            while ([result next])
            {
                song_tmp.songId = [result intForColumn:@"id"];
                //song_tmp.songNo = [result stringForColumn:@"no"];
                song_tmp.songTitle = [result stringForColumn:@"title"];
                song_tmp.songSingers = [result stringForColumn:@"singers"];
                song_tmp.songMedia_type = [result stringForColumn:@"media_type"];
                song_tmp.string_videoUrl = [result stringForColumn:@"video_url"];
                song_tmp.string_audio0Url = [result stringForColumn:@"audio0_url"];
                song_tmp.string_audio1Url = [result stringForColumn:@"audio1_url"];
                song_tmp.songMd5 = [result stringForColumn:@"md5"];
                song_tmp.songBuyTag = [result intForColumn:@"buyTag"];
                song_tmp.songFavoriteTag = [result intForColumn:@"favoriteTag"];
                song_tmp.songOrderTag = [result intForColumn:@"orderTag"];
            }
            if(song_tmp.songBuyTag == 0 && song_tmp.songFavoriteTag == 0 && song_tmp.songOrderTag == 0)
            {
                BOOL success_delete = [db executeUpdate:@"DELETE FROM alreadySong WHERE md5 = ?",song_tmp.songMd5];
                [song_tmp release];
                return success_delete;
            }
            [db close];
            return success_update;
        }break;
            
        case 1:
        {
            BOOL success_update = [db executeUpdate:@"UPDATE alreadySong SET favoriteTag = ? WHERE md5 = ? ",[NSNumber numberWithInteger:0],song.songMd5];
            NSString *escapeTag = [song.songMd5 stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *sql = [NSString stringWithFormat:@"select * from alreadySong where md5 = '%@'",escapeTag];
            FMResultSet *result = [db executeQuery:sql];
            SDSongs *song_tmp = [[SDSongs alloc] init];
            while ([result next])
            {
                song_tmp.songId = [result intForColumn:@"id"];
                //song_tmp.songNo = [result stringForColumn:@"no"];
                song_tmp.songTitle = [result stringForColumn:@"title"];
                song_tmp.songSingers = [result stringForColumn:@"singers"];
                song_tmp.songMedia_type = [result stringForColumn:@"media_type"];
                song_tmp.songMd5 = [result stringForColumn:@"md5"];
                song_tmp.songBuyTag = [result intForColumn:@"buyTag"];
                song_tmp.songFavoriteTag = [result intForColumn:@"favoriteTag"];
                song_tmp.songOrderTag = [result intForColumn:@"orderTag"];
                song_tmp.string_videoUrl = [result stringForColumn:@"video_url"];
                song_tmp.string_audio0Url = [result stringForColumn:@"audio0_url"];
                song_tmp.string_audio1Url = [result stringForColumn:@"audio1_url"];
            }
            
            if(song_tmp.songBuyTag == 0 && song_tmp.songFavoriteTag == 0 && song_tmp.songOrderTag == 0)
            {
                [db executeUpdate:@"DELETE FROM alreadySong WHERE md5 = ?",song_tmp.songMd5];
                [song_tmp release];
            }
            
            if(success_update)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"JDSongStateChange_favorite" object:@"-1"];
            }
            [db close];
            return success_update;
        }break;
            
        case 2:
        {
            BOOL success_update = [db executeUpdate:@"UPDATE alreadySong SET orderTag = ? WHERE md5 = ? ",[NSNumber numberWithInteger:0],song.songMd5];
            NSString *escapeTag = [song.songMd5 stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString *sql = [NSString stringWithFormat:@"select * from alreadySong where md5 = '%@'",escapeTag];
            FMResultSet *result = [db executeQuery:sql];
            SDSongs *song_tmp = [[SDSongs alloc] init];
            while ([result next])
            {
                //song_tmp.songId = [result intForColumn:@"id"];
                //song_tmp.songNo = [result stringForColumn:@"no"];
                song_tmp.songTitle = [result stringForColumn:@"title"];
                song_tmp.songSingers = [result stringForColumn:@"singers"];
                song_tmp.songMedia_type = [result stringForColumn:@"media_type"];
                song_tmp.songMd5 = [result stringForColumn:@"md5"];
                song_tmp.songBuyTag = [result intForColumn:@"buyTag"];
                song_tmp.songFavoriteTag = [result intForColumn:@"favoriteTag"];
                song_tmp.songOrderTag = [result intForColumn:@"orderTag"];
                song_tmp.string_videoUrl = [result stringForColumn:@"video_url"];
                song_tmp.string_audio0Url = [result stringForColumn:@"audio0_url"];
                song_tmp.string_audio1Url = [result stringForColumn:@"audio1_url"];
            }
            
            if(song_tmp.songBuyTag == 0 && song_tmp.songFavoriteTag == 0 && song_tmp.songOrderTag == 0)
            {
                [db executeUpdate:@"DELETE FROM alreadySong WHERE md5 = ?",song_tmp.songMd5];
                [song_tmp release];
            }

            if(success_update)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"JDSongStateChange_order" object:@"-1"];
            }
            [db close];
            return success_update;
            
        }break;
            
        default:
            [db close];
            break;
    }
    return NO;
}

- (void)changeAlreadySongList:(SDSongs *)song
{
    NSString *string_path = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    NSString *path = [NSString stringWithFormat:@"%@.db",string_path];
    
    NSMutableArray *array_new = [NSMutableArray arrayWithObject:song];
    NSString *dbPath = [self reciveDataPathWithString:path];
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
    [db executeUpdate:@"DELETE FROM alreadySong WHERE md5 = ?",song.songMd5];
    NSString *sql = @"select * from alreadySong where orderTag = 1";
    FMResultSet *result = [db executeQuery:sql];
    while ([result next])
    {
        SDSongs *song = [[SDSongs alloc] init];
        //song.songNo = [result stringForColumn:@"no"];
        song.songTitle = [result stringForColumn:@"title"];
        song.songSingers = [result stringForColumn:@"singers"];
        song.songMedia_type = [result stringForColumn:@"media_type"];
        song.songMd5 = [result stringForColumn:@"md5"];
        song.songBuyTag = [result intForColumn:@"buyTag"];
        song.songFavoriteTag = [result intForColumn:@"favoriteTag"];
        song.songOrderTag = [result intForColumn:@"orderTag"];
        song.string_videoUrl = [result stringForColumn:@"video_url"];
        song.string_audio0Url = [result stringForColumn:@"audio0_url"];
        song.string_audio1Url = [result stringForColumn:@"audio1_url"];
        [array_new addObject:song];
        [song release],  song = nil;
    }
    [db executeUpdate:@"DELETE FROM alreadySong"];
    for(int i = 0; i<[array_new count]; i++)
    {
        SDSongs *song = [array_new objectAtIndex:i];
        [db executeUpdate:@"INSERT INTO alreadySong (no,title,singers,media_type,md5,buyTag,orderTag,favoriteTag,video_url,audio0_url,audio1_url) VALUES (?,?,?,?,?,?,?,?,?,?,?)",song.songNo,song.songTitle,song.songSingers,song.songMedia_type,song.songMd5,[NSNumber numberWithInteger:song.songBuyTag],[NSNumber numberWithInteger:song.songOrderTag],[NSNumber numberWithInteger:song.songFavoriteTag],song.string_videoUrl,song.string_audio0Url,song.string_audio1Url];
    }
    [db close];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JDSongStateChange_order" object:nil];
}

- (void)changeAlreadySongList_moved:(NSMutableArray *)array_move
{
    NSString *string_path = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    NSString *path = [NSString stringWithFormat:@"%@.db",string_path];
    
    NSString *dbPath = [self reciveDataPathWithString:path];
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

    [db executeUpdate:@"DELETE FROM alreadySong"];
    for(int i = 0; i<[array_move count]; i++)
    {
        SDSongs *song = [array_move objectAtIndex:i];
        [db executeUpdate:@"INSERT INTO alreadySong (no,title,singers,media_type,md5,buyTag,orderTag,favoriteTag,video_url,audio0_url,audio1_url) VALUES (?,?,?,?,?,?,?,?,?,?,?)",song.songNo,song.songTitle,song.songSingers,song.songMedia_type,song.songMd5,[NSNumber numberWithInteger:song.songBuyTag],[NSNumber numberWithInteger:song.songOrderTag],[NSNumber numberWithInteger:song.songFavoriteTag],song.string_videoUrl,song.string_audio0Url,song.string_audio1Url];
    }
    [db close];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JDSongStateChange_order" object:nil];
}


- (void)changeAlreadySongList_inMySong:(SDSongs *)song
{
    NSString *string_path = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    NSString *path = [NSString stringWithFormat:@"%@.db",string_path];
    
    NSMutableArray *array_new = [NSMutableArray arrayWithObject:song];
    NSString *dbPath = [self reciveDataPathWithString:path];
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
    [db executeUpdate:@"DELETE FROM alreadySong WHERE md5 = ?",song.songMd5];
    NSString *sql = @"select * from alreadySong where orderTag = 1";
    FMResultSet *result = [db executeQuery:sql];
    while ([result next])
    {
        SDSongs *song = [[SDSongs alloc] init];
        //song.songNo = [result stringForColumn:@"no"];
        song.songTitle = [result stringForColumn:@"title"];
        song.songSingers = [result stringForColumn:@"singers"];
        song.songMedia_type = [result stringForColumn:@"media_type"];
        song.songMd5 = [result stringForColumn:@"md5"];
        song.songBuyTag = [result intForColumn:@"buyTag"];
        song.songFavoriteTag = [result intForColumn:@"favoriteTag"];
        song.songOrderTag = [result intForColumn:@"orderTag"];
        song.string_videoUrl = [result stringForColumn:@"video_url"];
        song.string_audio0Url = [result stringForColumn:@"audio0_url"];
        song.string_audio1Url = [result stringForColumn:@"audio1_url"];
        [array_new addObject:song];
        [song release],  song = nil;
    }
    [db executeUpdate:@"DELETE FROM alreadySong"];
    for(int i = 0; i<[array_new count]; i++)
    {
        SDSongs *song = [array_new objectAtIndex:i];
        [db executeUpdate:@"INSERT INTO alreadySong (no,title,singers,media_type,md5,buyTag,orderTag,favoriteTag,video_url,audio0_url,audio1_url) VALUES (?,?,?,?,?,?,?,?,?,?,?)",song.songNo,song.songTitle,song.songSingers,song.songMedia_type,song.songMd5,[NSNumber numberWithInteger:song.songBuyTag],[NSNumber numberWithInteger:song.songOrderTag],[NSNumber numberWithInteger:song.songFavoriteTag],song.string_videoUrl,song.string_audio0Url,song.string_audio1Url];
    }
    [db close];
}

- (void)changeAlreadySongList_next:(SDSongs *)song
{
    NSString *string_path = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    NSString *path = [NSString stringWithFormat:@"%@.db",string_path];
    
    NSMutableArray *array_new = [NSMutableArray arrayWithObject:song];
    NSMutableArray *array_midlle = [NSMutableArray arrayWithCapacity:10];
    
    NSString *dbPath = [self reciveDataPathWithString:path];
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
    [db executeUpdate:@"DELETE FROM alreadySong WHERE md5 = ?",song.songMd5];
    NSString *sql = @"select * from alreadySong where orderTag = 1";
    FMResultSet *result = [db executeQuery:sql];
    while ([result next])
    {
        SDSongs *song = [[SDSongs alloc] init];
        //song.songNo = [result stringForColumn:@"no"];
        song.songTitle = [result stringForColumn:@"title"];
        song.songSingers = [result stringForColumn:@"singers"];
        song.songMedia_type = [result stringForColumn:@"media_type"];
        song.songMd5 = [result stringForColumn:@"md5"];
        song.songBuyTag = [result intForColumn:@"buyTag"];
        song.songFavoriteTag = [result intForColumn:@"favoriteTag"];
        song.songOrderTag = [result intForColumn:@"orderTag"];
        song.string_videoUrl = [result stringForColumn:@"video_url"];
        song.string_audio0Url = [result stringForColumn:@"audio0_url"];
        song.string_audio1Url = [result stringForColumn:@"audio1_url"];
        [array_midlle addObject:song];
        [song release],  song = nil;
    }
    for (int k = 1; k<[array_midlle count]; k++)
    {
        [array_new addObject:[array_midlle objectAtIndex:k]];
    }
    
    if([array_midlle count] == 0)
    {
        
    }
    else
    {
        [array_new addObject:[array_midlle objectAtIndex:0]];
    }
    
    [db executeUpdate:@"DELETE FROM alreadySong"];
    for(int i = 0; i<[array_new count]; i++)
    {
        SDSongs *song = [array_new objectAtIndex:i];
        [db executeUpdate:@"INSERT INTO alreadySong (no,title,singers,media_type,md5,buyTag,orderTag,favoriteTag,video_url,audio0_url,audio1_url) VALUES (?,?,?,?,?,?,?,?,?,?,?)",song.songNo,song.songTitle,song.songSingers,song.songMedia_type,song.songMd5,[NSNumber numberWithInteger:song.songBuyTag],[NSNumber numberWithInteger:song.songOrderTag],[NSNumber numberWithInteger:song.songFavoriteTag],song.string_videoUrl,song.string_audio0Url,song.string_audio1Url];
    }
    [db close];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JDSongStateChange_order" object:nil];
}

- (NSMutableArray *)selectSongArrayWithArray:(NSMutableArray *)array_source
{
    [self sqlDataInstall];
    NSMutableArray *songArray = [NSMutableArray arrayWithCapacity:20];
    NSString *dbpath = [self reciveDataPath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbpath];
    [db open];
    
    SDSongs *song_theme = [array_source objectAtIndex:0];
    NSMutableString *allMd5 = [[NSMutableString alloc]initWithFormat:@"'%@'",[song_theme songMd5]];
    for (int i = 1; i < [array_source count]; i++)
    {
        SDSongs *song_theme = [array_source objectAtIndex:i];
        [allMd5 appendFormat:@",'%@'", song_theme.songMd5];
    }

    NSString *sql = [NSString stringWithFormat:@"select * from client_songs where md5 in (%@)",allMd5];
    FMResultSet *result = [db executeQuery:sql];
    while ([result next])
    {
        SDSongs *song = [[SDSongs alloc] init];
        song.songId = [result intForColumn:@"id"];
        song.int_price = [result intForColumn:@"price"];
        song.songTitle = [result stringForColumn:@"title"];
        song.songSingers = [result stringForColumn:@"singers"];
        song.songMedia_type = [result stringForColumn:@"media_type"];
        song.songSingers_no = [result stringForColumn:@"singers_no"];
        song.songMd5 = [result stringForColumn:@"md5"];
        song.string_videoUrl = [result stringForColumn:@"video_url"];
        song.string_audio0Url = [result stringForColumn:@"audio0_url"];
        song.string_audio1Url = [result stringForColumn:@"audio1_url"];
        song.songBuyTag = 0;
        song.songFavoriteTag = 0;
        song.songOrderTag = 0;
        [songArray addObject:song];
        [song release],  song = nil;
    }
    
    [db close];
    return songArray;
}

@end
