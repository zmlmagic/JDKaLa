//
//  JDMyOrderSongView.m
//  JDKaLa
//
//  Created by zhangminglei on 6/8/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDMyOrderSongView.h"
#import "JDModel_tmp_manger.h"
#import "JDSqlDataBase.h"
//#import "SDMoviePlayerViewController.h"
#import "JDModel_user.h"
#import "UIUtils.h"
#import "JDModel_userInfo.h"
#import "JDMoviePlayerViewController.h"
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

typedef enum
{
    JDButtonBuyTag_buySong         = 50,
    JDButtonBuyTag_useCard             ,
    JDButtonBuyTag_back                ,
}JDButtonBuyTag;

typedef enum
{
    JDPayTag_30min            = 200,
    JDPayTag_1hour                 ,
    JDPayTag_2hour                 ,
    JDPayTag_month                 ,
}
JDPayTag;

@implementation JDMyOrderSongView

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
    self.array_data = [base reciveSongArrayWithTag:2];
    //[base selectSongandChangeItTagWithArray:_array_data];
    [base release];
    if([_array_data count] != 0)
    {
        UITableView *tableView_songShow = [[UITableView alloc] initWithFrame:CGRectMake(0, 7, 1024, 691)];
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
    [button_list setFrame:CGRectMake(875, 14, 45, 45)];
    [UIUtils didLoadImageNotCached:@"player_list_thumbnail_btn_delete.png" inButton:button_list withState:UIControlStateNormal];
    [button_list setTag:JDCellButtonTag_list];
    [button_list addTarget:self action:@selector(didClickButton_cell:) forControlEvents:UIControlEventTouchUpInside];
    [button_background addSubview:button_list];
    
    UIButton *button_favorite = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_favorite setFrame:CGRectMake(800, 10, 50, 50)];
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
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(reloadTableView:)
                                                         name:@"JDSongStateChange_order"
                                                       object:nil];
            
            self.delectCellId = indexPath;
            JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
            [base deleteSongFormLocalSingerWithString:song withTag:2];
            [UIUtils view_showProgressHUD:@"已移出播放列表" inView:self withTime:1.0f];
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
        /*
        [self performSelectorInBackground:@selector(reloadKB) withObject:nil];
        [self installView_payView];*/
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
    
    UIImageView *imageView_pay = (UIImageView *)[cell viewWithTag:JDCellButtonTag_pay];
    [UIUtils didLoadImageNotCached:nil inImageView:imageView_pay];
    
    if(song.songBuyTag == 0)
    {
        UIImageView *imageView_pay = (UIImageView *)[cell viewWithTag:JDCellButtonTag_pay];
        [UIUtils didLoadImageNotCached:nil inImageView:imageView_pay];
    }
    else
    {
        UIImageView *imageView_pay = (UIImageView *)[cell viewWithTag:JDCellButtonTag_pay];
        [UIUtils didLoadImageNotCached:@"songs_icon_paid.png" inImageView:imageView_pay];
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
    
    //if(_label_no)
    //{
    //[_label_no removeFromSuperview];
    // _label_no = nil;
    //}
}


- (void)installView_payView
{
    UIView *back = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [back setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.7]];
    [self addSubview:back];
    [back release];
    
    UIView *view_viewBack = [[UIView alloc] initWithFrame:CGRectMake(288, 100, 448, 483)];
    UIImageView *imageView_back = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 448, 283)];
    [UIUtils didLoadImageNotCached:@"pop_up_board_lv1.png" inImageView:imageView_back];
    [view_viewBack addSubview:imageView_back];
    [imageView_back release];
    
    UIImageView *imageView_20 = [[UIImageView alloc] initWithFrame:CGRectMake(300, 15, 51, 20)];
    [UIUtils didLoadImageNotCached:@"pop_up_vip_20.png" inImageView:imageView_20];
    [view_viewBack addSubview:imageView_20];
    [imageView_20 release];
    
    UILabel *label_title = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, 400, 30)];
    [label_title setBackgroundColor:[UIColor clearColor]];
    [label_title setTextColor:[UIColor grayColor]];
    [label_title setText:@"该歌曲需要购买或者开启欢唱卡才可播放,请选择以下操作"];
    [view_viewBack addSubview:label_title];
    [label_title release];
    
    UIButton *button_buy_song = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_buy_song setFrame:CGRectMake(30, 100, 108, 133)];
    [UIUtils didLoadImageNotCached:@"pop_up_btn_k.png" inButton:button_buy_song withState:UIControlStateNormal];
    [button_buy_song setTag:JDButtonBuyTag_buySong];
    [button_buy_song addTarget:self action:@selector(didClickButton_buy:) forControlEvents:UIControlEventTouchUpInside];
    [view_viewBack addSubview:button_buy_song];
    
    UIButton *button_buy_card = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_buy_card setFrame:CGRectMake(153, 100, 108, 133)];
    [UIUtils didLoadImageNotCached:@"pop_up_btn_time.png" inButton:button_buy_card withState:UIControlStateNormal];
    [button_buy_card setTag:JDButtonBuyTag_useCard];
    [button_buy_card addTarget:self action:@selector(didClickButton_buy:) forControlEvents:UIControlEventTouchUpInside];
    [view_viewBack addSubview:button_buy_card];
    
    UIButton *button_back = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_back setFrame:CGRectMake(273, 130, 108, 58)];
    [UIUtils didLoadImageNotCached:@"pop_up_btn_return.png" inButton:button_back withState:UIControlStateNormal];
    [button_back setTag:JDButtonBuyTag_back];
    [button_back addTarget:self action:@selector(didClickButton_buy:) forControlEvents:UIControlEventTouchUpInside];
    [view_viewBack addSubview:button_back];
    
    [back addSubview:view_viewBack];
    [view_viewBack release];
    
}

