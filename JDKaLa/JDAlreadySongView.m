//
//  JDAlreadySongView.m
//  JDKaLa
//
//  Created by zhangminglei on 5/22/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//
///Ipvd1234

#import "JDAlreadySongView.h"
#import "UIUtils.h"
#import "JDSqlDataBase.h"
#import "MBProgressHUD.h"
#import "JDMainViewController.h"
#import "JDSqlDataBaseSongHistory.h"
#import "JDCircleSlider.h"
#import "MediaProxyGlobal.h"
#import "CustomAlertView.h"
#import "JDMoviePlayerViewController.h"

#define DUMMY_CELL @"Dummy"

typedef enum
{
    JDAlreadySongCellTag_play      = 50,
    JDAlreadySongCellTag_playback      ,
    JDAlreadySongCellTag_singer        ,
    JDAlreadySongCellTag_song          ,
    JDAlreadySongCellTag_delete        ,
    JDAlreadySongCellTag_arrow         ,
    JDAlreadySongCellTag_circle        ,
}JDAlreadySongCellTag;

@implementation JDAlreadySongView

- (id)initWithMoviePlayer:(JDMoviePlayerViewController *)movePlayer
{
    self = [super init];
    if(self)
    {
        _moviePlayer = movePlayer;
        self.bool_kind = YES;
        [self setFrame:CGRectMake(755, 50, 269, 593)];
        [self setBackgroundColor:RGB(159.0f, 163.0f, 168.0f)];
    
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadTableView)
                                                     name:@"JDSongStateChange_order"
                                                   object:nil];
       
    }
    MediaProxy *media = [[MediaProxy alloc] init];
    self.mediaCacher = media;
    return self;
}

- (id)initWithFrameK:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.bool_kind = NO;
        [self setFrame:frame];
        [self setBackgroundColor:[UIColor clearColor]];
        //[self configureView_table];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadTableView)
                                                     name:@"JDSongStateChange_order"
                                                   object:nil];
    }
    MediaProxy *media = [[MediaProxy alloc] init];
    self.mediaCacher = media;
    [NSTimer scheduledTimerWithTimeInterval:(8.0) target:self selector:@selector(reloadTableViewWhenCacheSong) userInfo:nil repeats:YES];
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                   name:@"JDSongStateChange_order"
                                                  object:nil];
    
    [_array_alreadySong release], _array_alreadySong = nil;
    [_array_historySong release], _array_historySong = nil;
    [_song_current release], _song_current = nil;
    [_scrollIndex release], _scrollIndex = nil;
    [_cacheProgressSlider release], _cacheProgressSlider = nil;
    [_mediaCacher release], _mediaCacher = nil;
    [_grabbedObject release], _grabbedObject = nil;
    //[_cell_cache release], _cell_cache = nil;
    [super dealloc];
}


