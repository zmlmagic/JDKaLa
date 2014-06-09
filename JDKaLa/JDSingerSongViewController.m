//
//  JDSingerSongViewController.m
//  JDKaLa
//
//  Created by zhangminglei on 4/10/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDSingerSongViewController.h"
#import "SKCustomNavigationBar.h"
//#import "SDMoviePlayerViewController.h"
#import "JDModel_userInfo.h"
#import "UIUtils.h"
#import "JDSqlDataBase.h"
#import "ClientAgent.h"
#import "JDModel_userInfo.h"
#import "CustomAlertView.h"
#import "JDAlreadySongView.h"
#import "JDSearchViewController.h"
#import "JDMoviePlayerViewController.h"

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
    //JDButtonBuyTag_background           ,
    //JDButtonBuyTag_pay                  ,
    //JDButtonBuyTag_play                 ,
    //JDButtonBuyTag_list                 ,
    //JDButtonBuyTag_favorite             ,
}JDButtonBuyTag;

typedef enum
{
    JDPayTag_30min            = 200,
    JDPayTag_1hour                 ,
    JDPayTag_2hour                 ,
    JDPayTag_month                 ,
}
JDPayTag;


@interface JDSingerSongViewController ()

@end

@implementation JDSingerSongViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (id)initWithTitleString:(NSString *)_string
{
    self = [super init];
    if(self)
    {
        IOS7_STATEBAR;
        _integer_tag = 0;
        self.bool_local = NO;
        self.bool_buySong = NO;
        [self configureView_background];
        [self configureView_table];
        [self configureView_title:_string];
        self.agent = [[ClientAgent alloc] init];
    }
    return self;
}

#pragma mark - 状态栏控制 -
/**状态栏控制**/
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleBlackOpaque;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTitleView:)
                                                 name:@"JDSongStateChange_order"
                                               object:nil];
    /*self.bool_already = YES;
    if(self.bool_already)
    {
        JDAlreadySongView *view = (JDAlreadySongView *)[self.view viewWithTag:100];
        [view removeFromSuperview];
        UIImageView *imageView = (UIImageView *)[self.view viewWithTag:101];
        [imageView removeFromSuperview];
        self.bool_already = !self.bool_already;
    }*/
   
    /*[[NSNotificationCenter defaultCenter] addObserver:self
           selector:@selector(handleBuySong:)
               name:NOTI_BUY_SONG_RESULT
             object:nil];*/
    
    /*[[NSNotificationCenter defaultCenter] addObserver:self
           selector:@selector(handleBuyMonthService:)
               name:NOTI_BUY_MONTH_RESULT
             object:nil];*/
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"JDSongStateChange_order"
                                                  object:nil];

    [_selectCell release], _selectCell = nil;
    [_array_data release], _array_data = nil;
    //[_song_favorite release], _song_favorite = nil;
    [_agent release], _agent = nil;
    [super dealloc];
}

