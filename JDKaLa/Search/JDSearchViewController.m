//
//  JDSearchViewController.m
//  JDKaLa
//
//  Created by 韩 抗 on 13-9-27.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import "JDSearchViewController.h"
#import "SKCustomNavigationBar.h"
#import "JDSqlDataBase.h"
#import "UIImageView+WebCache.h"
#import "JDModel_userInfo.h"
#import "JDAlreadySongView.h"
#import "JDSingerSongViewController.h"
#import "CustomAlertView.h"
#import "UIUtils.h"
#import "SDSingers.h"
#import "JDSingerCell.h"
//#import "SDMoviePlayerViewController.h"
#import "JDMoviePlayerViewController.h"


#define JDLINKMOVIEDOWNSTART @"http://ep.iktv.tv/songs/"

typedef enum
{
    JDCellButtonTag_songName         = 50000,
    JDCellButtonTag_singerName              ,
    JDCellButtonTag_background              ,
    JDCellButtonTag_pay                     ,
    JDCellButtonTag_play                    ,
    JDCellButtonTag_list                    ,
    JDCellButtonTag_favorite                ,
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


@interface JDSearchViewController ()

@end

@implementation JDSearchViewController

#define SECTION_SINGER  0
#define SECTION_SONG    1
#define SECTION_COUNT   2
#define ITEMS_COUNT_PER_ROW 5
#define TAG_OF_SINGER_ICON(x)  (10000 + x)
#define TAG_OF_SINGER_BACK(x)  (20000 + x)
#define TAG_OF_SINGER_NAME(x)  (30000 + x)
#define TAG_OF_SINGER_BTN(x)   (40000 + x)
#define SINGER_IDX_FROM_TAG(x)  (x - 40000)

#define JDLINKPHOTO @"http://ep.iktv.tv/api/kod/singers/"


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithKeyword:(NSString*)keyword
{
    self = [super init];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadTitleView:)
                                                     name:@"JDSongStateChange_order"
                                                   object:nil];
        [self configureView_background];
        [self configureView_title];
        self.keyword = keyword;
        [self performSelectorInBackground:@selector(installSearchResultViewInBack:) withObject:keyword];
        [UIUtils view_showProgressHUD:@"正在搜索..." forWaitInView:self.view];
        self.agent = [[ClientAgent alloc] init];
    }
    return self;
}

- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"JDSongStateChange_order"
                                                  object:nil];
    [_selectCell release], _selectCell = nil;
    [songResult release], songResult = nil;
    [singerResult release], singerResult = nil;
    [_agent release], _agent = nil;
    [_button_select release], _button_select = nil;
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureView_background
{
    UIImageView *imageView_background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 1024, 700)];
    IOS7(imageView_background);
    [UIUtils didLoadImageNotCached:@"mainView_background.png" inImageView:imageView_background];
    [self.view addSubview:imageView_background];
    [imageView_background release];
}

#pragma mark - ConfigureView
- (void)configureView_title
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
    
    UILabel *label_title = [[UILabel alloc] initWithFrame:CGRectMake(145, 0, 135, 50)];
    [label_title setBackgroundColor:[UIColor clearColor]];
    [label_title setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:30.0f]];
    [label_title setTextColor:[UIColor whiteColor]];
    [label_title setText:@"搜索"];
    [view_title addSubview:label_title];
    [label_title release];
    
    UIButton *button_master = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_master setFrame:CGRectMake(10, 7, 65, 37)];
    [UIUtils didLoadImageNotCached:@"back_btn.png" inButton:button_master withState:UIControlStateNormal];
    [customNavigationBar addSubview:button_master];
    [button_master addTarget:self action:@selector(dismissSelfView:) forControlEvents:UIControlEventTouchUpInside];
    
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
    self.keywordInput = text_search;
    
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
    [label_number setText:[NSString stringWithFormat:@"%d",[array_base count]]];
    [button_already addSubview:label_number];
    [label_number release];
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


/**
 * 创建搜索结果显示表
 */
