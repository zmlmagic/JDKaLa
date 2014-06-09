//
//  JDModel_pay.h
//  JDKaLa
//
//  Created by zhangminglei on 4/16/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDModel_song_pay : NSObject

@property (retain, nonatomic) NSString *string_songName;
@property (retain, nonatomic) NSString *string_singerName;
@property (retain, nonatomic) NSString *string_time;
@property (retain, nonatomic) NSString *string_payMoney;
@property (assign, nonatomic) BOOL bool_success;

@end
