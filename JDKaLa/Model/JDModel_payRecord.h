//
//  JDModel_payRecord.h
//  JDKaLa
//
//  Created by 韩 抗 on 13-10-21.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDModel_payRecord : NSObject
@property (retain, nonatomic) NSString *time;
@property (retain, nonatomic) NSString *type;
@property (retain, nonatomic) NSString *price;
@property (retain, nonatomic) NSString *songName;
@property (assign, nonatomic) BOOL success;
@end
