//
//  JDModel_userInfo.m
//  JDKaLa
//
//  Created by zhangminglei on 6/27/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDModel_userInfo.h"
#import "UIUtils.h"

@implementation JDModel_userInfo

static JDModel_userInfo *shareJDModel_userInfo = nil;

+ (JDModel_userInfo *)sharedModel
{
    @synchronized(self)
    {
        if(shareJDModel_userInfo == nil)
        {
            shareJDModel_userInfo = [[[self alloc] init] autorelease];
        }
    }
    return shareJDModel_userInfo;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (shareJDModel_userInfo == nil)
        {
            shareJDModel_userInfo = [super allocWithZone:zone];
            return shareJDModel_userInfo;
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

- (void)dealloc
{
    [_string_userID release] , _string_userID = nil;
    [_string_userPass release] , _string_userPass = nil;
    [_string_nickName release] , _string_nickName = nil;
    [_string_signature release] , _string_signature = nil;
    [_string_curPayActionKey release] , _string_curPayActionKey = nil;
    [_string_token release] , _string_token = nil;
    [_string_tourist release], _string_tourist = nil;
    [_string_tempToken release] , _string_tempToken = nil;
    [_string_money release] , _string_money = nil;
    [_string_loginTime release] , _string_loginTime = nil;
    [_string_portrait release] , _string_portrait = nil;
    [_string_device release], _string_device = nil;
    [_string_version release], _string_version = nil;
    [super dealloc];
}

- (void)configureDataWithUser
{
    _bool_hasMaster = YES;
    _bool_homeBack = NO;
    _string_tourist = NO;
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"userName"])
    {
        _string_userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    }
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"passWord"])
    {
        _string_userPass = [[NSUserDefaults standardUserDefaults] objectForKey:@"passWord"];
    }
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"])
    {
        _string_nickName = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"money"])
    {
        _string_money = [[NSUserDefaults standardUserDefaults] objectForKey:@"money"];
    }
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"device"])
    {
        _string_device = [[NSUserDefaults standardUserDefaults] objectForKey:@"device"];
    }
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"portrait"])
    {
        _string_portrait = [[NSUserDefaults standardUserDefaults] objectForKey:@"portrait"];
    }
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"token"])
    {
        _string_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    }
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"signature"])
    {
        _string_signature = [[NSUserDefaults standardUserDefaults] objectForKey:@"signature"];
    }
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"userID"])
    {
        _string_userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    }
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"sex"])
    {
        _integer_sex = [[NSUserDefaults standardUserDefaults] integerForKey:@"sex"];
    }
}

- (void)configureDataWithTourist
{
    _bool_hasMaster = YES;
    _bool_homeBack = NO;
    _string_tourist = NO;
}

@end