#pragma mark - 
#pragma mark ConfigureView
- (void)configureView_table
{
    JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
    if(_moviePlayer.bool_isHistoryOrSearchSong)
    {
        _bool_currentAlready = NO;
    }
    else
    {
        if(self.song_current.songOrderTag == 1)
        {
            _bool_currentAlready = YES;
        //[base changeAlreadySongList:self.song_current];
        }
        else
        {
            _bool_currentAlready = NO;
        }
    }
    
    self.array_alreadySong = [base reciveSongArrayWithTag:2];
    self.array_historySong = [JDSqlDataBaseSongHistory reciveDataBaseFromLocal];
    [base release];

    UITableView *table_already = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 348, 592) style:UITableViewStylePlain];
    if(self.bool_kind)
    {
        [table_already setFrame:CGRectMake(0, 0, 269, 592)];
    }
    [table_already setBackgroundColor:[UIColor clearColor]];
    [table_already setDataSource:self];
    [table_already setDelegate:self];
    [table_already setTag:10];
    [table_already setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self addSubview:table_already];
    [table_already release];
    
    self.tableViewRecognizer = [table_already enableGestureTableViewWithDelegate:self];
    if(_bool_kind)
    {
        self.tableViewRecognizer.integer_canMoveSection = 2;
        UIImageView *imageView_back = [[UIImageView alloc] initWithFrame:CGRectMake(0, -1, 269, 595)];
        [UIUtils didLoadImageNotCached:@"player_list_shadow.png" inImageView:imageView_back];
        [self addSubview:imageView_back];
        [imageView_back release];
    }
    else
    {
        self.tableViewRecognizer.integer_canMoveSection = 0;
    }
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.bool_kind)
    { 
        return 3;
    }
    else
    {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_bool_kind)
    {
        switch (section)
        {
            case 0:
            {
                return [_array_historySong count];
            }break;
            case 1:
            {
                return 1;
            }break;
            case 2:
            {
                if(_bool_currentAlready)
                {
                    return [_array_alreadySong count] - 1;
                }
                else
                {
                    return [_array_alreadySong count];
                }
            }break;
            default:
                break;
        }
    }
    else
    {
        return [_array_alreadySong count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_bool_kind)
    {
        if([_array_historySong count] > 2)
        {
            if(indexPath.section == 0 && indexPath.row == [_array_historySong count] - 2)
            {
                self.scrollIndex = indexPath;
            }
        }
        else
        {
                self.scrollIndex = indexPath;
            
        }
        switch (indexPath.section)
        {
            case 0:
            {
                static NSString *CellIdentifier = @"CellHistorySong";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil)
                {
                    cell = [[[UITableViewCell alloc] init] autorelease];
                    //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    [self installTableHistoryCell:cell forTableView:tableView];
                }
                SDSongs *song = [_array_historySong objectAtIndex:indexPath.row];
                [self useSong:song loadCell:cell withIndex:indexPath.row andSection:indexPath.section];
                [cell.contentView setBackgroundColor:[UIColor clearColor]];
                [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
                //[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
                
            }break;
            case 1:
            {
                static NSString *CellIdentifier = @"CellCurrentSong";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil)
                {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    [cell setBackgroundColor:[UIColor clearColor]];
                    [self installTableCurrentCell:cell forTableView:tableView];
                }
                [self useSong:_song_current loadCell:cell withIndex:indexPath.row andSection:indexPath.section];
                [cell.contentView setBackgroundColor:[UIColor clearColor]];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
                
            }break;
            case 2:
            {
                static NSString *CellIdentifier = @"CellAlreadySong";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

                if (cell == nil)
                {
                    //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    cell = [[[UITableViewCell alloc] init] autorelease];
                    /*NSObject *object;
                    if(_bool_currentAlready)
                    {
                        object = [self.array_alreadySong objectAtIndex:indexPath.row + 1];
                        if([object isEqual:DUMMY_CELL])
                        {
                            [cell setBackgroundColor:[UIColor clearColor]];
                            cell.contentView.backgroundColor = [UIColor clearColor];
                            return cell;
                        }
                    }
                    else
                    {
                        object = [self.array_alreadySong objectAtIndex:indexPath.row];
                        if([object isEqual:DUMMY_CELL])
                        {
                            [cell setBackgroundColor:[UIColor clearColor]];
                            cell.contentView.backgroundColor = [UIColor clearColor];
                            return cell;
                        }
                    }*/
                    [self installTableCell:cell forTableView:tableView];
                }
                
                SDSongs *song;
                if(_bool_currentAlready)
                {
                    song = [_array_alreadySong objectAtIndex:indexPath.row + 1];
                    [self useSong:song loadCell:cell withIndex:indexPath.row + 1 andSection:indexPath.section];
                }
                else
                {
                    song = [_array_alreadySong objectAtIndex:indexPath.row];
                    [self useSong:song loadCell:cell withIndex:indexPath.row andSection:indexPath.section];
                }
                
                [cell.contentView setBackgroundColor:RGB(235, 235, 235)];
                [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];

                return cell;
            }break;
            default:
            break;
        }
    }
    else
    {
        static NSString *CellIdentifier = @"CellAlreadySongMain";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell = [[[UITableViewCell alloc] init] autorelease];
            //NSObject *object = [self.array_alreadySong objectAtIndex:indexPath.row];
            /*if([object isEqual:DUMMY_CELL])
            {
                [cell setBackgroundColor:[UIColor clearColor]];
                cell.contentView.backgroundColor = [UIColor clearColor];
                return cell;
            }*/
            [self installTableCell:cell forTableView:tableView];
        }
        
        SDSongs *song = [_array_alreadySong objectAtIndex:indexPath.row];
        [self useSong:song loadCell:cell withIndex:indexPath.row andSection:indexPath.section];
        [cell.contentView setBackgroundColor:RGB(235, 235, 235)];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"sss");
    if(!_bool_kind)
    {
        /*self.bool_currentAlready = YES;
        
        if([SDMoviePlayerViewController sharedController].bool_isHUD)
        {
            [SDMoviePlayerViewController sharedController].bool_isHUD = NO;
            [MBProgressHUD hideHUDForView:[SDMoviePlayerViewController sharedController].moviePlayerController.view animated:YES];
        }

        SDSongs *song = [_array_alreadySong objectAtIndex:indexPath.row];
        SDMoviePlayerViewController *moviePlay = [SDMoviePlayerViewController sharedController];
        [moviePlay setBool_isHistoryOrSearchSong:NO];
        [moviePlay moviePlayerChangeState];
        [moviePlay setSong:song];
        [moviePlay playMovieWithLink:song.songMd5];
        
        JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
        [base changeAlreadySongList:song];
        [base release];
        
        UIViewController *controller = [self reciveSuperViewControllerWithView:self];
        [controller presentModalViewController:moviePlay animated:NO];*/
        
    }
    else
    {
        switch (indexPath.section)
        {
            case 0:
            {
                self.bool_currentAlready = NO;
                if(_moviePlayer.bool_isHUD)
                {
                    _moviePlayer.bool_isHUD = NO;
                    [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayer_main.view animated:YES];
                }
                SDSongs *song = [_array_historySong objectAtIndex:indexPath.row];
                [_moviePlayer setBool_isHistoryOrSearchSong:YES];
                [_moviePlayer changePlaySong:song];
                
            }break;
            case 2:
            {
                //NSLog(@"%d",indexPath.row);
                SDSongs *song;
                if(_bool_currentAlready)
                {
                    song = [_array_alreadySong objectAtIndex:indexPath.row + 1];
                }
                else
                {
                    song = [_array_alreadySong objectAtIndex:indexPath.row];
                }
                
                self.bool_currentAlready = YES;
                if(_moviePlayer.bool_isHUD)
                {
                    _moviePlayer.bool_isHUD = NO;
                    [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayer_main.view animated:YES];
                }
                
                [_moviePlayer setBool_isHistoryOrSearchSong:NO];
                [_moviePlayer changePlaySong:song];
                JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
                [base changeAlreadySongList:song];
                [base release];
        
            }break;
            default:
                break;
        }
    }
}

