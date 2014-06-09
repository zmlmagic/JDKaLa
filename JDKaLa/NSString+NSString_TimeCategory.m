//
//  NSString+NSString_TimeCategory.m
//  JuKaLa
//
//  Created by 张 明磊 on 10/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+NSString_TimeCategory.h"

@implementation NSString (NSString_TimeCategory)


+ (NSString *)stringWithTime:(NSTimeInterval)time 
{
//    BOOL isPositive;
//    NSInteger timeInt;
//    if (time > 3600 * 24 || time < - 3600 * 24)
//        return nil;
//    if (time < 0) 
//    {
//        timeInt = (NSInteger)-time;
//        isPositive = NO;
//    } 
//    else 
//    {
//        timeInt = (NSInteger)time;
//        isPositive = YES;
//    }
//    NSInteger hour = timeInt/3600;
//    NSInteger minute = (timeInt%3600)/60;
//    NSInteger second = (timeInt%3600)%60;
//    if (hour > 0) 
//    {
//        if (isPositive) 
//        {
//            return [NSString stringWithFormat:@"%d%d:%d%d:%d%d",hour/10, hour%10, minute/10, minute%10, second/10, second%10];
//        } 
//        else 
//        {
//            return [NSString stringWithFormat:@"-%d%d:%d%d:%d%d",hour/10, hour%10, minute/10, minute%10, second/10, second%10];
//        }
//        
//    } 
//    else 
//    {
//        if (isPositive) 
//        {
//            return [NSString stringWithFormat:@"%d%d:%d%d",minute/10, minute%10, second/10, second%10];
//        } 
//        else 
//        {
//            return [NSString stringWithFormat:@"-%d%d:%d%d",minute/10, minute%10, second/10, second%10];
//        }
//    }
    
    NSString *string = [NSString stringWithFormat:@"%02li:%02li:%02li",
                        lround(floor(time / 3600.)) % 100,
                        lround(floor(time / 60.)) % 60,
                        lround(floor(time*1000000 / 1.)) % 60000000];
    return  string;
}

+ (NSString *)stringWithTimeForSInt:(NSTimeInterval)time
{
    NSString *string = [NSString stringWithFormat:@"%02li",lround(floor(time*1000000 / 1.)) % 60000000];
    return string;
}

- (NSTimeInterval)timeValue 
{
    NSInteger hour = 0, minute = 0, second = 0;
    NSArray *sections = [self componentsSeparatedByString:@":"];
    NSInteger count = [sections count];
    second = [[sections objectAtIndex:count - 1] integerValue];
    minute = [[sections objectAtIndex:count - 2] integerValue];
    if (count > 2) 
    {
        hour = [[sections objectAtIndex:0] integerValue];
    }
    return hour * 3600 + minute * 60 + (float)second/1000000;
}

@end
