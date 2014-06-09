//
//  JDSingerKindViewController.m
//  JDKaLa
//
//  Created by zhangminglei on 4/7/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDSingerKindViewController.h"
#import "SKCustomNavigationBar.h"
#import "JDMasterViewController.h"
#import "SKRevealSideViewController.h"
#import "SDSingers.h"
#import "UIImageView+WebCache.h"
#import "JDSingerSongViewController.h"
#import "JDSqlDataBase.h"
#import "UIUtils.h"
#import "JDModel_userInfo.h"
#import "JDAlreadySongView.h"
#import "CustomAlertView.h"
#import "JDSearchViewController.h"

#define JDLINKPHOTO @"http://ep.iktv.tv/api/kod/singers/"

@interface JDSingerKindViewController ()

@end

@implementation JDSingerKindViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (id)initWithString:(NSString *)_string_title andDataArray:(NSMutableArray *)_array andTag:(JDTableViewTag )_tag
{
    self = [super init];
    if(self)
    {
        self.array_tableData = _array;
        [self configureView_background];
        [self configureView_tableWithTag:_tag];
        [self configureView_title:_string_title];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTitleView:)
                                                 name:@"JDSongStateChange_order"
                                               object:nil];
    
    
    self.bool_extension = NO;
    self.bool_oneTime = YES;
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(_bool_oneTime)
    {
        if([JDModel_userInfo sharedModel].bool_hasMaster)
        {
            [self didClickButton_master];
            [JDModel_userInfo sharedModel].bool_hasMaster = ![JDModel_userInfo sharedModel].bool_hasMaster;
            _bool_oneTime = NO;
        }
    }
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
    [_array_data release], _array_data = nil;
    [_array_tableData release], _array_tableData = nil;
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
    
    UILabel *label_titel = [[UILabel alloc]initWithFrame:CGRectMake(130, 0, 200, 50)];
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
    [button_master setFrame:CGRectMake(10, 3, 63, 37)];
    [UIUtils didLoadImageNotCached:@"title_bar_btn_menu.png"inButton:button_master withState:UIControlStateNormal];
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
            if([JDModel_userInfo sharedModel].bool_hasMaster)
            {
                [songView setFrame:CGRectMake(363, 59, 348, 593)];
                [imageView_sanjiao setFrame:CGRectMake(363, 50, 20, 9)];
            }
            IOS7(songView);
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

- (void)reloadTitleView:(NSNotification *)note
{
    NSInteger count1 = [label_total.text integerValue];
    NSInteger count2 = [(NSString *)[note object] integerValue];
    label_total.text = [NSString stringWithFormat:@"%d",count1 + count2];
}

- (void)configureView_tableWithTag:(JDTableViewTag)_tag
{
    self.array_data = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#",nil];
    if(_bool_extension)
    {
        UITableView *table_singer = [[UITableView alloc] initWithFrame:CGRectMake(0, 53, 1024, 695) style:UITableViewStylePlain];
        IOS7(table_singer);
        if(IOS7_VERSION)
        {
            [table_singer setSectionIndexColor:[UIColor darkGrayColor]];
            [table_singer setSectionIndexBackgroundColor:[UIColor clearColor]];
        }
        [table_singer setDataSource:self];
        [table_singer setDelegate:self];
        [table_singer setTag:30];
        [table_singer setBackgroundColor:[UIColor clearColor]];
        [table_singer setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.view addSubview:table_singer];
        [table_singer release];
    }
    else
    {
        UITableView *table_singer = [[UITableView alloc] initWithFrame:CGRectMake(0, 53, 744, 695) style:UITableViewStylePlain];
        IOS7(table_singer);
        if(IOS7_VERSION)
        {
            //[table_singer setFrame:CGRectMake(0, 53, 740, 695)];
            [table_singer setSectionIndexColor:[UIColor darkGrayColor]];
            [table_singer setSectionIndexBackgroundColor:[UIColor clearColor]];
        }
        [table_singer setDataSource:self];
        [table_singer setDelegate:self];
        [table_singer setTag:31];
        [table_singer setBackgroundColor:[UIColor clearColor]];
        [table_singer setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.view addSubview:table_singer];
        [table_singer release];
    }
}