#pragma mark - ConfigureView
- (void)configureView_title:(NSString *)string_title
{
    SKCustomNavigationBar *customNavigationBar = [[SKCustomNavigationBar alloc] initWithFrame:CGRectMake(0, 0, 1024, 50)];
    IOS7(customNavigationBar);
    [self.view addSubview:customNavigationBar];
    [customNavigationBar release];
    
    UIView *view_title = [[UIView alloc] initWithFrame:CGRectMake(300, 0, 700, 50)];
    [view_title setBackgroundColor:[UIColor clearColor]];
    [view_title setTag:70];
    [customNavigationBar addSubview:view_title];
    [view_title release];
    
    UILabel *label_titel = [[UILabel alloc]initWithFrame:CGRectMake(110, 0, 200, 50)];
    [label_titel setBackgroundColor:[UIColor clearColor]];
    [label_titel setTextAlignment:NSTextAlignmentCenter];
    [label_titel setShadowColor:[UIColor grayColor]];
    [label_titel setShadowOffset:CGSizeMake(2, 2)];
    [label_titel setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:30.0f]];
    [label_titel setTextColor:[UIColor whiteColor]];
    [label_titel setText:string_title];
    [view_title addSubview:label_titel];
    [label_titel release];
    
    UIButton *button_master = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_master setFrame:CGRectMake(10, 7, 65, 37)];
    [UIUtils didLoadImageNotCached:@"back_btn.png" inButton:button_master withState:UIControlStateNormal];
    [customNavigationBar addSubview:button_master];
    [button_master addTarget:self action:@selector(didClickButton_master) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageView_text = [[UIImageView alloc] initWithFrame:CGRectMake(415, 11, 294, 28)];
    [UIUtils didLoadImageNotCached:@"search_field.png" inImageView:imageView_text];
    [view_title addSubview:imageView_text];
    [imageView_text release];
    
    UITextField *text_search = [[UITextField alloc] initWithFrame:CGRectMake(420, 13, 294, 28)];
    [text_search setTextColor:[UIColor grayColor]];
    [text_search setDelegate:self];
    [text_search setPlaceholder:@"请输入关键字"];
    [text_search setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [text_search setReturnKeyType:UIReturnKeySearch];
    [view_title addSubview:text_search];
    [text_search release];
    
    UIButton *button_already = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_already setFrame:CGRectMake(357, 13, 37, 28)];
    [UIUtils didLoadImageNotCached:@"image.png" inButton:button_already withState:UIControlStateNormal];
    [button_already addTarget:self action:@selector(didCLickAlreadyButton) forControlEvents:UIControlEventTouchUpInside];
    [view_title addSubview:button_already];
    
    UILabel *label_number = [[UILabel alloc] initWithFrame:CGRectMake(15, 7, 20, 20)];
    [label_number setBackgroundColor:[UIColor clearColor]];
    [label_number setTextColor:[UIColor whiteColor]];
    [label_number setFont:[UIFont systemFontOfSize:12.0f]];
    label_total = label_number;
    [label_number setTextAlignment:NSTextAlignmentCenter];
    JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
    NSMutableArray *array_base = [base reciveSongArrayWithTag:2];
    [base release];
    [label_number setText:[NSString stringWithFormat:@"%d",[array_base count]]];
    [button_already addSubview:label_number];
    [label_number release];
}

- (void)didCLickAlreadyButton
{
    //self.bool_already = NO;
    JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
    NSMutableArray *array_alreadySong = [base reciveSongArrayWithTag:2];
    [base release];
    
    if([array_alreadySong count] != 0)
    {
        if(self.bool_already)
        {
            JDAlreadySongView *view = (JDAlreadySongView *)[self.view viewWithTag:100];
            [UIUtils removeView:view];
            UIImageView *imageView = (UIImageView *)[self.view viewWithTag:101];
            [UIUtils removeView:imageView];
        }
        else
        {
            JDAlreadySongView *songView = [[JDAlreadySongView alloc]initWithFrameK:CGRectMake(673, 59, 348, 593)];
            songView.navigationController_return = _navigationController_return;
            [songView configureView_table];
            IOS7(songView);
            UIImageView *imageView_sanjiao = [[UIImageView alloc] initWithFrame:CGRectMake(673, 50, 20, 9)];
            IOS7(imageView_sanjiao);
            [UIUtils addView:songView toView:self.view];
            [songView setTag:100];
            [UIUtils didLoadImageNotCached:@"sanjiao.png" inImageView:imageView_sanjiao];
            [self.view addSubview:imageView_sanjiao];
            [imageView_sanjiao setAlpha:0.0f];
            [UIUtils showView:imageView_sanjiao];
            [imageView_sanjiao setTag:101];
            [imageView_sanjiao release];
        }
        self.bool_already = !self.bool_already;
    }
    else
    {
        CustomAlertView *alert = [[CustomAlertView alloc] initWithTitle:@"您还没有播放别表" message:@"快去添加吧" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)didCLickButton_noSong
{
    JDAlreadySongView *view = (JDAlreadySongView *)[self.view viewWithTag:100];
    [UIUtils removeView:view];
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:101];
    [UIUtils removeView:imageView];
    self.bool_already = !self.bool_already;
}

- (void)removeAlreadySongView:(UIView *)view
{
    [view removeFromSuperview];
}

#pragma mark - 刷新已点列表消息回调 -
/**
 刷新已点列表消息回调
 **/
- (void)reloadTitleView:(NSNotification *)note
{
    NSInteger count1 = [label_total.text integerValue];
    NSInteger count2 = [(NSString *)[note object] integerValue];
    label_total.text = [NSString stringWithFormat:@"%d",count1 + count2];
}

#pragma mark - DidClickButton
- (void)didClickButton_master
{
    if(self.bool_already)
    {
        JDAlreadySongView *view = (JDAlreadySongView *)[self.view viewWithTag:100];
        [UIUtils removeView:view];
        UIImageView *imageView = (UIImageView *)[self.view viewWithTag:101];
        [UIUtils removeView:imageView];
    }
    [_navigationController_return popViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:NO completion:nil];
}


- (void)configureView_background
{
    UIImageView *imageView_background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 1024, 749)];
    IOS7(imageView_background);
    [UIUtils didLoadImageNotCached:@"mainView_background.png" inImageView:imageView_background];
    [self.view addSubview:imageView_background];
    [imageView_background release];
}

