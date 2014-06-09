//
//  JDSearchTableView.m
//  JDKaLa
//
//  Created by zhangminglei on 5/28/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDSearchTableView.h"
#import "JDSqlDataBase.h"
#import "UIUtils.h"
#import "MBProgressHUD.h"
#import "SDSingers.h"
#import "UIImageView+WebCache.h"
#import "CustomAlertView.h"
#import "JDMoviePlayerViewController.h"
#import "JDAlreadySongView.h"

#define JDLINKPHOTO @"http://ep.iktv.tv/api/kod/singers/"
#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

typedef enum
{
    JDSearchTableCellTag_song     = 20,
    JDSearchTableCellTag_portrait     ,
    JDSearchTableCellTag_singer       ,
    JDSearchTableCellTag_background   ,
    JDSearchTableCellTag_row          ,
}JDSearchTableCellTag;


@implementation JDSearchTableView

- (id)init
{
    self = [super init];
    if(self)
    {
        [self setFrame:CGRectMake(755, 39, 250, 572)];
        self.bool_isOpen = NO;
        //self.array_search_singer = [NSMutableArray arrayWithCapacity:10];
        //[self setBackgroundColor:RGB(159.0f, 163.0f, 168.0f)];
    }
    return self;
}

- (void)dealloc
{
    [_array_search_song release], _array_search_song = nil;
    [_array_search_singer_song release], _array_search_singer_song = nil;
    [_array_search_singer release], _array_search_singer = nil;
    [_selectIndex release], _selectIndex = nil;
    [super dealloc];
}

#pragma mark - 
#pragma mark ConfigureView
- (void)configureView_table
{
    /*CGFloat height;
    if([_array_search_singer count] == 0)
    {
        height = [_array_search_song count] * 52.0;
    }
    else
    {
        height = 572.0;
    }*/
    CGFloat height = ([_array_search_singer count]) * 60.0 + [_array_search_song count]* 52.0;
    if(height > 572.0)
    {
        height = 572.0f;
    }
    //CGFloat height = 572.0f;
    UITableView *table_search = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 250, height) style:UITableViewStylePlain];
    [table_search setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [table_search setBackgroundColor:RGB(159.0f, 163.0f, 168.0f)];
    [table_search setDataSource:self];
    [table_search setDelegate:self];
    [self addSubview:table_search];
    [table_search release];
    
    _table_search = table_search;
}

