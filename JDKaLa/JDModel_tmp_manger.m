//
//  JDModel_tmp_manger.m
//  JDKaLa
//
//  Created by zhangminglei on 4/18/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDModel_tmp_manger.h"

@implementation JDModel_tmp_manger

static  JDModel_tmp_manger *shareModelManger = nil;

+ (JDModel_tmp_manger *)sharedModel
{
    @synchronized(self)
    {
        if(shareModelManger == nil)
        {
            shareModelManger = [[[self alloc] init] autorelease];
        }
    }
    return shareModelManger;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (shareModelManger == nil)
        {
            shareModelManger = [super allocWithZone:zone];
            return  shareModelManger;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (oneway void)release
{
    
}

- (id)autorelease
{
    return self;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        _bool_hasCard = NO;
        _array_song = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}


- (void)dealloc
{
    [_array_song release], _array_song = nil;
    [super dealloc];
}


@end