- (void)configureView_table
{
    UITableView *table_singer = [[UITableView alloc] initWithFrame:CGRectMake(0, 57, 1024, 691) style:UITableViewStylePlain];
    IOS7(table_singer);
    [table_singer setDataSource:self];
    [table_singer setDelegate:self];
    [table_singer setBackgroundColor:[UIColor clearColor]];
    [table_singer setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:table_singer];
    [table_singer release];
}

- (void)configureTable_data
{
    JDSqlDataBase *dataController = [[JDSqlDataBase alloc] init];
    [dataController selectSongandChangeItTagWithArray:_array_data];
    [dataController release];
}

#pragma mark - Table View -
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
    //SDSongs *song = [_array_data objectAtIndex:index];
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
    
    UILabel *label_singer = [[UILabel alloc] initWithFrame:CGRectMake(530, 14, 150, 45)];
    [label_singer setBackgroundColor:[UIColor clearColor]];
    [label_singer setTextColor:[UIColor whiteColor]];
    [label_singer setTag:JDCellButtonTag_singerName];
    [label_songName setShadowColor:[UIColor grayColor]];
    [label_songName setShadowOffset:CGSizeMake(2, 2)];
    [label_singer setFont:[UIFont systemFontOfSize:20.0f]];
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
    [button_list setTag:JDCellButtonTag_list];
    [button_list addTarget:self action:@selector(didClickButton_cell:) forControlEvents:UIControlEventTouchUpInside];
    [button_background addSubview:button_list];
    
    UIButton *button_favorite = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_favorite setTag:JDCellButtonTag_favorite];
    [button_favorite addTarget:self action:@selector(didClickButton_cell:) forControlEvents:UIControlEventTouchUpInside];
    [button_background addSubview:button_favorite];
}
#pragma mark - 重置cell上内容 -
/**
 重置cell上内容
 **/