- (void)searchSongWithString:(NSString*)tag
{
    NSString *escapeTag = [tag stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *sql = [NSString stringWithFormat:
                     @"select * from client_songs where tags like '%@%%' and media_type is not null order by tags", escapeTag];
    
    NSString *sql_china = [NSString stringWithFormat:@"select * from client_songs where title like '%@%%' and media_type is not null order by tags", escapeTag];
    
    self.array_search_singer = [self searchSingerWithTag:tag];
    
    self.array_search_song = [self querySongWithSQL:sql];
    NSMutableArray *array_china = [self querySongWithSQL:sql_china];
    
    [self.array_search_song addObjectsFromArray:array_china];
    //[self.array_search_data addObjectsFromArray:self.array_search];
    
    [self configureView_table];
}

/**搜人名**/
- (NSMutableArray*)searchSingerWithTag:(NSString*)tag
{
    NSString *sql = [NSString stringWithFormat:
                     @"select * from client_singers where tags like '%@%%' or tags like '#%@%%' order by tags", tag, tag];
    NSString *sql_china = [NSString stringWithFormat:
                           @"select * from client_singers where name like '%@%%'",tag];
    
    NSMutableArray *resultArray = [self querySingerWithSQL:sql];
    NSMutableArray *arrayChina = [self querySingerWithSQL:sql_china];
    
    [resultArray addObjectsFromArray:arrayChina];
    
    return resultArray;
}

- (NSMutableArray *)querySongBySinger:(NSString *)_string
{
    NSString *escapeTag = [_string stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *sql = [NSString stringWithFormat:@"select * from client_songs where singers_no like '%%%%%@%%%%'", escapeTag];
    NSMutableArray *resultArray = [self querySongWithSQL:sql];
    return resultArray;
}


- (NSMutableArray *)querySingerWithSQL:(NSString *)string
{
    JDSqlDataBase *dataController = [[JDSqlDataBase alloc] init];
    NSMutableArray *singerArray = [dataController reciveDataBaseWithStringFromSinger:string];
    [dataController release];
    return singerArray;
}

- (NSMutableArray *)querySongWithSQL:(NSString *)string
{
    JDSqlDataBase *dataController = [[JDSqlDataBase alloc] init];
    NSMutableArray *songArray = [dataController reciveDataBaseWithString:string];
    [dataController selectSongandChangeItTagWithArray:songArray];
    [dataController release];
    return songArray;
}

#pragma mark - 
#pragma mark UITableView
#pragma mark - 
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return 1;
    return 1 + [_array_search_singer count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.bool_isOpen)
    {
        if(section < [self.array_search_singer count])
        {
            if (self.selectIndex.section == section)
            {
                return [self.array_search_singer_song count] + 1;
            }
            else
            {
                return 1;
            }
        }
        else
        {
            return [_array_search_song count];
        }
    }
    else
    {
        if(section < [self.array_search_singer count])
        {
            return 1;
        }
        else
        {
            return [_array_search_song count];
        }
    }
    //return [self.array_search count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section<[_array_search_singer count])
    {
        if (self.bool_isOpen && self.selectIndex.section == indexPath.section && indexPath.row!=0)
        {
            static NSString *CellIdentifier = @"CellSearchSingerSong";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] init] autorelease];
                //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                [self installTableCell:cell withIndex:indexPath.row];
            }
            SDSongs *song = [self.array_search_singer_song objectAtIndex:indexPath.row -1];
            [self useSong:song loadChildCell:cell withIndex:indexPath.row];
            //[cell.contentView setBackgroundColor:[UIColor clearColor]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
        if(indexPath.row == 0)
        {
            static NSString *CellIdentifier = @"CellSearchSinger";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] init] autorelease];
                //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                [self installTableSingerCell:cell withIndex:indexPath.row];
            }
            SDSingers *singer = [_array_search_singer objectAtIndex:indexPath.section];
            [self useSong:singer loadSingerCell:cell withIndex:indexPath.row];
            //[cell.contentView setBackgroundColor:[UIColor clearColor]];
            //[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            return cell;
        }
    }
    else
    {
        static NSString *CellIdentifier = @"CellSearchSong";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] init] autorelease];
            //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            [self installTableCell:cell withIndex:indexPath.row];
        }
        SDSongs *song = [_array_search_song objectAtIndex:indexPath.row];
        [self useSong:song loadCell:cell withIndex:indexPath.row];
        //[cell.contentView setBackgroundColor:[UIColor clearColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    return nil;
}

- (void)installTableCell:(UITableViewCell *)cell withIndex:(NSInteger)index
{
    UIImageView *imageView_back = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 250, 52)];
    [imageView_back setTag:JDSearchTableCellTag_background];
    [cell addSubview:imageView_back];
    [imageView_back release];
    
    UILabel *label_song = [[UILabel alloc] initWithFrame:CGRectMake(30, 11, 150, 30)];
    [label_song setBackgroundColor:[UIColor clearColor]];
    [label_song setTextColor:[UIColor grayColor]];
    [label_song setNumberOfLines:2];
    [label_song setFont:[UIFont systemFontOfSize:15.0f]];
    [label_song setTag:JDSearchTableCellTag_song];
    [cell addSubview:label_song];
    [label_song release];
    
    UILabel *label_singer = [[UILabel alloc] initWithFrame:CGRectMake(190, 4, 60, 50)];
    [label_singer setNumberOfLines:2];
    [label_singer setBackgroundColor:[UIColor clearColor]];
    [label_singer setTextColor:[UIColor grayColor]];
    [label_singer setFont:[UIFont systemFontOfSize:13.0f]];
    [label_singer setTag:JDSearchTableCellTag_singer];
    [cell addSubview:label_singer];
    [label_singer release];
}

