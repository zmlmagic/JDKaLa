//
//  JDModel_user.h
//  JDKaLa
//
//  Created by zhangminglei on 4/16/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDModel_card_pay.h"
#import "JDModel_song_pay.h"
#import "JDModel_supplement.h"

@interface JDModel_user : NSObject<NSCoding>

@property (retain, nonatomic) NSString *string_userName;
@property (retain, nonatomic) NSString *string_passWord;
@property (retain, nonatomic) NSString *string_petName;

@property (retain, nonatomic) NSString *string_userMoney;
@property (retain, nonatomic) NSMutableArray *array_record_buy;
@property (retain, nonatomic) NSMutableArray *array_card;
@property (retain, nonatomic) NSMutableArray *array_song;

//@property (retain, nonatomic) JDModel_supplement *model_record_buy;
//@property (retain, nonatomic) JDModel_card_pay *model_card;
//@property (retain, nonatomic) JDModel_song_pay *model_song;


- (void)writeToFile;
- (void)readFormFile;
- (void)addSupplement:(JDModel_supplement *)_supplment;
- (void)buyCard:(JDModel_card_pay *)_card;
- (void)buySong:(JDModel_song_pay *)_song;


@end