- (void)installCell:(UITableViewCell *)cell withSong:(SDSongs *)song
{
    UILabel *label_songName = (UILabel *)[cell viewWithTag:JDCellButtonTag_songName];
    [label_songName setText:song.songTitle];
    
    UILabel *label_singerName = (UILabel *)[cell viewWithTag:JDCellButtonTag_singerName];
    [label_singerName setText:song.songSingers];
    
    if(song.songBuyTag == 1)
    {
        UIImageView *imageView_pay = (UIImageView *)[cell viewWithTag:JDCellButtonTag_pay];
        [UIUtils didLoadImageNotCached:@"songs_icon_paid.png" inImageView:imageView_pay];
    }
    else
    {
        switch (song.int_price)
        {
            case 0:
            {
                UIImageView *imageView_pay = (UIImageView *)[cell viewWithTag:JDCellButtonTag_pay];
                [UIUtils didLoadImageNotCached:nil inImageView:imageView_pay];
            }break;
                
            case 20:
            {
                UIImageView *imageView_pay = (UIImageView *)[cell viewWithTag:JDCellButtonTag_pay];
                [UIUtils didLoadImageNotCached:@"songs_icon_vip_20.png" inImageView:imageView_pay];
            }break;
            case 50:
            {
                UIImageView *imageView_pay = (UIImageView *)[cell viewWithTag:JDCellButtonTag_pay];
                [UIUtils didLoadImageNotCached:@"songs_icon_vip_50.png" inImageView:imageView_pay];
            }break;
            default:
                break;
        }
    }
    
    UIButton *button_list = (UIButton *)[cell viewWithTag:JDCellButtonTag_list];
    if(song.songOrderTag == 1)
    {
        [UIUtils didLoadImageNotCached:@"songs_bar_btn_list.png" inButton:button_list withState:UIControlStateNormal];
    }
    else
    {
        [UIUtils didLoadImageNotCached:@"songs_bar_btn_list_added_new.png" inButton:button_list withState:UIControlStateNormal];
    }
    
    UIButton *button_favorite = (UIButton *)[cell viewWithTag:JDCellButtonTag_favorite];
    [button_favorite setFrame:CGRectMake(875, 10, 50, 50)];
    if(song.songFavoriteTag == 1)
    {
        [UIUtils didLoadImageNotCached:@"songs_bar_btn_favor_added.png" inButton:button_favorite withState:UIControlStateNormal];
    }
    else
    {
        [UIUtils didLoadImageNotCached:@"songs_bar_btn_favor.png" inButton:button_favorite withState:UIControlStateNormal];
    }
    
}

#pragma mark - cell上按钮点击回调 -
/**
 cell上按钮点击回调
 **/
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
            if(![[NSUserDefaults standardUserDefaults] objectForKey:@"token"])
            {
                CustomAlertView *alter = [[CustomAlertView alloc] initWithTitle:@"请先进行登陆" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alter show];
                [alter release];
                return;
            }
            
            self.song_buy = song;
            self.selectCell = cell;
            self.integer_tag = 3;
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleGetPermission:)
                                                         name:NOTI_GET_PERMISSION_RESULT
                                                       object:nil];
            
            [self.agent getPermission:_song_buy.songMd5 UserID:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
          
        }break;
          
        case JDCellButtonTag_play:
        {
            if(![[NSUserDefaults standardUserDefaults] objectForKey:@"token"])
            {
                CustomAlertView *alter = [[CustomAlertView alloc] initWithTitle:@"请先进行登陆" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alter show];
                [alter release];
                return;
            }
            
            self.song_buy = song;
            self.selectCell = cell;
            self.integer_tag = 3;
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleGetPermission:)
                                                         name:NOTI_GET_PERMISSION_RESULT
                                                       object:nil];
            
            [self.agent getPermission:_song_buy.songMd5 UserID:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
        }break;
            
        case JDCellButtonTag_list:
        {
            if(![[NSUserDefaults standardUserDefaults] objectForKey:@"token"])
            {
                CustomAlertView *alter = [[CustomAlertView alloc] initWithTitle:@"请先进行登陆" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alter show];
                [alter release];
                return;
            }
            
            JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
            [base selectSongandChangeItTag:song];
            if(song.songOrderTag == 1)
            {
                [UIUtils didLoadImageNotCached:@"songs_bar_btn_list_added_new.png" inButton:button_singer withState:UIControlStateNormal];
                [base deleteSongFormLocalSingerWithString:song withTag:2];
                song.songOrderTag = 0;
                [UIUtils view_showProgressHUD:@"已移出播放列表" inView:self.view withTime:1.0f];
                
            }
            else
            {
                self.song_buy = song;
                self.selectCell = cell;
                self.button_select = button_singer;
                self.integer_tag = 1;
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(handleGetPermission_order:)
                                                             name:NOTI_GET_PERMISSION_RESULT
                                                           object:nil];
                
                [self.agent getPermission:_song_buy.songMd5 UserID:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
            }
            
        }break;
            
        case JDCellButtonTag_favorite:
        {
            if(![[NSUserDefaults standardUserDefaults] objectForKey:@"token"])
            {
                CustomAlertView *alter = [[CustomAlertView alloc] initWithTitle:@"请先进行登陆" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alter show];
                [alter release];
                return;
            }
            
            self.integer_tag = 2;
            JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
            [base selectSongandChangeItTag:song];
            if(song.songFavoriteTag == 1)
            {
                [UIUtils didLoadImageNotCached:@"songs_bar_btn_favor.png" inButton:button_singer withState:UIControlStateNormal];
                [base deleteSongFormLocalSingerWithString:song withTag:1];
                song.songFavoriteTag = 0;
                [UIUtils view_showProgressHUD:@"已移出播收藏列表" inView:self.view withTime:1.0f];
                
            }
            else
            {
                self.song_buy = song;
                self.selectCell = cell;
                self.button_select = button_singer;
                self.integer_tag = 2;
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(handleGetPermission_favorite:)
                                                             name:NOTI_GET_PERMISSION_RESULT
                                                           object:nil];
                
                [self.agent getPermission:_song_buy.songMd5 UserID:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
                
                
            }
            [base release];

        }break;
        default:
            break;
    }
}