#pragma mark - 
#pragma mark JTTableViewGestureMoveRowDelegate
- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_bool_kind)
    {
        return YES;
    }
    if(indexPath.section == 2)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsCreatePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_bool_kind)
    {
        if(_bool_currentAlready)
        {
            self.grabbedObject = [self.array_alreadySong objectAtIndex:indexPath.row + 1];
            [self.array_alreadySong replaceObjectAtIndex:indexPath.row + 1  withObject:DUMMY_CELL];
        }
        else
        {
            self.grabbedObject = [self.array_alreadySong objectAtIndex:indexPath.row];
            [self.array_alreadySong replaceObjectAtIndex:indexPath.row  withObject:DUMMY_CELL];
        }
    }
    else
    {
        self.grabbedObject = [self.array_alreadySong objectAtIndex:indexPath.row];
        [self.array_alreadySong replaceObjectAtIndex:indexPath.row withObject:DUMMY_CELL];
    }
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsMoveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if(_bool_kind)
    {
        if(_bool_currentAlready)
        {
            id object = [self.array_alreadySong objectAtIndex:sourceIndexPath.row + 1];
            [self.array_alreadySong removeObjectAtIndex:sourceIndexPath.row + 1];
            [self.array_alreadySong insertObject:object atIndex:destinationIndexPath.row + 1];
        }
        else
        {
            id object = [self.array_alreadySong objectAtIndex:sourceIndexPath.row];
            [self.array_alreadySong removeObjectAtIndex:sourceIndexPath.row];
            [self.array_alreadySong insertObject:object atIndex:destinationIndexPath.row];
        }
    }
    else
    {
        id object = [self.array_alreadySong objectAtIndex:sourceIndexPath.row];
        [self.array_alreadySong removeObjectAtIndex:sourceIndexPath.row];
        [self.array_alreadySong insertObject:object atIndex:destinationIndexPath.row];
    }
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer needsReplacePlaceholderForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_bool_kind)
    {
        if(_bool_currentAlready)
        {
            [self.array_alreadySong replaceObjectAtIndex:indexPath.row + 1 withObject:self.grabbedObject];
            self.grabbedObject = nil;
        }
        else
        {
            [self.array_alreadySong replaceObjectAtIndex:indexPath.row withObject:self.grabbedObject];
            self.grabbedObject = nil;
        }
    }
    else
    {
        [self.array_alreadySong replaceObjectAtIndex:indexPath.row withObject:self.grabbedObject];
        self.grabbedObject = nil;
    }
    
    /*for (int i = 0; i<[self.array_alreadySong count]; i++)
    {
        SDSongs *songtmp = [self.array_alreadySong objectAtIndex:i];
        NSLog(@"%@,order %d,favorite %d,buyTag %d",songtmp.songTitle,songtmp.songOrderTag,songtmp.songFavoriteTag,songtmp.songBuyTag);
    }*/
    
    JDSqlDataBase *sqlBase = [[JDSqlDataBase alloc] init];
    [sqlBase changeAlreadySongList_moved:self.array_alreadySong];
    [sqlBase release];
    
    [_array_historySong removeObject:0];
    [self performSelector:@selector(reloadDataTableViewAfterTime) withObject:nil afterDelay:0.5];
    
    //NSLog(@"stop");
}

