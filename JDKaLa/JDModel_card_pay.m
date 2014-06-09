//
//  JDModel_card_pay.m
//  JDKaLa
//
//  Created by zhangminglei on 4/16/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDModel_card_pay.h"

@implementation JDModel_card_pay

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:_string_time forKey:@"string_time"];
	[aCoder encodeObject:_string_endTime forKey:@"string_endTime"];
	[aCoder encodeInteger:_integer_kindOfKind forKey:@"integer_kindOfKind"];
    [aCoder encodeBool:_bool_success forKey:@"bool_success"];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
	{
		self.string_time = [aDecoder decodeObjectForKey:@"string_time"];
        self.string_endTime = [aDecoder decodeObjectForKey:@"string_endTime"];
        self.integer_kindOfKind = [aDecoder decodeIntegerForKey:@"integer_kindOfKind"];
        self.bool_success = [aDecoder decodeBoolForKey:@"bool_success"];
	}
	return self;
}


- (void)dealloc
{
    //[_string_payMoney release], _string_payMoney = nil;
    [_string_time release], _string_time = nil;
    [_string_endTime release], _string_endTime = nil;
    [super dealloc];
}

@end