- (void)didClickButton_buy:(id)sender
{
    UIButton *button_tmp = (UIButton *)sender;
    switch (button_tmp.tag)
    {
        case JDButtonBuyTag_buySong:
        {
            
            UIView *view_back = [self reciveSuperViewWithButton:button_tmp];
            
            UIImageView *imageView_card = [[UIImageView alloc] initWithFrame:CGRectMake(0, 283, 448, 110)];
            [UIUtils didLoadImageNotCached:@"pop_up_board_lv.png" inImageView:imageView_card];
            [view_back addSubview:imageView_card];
            [imageView_card release];
            
            JDModel_user *users = [[JDModel_user alloc] init];
            [users readFormFile];
            NSString *string_tmp = [NSString stringWithFormat:@"您当前的账户余额为%@K币",users.string_userMoney];
            
            UILabel *label_ye = [[UILabel alloc] initWithFrame:CGRectMake(30, 300, 300, 30)];
            [label_ye setTextColor:[UIColor whiteColor]];
            [label_ye setBackgroundColor:[UIColor clearColor]];
            [label_ye setText:string_tmp];
            [users release];
            [view_back addSubview:label_ye];
            [label_ye release];
            
            UIButton *button_180k = [UIButton buttonWithType:UIButtonTypeCustom];
            [button_180k setFrame:CGRectMake(30, 350, 80, 35)];
            [UIUtils didLoadImageNotCached:@"pop_up_btn_buy.png" inButton:button_180k withState:UIControlStateNormal];
            [button_180k setTag:JDPayTag_30min];
            [button_180k addTarget:self action:@selector(didClickSongPay:) forControlEvents:UIControlEventTouchUpInside];
            [view_back addSubview:button_180k];
            
            UIButton *button_280k = [UIButton buttonWithType:UIButtonTypeCustom];
            [button_280k setFrame:CGRectMake(250, 350, 120, 35)];
            [UIUtils didLoadImageNotCached:@"pop_up_btn_notbuy.png" inButton:button_280k withState:UIControlStateNormal];
            [button_280k setTag:JDPayTag_1hour];
            [button_280k addTarget:self action:@selector(didClickSongPay:) forControlEvents:UIControlEventTouchUpInside];
            [view_back addSubview:button_280k];
            
            
        }break;
            
        case JDButtonBuyTag_useCard:
        {
            UIView *view_back = [self reciveSuperViewWithButton:button_tmp];
            
            UIImageView *imageView_card = [[UIImageView alloc] initWithFrame:CGRectMake(0, 283, 448, 110)];
            [UIUtils didLoadImageNotCached:@"pop_up_board_lv.png" inImageView:imageView_card];
            [view_back addSubview:imageView_card];
            [imageView_card release];
            
            UIButton *button_180k = [UIButton buttonWithType:UIButtonTypeCustom];
            [button_180k setFrame:CGRectMake(30, 300, 175, 35)];
            [UIUtils didLoadImageNotCached:@"pop_up_time_btn_30min.png" inButton:button_180k withState:UIControlStateNormal];
            [button_180k setTag:JDPayTag_30min];
            [button_180k addTarget:self action:@selector(didClickCardPay:) forControlEvents:UIControlEventTouchUpInside];
            [view_back addSubview:button_180k];
            
            UIButton *button_280k = [UIButton buttonWithType:UIButtonTypeCustom];
            [button_280k setFrame:CGRectMake(250, 300, 175, 35)];
            [UIUtils didLoadImageNotCached:@"pop_up_time_btn_1hour.png" inButton:button_280k withState:UIControlStateNormal];
            [button_280k setTag:JDPayTag_1hour];
            [button_280k addTarget:self action:@selector(didClickCardPay:) forControlEvents:UIControlEventTouchUpInside];
            [view_back addSubview:button_280k];
            
            UIButton *button_480k = [UIButton buttonWithType:UIButtonTypeCustom];
            [button_480k setFrame:CGRectMake(30, 350, 175, 35)];
            [UIUtils didLoadImageNotCached:@"pop_up_time_btn_2hour.png" inButton:button_480k withState:UIControlStateNormal];
            [button_480k setTag:JDPayTag_2hour];
            [button_480k addTarget:self action:@selector(didClickCardPay:) forControlEvents:UIControlEventTouchUpInside];
            [view_back addSubview:button_480k];
            
            UIButton *button_1980k = [UIButton buttonWithType:UIButtonTypeCustom];
            [button_1980k setFrame:CGRectMake(250, 350, 175, 35)];
            [UIUtils didLoadImageNotCached:@"pop_up_time_btn_month.png" inButton:button_1980k withState:UIControlStateNormal];
            [button_1980k setTag:JDPayTag_month];
            [button_1980k addTarget:self action:@selector(didClickCardPay:) forControlEvents:UIControlEventTouchUpInside];
            [view_back addSubview:button_1980k];
            
        }break;
            
        case JDButtonBuyTag_back:
        {
            UIView *view_back = [self reciveSuperViewWithButton:button_tmp];
            UIView *back = [self reciveSuperViewWithView:view_back];
            [back removeFromSuperview];
            
        }break;
            
        default:
            break;
    }
}