- (void)reloadDataTableViewAfterTime
{
    [self reloadTableViewWhenCacheSong];
    [_moviePlayer songTabelMoveReload];
}

/**
 已点歌曲列表部分初始化
 **/
- (void)installTableCell:(UITableViewCell *)cell forTableView:(UITableView *)tableView 
{
    if(!self.bool_kind)
    {
        UIButton *button_back = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_back setFrame:CGRectMake(0, 0, 348, 60)];
        [UIUtils didLoadImageNotCached:@"bg.png" inButton:button_back withState:UIControlStateNormal];
        [button_back setTag:JDAlreadySongCellTag_playback];
        [UIUtils didLoadImageNotCached:@"bg.png" inButton:button_back withState:UIControlStateHighlighted];
        
        [button_back addTarget:self action:@selector(didClickCellButton_play:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:button_back];
    }
    else
    {
        UIImageView *imageView_back = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 269, 60)];
        [UIUtils didLoadImageNotCached:@"bg.png" inImageView:imageView_back];
        [cell addSubview:imageView_back];
        [imageView_back release];
    }
    
    UIButton *button_play = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_play setFrame:CGRectMake(20, 10, 40, 40)];
    [UIUtils didLoadImageNotCached:@"played_btn.png" inButton:button_play withState:UIControlStateNormal];
    [button_play setTag:JDAlreadySongCellTag_play];
    //[button_play addTarget:self action:@selector(didClickCellButton_play:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:button_play];
    
    UIButton *button_delete = [UIButton buttonWithType:UIButtonTypeCustom];
    if(self.bool_kind)
    {
        [button_delete setFrame:CGRectMake(214, 19, 26, 26)];
    }
    else
    {
        [button_delete setFrame:CGRectMake(300, 19, 26, 26)];
    }
    [button_delete setTag:JDAlreadySongCellTag_delete];
    [UIUtils didLoadImageNotCached:@"delete.png" inButton:button_delete withState:UIControlStateNormal];
    [button_delete addTarget:self action:@selector(didClickCellButton_delete:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:button_delete];
    
    UILabel *label_singer = [[UILabel alloc] initWithFrame:CGRectMake(70, 8, 200, 20)];
    [label_singer setBackgroundColor:[UIColor clearColor]];
    [label_singer setTextColor:[UIColor grayColor]];
    [label_singer setFont:[UIFont systemFontOfSize:12.0f]];
    [label_singer setTag:JDAlreadySongCellTag_singer];
    [cell addSubview:label_singer];
    [label_singer release];
    
    UILabel *label_song = [[UILabel alloc] initWithFrame:CGRectMake(70, 25, 144, 30)];
    [label_song setBackgroundColor:[UIColor clearColor]];
    [label_song setTextColor:[UIColor blackColor]];
    [label_song setFont:[UIFont systemFontOfSize:15.0f]];
    [label_song setTag:JDAlreadySongCellTag_song];
    [cell addSubview:label_song];
    [label_song release];
    
    JDCircleSlider *cacheSlider = [[JDCircleSlider alloc] initWithFrame:CGRectMake(17.5, 8, TB_SLIDER_SIZE, TB_SLIDER_SIZE)];
    CGAffineTransform rotation = CGAffineTransformMakeRotation(1.57079633);
    [cacheSlider setTransform:rotation];
    [cacheSlider setTag:JDAlreadySongCellTag_circle];
    [cell addSubview:cacheSlider];
    [cacheSlider release];
}

