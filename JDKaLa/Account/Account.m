//
//  Account.m
//  JDKaLa
//
//  Created by 韩 抗 on 13-4-15.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import "Account.h"

@implementation Account


/**
 @fn setKCoinCount
 @brief 设置K币数量
 @param
 */
- (void) setKCoinCount:(NSInteger)kCoinCount
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:kCoinCount forKey:@"kCoin"];
    [userDefaults synchronize];
}

- (NSInteger) kCoinCount
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:@"kCoin"];
}
@end