#pragma mark - 刷新K币 -
/**
 刷新K币
 **/
- (void)reloadKB
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleGetUserDetail:)
                                                 name:NOTI_GET_USER_DETAIL_RESULT
                                               object:nil];
    
    [_agent getUserDetail:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
}

#pragma mark - 刷新K币,消息回调 -
- (void)handleGetUserDetail:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    if([[state objectForKey:@"result"] length] > 0 && 0 == resultCode)
    {

        NSDictionary *accountInfo = [state objectForKey:@"account"];
        [[NSUserDefaults standardUserDefaults] setObject:[accountInfo objectForKey:@"kb"] forKey:@"money"];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NOTI_GET_USER_DETAIL_RESULT
                                                      object:nil];
       
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NOTI_GET_USER_DETAIL_RESULT
                                                      object:nil];
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
        
        JDMoviePlayerViewController *movePlay = [[JDMoviePlayerViewController alloc] initWithSong:self.song_buy];
        [movePlay setBool_isHistoryOrSearchSong:YES];
        movePlay.navigationController_return = _navigationController_return;
        [movePlay.view_alreadySong setBool_currentAlready:NO];
        [_navigationController_return pushViewController:movePlay animated:YES];
        [movePlay playBegin];
        [movePlay release];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NOTI_GET_PERMISSION_RESULT
                                                      object:nil];
        
        [self performSelectorInBackground:@selector(reloadKB) withObject:nil];
        [self installView_payView];
    }
}

#pragma mark - 点歌鉴权 -
/**
 收藏鉴权
 **/
- (void)handleGetPermission_order:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    if([[state objectForKey:@"result"] length] > 0 && 0 == resultCode)
    {
        JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
        [base selectSongandChangeItTag:_song_buy];
        _song_buy.songOrderTag = 1;
        if([base saveSong:_song_buy withTag:2])
        {
            [UIUtils didLoadImageNotCached:@"songs_bar_btn_list.png" inButton:_button_select withState:UIControlStateNormal];
            [UIUtils view_showProgressHUD:@"已添加至播放列表" inView:self.view withTime:1.0f];
        }
        [base release];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NOTI_GET_PERMISSION_RESULT
                                                      object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NOTI_GET_PERMISSION_RESULT
                                                      object:nil];
        
        [self performSelectorInBackground:@selector(reloadKB) withObject:nil];
        [self installView_payView];
    }
}

#pragma mark - 收藏鉴权 -
/**
 收藏鉴权
 **/
- (void)handleGetPermission_favorite:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    if([[state objectForKey:@"result"] length] > 0 && 0 == resultCode)
    {
        JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
        [base selectSongandChangeItTag:_song_buy];
        _song_buy.songFavoriteTag = 1;
        if([base saveSong:_song_buy withTag:1])
        {
            [UIUtils didLoadImageNotCached:@"songs_bar_btn_favor_added.png" inButton:_button_select withState:UIControlStateNormal];
            [UIUtils view_showProgressHUD:@"已添加至收藏列表" inView:self.view withTime:1.0f];

        }
        [base release];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NOTI_GET_PERMISSION_RESULT
                                                      object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NOTI_GET_PERMISSION_RESULT
                                                      object:nil];
        
        [self performSelectorInBackground:@selector(reloadKB) withObject:nil];
        [self installView_payView];
        
    }
    
}