- (void)installTableHistoryCell:(UITableViewCell *)cell forTableView:(UITableView *)tableView
{
    UIImageView *imageView_back = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 348, 60)];
    if(self.bool_kind)
    {
        [imageView_back setFrame:CGRectMake(0, 0, 269, 60)];
    }
    [UIUtils didLoadImageNotCached:@"sub_menu_bar_bg.png" inImageView:imageView_back];
    [cell addSubview:imageView_back];
    [imageView_back release];
    
    UIButton *button_play = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_play setFrame:CGRectMake(20, 10, 40, 40)];
    [UIUtils didLoadImageNotCached:@"played_btn.png" inButton:button_play withState:UIControlStateNormal];
    [button_play setTag:JDAlreadySongCellTag_play];
    [button_play addTarget:self action:@selector(didClickCellButtonHistory_play:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:button_play];

    UIButton *button_delete = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_delete setFrame:CGRectMake(214, 17, 26, 26)];
    [button_delete setTag:JDAlreadySongCellTag_delete];
    [UIUtils didLoadImageNotCached:@"delete.png" inButton:button_delete withState:UIControlStateNormal];
    [button_delete addTarget:self action:@selector(didClickCellButtonHistory_delete:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:button_delete];
    
    UILabel *label_singer = [[UILabel alloc] initWithFrame:CGRectMake(70, 8, 200, 20)];
    [label_singer setBackgroundColor:[UIColor clearColor]];
    [label_singer setTextColor:[UIColor grayColor]];
    [label_singer setFont:[UIFont systemFontOfSize:12.0f]];
    [label_singer setTag:JDAlreadySongCellTag_singer];
    [cell addSubview:label_singer];
    [label_singer release];
    
    UILabel *label_song = [[UILabel alloc] initWithFrame:CGRectMake(70, 25, 144, 30)];
    [label_song setBackgroundColor:[UIColor clearColor]];
    [label_song setTextColor:[UIColor colorWithWhite:0.8 alpha:1.0]];
    [label_song setFont:[UIFont systemFontOfSize:15.0f]];
    [label_song setTag:JDAlreadySongCellTag_song];
    [cell addSubview:label_song];
    [label_song release];
}

- (void)installTableCurrentCell:(UITableViewCell *)cell forTableView:(UITableView *)tableView
{
    UIImageView *imageView_back = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 348, 60)];
    if(self.bool_kind)
    {
        [imageView_back setFrame:CGRectMake(0, 0, 269, 60)];
    }
    [UIUtils didLoadImageNotCached:@"playing.png" inImageView:imageView_back];
    [cell addSubview:imageView_back];
    [imageView_back release];
    
    UIButton *button_play = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_play setFrame:CGRectMake(20, 10, 40, 40)];
    [UIUtils didLoadImageNotCached:@"playing.png" inButton:button_play withState:UIControlStateNormal];
    [button_play setHidden:YES];
    [button_play setTag:JDAlreadySongCellTag_play];
    [button_play addTarget:self action:@selector(didClickCellButton_play:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:button_play];
    
    UIButton *button_delete = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_delete setFrame:CGRectMake(214, 17, 26, 26)];
    [button_delete setTag:JDAlreadySongCellTag_delete];
    [UIUtils didLoadImageNotCached:@"delete.png" inButton:button_delete withState:UIControlStateNormal];
    [button_delete setHidden:YES];
    [button_delete addTarget:self action:@selector(didClickCellButton_delete:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:button_delete];
    
    UILabel *label_singer = [[UILabel alloc] initWithFrame:CGRectMake(70, 8, 200, 20)];
    [label_singer setBackgroundColor:[UIColor clearColor]];
    [label_singer setTextColor:[UIColor grayColor]];
    [label_singer setFont:[UIFont systemFontOfSize:12.0f]];
    [label_singer setTag:JDAlreadySongCellTag_singer];
    [cell addSubview:label_singer];
    [label_singer release];
    
    UILabel *label_song = [[UILabel alloc] initWithFrame:CGRectMake(70, 25, 200, 30)];
    [label_song setBackgroundColor:[UIColor clearColor]];
    [label_song setTextColor:[UIColor blackColor]];
    [label_song setFont:[UIFont systemFontOfSize:15.0f]];
    [label_song setTag:JDAlreadySongCellTag_song];
    [cell addSubview:label_song];
    [label_song release];

}


