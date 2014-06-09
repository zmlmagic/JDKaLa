//
//  JDModel_user.m
//  JDKaLa
//
//  Created by zhangminglei on 4/16/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDModel_user.h"

@implementation JDModel_user

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_string_userName forKey:@"string_userName"];
    [aCoder encodeObject:_string_passWord forKey:@"string_passWord"];
    [aCoder encodeObject:_string_petName forKey:@"string_petName"];
	[aCoder encodeObject:_string_userMoney forKey:@"string_userMoney"];
	[aCoder encodeObject:_array_record_buy forKey:@"array_record_buy"];
	[aCoder encodeObject:_array_card forKey:@"array_card"];
    [aCoder encodeObject:_array_song forKey:@"array_song"];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
	{
        self.string_userName = [aDecoder decodeObjectForKey:@"string_userName"];
        self.string_passWord = [aDecoder decodeObjectForKey:@"string_passWord"];
        self.string_petName = [aDecoder decodeObjectForKey:@"string_petName"];
		self.string_userMoney = [aDecoder decodeObjectForKey:@"string_userMoney"];
        self.array_record_buy = [aDecoder decodeObjectForKey:@"array_record_buy"];
        self.array_card = [aDecoder decodeObjectForKey:@"array_card"];
        self.array_song = [aDecoder decodeObjectForKey:@"array_song"];
	}
	return self;
}


- (void)dealloc
{
    [_string_userName release], _string_userName = nil;
    [_string_passWord release], _string_passWord = nil;
    [_string_petName release], _string_petName = nil;
    [_string_userMoney release], _string_userMoney = nil;
    [_array_record_buy release], _array_record_buy = nil;
    [_array_card release], _array_card = nil;
    [_array_song release], _array_song = nil;
    [super dealloc];
}


- (NSString *)getPath_songDownLoadConfigurationFiles
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"payRecord_configurationFiles"];
}


- (void)writeToFile
{
    NSMutableArray *array_card = [NSMutableArray arrayWithObjects:@"2013-03-20 11:43:20",@"2013-03-20 12:13:20",@"0",@"1",nil];
    NSMutableArray *array_song = [NSMutableArray arrayWithObjects:@"我的歌声里",@"曲婉莹",@"2013-03-20 12:18:29",@"20",@"1",nil];
    NSMutableArray *array_supplement = [NSMutableArray arrayWithObjects:@"2013-02-19 12:20:12",@"0",@"1",nil];
    
    NSMutableArray *array_card_many = [NSMutableArray arrayWithObjects:array_card,nil];
    NSMutableArray *array_song_many = [NSMutableArray arrayWithObjects:array_song,nil];
    NSMutableArray *array_supplement_many = [NSMutableArray arrayWithObjects:array_supplement,nil];
    
    NSMutableArray *user = [NSMutableArray arrayWithObjects:@"500",array_supplement_many,array_card_many,array_song_many,nil];
    
    [user writeToFile:[self getPath_songDownLoadConfigurationFiles] atomically:YES];
}

- (void)readFormFile
{
    NSMutableArray *array_user = [NSMutableArray arrayWithContentsOfFile:[self getPath_songDownLoadConfigurationFiles]];
    self.string_userMoney = [array_user objectAtIndex:0];
    
    NSMutableArray *array_supplement_new = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *array_supplement_many = [array_user objectAtIndex:1];
    for (int i = 0; i<[array_supplement_many count]; i++)
    {
        NSMutableArray *array_supplement = [array_supplement_many objectAtIndex:i];
        JDModel_supplement *supplement = [[JDModel_supplement alloc] init];
        supplement.string_time = [array_supplement objectAtIndex:0];
        supplement.integer_kind = [[array_supplement objectAtIndex:1]integerValue];
        if([[array_supplement objectAtIndex:2] isEqualToString:@"1"])
        {
            supplement.bool_success = YES;
        }
        else
        {
            supplement.bool_success = NO;
        }
        [array_supplement_new addObject:supplement];
        [supplement release];
    }
    self.array_record_buy = array_supplement_new;
    
    NSMutableArray *array_card_new = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *array_card_many = [array_user objectAtIndex:2];
    for (int i = 0; i<[array_card_many count]; i++)
    {
        NSMutableArray *array_card = [array_card_many objectAtIndex:i];
        JDModel_card_pay *card = [[JDModel_card_pay alloc]init];
        card.string_time = [array_card objectAtIndex:0];
        card.string_endTime = [array_card objectAtIndex:1];
        card.integer_kindOfKind = [[array_card objectAtIndex:2]integerValue];
        if([[array_card objectAtIndex:3] isEqualToString:@"1"])
        {
            card.bool_success = YES;
        }
        else
        {
            card.bool_success = NO;
        }
        [array_card_new addObject:card];
        [card release];
    }
    self.array_card = array_card_new;
    
    NSMutableArray *array_song_new = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *array_song_many = [array_user objectAtIndex:3];
    for (int i = 0; i<[array_song_many count]; i++)
    {
        NSMutableArray *array_song = [array_song_many objectAtIndex:i];
        JDModel_song_pay *song = [[JDModel_song_pay alloc]init];
        song.string_songName = [array_song objectAtIndex:0];
        song.string_singerName = [array_song objectAtIndex:1];
        song.string_time = [array_song objectAtIndex:2];
        song.string_payMoney = [array_song objectAtIndex:3];
        if([[array_song objectAtIndex:4] isEqualToString:@"1"])
        {
            song.bool_success = YES;
        }
        else
        {
            song.bool_success = NO;
        }
        [array_song_new addObject:song];
        [song release];
    }
    self.array_song = array_song_new;
}

