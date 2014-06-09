//
//  JDAlbum.h
//  JDKaLa
//
//  Created by 韩 抗 on 13-5-22.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDAlbumItem.h"

@interface JDAlbum : NSObject <NSXMLParserDelegate>
{
    NSString *mFileName;
    NSMutableArray  *mItemList;
    JDAlbumItem     *mCurItem;
    NSString        *mCurProperty;
}

@property (readonly, nonatomic) NSMutableString* albumName;

- (id)initWithFileName:(NSString*)fileName;
- (int)count;
- (JDAlbumItem*)getItemAtIndex:(unsigned int)index;
@end