- (void)configureView_table
{
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, 1024, 700) style:UITableViewStylePlain];
    IOS7(table);
    [table setDataSource:self];
    [table setDelegate:self];
    [table setBackgroundColor:[UIColor clearColor]];
    [table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:table];
    _resultTable = table;
    [table release];
}

//关闭窗口
- (void)dismissSelfView:(id)sender
{
    [_navigationController_return popViewControllerAnimated:YES];
    //NSLog(@"DismissView\n");
    //[self dismissViewControllerAnimated:YES completion:nil];
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
            UIImageView *imageView_sanjiao = [[UIImageView alloc] initWithFrame:CGRectMake(673, 50, 20, 9)];
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

- (void)reloadTitleView:(NSNotification *)note
{
    NSInteger count1 = [label_total.text integerValue];
    NSInteger count2 = [(NSString *)[note object] integerValue];
    label_total.text = [NSString stringWithFormat:@"%d",count1 + count2];
}

/**
 * 搜索关键字
 */
- (void)searchKeyword:(NSString *)keyword
{
    [singerResult release];
    [songResult release];
    
    singerResult = [self searchSingerWithTag:keyword];
    [singerResult retain];
    
    songResult = [self searchSongWithTag:keyword];
    [songResult retain];
    
    for(SDSongs *song in songResult)
    {
        NSLog(@"song:%@\n", song.songTitle);
    }
    
}

- (void)installSearchResultViewInBack:(NSString *)keyword
{
    [self searchKeyword:keyword];
    [self configureView_table];
    [UIUtils view_hideProgressHUDinView:self.view];
}

#pragma mark - Database Operation
/**
 * 从歌手表中执行SQL语句进行搜索
 */
-(NSMutableArray *)querySingerWithSQL:(NSString *)string
{
    JDSqlDataBase *dataController = [[JDSqlDataBase alloc] init];
    NSMutableArray *singerArray = [dataController reciveDataBaseWithStringFromSinger:string];
    [dataController release];
    return singerArray;
}

/**搜人名**/
- (NSMutableArray*)searchSingerWithTag:(NSString*)tag
{
    NSString *escapeTag = [tag stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *sql = [NSString stringWithFormat:
                     @"select * from client_singers where tags like '%@%%' or tags like '#%@%%' or name like '%@%%' order by tags", escapeTag, escapeTag, escapeTag];
    //NSString *sql_china = [NSString stringWithFormat:
    //                       @"select * from client_singers where name like '%@%%'",tag];
    
    NSMutableArray *resultArray = [self querySingerWithSQL:sql];
    //NSMutableArray *arrayChina = [self querySingerWithSQL:sql_china];
    
    //[resultArray addObjectsFromArray:arrayChina];
    
    return resultArray;
}

/**
 * 从歌曲表中执行SQL语句进行搜索
 */
- (NSMutableArray *)querySongWithSQL:(NSString *)string
{
    JDSqlDataBase *dataController = [[JDSqlDataBase alloc] init];
    NSMutableArray *songArray = [dataController reciveDataBaseWithString:string];
    [dataController release];
    return songArray;
}

/**
 * 搜曲名
 */
- (NSMutableArray*)searchSongWithTag:(NSString*)tag
{
    NSString *escapeTag = [tag stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *sql = [NSString stringWithFormat:
                     @"select * from client_songs where (tags like '%@%%' or title like '%@%%') and media_type is not null order by tags", escapeTag, escapeTag];
    //NSString *sql_china = [NSString stringWithFormat:
    //                       @"select * from client_songs where title like '%@%%' and media_type is not null order by tags", escapeTag];
    
    //NSLog(@"sql:%@", sql);
    NSMutableArray *resultArray = [self querySongWithSQL:sql];
    //NSMutableArray *array_china = [self querySongWithSQL:sql_china];
    //[resultArray addObjectsFromArray:array_china];
    //if([resultArray count] == 0)
    //{
        //SDSongs *song = [[SDSongs alloc] init];
        //song.songTitle = @"暂无";
        //[resultArray addObject:song];
        //[song release];
    //}
    //NSLog(@"Song search result count:%d\n", [resultArray count]);
    return resultArray;
}

/**
 * 根据歌手号搜歌曲
 */
- (NSMutableArray *)querySongBySinger:(NSString *)_string
{
    NSString *escapeTag = [_string stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *sql = [NSString stringWithFormat:@"select * from client_songs where singers_no like '%%%%%@%%%%'", escapeTag];
    NSMutableArray *resultArray = [self querySongWithSQL:sql];
    return resultArray;
}

#pragma mark - TableView Delegate

//返回分区个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //IOS7(tableView);
    return SECTION_COUNT;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    if(SECTION_SINGER == section)
    {
        return nil;
    }
    else
    {
        return @"歌曲列表";
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle=[self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle==nil)
    {
        // Create header view and add label as a subview
        UIView *sectionView=[[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)] autorelease];
        [sectionView setBackgroundColor:[UIColor clearColor]];
        return sectionView;
    }
    
    // Create label with section title
    UILabel *label=[[[UILabel alloc] init] autorelease];
    label.frame=CGRectMake(0, 0, tableView.bounds.size.width, 30);
    label.backgroundColor=[UIColor clearColor];
    label.textColor=[UIColor darkGrayColor];
    label.textAlignment=NSTextAlignmentCenter;
    //label.font=[UIFont fontWithName:@"Helvetica-Bold" size:16];
    label.text=sectionTitle;
    
    // Create header view and add label as a subview
    UIView *sectionView=[[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)] autorelease];
    [sectionView setBackgroundColor:[UIColor clearColor]];
    [sectionView addSubview:label];
    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(SECTION_SINGER == indexPath.section)
    {
        return 220;
    }
    else
    {
        return 85;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(SECTION_SINGER == section)
    {
        if([singerResult count] % ITEMS_COUNT_PER_ROW == 0)
        {
            return [singerResult count] / ITEMS_COUNT_PER_ROW;
        }
        else
        {
            return [singerResult count] / ITEMS_COUNT_PER_ROW + 1;
        }
        
    }
    else
    {
        return [songResult count];
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Step 1: Check to see if we can reuse a cell from a row that has just rolled off the screen
    static NSString *SongCellIdentifier = @"SongCellIdentifier";
    static NSString *SingerCellIdentifier = @"SingerCellIdentifier";
    
    if(SECTION_SINGER == indexPath.section)
    {        
        JDSingerCell *cell = [tableView dequeueReusableCellWithIdentifier:SingerCellIdentifier];
        
        if(cell == nil)
        {
            cell = [[[JDSingerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SingerCellIdentifier] autorelease];
            [cell setBackgroundColor:[UIColor clearColor]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        int rowStartIdx = indexPath.row * ITEMS_COUNT_PER_ROW;
        int i;
        
        if(![cell Inited])
        {
            [self createSingerCell:cell sinerIdx:rowStartIdx];
        }
        
        for(i = 0; i < ITEMS_COUNT_PER_ROW; ++i)
        {
            UIImageView *iconView = (UIImageView *)[cell viewWithTag:TAG_OF_SINGER_ICON(rowStartIdx + i)];
            UIImageView * backView = (UIImageView *)[cell viewWithTag:TAG_OF_SINGER_BACK(rowStartIdx + i)];
            UILabel *nameLabel = (UILabel*)[cell viewWithTag:TAG_OF_SINGER_NAME(rowStartIdx + i)];
            if(rowStartIdx + i < [singerResult count])
            {
                SDSingers *singer = [singerResult objectAtIndex:rowStartIdx + i];
                [backView setImage:[UIImage imageNamed:@"singerBack.png"]];
                [iconView setImageWithURL:[NSURL URLWithString:singer.string_portrait]];
                [nameLabel setText:[singer singerName]];
            }
            else
            {
                
                [backView setImage:nil];
                [iconView setImage:nil];
                [nameLabel setText:nil];
                
            }
        }
        return cell;
    }
    else
    {        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SongCellIdentifier];
        
        if(cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SongCellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setBackgroundColor:[UIColor clearColor]];
            [self createSongCell:cell withIndex:indexPath.row];
        }
        
        [self installSongCell:cell withSong:[songResult objectAtIndex:indexPath.row]];
        return cell;
    }
}

//创建显示歌手的表格cell
- (void)createSingerCell:(JDSingerCell *)cell sinerIdx:(int)idx
{
    //以下2句可将Grouped style下的单元格背景设为空
    UIView *tempView = [[[UIView alloc] init] autorelease];
    [cell setBackgroundView:tempView];
    
    for (int i = 0; i < ITEMS_COUNT_PER_ROW; i++)
    {
        UIImageView *imageView_portrait = [[UIImageView alloc] initWithFrame:CGRectMake(20 + i * 195, 15, 170, 190)];
        [imageView_portrait setTag:TAG_OF_SINGER_ICON(idx + i)];
        [imageView_portrait setContentMode:UIViewContentModeScaleAspectFit];
        [cell addSubview:imageView_portrait];
        cell.Inited = YES;
        [imageView_portrait release];
        
        UIImageView *imageView_firstBack = [[UIImageView alloc] initWithFrame:CGRectMake(20 + i * 195, 15, 175, 200)];
        [imageView_firstBack setImage:[UIImage imageNamed:@"singerBack.png"]];
        [imageView_firstBack setTag:TAG_OF_SINGER_BACK(idx + i)];
        [cell addSubview:imageView_firstBack];
        [imageView_firstBack release];
        
        UILabel *label_singerName = [[UILabel alloc] initWithFrame:CGRectMake(5, 165, 150, 30)];
        [label_singerName setTextAlignment:NSTextAlignmentLeft];
        [label_singerName setTextColor:[UIColor whiteColor]];
        [label_singerName setBackgroundColor:[UIColor clearColor]];
        [label_singerName setFont:[UIFont systemFontOfSize:18.0f]];
        [label_singerName setTag:TAG_OF_SINGER_NAME(idx + i)];
        [imageView_firstBack addSubview:label_singerName];
        [label_singerName release];
        
        UIButton *btnSinger = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnSinger setFrame:CGRectMake(20 + i*195, 15, 175, 200)];
        [btnSinger setTag:TAG_OF_SINGER_BTN(idx + i)];
        [btnSinger addTarget:self action:@selector(didClickSinger:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btnSinger];
    }
}

/**
 * 创建显示歌曲的表格Cell
 */
- (void)createSongCell:(UITableViewCell *)cell withIndex:(NSInteger)index
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

/**
 * 填充歌曲cell上内容
 **/
- (void)installSongCell:(UITableViewCell *)cell withSong:(SDSongs *)song
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

//歌手图标被点击的处理函数
- (void)didClickSinger:(id)sender
{
    NSLog(@"Click button singer: %d.\n", SINGER_IDX_FROM_TAG([sender tag]));
    int     singerIdx = SINGER_IDX_FROM_TAG([sender tag]);
    
    if(singerIdx >= [singerResult count])
        return;
    
    SDSingers *singer = [singerResult objectAtIndex:singerIdx];
    
    JDSingerSongViewController *songController = [[JDSingerSongViewController alloc] initWithTitleString:singer.singerName];
    songController.navigationController_return = _navigationController_return;
    
    NSMutableArray *array_tmp = [self querySongBySinger:singer.singerNo];
    
    JDSqlDataBase *dataController = [[JDSqlDataBase alloc] init];
    [dataController selectSongandChangeItTagWithArray:array_tmp];
    [dataController release];
    
    songController.array_data = array_tmp;
    [_navigationController_return pushViewController:songController animated:YES];
    //[self presentViewController:songController animated:NO completion:nil];
    [songController release];
}

#pragma mark - cell上按钮点击回调 -
/**
 Song cell上按钮点击回调
 **/
- (void)didClickButton_cell:(id)sender
{
    UIButton *button_singer = (UIButton *)sender;
    UITableViewCell *cell = [self reciveSuperCellWithView:button_singer];
    UITableView *tableView = [self reciveSuperTableWithView:cell];
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    SDSongs *song = [songResult objectAtIndex:indexPath.row];
    
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

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.keywordInput resignFirstResponder];
    [self searchKeyword:[textField text]];
    [_resultTable reloadData];
    return YES;
}




@end