- (void)installTableSingerCell:(UITableViewCell *)cell withIndex:(NSInteger)index
{
    UIImageView *imageView_back = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 250, 60)];
    [imageView_back setTag:JDSearchTableCellTag_background];
    [cell addSubview:imageView_back];
    [imageView_back release];
    
    UIImageView *imageView_portrait = [[UIImageView alloc] initWithFrame:CGRectMake(5, 7, 45, 45)];
    [imageView_portrait setTag:JDSearchTableCellTag_portrait];
    [imageView_portrait setContentMode:UIViewContentModeScaleAspectFit];
    [cell addSubview:imageView_portrait];
    [imageView_portrait release];
    
    UILabel *label_song = [[UILabel alloc] initWithFrame:CGRectMake(55, 7, 150, 20)];
    [label_song setBackgroundColor:[UIColor clearColor]];
    [label_song setTextColor:[UIColor grayColor]];
    [label_song setText:@"歌手"];
    [label_song setFont:[UIFont systemFontOfSize:13.0f]];
    [cell addSubview:label_song];
    [label_song release];
    
    UILabel *label_singer = [[UILabel alloc] initWithFrame:CGRectMake(55, 28, 190, 30)];
    [label_singer setBackgroundColor:[UIColor clearColor]];
    [label_singer setTextColor:[UIColor grayColor]];
    [label_singer setFont:[UIFont systemFontOfSize:15.0f]];
    [label_singer setTag:JDSearchTableCellTag_singer];
    [cell addSubview:label_singer];
    [label_singer release];
    
    UIImageView *imageView_row = [[UIImageView alloc] initWithFrame:CGRectMake(210, 17, 26, 26)];
    [UIUtils didLoadImageNotCached:@"menu_bar_arrow_up.png" inImageView:imageView_row];
    [imageView_row setTag:JDSearchTableCellTag_row];
    [cell addSubview:imageView_row];
    [imageView_row release];
}


- (void)useSong:(SDSongs *)song loadCell:(UITableViewCell *)cell withIndex:(NSInteger)index
{
    UIImageView *imageView_back = (UIImageView *)[cell viewWithTag:JDSearchTableCellTag_background];
    NSInteger remainder = index%2;
    if(remainder == 0)
    {
        [UIUtils didLoadImageNotCached:@"player_search_bar_level3_bg_02.png" inImageView:imageView_back];
    }
    else
    {
        [UIUtils didLoadImageNotCached:@"player_search_bar_level3_bg_01.png" inImageView:imageView_back];
    }
    UILabel *label_song = (UILabel *)[cell viewWithTag:JDSearchTableCellTag_song];
    [label_song setText:song.songTitle];
    UILabel *label_singer = (UILabel *)[cell viewWithTag:JDSearchTableCellTag_singer];
    [label_singer setText:song.songSingers];
}

- (void)useSong:(SDSongs *)song loadChildCell:(UITableViewCell *)cell withIndex:(NSInteger)index
{
    UIImageView *imageView_back = (UIImageView *)[cell viewWithTag:JDSearchTableCellTag_background];
    if(index == 1)
    {
        [UIUtils didLoadImageNotCached:@"sub_menu_bar_bg_top.png" inImageView:imageView_back];
    }
    else
    {
        [UIUtils didLoadImageNotCached:@"sub_menu_bar_bg.png" inImageView:imageView_back];
    }
    UILabel *label_song = (UILabel *)[cell viewWithTag:JDSearchTableCellTag_song];
    [label_song setText:song.songTitle];
    [label_song setTextColor:[UIColor whiteColor]];
    UILabel *label_singer = (UILabel *)[cell viewWithTag:JDSearchTableCellTag_singer];
    [label_singer setTextColor:[UIColor whiteColor]];
    [label_singer setText:song.songSingers];
}

