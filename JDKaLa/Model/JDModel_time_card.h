//
//  JDModel_time_card.h
//  JDKaLa
//
//  Created by 韩 抗 on 13-10-11.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDModel_time_card : NSObject

@property (retain, nonatomic) NSString *cardID;
@property (retain, nonatomic) NSString *productID;
@property (retain, nonatomic) NSString *buyTime;
@property (retain, nonatomic) NSString *invalidTime;
@property (retain, nonatomic) NSString *activeDate;
@property (assign, nonatomic) BOOL valid;

@end
