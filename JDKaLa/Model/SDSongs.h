//
//  SDSongs.h
//  JuKaLa
//
//  Created by 张 明磊 on 9/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDSongs : NSObject


@property (assign, nonatomic) NSInteger songId;
@property (retain, nonatomic) NSString *songNo;
@property (retain, nonatomic) NSString *songTitle;

/**
 视频绝对地址
 **/
@property (retain, nonatomic) NSString *string_videoUrl;

/**
 音频绝对地址
 **/
@property (retain, nonatomic) NSString *string_audio0Url;
@property (retain, nonatomic) NSString *string_audio1Url;

//@property (retain, nonatomic) NSString *songTags;
//@property (retain, nonatomic) NSString *songLang;
//@property (assign, nonatomic) NSInteger songWord_count;
//@property (assign, nonatomic) NSInteger songIs_karaoke;
//@property (retain, nonatomic) NSString *songVocal;
@property (retain, nonatomic) NSString *songSingers;
//@property (assign, nonatomic) NSInteger songHits;
@property (assign, nonatomic) NSInteger songIs_new;
//@property (assign, nonatomic) NSInteger songOriginal_id;
//@property (retain, nonatomic) NSString *songPicture_type;
@property (retain, nonatomic) NSString *songMedia_type;
@property (retain, nonatomic) NSString *songSingers_no;
//@property (retain, nonatomic) NSString *songCategorise_id;
@property (retain, nonatomic) NSString *songMd5;
@property (assign, nonatomic) NSInteger songBuyTag;
@property (assign, nonatomic) NSInteger songOrderTag;
@property (assign, nonatomic) NSInteger songFavoriteTag;
@property (retain, nonatomic) NSString *songPlayTime;
@property (assign, nonatomic) bool bought;

@property (assign, nonatomic) int int_price;

@end
