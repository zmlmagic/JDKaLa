//
//  JDDataBaseRecordSound.h
//  JDKaLa
//
//  Created by zhangminglei on 6/17/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDRecordSound.h"

@interface JDDataBaseRecordSound : NSObject

+ (NSMutableArray *)reciveDataBaseFromLocal;
+ (BOOL)saveRecord:(SDRecordSound *)record;
+ (BOOL)deleteRecord:(SDRecordSound *)record;
+ (NSInteger)countOfRecordTable;

@end
