//
//  JDSqlDataBase.h
//  JDKaLa
//
//  Created by zhangminglei on 4/8/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDSongs.h"

@class FMDatabase;

@interface JDSqlDataBase : NSObject

@property (assign , nonatomic) FMDatabase *db;

- (void)openDataBase;
- (void)closeDataBase;
- (NSMutableArray *)reciveManyWithString:(NSString *)string;

- (void)sqlDataInstall;
- (void)arrangeDataBase;///过滤数据库
//- (void)reloadKODandLocalDataBase;///刷新数据库
//- (void)upLoadDataBase;///数据库升级

- (NSMutableArray *)reciveDataBaseWithString:(NSString *)string;
- (NSMutableArray *)reciveDataBaseWithStringFromSinger:(NSString *)string;

- (BOOL)saveSong:(SDSongs *)song withTag:(NSInteger)saveTag;

- (NSMutableArray *)reciveSongArrayWithTag:(NSInteger )reciveSongTag;
- (NSMutableArray *)selectSongArrayWithArray:(NSMutableArray *)array_source;

- (BOOL)deleteSongFormLocalSingerWithString:(SDSongs *)song withTag:(NSInteger)deleteTag;
- (void)selectSongandChangeItTag:(SDSongs *)song;
- (void)selectSongandChangeItTagWithArray:(NSMutableArray *)array_song;
- (void)changeAlreadySongList:(SDSongs *)song;
- (void)changeAlreadySongList_inMySong:(SDSongs *)song;
- (void)changeAlreadySongList_next:(SDSongs *)song;

- (void)changeAlreadySongList_moved:(NSMutableArray *)array_move;

//- (NSMutableArray *)selectSongArrayWithArray:(NSMutableArray *)array_source;

/**
 清空数据库
 **/
- (void)reloadLocalDataBase;

@end