- (void)buySong:(JDModel_song_pay *)_song
{
    NSMutableArray *array_user = [NSMutableArray arrayWithContentsOfFile:[self getPath_songDownLoadConfigurationFiles]];
    int money = [[array_user objectAtIndex:0] intValue];
    money = money - [_song.string_payMoney intValue];
    NSString *string_money = [[NSString alloc]initWithFormat:@"%d",money];
    [array_user replaceObjectAtIndex:0 withObject:string_money];
    [string_money release];
    
    NSString *string_bool;
    if(_song.bool_success)
    {
        string_bool = @"1";
    }
    else
    {
        string_bool = @"0";
    }

    NSMutableArray *array_song_new = [NSMutableArray arrayWithObjects:_song.string_songName,_song.string_singerName,_song.string_time,_song.string_payMoney,string_bool,nil];
    NSMutableArray *array_song_many = [array_user objectAtIndex:3];
    [array_song_many addObject:array_song_new];
    [array_user writeToFile:[self getPath_songDownLoadConfigurationFiles] atomically:YES];
    
}

- (void)buyCard:(JDModel_card_pay *)_card
{
    NSMutableArray *array_user = [NSMutableArray arrayWithContentsOfFile:[self getPath_songDownLoadConfigurationFiles]];
    int money = [[array_user objectAtIndex:0] intValue];
    switch (_card.integer_kindOfKind)
    {
        case 0:
        {
            money = money - 180;
            NSString *string_money = [[NSString alloc]initWithFormat:@"%d",money];
            [array_user replaceObjectAtIndex:0 withObject:string_money];
            [string_money release];
            break;
        }
        case 1:
        {
            money = money - 280;
            NSString *string_money = [[NSString alloc]initWithFormat:@"%d",money];
            [array_user replaceObjectAtIndex:0 withObject:string_money];
            [string_money release];
            break;
        }
        case 2:
        {
            money = money - 480;
            NSString *string_money = [[NSString alloc]initWithFormat:@"%d",money];
            [array_user replaceObjectAtIndex:0 withObject:string_money];
            [string_money release];
            break;
        }
        case 3:
        {
            money = money - 1980;
            NSString *string_money = [[NSString alloc]initWithFormat:@"%d",money];
            [array_user replaceObjectAtIndex:0 withObject:string_money];
            [string_money release];
            break;
        }
        default:
            break;
    }
    
    NSString *string_kind = [NSString stringWithFormat:@"%d",_card.integer_kindOfKind];
    NSString *string_bool;
    if(_card.bool_success)
    {
        string_bool = @"1";
    }
    else
    {
        string_bool = @"0";
    }
    
    NSMutableArray *array_card_new = [NSMutableArray arrayWithObjects:_card.string_time,_card.string_endTime,string_kind,string_bool,nil];
    NSMutableArray *array_card_many = [array_user objectAtIndex:2];
    [array_card_many addObject:array_card_new];
    
    [array_user writeToFile:[self getPath_songDownLoadConfigurationFiles] atomically:YES];
}

- (void)addSupplement:(JDModel_supplement *)_supplment
{
    NSMutableArray *array_user = [NSMutableArray arrayWithContentsOfFile:[self getPath_songDownLoadConfigurationFiles]];
    
    int money = [[array_user objectAtIndex:0] intValue];
    switch (_supplment.integer_kind)
    {
        case 0:
        {
            money = money + 300;
            NSString *string_money = [[NSString alloc]initWithFormat:@"%d",money];
            [array_user replaceObjectAtIndex:0 withObject:string_money];
            [string_money release];
            break;
        }
        case 1:
        {
            money = money + 500;
            NSString *string_money = [[NSString alloc]initWithFormat:@"%d",money];
            [array_user replaceObjectAtIndex:0 withObject:string_money];
            [string_money release];
            break;
        }
        case 2:
        {
            money = money + 1000;
            NSString *string_money = [[NSString alloc]initWithFormat:@"%d",money];
            [array_user replaceObjectAtIndex:0 withObject:string_money];
            [string_money release];
            break;
        }
        case 3:
        {
            money = money + 2000;
            NSString *string_money = [[NSString alloc]initWithFormat:@"%d",money];
            [array_user replaceObjectAtIndex:0 withObject:string_money];
            [string_money release];
            break;
        }
        default:
            break;
    }
    NSString *string_kind = [NSString stringWithFormat:@"%d",_supplment.integer_kind];
    NSString *string_bool;
    if(_supplment.bool_success)
    {
        string_bool = @"1";
    }
    else
    {
        string_bool = @"0";
    }
    NSMutableArray *array_supplement_new = [NSMutableArray arrayWithObjects:_supplment.string_time,string_kind,string_bool,nil];
    NSMutableArray *array_supplement_many = [array_user objectAtIndex:1];
    [array_supplement_many addObject:array_supplement_new];
    
    [array_user writeToFile:[self getPath_songDownLoadConfigurationFiles] atomically:YES];
}

@end
