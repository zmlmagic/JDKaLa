//
//  NSString+NSString_TimeCategory.h
//  JuKaLa
//
//  Created by 张 明磊 on 10/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSString_TimeCategory)


+ (NSString *)stringWithTime:(NSTimeInterval)time;
- (NSTimeInterval)timeValue;
+ (NSString *)stringWithTimeForSInt:(NSTimeInterval)time;

@end