- (void)configureView_background
{
    UIImageView *imageView_background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 1024, 749)];
    [UIUtils didLoadImageNotCached:@"mainView_background.png" inImageView:imageView_background];
    [self.view addSubview:imageView_background];
    [imageView_background release];
}

#pragma mark - DidClickButton
- (void)didClickButton_master
{
    [JDModel_userInfo sharedModel].bool_hasMaster = ![JDModel_userInfo sharedModel].bool_hasMaster;
    
    if(self.bool_already)
    {
        JDAlreadySongView *view = (JDAlreadySongView *)[self.view viewWithTag:100];
        [view removeFromSuperview];
        UIImageView *imageView = (UIImageView *)[self.view viewWithTag:101];
        [imageView removeFromSuperview];
        self.bool_already = !self.bool_already;
    }
    
    JDMasterViewController *masterViewController = [JDMasterViewController sharedController];
    [self.revealSideViewController pushViewController:masterViewController onDirection:PPRevealSideDirectionLeft withOffset:478.0 animated:YES];
    self.revealSideViewController.panInteractionsWhenClosed = PPRevealSideInteractionNone;
    self.revealSideViewController.panInteractionsWhenOpened = PPRevealSideInteractionNone;
    
    if(_bool_extension)
    {
        UIView *tmp = (UIView *)[self.view viewWithTag:70];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationRepeatCount:1];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDelegate:self];
        tmp.center = CGPointMake(tmp.center.x + 300,tmp.center.y);
        [UIView commitAnimations];
    }
    else
    {
        UIView *tmp = (UIView *)[self.view viewWithTag:70];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationRepeatCount:1];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDelegate:self];
        tmp.center = CGPointMake(tmp.center.x - 300,tmp.center.y);
        [UIView commitAnimations];
    }
    _bool_extension = !_bool_extension;
    
    if(!_bool_oneTime)
    {
        UITableView *tabelView_ex = (UITableView *)[self.view viewWithTag:30];
        if(tabelView_ex)
        {
            [tabelView_ex setTag:31];
            [tabelView_ex setFrame:CGRectMake(tabelView_ex.frame.origin.x, tabelView_ex.frame.origin.y, 744, tabelView_ex.frame.size.height)];
            [tabelView_ex reloadData];
        }
        else
        {
            UITableView *tabelView_nex = (UITableView *)[self.view viewWithTag:31];
            [tabelView_nex setTag:30];
            [tabelView_nex setFrame:CGRectMake(tabelView_nex.frame.origin.x, tabelView_nex.frame.origin.y, 1024, tabelView_nex.frame.size.height)];
            [tabelView_nex reloadData];
        }
    }
}

#pragma mark - UITableViewDataSource and UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView.tag == 30)
    {
        if([[_array_tableData objectAtIndex:section] count]%5 == 0)
        {
            return [[_array_tableData objectAtIndex:section] count]/5;
        }
        else
        {
            return [[_array_tableData objectAtIndex:section] count]/5+1;
        }
    }
    else
    {
        if([[_array_tableData objectAtIndex:section] count]%4 == 0)
        {
            return [[_array_tableData objectAtIndex:section] count]/4;
        }
        else
        {
            return [[_array_tableData objectAtIndex:section] count]/4+1;
        }
    }
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 30)
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            [cell setBackgroundColor:[UIColor clearColor]];
            [self installTableCell:cell forTableView:tableView withIndex:indexPath.row];
        }
        
        NSMutableArray *arraySection = [_array_tableData objectAtIndex:indexPath.section];
        NSMutableArray *array_tmp = [[NSMutableArray alloc]initWithCapacity:5];
        if(indexPath.row*5 + 5 <= [arraySection count])
        {
            for(int i = indexPath.row*5; i<(indexPath.row+1)*5; i++)
            {
                [array_tmp addObject:[arraySection objectAtIndex:i]];
            }
        }
        else
        {
            int j = [arraySection count] - indexPath.row*5;
            for (int i = indexPath.row*5; i<indexPath.row*5 + j; i++)
            {
                [array_tmp addObject:[arraySection objectAtIndex:i]];
            }
        }
        [self installTableCell:cell forTableView:tableView withIndex:indexPath.row withArray:array_tmp];
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"Cell_extension";
        UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            [cell setBackgroundColor:[UIColor clearColor]];
            [self installTableCell:cell forTableView:tableView withIndex:indexPath.row];
        }
        
        NSMutableArray *arraySection = [_array_tableData objectAtIndex:indexPath.section];
        NSMutableArray *array_tmp = [[NSMutableArray alloc]initWithCapacity:4];
        if(indexPath.row*4 + 4 <= [arraySection count])
        {
            for(int i = indexPath.row*4; i<(indexPath.row+1)*4; i++)
            {
                [array_tmp addObject:[arraySection objectAtIndex:i]];
            }
        }
        else
        {
            int j = [arraySection count] - indexPath.row*4;
            for (int i = indexPath.row*4; i<indexPath.row*4 + j; i++)
            {
                [array_tmp addObject:[arraySection objectAtIndex:i]];
            }
        }
        [self installTableCell:cell forTableView:tableView withIndex:indexPath.row withArray:array_tmp];
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
}

