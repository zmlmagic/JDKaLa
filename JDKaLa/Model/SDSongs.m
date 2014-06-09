//
//  SDSongs.m
//  JuKaLa
//
//  Created by 张 明磊 on 9/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDSongs.h"

@implementation SDSongs


- (void)dealloc
{
    [_songTitle release], _songTitle = nil;
    //[_songTags release], _songTags = nil;
    //[_songLang release], _songLang = nil;
    //[_songVocal release], _songVocal = nil;
    [_songPlayTime release], _songPlayTime = nil;
    [_songSingers release], _songSingers = nil;
    [_songMedia_type release], _songMedia_type = nil;
    [_songSingers_no release], _songSingers_no = nil;
    [_string_videoUrl release], _string_videoUrl = nil;
    [_string_audio0Url release], _string_audio0Url = nil;
    [_string_audio1Url release], _string_audio1Url = nil;
    //[_songCategorise_id release], _songCategorise_id = nil;
    [_songMd5 release], _songMd5 = nil;
    [super dealloc];
}


@end