- (void)useSong:(SDSingers *)singer loadSingerCell:(UITableViewCell *)cell withIndex:(NSInteger)index
{
    UIImageView *imageView_back = (UIImageView *)[cell viewWithTag:JDSearchTableCellTag_background];
    [UIUtils didLoadImageNotCached:@"menu_bar_bg.png" inImageView:imageView_back];
    UILabel *label_singer = (UILabel *)[cell viewWithTag:JDSearchTableCellTag_singer];
    [label_singer setText:singer.singerName];
    
    UIImageView *imageView_portrait = (UIImageView *)[cell viewWithTag:JDSearchTableCellTag_portrait];
    [imageView_portrait setImageWithURL:[NSURL URLWithString:singer.string_portrait]];
    //UILabel *label_singer = (UILabel *)[cell viewWithTag:JDSearchTableCellTag_singer];
    //[label_singer setText:song.songSingers];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section<[_array_search_singer count])
    {
        if(indexPath.row == 0)
        {
            return 60.0f;
        }
        else
        {
            return 52.0f;
        }
    }
    else
    {
        return 52.0f;
    }
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section < [_array_search_singer count])
    {
        if(indexPath.row == 0)
        {
            if(_bool_isOpen)
            {
                if(self.selectIndex.section == indexPath.section)
                {
                    [self didSelectCellRowFirstDo:NO nextDo:YES];
                }
                else
                {
                    [self didSelectCellRowFirstDo:NO nextDo:YES];
                    
                    SDSingers *singer = [_array_search_singer objectAtIndex:indexPath.section];
                    NSString *string_sql = singer.singerNo;
                    self.array_search_singer_song = nil;
                    self.array_search_singer_song = [self querySongBySinger:string_sql];
                    self.selectIndex = indexPath;
                    [self didSelectCellRowFirstDo:YES nextDo:NO];
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                }
            }
            else
            {
                SDSingers *singer = [_array_search_singer objectAtIndex:indexPath.section];
                NSString *string_sql = singer.singerNo;
                self.array_search_singer_song = nil;
                self.array_search_singer_song = [self querySongBySinger:string_sql];
                
                self.selectIndex = indexPath;
                [self didSelectCellRowFirstDo:YES nextDo:NO];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
        else
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if(cell.tag == 0)
            {
                UIView *view_animation = [[UIView alloc] initWithFrame:CGRectMake(-294, 0, 294, 52)];
                [view_animation setBackgroundColor:[UIColor clearColor]];
                [cell addSubview:view_animation];
                [view_animation release];
                
                UIImageView *imageView_background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 245, 52)];
                [UIUtils didLoadImageNotCached:@"Untitled-2_03.png" inImageView:imageView_background];
                [view_animation addSubview:imageView_background];
                [imageView_background release];
                
                UIButton *button_play = [UIButton buttonWithType:UIButtonTypeCustom];
                [button_play setFrame:CGRectMake(10, 10, 33, 33)];
                [UIUtils didLoadImageNotCached:@"Untitled-2_03-02.png" inButton:button_play withState:UIControlStateNormal];
                [button_play addTarget:self action:@selector(didClickSearchChildCellButton_play:) forControlEvents:UIControlEventTouchUpInside];
                [button_play setTag:indexPath.row];
                [view_animation addSubview:button_play];
                
                UIButton *button_add = [UIButton buttonWithType:UIButtonTypeCustom];
                [button_add setFrame:CGRectMake(53, 10, 42, 33)];
                
                SDSongs *song = [_array_search_singer_song objectAtIndex:indexPath.row - 1];
                
                if(song.songOrderTag == 1)
                {
                    [UIUtils didLoadImageNotCached:@"Untitled-2_10.png" inButton:button_add withState:UIControlStateNormal];
                }
                else
                {
                    [UIUtils didLoadImageNotCached:@"Untitled-2_10-03.png" inButton:button_add withState:UIControlStateNormal];
                }
                
                [button_add addTarget:self action:@selector(didClickSearchChildCellButton_add:) forControlEvents:UIControlEventTouchUpInside];
                [button_add setTag:indexPath.row + 5];
                [view_animation addSubview:button_add];
                
                UIButton *button_back = [UIButton buttonWithType:UIButtonTypeCustom];
                [button_back setFrame:CGRectMake(180, 10, 42, 33)];
                [UIUtils didLoadImageNotCached:@"back.png" inButton:button_back withState:UIControlStateNormal];
                [button_back addTarget:self action:@selector(didClickSearchCellButton_back:) forControlEvents:UIControlEventTouchUpInside];
                [view_animation addSubview:button_back];
                [self cellViewAddWithAnimation:view_animation];
                [cell setTag:10];
            }
        }
    }
    else
    {
        //[tableView  deselectRowAtIndexPath:indexPath animated:NO];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if(cell.tag == 0)
        {
            UIView *view_animation = [[UIView alloc] initWithFrame:CGRectMake(-294, 0, 294, 52)];
            [view_animation setBackgroundColor:[UIColor clearColor]];
            [cell addSubview:view_animation];
            [view_animation release];
            
            UIImageView *imageView_background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 245, 52)];
            [UIUtils didLoadImageNotCached:@"Untitled-2_03.png" inImageView:imageView_background];
            [view_animation addSubview:imageView_background];
            [imageView_background release];
            
            UIButton *button_play = [UIButton buttonWithType:UIButtonTypeCustom];
            [button_play setFrame:CGRectMake(10, 10, 33, 33)];
            [UIUtils didLoadImageNotCached:@"Untitled-2_03-02.png" inButton:button_play withState:UIControlStateNormal];
            [button_play addTarget:self action:@selector(didClickSearchCellButton_play:) forControlEvents:UIControlEventTouchUpInside];
            [button_play setTag:indexPath.row];
            [view_animation addSubview:button_play];
            
            UIButton *button_add = [UIButton buttonWithType:UIButtonTypeCustom];
            [button_add setFrame:CGRectMake(53, 10, 42, 33)];
            
            SDSongs *song = [_array_search_song objectAtIndex:indexPath.row];
            
            if(song.songOrderTag == 1)
            {
                [UIUtils didLoadImageNotCached:@"Untitled-2_10.png" inButton:button_add withState:UIControlStateNormal];
            }
            else
            {
                [UIUtils didLoadImageNotCached:@"Untitled-2_10-03.png" inButton:button_add withState:UIControlStateNormal];
            }
            
            [button_add addTarget:self action:@selector(didClickSearchCellButton_add:) forControlEvents:UIControlEventTouchUpInside];
            [button_add setTag:indexPath.row + 5];
            [view_animation addSubview:button_add];
            
            UIButton *button_back = [UIButton buttonWithType:UIButtonTypeCustom];
            [button_back setFrame:CGRectMake(180, 10, 42, 33)];
            [UIUtils didLoadImageNotCached:@"back.png" inButton:button_back withState:UIControlStateNormal];
            [button_back addTarget:self action:@selector(didClickSearchCellButton_back:) forControlEvents:UIControlEventTouchUpInside];
            [view_animation addSubview:button_back];
            [self cellViewAddWithAnimation:view_animation];
            [cell setTag:10];
        }
    }
}

