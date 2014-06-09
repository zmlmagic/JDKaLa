//
//  JDThemeXMLPaser.h
//  JDKaLa
//
//  Created by zhangminglei on 9/9/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JDModel_theme;
@class SDSongs;

@interface JDThemeXMLPaser : NSObject<NSXMLParserDelegate>

@property (retain, nonatomic) JDModel_theme *model_theme;
@property (retain, nonatomic) NSString *mCurProperty;
@property (retain, nonatomic) SDSongs *song;

- (id)initWithFileName:(NSString *)fileName;

@end
