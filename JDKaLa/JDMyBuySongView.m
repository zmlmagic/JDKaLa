//
//  JDMyBuySongView.m
//  JDKaLa
//
//  Created by zhangminglei on 9/22/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDMyBuySongView.h"
#import "JDMyOrderSongView.h"
#import "JDModel_tmp_manger.h"
#import "JDSqlDataBase.h"
//#import "SDMoviePlayerViewController.h"
#import "JDMoviePlayerViewController.h"
#import "JDModel_user.h"
#import "UIUtils.h"
#import "JDModel_userInfo.h"
#import "ClientAgent.h"
#import "JDAlreadySongView.h"

typedef enum
{
    JDCellButtonTag_songName         = 10,
    JDCellButtonTag_singerName           ,
    JDCellButtonTag_background           ,
    JDCellButtonTag_pay                  ,
    JDCellButtonTag_play                 ,
    JDCellButtonTag_list                 ,
    JDCellButtonTag_favorite             ,
}JDCellButtonTag;

@implementation JDMyBuySongView

- (id)init
{
    self = [super init];
    if(self)
    {
        [self setFrame:CGRectMake(0, 50, 1024, 718)];
        [self configureView_tableView];
    }
    return self;
}

- (void)dealloc
{
    [_selectCell release], _selectCell = nil;
    [_array_data release], _array_data = nil;
    [super dealloc];
}

- (void)configureView_tableView
{
    JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
    self.array_data = [base reciveSongArrayWithTag:0];
    [base release];
    if([_array_data count] != 0)
    {
        UITableView *tableView_songShow = [[UITableView alloc] initWithFrame:CGRectMake(0, 7, 1024, 691)];
        IOS7(tableView_songShow);
        [tableView_songShow setTag:800];
        [tableView_songShow setBackgroundColor:[UIColor clearColor]];
        [tableView_songShow setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [tableView_songShow setDataSource:self];
        [tableView_songShow setDelegate:self];
        [self addSubview:tableView_songShow];
        [tableView_songShow release];
    }
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_array_data count];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85.0f;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SingerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor clearColor]];
        [self installCell:cell withIndex:indexPath.row];
    }
    SDSongs *song = [_array_data objectAtIndex:indexPath.row];
    [self installCell:cell withSong:song];
    return cell;
}

- (void)installCell:(UITableViewCell *)cell withIndex:(NSInteger)index
{
    SDSongs *song = [_array_data objectAtIndex:index];
    UIButton *button_background = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_background setFrame:CGRectMake(20, 5, 956, 75)];
    [UIUtils didLoadImageNotCached:@"songs_bar_bg.png" inButton:button_background withState:UIControlStateNormal];
    [button_background setTag:JDCellButtonTag_background];
    [button_background addTarget:self action:@selector(didClickButton_cell:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:button_background];
    
    UILabel *label_songName = [[UILabel alloc] initWithFrame:CGRectMake(120, 14, 430, 45)];
    [label_songName setBackgroundColor:[UIColor clearColor]];
    [label_songName setFont:[UIFont systemFontOfSize:25.0]];
    [label_songName setTextColor:[UIColor whiteColor]];
    [label_songName setTag:JDCellButtonTag_songName];
    [button_background addSubview:label_songName];
    [label_songName release];
    
    UIImageView *imageView_pay = [[UIImageView alloc] initWithFrame:CGRectMake(20, 26, 62, 22)];
    [imageView_pay setTag:JDCellButtonTag_pay];
    [button_background addSubview:imageView_pay];
    [imageView_pay release];
    
    UILabel *label_singer = [[UILabel alloc] initWithFrame:CGRectMake(530, 14, 120, 45)];
    [label_singer setBackgroundColor:[UIColor clearColor]];
    [label_singer setTextColor:[UIColor whiteColor]];
    [label_singer setTag:JDCellButtonTag_singerName];
    [label_singer setFont:[UIFont systemFontOfSize:25.0f]];
    [button_background addSubview:label_singer];
    [label_singer release];
    
    UIButton *button_play = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_play setFrame:CGRectMake(725, 10, 50, 50)];
    [UIUtils didLoadImageNotCached:@"songs_bar_btn_play.png" inButton:button_play withState:UIControlStateNormal];
    [button_play setTag:JDCellButtonTag_play];
    [button_play addTarget:self action:@selector(didClickButton_cell:) forControlEvents:UIControlEventTouchUpInside];
    [button_background addSubview:button_play];
    
    UIButton *button_list = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_list setFrame:CGRectMake(800, 10, 50, 50)];
    if(song.songOrderTag == 1)
    {
        [UIUtils didLoadImageNotCached:@"songs_bar_btn_list.png" inButton:button_list withState:UIControlStateNormal];
    }
    else
    {
        [UIUtils didLoadImageNotCached:@"songs_bar_btn_list_added_new.png" inButton:button_list withState:UIControlStateNormal];
    }
    [UIUtils didLoadImageNotCached:@"player_list_thumbnail_btn_delete.png" inButton:button_list withState:UIControlStateNormal];
    [button_list setTag:JDCellButtonTag_list];
    [button_list addTarget:self action:@selector(didClickButton_cell:) forControlEvents:UIControlEventTouchUpInside];
    [button_background addSubview:button_list];
    
    
    UIButton *button_favorite = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_favorite setFrame:CGRectMake(875, 10, 50, 50)];
    if(song.songFavoriteTag == 1)
    {
        [UIUtils didLoadImageNotCached:@"songs_bar_btn_favor_added.png" inButton:button_favorite withState:UIControlStateNormal];
    }
    else
    {
        [UIUtils didLoadImageNotCached:@"songs_bar_btn_favor.png" inButton:button_favorite withState:UIControlStateNormal];
    }
    [button_favorite setTag:JDCellButtonTag_favorite];
    [button_favorite addTarget:self action:@selector(didClickButton_cell:) forControlEvents:UIControlEventTouchUpInside];
    [button_background addSubview:button_favorite];
}