- (void)didSelectCellRowFirstDo:(BOOL)firstDoInsert nextDo:(BOOL)nextDoInsert
{
    self.bool_isOpen = firstDoInsert;
    
    UITableViewCell *cell = (UITableViewCell *)[_table_search cellForRowAtIndexPath:self.selectIndex];
    [self changArrowWithUpInCell:cell withBool:firstDoInsert];
    
    [self.table_search beginUpdates];
    int section = self.selectIndex.section;
    int contentCount = [_array_search_singer_song count];
	NSMutableArray* rowToInsert = [[NSMutableArray alloc] init];
	for (NSUInteger i = 1; i < contentCount + 1; i++)
    {
		NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:i inSection:section];
		[rowToInsert addObject:indexPathToInsert];
	}
    
	if (firstDoInsert)
    {   [_table_search insertRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
	else
    {
        [_table_search deleteRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
	[rowToInsert release];
	
	[self.table_search endUpdates];
    
    /*if (nextDoInsert)
     {
     self.bool_isOpen = YES;
     self.selectIndex = [self.table_master indexPathForSelectedRow];
     [self didSelectCellRowFirstDo:YES nextDo:NO];
     }*/
    if (self.bool_isOpen)
    {
        [self.table_search scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)changArrowWithUpInCell:(UITableViewCell *)_cell withBool:(BOOL)_bool
{
    if(_bool)
    {
        _float_height = _table_search.frame.size.height;
        [_table_search setFrame:CGRectMake(0, 0, 250, 572)];
        
        UIImageView *imageView = (UIImageView *)[_cell viewWithTag:JDSearchTableCellTag_row];
        [UIUtils didLoadImageNotCached:@"menu_bar_arrow_down.png" inImageView:imageView];
    }
    else
    {
        [_table_search setFrame:CGRectMake(0, 0, 250, _float_height)];
        UIImageView *imageView = (UIImageView *)[_cell viewWithTag:JDSearchTableCellTag_row];
        [UIUtils didLoadImageNotCached:@"menu_bar_arrow_up.png" inImageView:imageView];
    }
}


- (void)cellViewAddWithAnimation:(UIView *)view
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationRepeatCount:1];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [view setCenter:CGPointMake(147, 26)];
    [UIView commitAnimations];
}

- (void)cellViewRemoveWithAnimation:(UIView *)view
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationRepeatCount:1];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [view setCenter:CGPointMake(-147, 26)];
    [UIView commitAnimations];
    [self performSelector:@selector(removieFromCellView:) withObject:view afterDelay:1.0f];
}

- (void)removieFromCellView:(UIView *)view
{
    [view removeFromSuperview];
}

#pragma mark - 
#pragma mark DidClickButton
- (void)didClickSearchCellButton_play:(id)sender
{
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"token"])
    {
        CustomAlertView *alter = [[CustomAlertView alloc] initWithTitle:@"请先进行登陆" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alter show];
        [alter release];
        return;
    }
    
    _moviePlayer.view_alreadySong.bool_currentAlready = NO;
    if(_moviePlayer.bool_isHUD)
    {
        _moviePlayer.bool_isHUD = NO;
        [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayer_main.view animated:YES];
    }
    UIButton *button_play = (UIButton *)sender;
    SDSongs *song = [_array_search_song objectAtIndex:button_play.tag];
    [_moviePlayer setBool_isHistoryOrSearchSong:YES];
    [_moviePlayer changePlaySong:song];
    
    [_moviePlayer.view_searchView removeFromSuperview];
    _moviePlayer.view_searchView = nil;
}