#pragma mark - 获取父类视图 -
/**
 获取父类视图
 **/
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

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    JDSearchViewController *search = [[JDSearchViewController alloc]initWithKeyword:textField.text];
    search.navigationController_return = self.navigationController_return;
    [textField resignFirstResponder];
    [self.navigationController_return pushViewController:search animated:YES];
    [search release];
    return YES;
}

#pragma mark - 初始化支付界面 -
/**
 初始化支付界面
 **/
- (void)installView_payView
{
    JDSongPayView *payView = [[JDSongPayView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [payView setDelegate:self];
    [self.view addSubview:payView];
    [payView showAnimated];
    [payView release];
}

#pragma mark - 买歌回调 JDSongPayViewDelegate -
/**
 购买单曲
 **/
- (void)delegate_didClickButtonBuySong
{
    [UIUtils view_showProgressHUD:@"购买中，请稍候..." forWaitInView:self.view];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleBuySong:)
                                                 name:NOTI_BUY_SONG_RESULT
                                               object:nil];
    
    [_agent buySong:_song_buy.songMd5 Price:_song_buy.int_price UserID:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
}

#pragma mark - 启用时长卡 -
/**
 启用时长卡
 **/
- (void)delegate_didClickButtonUseCard:(NSString *)string_CardID
{
    [UIUtils view_showProgressHUD:@"开启中，请稍候..." forWaitInView:self.view];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleStartTimeCardResult:)
                                                 name:NOTI_START_TIME_CARD_RESULT
                                               object:nil];
    [_agent startTimeCard:string_CardID
                   UserID:[JDModel_userInfo sharedModel].string_userID
                    Token:[JDModel_userInfo sharedModel].string_token];
}


#pragma mark - 启用时长卡的反馈处理 -
/**
 * 启用时长卡的反馈处理
 */