- (void)didClickButton_cell:(id)sender
{
    UIButton *button_singer = (UIButton *)sender;
    UITableViewCell *cell = [self reciveSuperCellWithView:button_singer];
    UITableView *tableView = [self reciveSuperTableWithView:cell];
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    SDSongs *song = [_array_data objectAtIndex:indexPath.row];
    
    switch (button_singer.tag)
    {
        case JDCellButtonTag_background:
        {
            self.song_buy = song;
            self.selectCell = cell;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleGetPermission:)
                                                         name:NOTI_GET_PERMISSION_RESULT
                                                       object:nil];
            
            ClientAgent *agent = [[ClientAgent alloc] init];
            [agent getPermission:_song_buy.songMd5 UserID:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
            
        }break;
            
        case JDCellButtonTag_play:
        {
            self.song_buy = song;
            self.selectCell = cell;
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleGetPermission:)
                                                         name:NOTI_GET_PERMISSION_RESULT
                                                       object:nil];
            
            ClientAgent *agent = [[ClientAgent alloc] init];
            [agent getPermission:_song_buy.songMd5 UserID:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
            
        }break;
            
        case JDCellButtonTag_list:
        {
            JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
            [base selectSongandChangeItTag:song];
            if(song.songOrderTag == 1)
            {
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(reloadTableView:)
                                                             name:@"JDSongStateChange_favorite"
                                                           object:nil];
                
                
                [UIUtils didLoadImageNotCached:@"songs_bar_btn_list_added_new.png" inButton:button_singer withState:UIControlStateNormal];
                [base deleteSongFormLocalSingerWithString:song withTag:1];
                [UIUtils view_showProgressHUD:@"已移出播放列表" inView:self withTime:1.0f];
                
                
            }
            else
            {
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(reloadTableView:)
                                                             name:@"JDSongStateChange_favorite"
                                                           object:nil];
                
                song.songOrderTag = 1;
                if([base saveSong:song withTag:2])
                {
                    [UIUtils didLoadImageNotCached:@"songs_bar_btn_list.png" inButton:button_singer withState:UIControlStateNormal];
                    [UIUtils view_showProgressHUD:@"已添加至播放列表" inView:self withTime:1.0f];
                }
            }
            [base release];
            
        }break;
            
        case JDCellButtonTag_favorite:
        {
            JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
            [base selectSongandChangeItTag:song];
            if(song.songFavoriteTag == 1)
            {
                [UIUtils didLoadImageNotCached:@"songs_bar_btn_favor.png" inButton:button_singer withState:UIControlStateNormal];
                [base deleteSongFormLocalSingerWithString:song withTag:1];
                [UIUtils view_showProgressHUD:@"已移出收藏列表" inView:self withTime:1.0f];
                
            }
            else
            {
                song.songFavoriteTag = 1;
                if([base saveSong:song withTag:1])
                {
                    [UIUtils didLoadImageNotCached:@"songs_bar_btn_favor_added.png" inButton:button_singer withState:UIControlStateNormal];
                    [UIUtils view_showProgressHUD:@"已添加至收藏列表" inView:self withTime:1.0f];
                }
            }
            [base release];
            
        }break;
        default:
            break;
    }
}

