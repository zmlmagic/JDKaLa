//
//  JDSqlDataBaseSongHistory.h
//  JDKaLa
//
//  Created by 张明磊 on 13-6-30.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDSongs.h"

@interface JDSqlDataBaseSongHistory : NSObject

+ (NSMutableArray *)reciveDataBaseFromLocal;
+ (BOOL)saveSong:(SDSongs *)song;
+ (BOOL)deleteSong:(SDSongs *)record;
+ (NSInteger)countOfHistoryTable;
+ (BOOL)deleteSongOnTop;

@end