- (void)handleStartTimeCardResult:(NSNotification *)note
{
    [UIUtils view_hideProgressHUDinView:self.view];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTI_START_TIME_CARD_RESULT
                                                  object:nil];
    
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    CustomAlertView *alertDialog;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    if([[state objectForKey:@"result"] length] > 0 && 0 == resultCode)
    {
        alertDialog = [[CustomAlertView alloc] initWithTitle:@"成功"
                                                     message:@"激活时长卡成功"
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        
        if(_integer_tag == 3)
        {
            JDMoviePlayerViewController *movePlayer = [[JDMoviePlayerViewController alloc] initWithSong:_song_buy];
            [movePlayer setBool_isHistoryOrSearchSong:YES];
            [movePlayer.view_alreadySong setBool_currentAlready:NO];
            movePlayer.navigationController_return = _navigationController_return;
            [_navigationController_return pushViewController:movePlayer animated:YES];
            [movePlayer playBegin];
            [movePlayer release];
            
            UIImageView *imageView_pay = (UIImageView *)[self.selectCell viewWithTag:JDCellButtonTag_pay];
            [UIUtils didLoadImageNotCached:@"songs_icon_paid.png" inImageView:imageView_pay];
            
        }
        else if(_integer_tag == 2)
        {
            [UIUtils didLoadImageNotCached:@"songs_bar_btn_favor_added.png" inButton:_button_select withState:UIControlStateNormal];
            [UIUtils view_showProgressHUD:@"已添加至收藏列表" inView:self.view withTime:1.0f];
            
            UIImageView *imageView_pay = (UIImageView *)[self.selectCell viewWithTag:JDCellButtonTag_pay];
            [UIUtils didLoadImageNotCached:@"songs_icon_paid.png" inImageView:imageView_pay];
            
            JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
            _song_buy.songFavoriteTag = 1;
            _song_buy.songBuyTag = 1;
            [base saveSong:_song_buy withTag:0];
            [base saveSong:_song_buy withTag:1];
            [base release];
            
        }
        else if(_integer_tag == 1)
        {
            [UIUtils didLoadImageNotCached:@"songs_bar_btn_list.png" inButton:_button_select withState:UIControlStateNormal];
            [UIUtils view_showProgressHUD:@"已添加至播放列表" inView:self.view withTime:1.0f];
            
            UIImageView *imageView_pay = (UIImageView *)[self.selectCell viewWithTag:JDCellButtonTag_pay];
            [UIUtils didLoadImageNotCached:@"songs_icon_paid.png" inImageView:imageView_pay];
            
            JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
            _song_buy.songBuyTag = 1;
            [base saveSong:_song_buy withTag:0];
            _song_buy.songOrderTag = 1;
            [base saveSong:_song_buy withTag:2];
            [base release];
        }
    }
    else
    {
        alertDialog = [[CustomAlertView alloc] initWithTitle:@"失败"
                                                     message:[state objectForKey:@"msg"]
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        
    }
    
    [alertDialog show];
    [alertDialog release];
}


#pragma mark - 购买单曲成功消息回调 -
/**
 购买单曲成功消息回调
 **/
- (void)handleBuySong:(NSNotification *)note
{
    [UIUtils view_hideProgressHUDinView:self.view];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTI_BUY_SONG_RESULT
                                                  object:nil];
    
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    if([[state objectForKey:@"result"] length] > 0 && 0 == resultCode)
    {
        if(_integer_tag == 3)
        {
            JDMoviePlayerViewController *movePlayer = [[JDMoviePlayerViewController alloc] initWithSong:_song_buy];
            [movePlayer setBool_isHistoryOrSearchSong:YES];
            [movePlayer.view_alreadySong setBool_currentAlready:NO];
            movePlayer.navigationController_return = _navigationController_return;
            [_navigationController_return pushViewController:movePlayer animated:YES];
            [movePlayer playBegin];
            [movePlayer release];
            
            UIImageView *imageView_pay = (UIImageView *)[self.selectCell viewWithTag:JDCellButtonTag_pay];
            [UIUtils didLoadImageNotCached:@"songs_icon_paid.png" inImageView:imageView_pay];
            
            JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
            _song_buy.songBuyTag = 1;
            [base saveSong:_song_buy withTag:0];
            [base release];
        }
        else if(_integer_tag == 2)
        {
            [UIUtils didLoadImageNotCached:@"songs_bar_btn_favor_added.png" inButton:_button_select withState:UIControlStateNormal];
            [UIUtils view_showProgressHUD:@"已添加至收藏列表" inView:self.view withTime:1.0f];
            
            UIImageView *imageView_pay = (UIImageView *)[self.selectCell viewWithTag:JDCellButtonTag_pay];
            [UIUtils didLoadImageNotCached:@"songs_icon_paid.png" inImageView:imageView_pay];
            
            JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
            _song_buy.songFavoriteTag = 1;
            _song_buy.songBuyTag = 1;
            [base saveSong:_song_buy withTag:0];
            [base saveSong:_song_buy withTag:1];
            [base release];
            
        }
        else if(_integer_tag == 1)
        {
            [UIUtils didLoadImageNotCached:@"songs_bar_btn_list.png" inButton:_button_select withState:UIControlStateNormal];
            [UIUtils view_showProgressHUD:@"已添加至播放列表" inView:self.view withTime:1.0f];
            
            UIImageView *imageView_pay = (UIImageView *)[self.selectCell viewWithTag:JDCellButtonTag_pay];
            [UIUtils didLoadImageNotCached:@"songs_icon_paid.png" inImageView:imageView_pay];
            
            JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
            _song_buy.songBuyTag = 1;
            [base saveSong:_song_buy withTag:0];
            _song_buy.songOrderTag = 1;
            [base saveSong:_song_buy withTag:2];
            [base release];
        }
        
    }
    else
    {
        CustomAlertView *alter = [[CustomAlertView alloc] initWithTitle:@"购买失败"
                                                                message:[state objectForKey:@"msg"]
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
        [alter show];
        [alter release];
        
        
    }
}

@end