- (void)useSong:(SDSongs *)song loadCell:(UITableViewCell *)cell withIndex:(NSInteger)index andSection:(NSInteger)section
{
    if([song isEqual:DUMMY_CELL])
    {
        UILabel *label_singer = (UILabel *)[cell viewWithTag:JDAlreadySongCellTag_singer];
        [label_singer setText:nil];
        UILabel *label_song = (UILabel *)[cell viewWithTag:JDAlreadySongCellTag_song];
        [label_song setText:nil];
        return;
    }
    
    UIButton *button_play = (UIButton *)[cell viewWithTag:JDAlreadySongCellTag_playback];
    [button_play setTag:index];
    
    if(section == 2 || !_bool_kind)
    {
        JDCircleSlider *cacheSlider = (JDCircleSlider *)[cell viewWithTag:JDAlreadySongCellTag_circle];
        int i = [_mediaCacher getPrereadPercent:song.string_videoUrl];
        [cacheSlider setProgressWithAngle:i];

        if(_cacheProgressSlider || !_bool_kind)
        {
        
        }
        else
        {
            if(i != 100 && ![_song_current.songMd5 isEqualToString:song.songMd5])
            {
                self.cacheProgressSlider = cacheSlider;
            }
        }
    }
    
    UIButton *button_delete = (UIButton *)[cell viewWithTag:JDAlreadySongCellTag_delete];
    [button_delete setTag:index + 5];
    UILabel *label_singer = (UILabel *)[cell viewWithTag:JDAlreadySongCellTag_singer];
    [label_singer setText:song.songSingers];
    UILabel *label_song = (UILabel *)[cell viewWithTag:JDAlreadySongCellTag_song];
    [label_song setText:song.songTitle];
}

/**
 点击播放
 **/
- (void)didClickCellButton_play:(id)sender
{
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"token"])
    {
        CustomAlertView *alter = [[CustomAlertView alloc] initWithTitle:@"请先进行登陆" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alter show];
        [alter release];
        return;
    }
    
    self.bool_currentAlready = YES;
    UIButton *button_play = (UIButton *)sender;
    //NSLog(@"%d",button_play.tag);
    SDSongs *song = [_array_alreadySong objectAtIndex:button_play.tag];
    JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
    [base changeAlreadySongList:song];
    [base release];
    JDMoviePlayerViewController *moveplayer = [[JDMoviePlayerViewController alloc] initWithSong:song];
    [moveplayer setNavigationController_return:_navigationController_return];
    [moveplayer setBool_isHistoryOrSearchSong:NO];
    [_navigationController_return pushViewController:moveplayer animated:YES];
    [moveplayer release];
    [moveplayer playBegin];
}

- (void)didClickCellButtonHistory_play:(id)sender
{
    self.bool_currentAlready = NO;
    if(_moviePlayer.bool_isHUD)
    {
       _moviePlayer.bool_isHUD = NO;
        [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayer_main.view animated:YES];
    }
    UIButton *button_play = (UIButton *)sender;
    SDSongs *song = [_array_historySong objectAtIndex:button_play.tag];
    [_moviePlayer setBool_isHistoryOrSearchSong:YES];
    [_moviePlayer changePlaySong:song];
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

- (UITableViewCell *)reciveCellWithView:(UIView *)view
{
    for (UIView *next = [view superview]; next; next = next.superview)
    {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UITableViewCell class]])
        {
            return (UITableViewCell *)nextResponder;
        }
    }
    return nil;
}