- (void)didClickCardPay:(id)sender
{
    UIButton *button_tmp = (UIButton *)sender;
    
    UIView *view_back = [self reciveSuperViewWithButton:button_tmp];
    UIView *back = [self reciveSuperViewWithView:view_back];
    [back removeFromSuperview];
    JDModel_user *user = [[JDModel_user alloc] init];
    switch (button_tmp.tag)
    {
        case JDPayTag_30min:
        {
            JDModel_card_pay *card_30 = [[JDModel_card_pay alloc] init];
            [card_30 setString_time:[self get_CalendarAndDate]];
            [card_30 setString_endTime:[UIUtils getDateStringAfterSeconds:1800]];
            [card_30 setInteger_kindOfKind:0];
            [card_30 setBool_success:YES];
            [user buyCard:card_30];
            [card_30 release];
            
        }break;
            
        case JDPayTag_1hour:
        {
            JDModel_card_pay *card_1 = [[JDModel_card_pay alloc] init];
            [card_1 setString_time:[self get_CalendarAndDate]];
            [card_1 setString_endTime:[UIUtils getDateStringAfterSeconds:3600]];
            [card_1 setInteger_kindOfKind:1];
            [card_1 setBool_success:YES];
            [user buyCard:card_1];
            [card_1 release];
            
        }break;
        case JDPayTag_2hour:
        {
            JDModel_card_pay *card_2 = [[JDModel_card_pay alloc] init];
            [card_2 setString_time:[self get_CalendarAndDate]];
            [card_2 setString_endTime:[UIUtils getDateStringAfterSeconds:7200]];
            [card_2 setInteger_kindOfKind:2];
            [card_2 setBool_success:YES];
            [user buyCard:card_2];
            [card_2 release];
            
        }break;
        case JDPayTag_month:
        {
            JDModel_card_pay *card_m = [[JDModel_card_pay alloc] init];
            [card_m setString_time:[self get_CalendarAndDate]];
            [card_m setString_endTime:[UIUtils getDateStringAfterSeconds:1296000]];
            [card_m setInteger_kindOfKind:3];
            [card_m setBool_success:YES];
            [user buyCard:card_m];
            [card_m release];
            
        }break;
            
        default:
            break;
    }
    
    JDMoviePlayerViewController *movePlayer = [[JDMoviePlayerViewController alloc] initWithSong:_song_buy];
    [movePlayer setBool_isHistoryOrSearchSong:NO];
    [movePlayer.view_alreadySong setBool_currentAlready:YES];
    movePlayer.navigationController_return = _navigationController_return;
    [_navigationController_return pushViewController:movePlayer animated:YES];
    [movePlayer playBegin];
    [movePlayer release];

    
    JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
    [base changeAlreadySongList:self.song_buy];
    [base release];
   
}


- (NSString *)get_CalendarAndDate
{
    NSDate * sendDate = [NSDate date];
    NSDateFormatter *dateformatter=[[[NSDateFormatter alloc] init] autorelease];
    [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSString * locationString = [dateformatter stringFromDate:sendDate];
    return locationString;
}


@end