#pragma mark - 播放前鉴权回调 -
/**
 * 播放前鉴权回调
 */
- (void)handleGetPermission:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    if([[state objectForKey:@"result"] length] > 0 && 0 == resultCode)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NOTI_GET_PERMISSION_RESULT
                                                      object:nil];
        
        JDMoviePlayerViewController *movePlayer = [[JDMoviePlayerViewController alloc] initWithSong:_song_buy];
        [movePlayer setBool_isHistoryOrSearchSong:YES];
        [movePlayer.view_alreadySong setBool_currentAlready:NO];
        movePlayer.navigationController_return = _navigationController_return;
        [_navigationController_return pushViewController:movePlayer animated:YES];
        [movePlayer playBegin];
        [movePlayer release];
        
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NOTI_GET_PERMISSION_RESULT
                                                      object:nil];
    }
}




- (UITableViewCell *)reciveSuperCellWithView:(UIView *)view
{
    for (UIView *next = [view superview]; next; next = next.superview)
    {
        if ([next isKindOfClass:[UITableViewCell class]])
        {
            return (UITableViewCell *)next;
        }
    }
    return nil;
}

- (UITableView *)reciveSuperTableWithView:(UIView *)view
{
    for (UIView *next = [view superview]; next; next = next.superview)
    {
        if ([next isKindOfClass:[UITableView class]])
        {
            return (UITableView *)next;
        }
    }
    return nil;
}

- (UIView *)reciveSuperViewWithButton:(UIButton *)button
{
    for (UIView *next = [button superview]; next; next = next.superview)
    {
        if ([next isKindOfClass:[UIView class]])
        {
            return (UIView *)next;
        }
    }
    return nil;
}

- (UIView *)reciveSuperViewWithView:(UIView *)view
{
    for (UIView *next = [view superview]; next; next = next.superview)
    {
        if ([next isKindOfClass:[UIView class]])
        {
            return (UIView *)next;
        }
    }
    return nil;
}

- (UIViewController *)reciveSuperViewControllerWithView:(UIView *)view
{
    for (UIView *next = [view superview]; next; next = next.superview)
    {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (void)installCell:(UITableViewCell *)cell withSong:(SDSongs *)song
{
    UILabel *label_songName = (UILabel *)[cell viewWithTag:JDCellButtonTag_songName];
    [label_songName setText:song.songTitle];
    
    UILabel *label_singerName = (UILabel *)[cell viewWithTag:JDCellButtonTag_singerName];
    [label_singerName setText:song.songSingers];
    
    if(_song_buy.int_price == 0)
    {
        UIImageView *imageView_pay = (UIImageView *)[cell viewWithTag:JDCellButtonTag_pay];
        [UIUtils didLoadImageNotCached:@"songs_icon_paid.png" inImageView:imageView_pay];
    }
    else
    {
        UIImageView *imageView_pay = (UIImageView *)[cell viewWithTag:JDCellButtonTag_pay];
        [UIUtils didLoadImageNotCached:nil inImageView:imageView_pay];
    }
}

- (void)reloadTableView:(NSNotification *)note
{
    [self.array_data removeAllObjects];
    JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
    self.array_data = [base reciveSongArrayWithTag:2];
    [base release];
    
    NSInteger count = [(NSString *)[note object] integerValue];
    if(count == 1)
    {
        UITableView *tableView_already = (UITableView *)[self viewWithTag:800];
        [tableView_already reloadData];
    }
    else
    {
        UITableView *tableView_already = (UITableView *)[self viewWithTag:800];
        [tableView_already deleteRowsAtIndexPaths:[NSArray arrayWithObject:_delectCellId] withRowAnimation:UITableViewRowAnimationLeft];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"JDSongStateChange_order"
                                                  object:nil];
    
}


@end
