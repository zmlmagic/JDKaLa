//
//  SDSingers.m
//  JuKaLa
//
//  Created by 张 明磊 on 9/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDSingers.h"

@implementation SDSingers


- (void)dealloc
{
    [_singerNo release], _singerNo = nil;
    [_singerName release], _singerName = nil;
    [_singerTags release], _singerTags = nil;
    [_singer_pingyin release], _singer_pingyin = nil;
    [_string_portrait release], _string_portrait = nil;
    [super dealloc];
}

@end
