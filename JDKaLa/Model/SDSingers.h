//
//  SDSingers.h
//  JuKaLa
//
//  Created by 张 明磊 on 9/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDSingers : NSObject

   
@property (assign, nonatomic) NSInteger singerId;
@property (retain, nonatomic) NSString *singerNo;
@property (retain, nonatomic) NSString *singerTags;
@property (retain, nonatomic) NSString *singerName;
@property (assign, nonatomic) NSInteger singerSex;
@property (assign, nonatomic) NSInteger singerArea;
@property (assign, nonatomic) NSInteger singerIs_hot;
@property (retain, nonatomic) NSString *singer_pingyin;

@property (retain, nonatomic) NSString *string_portrait;

@end