- (void)didClickCellButton_arrow:(id)sender
{
    UIButton *button_arrow = (UIButton *)sender;
    
    UIView *view_arrow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 306, 60)];
    [view_arrow setBackgroundColor:[UIColor clearColor]];
    UIImageView *imageView_arrow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 306, 60)];
    [UIUtils didLoadImageNotCached:@"arrow_back.png" inImageView:imageView_arrow];
    [view_arrow addSubview:imageView_arrow];
    [imageView_arrow release];
    
    UITableViewCell *cell = (UITableViewCell *)[self reciveCellWithView:button_arrow];
    [cell.contentView addSubview:view_arrow];
}

- (void)didClickCellButton_delete:(id)sender
{
    UIButton *button_delete = (UIButton *)sender;
    SDSongs *song = [_array_alreadySong objectAtIndex:button_delete.tag - 5];
    JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
    [base deleteSongFormLocalSingerWithString:song withTag:2];
    //[_array_alreadySong removeObject:song];
    [base release];
    //UITableView *tableView_already = (UITableView *)[self viewWithTag:10];
    //[tableView_already reloadData];
    if([_array_alreadySong count] == 0)
    {
        JDMainViewController *mainView =(JDMainViewController *)[self reciveSuperViewControllerWithView:self];
        [mainView didCLickButton_noSong];
    }
}

- (void)didClickCellButtonHistory_delete:(id)sender
{
    UIButton *button_delete = (UIButton *)sender;
    SDSongs *song = [_array_historySong objectAtIndex:button_delete.tag - 5];
    
    [JDSqlDataBaseSongHistory deleteSong:song];
    //JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
    //[base deleteSongFormLocalSingerWithString:song withTag:2];
    //[_array_alreadySong removeObject:song];
    //[base release];
    //UITableView *tableView_already = (UITableView *)[self viewWithTag:10];
    //[tableView_already reloadData];
    /*if([_array_alreadySong count] == 0)
    {
        JDMainViewController *mainView =(JDMainViewController *)[self reciveSuperViewControllerWithView:self];
        [mainView didCLickButton_noSong];
    }*/
}

- (void)reloadTableView
{
    //_cell_cache = nil;
    _cacheProgressSlider = nil;
    if(_bool_kind)
    {
        [self.array_alreadySong removeAllObjects];
        [self.array_historySong removeAllObjects];
        JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
        self.array_alreadySong = [base reciveSongArrayWithTag:2];
        self.array_historySong = [JDSqlDataBaseSongHistory reciveDataBaseFromLocal];
        [base release];
        UITableView *tableView_already = (UITableView *)[self viewWithTag:10];
        [tableView_already reloadData];
    }
    else
    {
        [self.array_alreadySong removeAllObjects];
        JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
        self.array_alreadySong = [base reciveSongArrayWithTag:2];
        [base release];
        UITableView *tableView_already = (UITableView *)[self viewWithTag:10];
        [tableView_already reloadData];
    }
}

- (void)reloadTableViewWhenCacheSong
{
    _cacheProgressSlider = nil;
    UITableView *tableView_already = (UITableView *)[self viewWithTag:10];
    [tableView_already reloadData];
}

/*- (void)reloadTableView:(NSNotification *)note
{
    [self.array_data removeAllObjects];
    self.array_data = [JDDataBaseRecordSound reciveDataBaseFromLocal];
    
    UITableView *tableView_already = (UITableView *)[self viewWithTag:800];
    [tableView_already deleteRowsAtIndexPaths:[NSArray arrayWithObject:_delectCellId] withRowAnimation:UITableViewRowAnimationLeft];
    //if(_label_no)
    //{
    //[_label_no removeFromSuperview];
    // _label_no = nil;
    //}
}*/

- (void)tableScrollToPosition
{
    UITableView *tableView_already = (UITableView *)[self viewWithTag:10];
    if([_array_historySong count] > 2)
    {
        NSInteger integer_point = ([_array_historySong count] - 2) * 60;
        
       [tableView_already setContentOffset:CGPointMake(0, 30+integer_point) animated:NO];
    }
}




@end
