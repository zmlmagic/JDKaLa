//
//  JDModel_theme.m
//  JDKaLa
//
//  Created by zhangminglei on 9/9/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDModel_theme.h"

@implementation JDModel_theme

- (void)dealloc
{
    [_string_title release], _string_title = nil;
    [_string_themeDetail release], _string_themeDetail = nil;
    [_string_imageTheme release], _string_imageTheme = nil;
    [_array_song release], _array_song = nil;
    [super dealloc];
}

@end
