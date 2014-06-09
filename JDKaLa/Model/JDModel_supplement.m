//
//  JDModel_supplement.m
//  JDKaLa
//
//  Created by zhangminglei on 4/16/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDModel_supplement.h"

@implementation JDModel_supplement

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_string_time forKey:@"string_time"];
	[aCoder encodeInteger:_integer_kind forKey:@"integer_kind"];
    [aCoder encodeBool:_bool_success forKey:@"bool_success"];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
	{
		self.integer_kind = [aDecoder decodeIntegerForKey:@"integer_kind"];
        self.string_time = [aDecoder decodeObjectForKey:@"string_time"];
        self.bool_success = [aDecoder decodeBoolForKey:@"bool_success"];
	}
	return self;
}


- (void)dealloc
{
    [_string_time release], _string_time = nil;
    [super dealloc];
}

@end
