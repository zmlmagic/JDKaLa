//
//  JDThemeXMLPaser.m
//  JDKaLa
//
//  Created by zhangminglei on 9/9/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDThemeXMLPaser.h"
#import "JDModel_theme.h"
#import "SDSongs.h"

@implementation JDThemeXMLPaser

- (id)initWithFileName:(NSString *)fileName
{
    self = [super init];
    if(self != nil)
    {
        if(fileName != nil)
        {
            self.model_theme = [[[JDModel_theme alloc] init] autorelease];
            [self parseWithString:fileName];
        }
    }
    return self;
}

- (void)dealloc
{
    [_model_theme release], _model_theme = nil;
    [_mCurProperty release], _mCurProperty = nil;
    [super dealloc];
}

- (BOOL)parseWithString:(NSString *)fileName
{
    BOOL  rtn = NO;
    if(nil == fileName)
        return NO;
    NSURL  *url;
    //如果以"http://"或"https://"开头，则按照URL处理，否则按照本地文件处理
    if([fileName hasPrefix:@"http://"] || [fileName hasPrefix:@"https://"])
    {
        url = [NSURL URLWithString:fileName];
    }
    else
    {
        url = [NSURL fileURLWithPath:fileName];
    }
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    NSMutableArray *array_songs = [NSMutableArray arrayWithCapacity:0];
    self.model_theme.array_song = array_songs;
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
        self.song = [[SDSongs alloc] init];
        // 输出属性值
        //NSLog(@"Name is %@ , Age is %@", [attributeDict objectForKey:@"name"], [attributeDict objectForKey:@"age"]);
        //mCurItem = [[JDAlbumItem alloc]init];
    }
    else if([elementName isEqualToString:@"albumName"])
    {
        //[_albumName release];
        //_albumName = [[NSMutableString alloc] init];
        self.mCurProperty = [NSString stringWithString:elementName];
        //mCurProperty = [[NSString alloc] initWithString:elementName];
    }
    else
    {
        self.mCurProperty = [NSString stringWithString:elementName];
        //mCurProperty = [[NSString alloc] initWithString:elementName];
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
        
        [_model_theme.array_song addObject:_song];
        //[_song release];
    }
    else
    {
        if(_mCurProperty != nil)
        {
            [_mCurProperty release];
            _mCurProperty = nil;
        }
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    // 取得元素的text
    NSString *value = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([_mCurProperty isEqualToString:@"title"])
    {
        _song.songTitle = value;
    }
    else if([_mCurProperty isEqualToString:@"md5"])
    {
        _song.songMd5 = value;
    }
    else if([_mCurProperty isEqualToString:@"albumName"])
    {
        _model_theme.string_title = value;
    }
    else if([_mCurProperty isEqualToString:@"imageUrl"])
    {
        _model_theme.string_imageTheme = value;
    }
    else if([_mCurProperty isEqualToString:@"comment"])
    {
        if([_model_theme.string_themeDetail length] != 0)
        {
            _model_theme.string_themeDetail = [_model_theme.string_themeDetail stringByAppendingString:value];
        }
        else
        {
            _model_theme.string_themeDetail = value;
        }
    }
}


@end
