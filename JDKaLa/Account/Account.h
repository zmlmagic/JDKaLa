//
//  Account.h
//  JDKaLa
//
//  Created by 韩 抗 on 13-4-15.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CARD_TYPE_HALF_HOUR     0
#define CARD_TYPE_ONE_HOUR      1
#define CARD_TYPE_TWO_HOUR      2
#define CARD_TYPE_MONTHLY       3
@interface Account : NSObject

@property (assign, nonatomic) NSInteger kCoinCount;
@end
