//
//  JDModel_pay.m
//  JDKaLa
//
//  Created by zhangminglei on 4/16/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDModel_song_pay.h"

@implementation JDModel_song_pay

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_string_songName forKey:@"string_songName"];
	[aCoder encodeObject:_string_singerName forKey:@"string_singerName"];
	[aCoder encodeObject:_string_time forKey:@"string_time"];
    [aCoder encodeObject:_string_payMoney forKey:@"string_payMoney"];
    [aCoder encodeBool:_bool_success forKey:@"bool_success"];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
	{
        self.string_songName = [aDecoder decodeObjectForKey:@"string_songName"];
		self.string_singerName = [aDecoder decodeObjectForKey:@"string_singerName"];
        self.string_time = [aDecoder decodeObjectForKey:@"string_time"];
        self.string_payMoney = [aDecoder decodeObjectForKey:@"string_payMoney"];
        self.bool_success = [aDecoder decodeBoolForKey:@"bool_success"];
	}
	return self;
}


- (void)dealloc
{
    [_string_singerName release], _string_singerName = nil;
    [_string_songName release], _string_songName = nil;
    [_string_time release], _string_time = nil;
    [_string_payMoney release], _string_payMoney = nil;
    [super dealloc];
}

@end
