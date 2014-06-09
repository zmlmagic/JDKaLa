//
//  JDModel_tmp_manger.h
//  JDKaLa
//
//  Created by zhangminglei on 4/18/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDModel_tmp_manger : NSObject

@property (assign, nonatomic) BOOL bool_hasCard;
@property (retain, nonatomic) NSMutableArray *array_song;


+ (JDModel_tmp_manger *)sharedModel;

@end
