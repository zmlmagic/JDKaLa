//
//  JDAlbum.m
//  JDKaLa
//
//  Created by 韩 抗 on 13-5-22.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import "JDAlbum.h"

@implementation JDAlbum

#pragma mark init and dealloc
- (id)initWithFileName:(NSString *)fileName
{
    self = [super init];
    
    if(self != nil)
    {
        
        if(fileName != nil)
        {
            mFileName = [[NSString alloc]initWithString:fileName];
            [self parse];
        }
        else
            mFileName = nil;
    }
    
    return self;
}

- (id)init
{
    return [self initWithFileName:nil];
}

- (void)dealloc
{
    [mFileName release];
    [mItemList release];
    [_albumName release];
    [super dealloc];
}

- (BOOL)parse
{
    BOOL    rtn = NO;
    
    if(nil == mFileName)
        return NO;
    
    if(mItemList != nil)
    {
        [mItemList release];
        mItemList = nil;
    }
    
    mItemList = [[NSMutableArray alloc] init];
    
    NSURL       *url;
    
    //如果以"http://"或"https://"开头，则按照URL处理，否则按照本地文件处理
    if([mFileName hasPrefix:@"http://"] || [mFileName hasPrefix:@"https://"])
    {
        url = [NSURL URLWithString:mFileName];
    }
    else
    {
        url = [NSURL fileURLWithPath:mFileName];
    }
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    
    [parser setDelegate:self];
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    NSError *parseError = [parser parserError];
    if(!parseError)
    {
        rtn = YES;
    }
    [parser release];
    return rtn;
}

#pragma mark NSXMLParser delegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    // 元素开始句柄
    if (qName) {
        elementName = qName;
    }

    if ([elementName isEqualToString:@"item"])
    {
        // 输出属性值
        //NSLog(@"Name is %@ , Age is %@", [attributeDict objectForKey:@"name"], [attributeDict objectForKey:@"age"]);
        mCurItem = [[JDAlbumItem alloc]init];
    }
    else if([elementName isEqualToString:@"album_name"])
    {
        [_albumName release];
        _albumName = [[NSMutableString alloc] init];
        mCurProperty = [[NSString alloc] initWithString:elementName];
    }
    else
    {
        mCurProperty = [[NSString alloc] initWithString:elementName];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // 元素终了句柄
    if (qName)
    {
        elementName = qName;
    }
    
    if ([elementName isEqualToString:@"item"])
    {
        [mItemList addObject:mCurItem];
        [mCurItem release];
    }
    else
    {
        if(mCurProperty != nil)
        {
            [mCurProperty release];
            mCurProperty = nil;
        }
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    // 取得元素的text
    NSString *value = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([mCurProperty isEqualToString:@"title"])
    {
        [mCurItem setTitle:value];
    }
    else if([mCurProperty isEqualToString:@"md5"])
    {
        [mCurItem setMd5:value];
    }
    else if([mCurProperty isEqualToString:@"album_name"])
    {
        [_albumName appendString:value];
    }
}

#pragma mark methods

/**
 * 返回歌曲数量
 */
- (int)count
{
    return mItemList == nil ? 0 : [mItemList count];
}

/**
 * 返回指定序号的歌曲Item
 */
- (JDAlbumItem*)getItemAtIndex:(unsigned int)index
{
    if(mItemList != nil && index < [mItemList count])
    {
        return [mItemList objectAtIndex:index];
    }
    else
    {
        return nil;
    }
}

@end