- (void)installTableCell:(UITableViewCell *)cell forTableView:(UITableView *)table withIndex:(NSInteger)index
{
    if(table.tag == 30)
    {
        for (int i = 0; i < 5; i++)
        {
            UIImageView *imageView_portrait = [[UIImageView alloc] initWithFrame:CGRectMake(15 + i*195, 15, 170, 190)];
            [imageView_portrait setContentMode:UIViewContentModeScaleAspectFit];
            [imageView_portrait setTag:i+5];
            [cell addSubview:imageView_portrait];
            [imageView_portrait release];
            
            UIImageView *imageView_firstBack = [[UIImageView alloc] initWithFrame:CGRectMake(15+i*195, 15, 175, 196)];
            [UIUtils didLoadImageNotCached:@"singerBack.png" inImageView:imageView_firstBack];
            [imageView_firstBack setTag:i+15];
            [cell addSubview:imageView_firstBack];
            [imageView_firstBack release];
            
            UILabel *label_singerName = [[UILabel alloc] initWithFrame:CGRectMake(5, 160, 150, 30)];
            [label_singerName setTextAlignment:NSTextAlignmentLeft];
            [label_singerName setTextColor:[UIColor whiteColor]];
            [label_singerName setShadowColor:[UIColor grayColor]];
            [label_singerName setShadowOffset:CGSizeMake(2, 2)];
            [label_singerName setBackgroundColor:[UIColor clearColor]];
            [label_singerName setFont:[UIFont systemFontOfSize:18.0f]];
            [label_singerName setTag:i+10];
            [imageView_firstBack addSubview:label_singerName];
            [label_singerName release];
            
            UIButton *button_firstSinger = [UIButton buttonWithType:UIButtonTypeCustom];
            [button_firstSinger setFrame:CGRectMake(15 + i*195, 15, 180, 180)];
            [button_firstSinger setTag:i];
            [button_firstSinger addTarget:self action:@selector(didClickSinger:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button_firstSinger];
        }
    }
    else
    {
        for (int i = 0; i < 4; i++)
        {
            UIImageView *imageView_portrait = [[UIImageView alloc] initWithFrame:CGRectMake(5 + i*180, 15, 170, 190)];
            [imageView_portrait setContentMode:UIViewContentModeScaleAspectFit];
            [imageView_portrait setTag:i+5];
            [cell addSubview:imageView_portrait];
            [imageView_portrait release];
            
            UIImageView *imageView_firstBack = [[UIImageView alloc] initWithFrame:CGRectMake(5 + i*180, 15, 175, 196)];
            [UIUtils didLoadImageNotCached:@"singerBack.png" inImageView:imageView_firstBack];
            [imageView_firstBack setTag:i + 15];
            [cell addSubview:imageView_firstBack];
            [imageView_firstBack release];
            
            UILabel *label_singerName = [[UILabel alloc] initWithFrame:CGRectMake(5, 160, 150, 30)];
            [label_singerName setTextAlignment:NSTextAlignmentLeft];
            [label_singerName setTextColor:[UIColor whiteColor]];
            [label_singerName setBackgroundColor:[UIColor clearColor]];
            [label_singerName setFont:[UIFont systemFontOfSize:18.0f]];
            [label_singerName setShadowColor:[UIColor grayColor]];
            [label_singerName setShadowOffset:CGSizeMake(2, 2)];
            [label_singerName setTag:i+10];
            [imageView_firstBack addSubview:label_singerName];
            [label_singerName release];
            
            UIButton *button_firstSinger = [UIButton buttonWithType:UIButtonTypeCustom];
            [button_firstSinger setFrame:CGRectMake(5 + i*180, 15, 180, 180)];
            [button_firstSinger setTag:i];
            [button_firstSinger addTarget:self action:@selector(didClickSinger:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button_firstSinger];
        }
    }
}

- (void)installTableCell:(UITableViewCell *)cell forTableView:(UITableView *)table withIndex:(NSInteger)index withArray:(NSMutableArray *)array
{
    if(table.tag == 30)
    {
        if([array count] == 5)
        {
            for (int i = 0; i<[array count]; i++)
            {
                UIImageView *imageView_tmp = (UIImageView *)[cell viewWithTag:i+5];
                UILabel *label_tmp = (UILabel *)[cell viewWithTag:i+10];
                SDSingers *singer = [array objectAtIndex:i];
                [imageView_tmp setImageWithURL:[NSURL URLWithString:singer.string_portrait]];
                [label_tmp setText:singer.singerName];
                UIImageView *imageView_back = (UIImageView *)[cell viewWithTag:i+15];
                [UIUtils didLoadImageNotCached:@"singerBack.png" inImageView:imageView_back];
                UIButton *button_tmp = (UIButton *)[cell viewWithTag:4 - i];
                [button_tmp setEnabled:YES];
            }
        }
        else
        {
            for (int i = 0; i<[array count]; i++)
            {
                UIImageView *imageView_tmp = (UIImageView *)[cell viewWithTag:i+5];
                UILabel *label_tmp = (UILabel *)[cell viewWithTag:i+10];
                SDSingers *singer = [array objectAtIndex:i];
                [imageView_tmp setImageWithURL:[NSURL URLWithString:singer.string_portrait]];
                [label_tmp setText:singer.singerName];
                UIImageView *imageView_back = (UIImageView *)[cell viewWithTag:i+15];
                [UIUtils didLoadImageNotCached:@"singerBack.png" inImageView:imageView_back];
                UIButton *button_tmp = (UIButton *)[cell viewWithTag:i];
                [button_tmp setEnabled:YES];
            }
            for (int i = 0; i< 5 - [array count]; i++)
            {
                UIImageView *imageView_tmp = (UIImageView *)[cell viewWithTag:9 - i];
                UILabel *label_tmp = (UILabel *)[cell viewWithTag:14 - i];
                UIImageView *imageView_back = (UIImageView *)[cell viewWithTag:19 - i];
                UIButton *button_tmp = (UIButton *)[cell viewWithTag:4 - i];
                [button_tmp setEnabled:NO];
                [imageView_tmp setImageWithURL:nil];
                [label_tmp setText:nil];
                [imageView_back setImage:nil];
            }
        }
    }
    else
    {
        if([array count] == 4)
        {
            for (int i = 0; i<[array count]; i++)
            {
                UIImageView *imageView_tmp = (UIImageView *)[cell viewWithTag:i+5];
                UILabel *label_tmp = (UILabel *)[cell viewWithTag:i+10];
                SDSingers *singer = [array objectAtIndex:i];
                [imageView_tmp setImageWithURL:[NSURL URLWithString:singer.string_portrait]];
                [label_tmp setText:singer.singerName];
                UIImageView *imageView_back = (UIImageView *)[cell viewWithTag:i+15];
                [UIUtils didLoadImageNotCached:@"singerBack.png" inImageView:imageView_back];
                UIButton *button_tmp = (UIButton *)[cell viewWithTag:3 - i];
                [button_tmp setEnabled:YES];
            }
        }
        else
        {
            for (int i = 0; i<[array count]; i++)
            {
                UIImageView *imageView_tmp = (UIImageView *)[cell viewWithTag:i+5];
                UILabel *label_tmp = (UILabel *)[cell viewWithTag:i+10];
                SDSingers *singer = [array objectAtIndex:i];
                [imageView_tmp setImageWithURL:[NSURL URLWithString:singer.string_portrait]];
                [label_tmp setText:singer.singerName];
                UIImageView *imageView_back = (UIImageView *)[cell viewWithTag:i+15];
                [UIUtils didLoadImageNotCached:@"singerBack.png" inImageView:imageView_back];
                UIButton *button_tmp = (UIButton *)[cell viewWithTag:i];
                [button_tmp setEnabled:YES];
            }
            for (int i = 0; i< 4 - [array count]; i++)
            {
                UIImageView *imageView_tmp = (UIImageView *)[cell viewWithTag:8 - i];
                UILabel *label_tmp = (UILabel *)[cell viewWithTag:13 - i];
                UIImageView *imageView_back = (UIImageView *)[cell viewWithTag:18 - i];
                UIButton *button_tmp = (UIButton *)[cell viewWithTag:3 - i];
                [button_tmp setEnabled:NO];
                [imageView_tmp setImageWithURL:nil];
                [label_tmp setText:nil];
                [imageView_back setImage:nil];
            }
        }
    }
}


- (void)didClickSinger:(id)sender
{
    UITableView *tabelView_ex = (UITableView *)[self.view viewWithTag:30];
    if(tabelView_ex)
    {
        UIButton *button_singer = (UIButton *)sender;
        UITableViewCell *cell = [self reciveSuperCellWithView:button_singer];
        UITableView *tableView = [self reciveSuperTableWithView:cell];
        NSIndexPath *indexPath = [tableView indexPathForCell:cell];
        NSMutableArray *array_singer = [_array_tableData objectAtIndex:indexPath.section];
        SDSingers *singer = [array_singer objectAtIndex:indexPath.row * 5 + button_singer.tag];
        
        JDSingerSongViewController *songController = [[JDSingerSongViewController alloc] initWithTitleString:singer.singerName];
        songController.navigationController_return = _navigationController_return;
        songController.array_data = [self installDataArray_Content:singer.singerNo];
        [songController configureTable_data];
        [_navigationController_return pushViewController:songController animated:YES];
        [songController release];
    }
    else
    {
        UIButton *button_singer = (UIButton *)sender;
        UITableViewCell *cell = [self reciveSuperCellWithView:button_singer];
        UITableView *tableView = [self reciveSuperTableWithView:cell];
        NSIndexPath *indexPath = [tableView indexPathForCell:cell];
        NSMutableArray *array_singer = [_array_tableData objectAtIndex:indexPath.section];
        SDSingers *singer = [array_singer objectAtIndex:indexPath.row * 4 + button_singer.tag];
        
        JDSingerSongViewController *songController = [[JDSingerSongViewController alloc] initWithTitleString:singer.singerName];
        songController.navigationController_return = _navigationController_return;
        songController.array_data = [self installDataArray_Content:singer.singerNo];
        [songController configureTable_data];
        [_navigationController_return pushViewController:songController animated:YES];
        [songController release];
    }
}


- (NSMutableArray *)installDataArray_Content:(NSString *)_string
{
    NSString *escapeTag = [_string stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *sql = [NSString stringWithFormat:@"select * from client_songs where singers_no like '%%%%%@%%%%'", escapeTag];
    NSMutableArray *content = [self installDataArrayWithString:sql];
    return content;
}

- (NSMutableArray *)installDataArrayWithString:(NSString *)string
{
    JDSqlDataBase *dataController = [[JDSqlDataBase alloc] init];
    NSMutableArray *songArray = [dataController reciveDataBaseWithString:string];
    [dataController release];
    return songArray;
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


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *myView = [[[UIView alloc] init] autorelease];
    myView.backgroundColor = [UIColor grayColor];
    [myView setAlpha:0.8];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 90, 22)];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = [_array_data objectAtIndex:section];
    [myView addSubview:titleLabel];
    [titleLabel release];
    return myView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSMutableArray *array_tmp = [_array_tableData objectAtIndex:section];
    if([array_tmp count] == 0)
    {
        return 0;
    }
    else
    {
        return 23;
    }
}

/*
 分类数
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_array_data count];
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSMutableArray *array_check = [_array_tableData objectAtIndex:index];
    if([array_check count] == 0)
    {
        NSMutableArray *array_tmp;
        for (int i = index-1; i<index; i--)
        {
            array_tmp = [_array_tableData objectAtIndex:i];
            if([array_tmp count] != 0)
            {
                [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                return i;
            }
        }
    }
    else
    {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        return index;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 210;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _array_data;
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

@end