- (void)didClickSearchChildCellButton_play:(id)sender
{
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"token"])
    {
        CustomAlertView *alter = [[CustomAlertView alloc] initWithTitle:@"请先进行登陆" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alter show];
        [alter release];
        return;
    }
    
    _moviePlayer.view_alreadySong.bool_currentAlready = NO;
    if(_moviePlayer.bool_isHUD)
    {
        _moviePlayer.bool_isHUD = NO;
        [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayer_main.view animated:YES];
    }
    UIButton *button_play = (UIButton *)sender;
    SDSongs *song = [_array_search_singer_song objectAtIndex:button_play.tag - 1];
    [_moviePlayer setBool_isHistoryOrSearchSong:YES];
    [_moviePlayer changePlaySong:song];
    
    [_moviePlayer.view_searchView removeFromSuperview];
    _moviePlayer.view_searchView = nil;
}



- (void)didClickSearchCellButton_add:(id)sender
{
    UIButton *button_add = (UIButton *)sender;
    [UIUtils didLoadImageNotCached:@"Untitled-2_10.png" inButton:button_add withState:UIControlStateNormal];
    SDSongs *song = [_array_search_song objectAtIndex:button_add.tag - 5];
    //song.songOrderTag = 1;
    JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
    //[base selectSongandChangeItTag:song];
  
    if(song.songOrderTag == 1)
    {
        [UIUtils view_showProgressHUD:@"已添加过该歌曲" inView:_moviePlayer.moviePlayer_main.view withTime:1.0f];
    }
    else
    {
        song.songOrderTag = 1;
        if([base saveSong:song withTag:2])
        {
            [UIUtils view_showProgressHUD:@"已添加至播放列表" inView: _moviePlayer.moviePlayer_main.view withTime:1.0f];
        }
    }
    [base release];
}

- (void)didClickSearchChildCellButton_add:(id)sender
{
    UIButton *button_add = (UIButton *)sender;
    [UIUtils didLoadImageNotCached:@"Untitled-2_10.png" inButton:button_add withState:UIControlStateNormal];
    SDSongs *song = [_array_search_singer_song objectAtIndex:button_add.tag - 6];
    //song.songOrderTag = 1;
    JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
    //[base selectSongandChangeItTag:song];
    
    //SDMoviePlayerViewController *moviePlay = [SDMoviePlayerViewController sharedController];
    
    if(song.songOrderTag == 1)
    {
        [UIUtils view_showProgressHUD:@"已添加过该歌曲" inView:_moviePlayer.moviePlayer_main.view withTime:1.0f];
    }
    else
    {
        song.songOrderTag = 1;
        if([base saveSong:song withTag:2])
        {
            [UIUtils view_showProgressHUD:@"已添加至播放列表" inView:_moviePlayer.moviePlayer_main.view withTime:1.0f];
        }
    }
    [base release];
}

- (void)didClickSearchCellButton_back:(id)sender
{
    UIButton *button_back = (UIButton *)sender;
    UIView *view_animation = [button_back superview];
    UITableViewCell *cell = (UITableViewCell *)[view_animation superview];
    [cell setTag:0];
    [self cellViewRemoveWithAnimation:view_animation];
}


@end
