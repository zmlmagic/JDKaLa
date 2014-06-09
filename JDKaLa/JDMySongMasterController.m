//
//  JDMySongMasterController.m
//  JDKaLa
//
//  Created by zhangminglei on 5/31/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDMySongMasterController.h"
#import "UIUtils.h"
#import "JDMenuView.h"
#import "JDMyOrderSongView.h"
#import "JDMyFavoriteView.h"
#import "JDMySongViewController.h"
#import "JDMyRecordSoundView.h"
#import "JDMyHistorySongView.h"
#import "JDMyBuySongView.h"

@implementation JDMySongMasterController

- (id)init
{
    self = [super init];
    if(self)
    {
        [self configureView_title];
        [self configureView_table];
    }
    return self;
}

- (void)dealloc
{
    [_array_myMasterData release], _array_myMasterData = nil;
    [super dealloc];
}

#pragma mark - 
#pragma mark ConfigureView
- (void)configureView_title
{
    UIImageView *imageView_title = [[UIImageView alloc] initWithFrame:CGRectMake(-10, 0, 300, 50)];
    IOS7(imageView_title);
    [UIUtils didLoadImageNotCached:@"menu_title_bg_mySong.png" inImageView:imageView_title];
    [self.view addSubview:imageView_title];
    [imageView_title release];
}

- (void)configureView_table
{
    [self configureData_table];
    //_bool_firstConfigure = YES;
    UITableView *table_master = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, 300, 704) style:UITableViewStylePlain];
    IOS7(table_master);
    table_master.dataSource = self;
    table_master.delegate = self;
    [table_master setSeparatorColor:[self colorWithHex:0xCBCBCB alpha:1.0]];
    [table_master setBackgroundColor:[self colorWithHex:0xCBCBCB alpha:1.0]];
    [self.view addSubview:table_master];
    [table_master release];
    
    _tableView_self = table_master;
}

- (void)configureData_table
{
    self.array_myMasterData = [NSMutableArray arrayWithObjects:@"mySong1.png",@"mySong2.png",@"mySong3.png",@"mySong4.png",@"mySong5.png",@"mySong1_pressed.png",@"mySong2_pressed.png",@"mySong3_pressed.png",@"mySong4_pressed.png",@"mySong5_pressed.png",nil];
}

- (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity
{
    float red = ((float)((hexColor & 0xFF0000) >> 16))/255.0;
    float green = ((float)((hexColor & 0xFF00) >> 8))/255.0;
    float blue = ((float)(hexColor & 0xFF))/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:opacity];
}


#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_array_myMasterData count] - 5;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MySongCellIdentifier";
    
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self initCell:cell withIndex:indexPath.row];
    }
    return cell;
}

- (void)initCell:(UITableViewCell *)cell withIndex:(NSInteger)index
{
    UIButton *button_back = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_back setFrame:CGRectMake(0, 0, 300, 75)];
    
    if(index == 0)
    {
        _button_first = button_back;
        _button_before = button_back;
        [UIUtils didLoadImageNotCached:[_array_myMasterData objectAtIndex:5] inButton:button_back withState:UIControlStateNormal];
    }
    else
    {
        [UIUtils didLoadImageNotCached:[_array_myMasterData objectAtIndex:index] inButton:button_back withState:UIControlStateNormal];
    }
    
    [UIUtils didLoadImageNotCached:[_array_myMasterData objectAtIndex:index + 5] inButton:button_back withState:UIControlStateHighlighted];
    
    [button_back addTarget:self action:@selector(didSelectButton:) forControlEvents:UIControlEventTouchUpInside];
    [button_back setTag:index];
    [cell addSubview:button_back];
}

- (void)didSelectButton:(id)sender
{
    UIButton *button_tag = (UIButton *)sender;
    JDMenuView *view_menu = [JDMenuView sharedView];
    [UIUtils didLoadImageNotCached:[_array_myMasterData objectAtIndex:_button_before.tag] inButton:_button_before withState:UIControlStateNormal];
    switch (button_tag.tag)
    {
        case 0:
        {
            JDMyOrderSongView *orderView = [[JDMyOrderSongView alloc] init];
            orderView.navigationController_return = _navigationController_return;
            [orderView setTag:20];
            [_tableView_self setUserInteractionEnabled:NO];
            UIView *tmp = [self.revealSideViewController.rootViewController.view viewWithTag:20];
            JDMySongViewController *mySongController = (JDMySongViewController *)self.revealSideViewController.rootViewController;
            mySongController.label_title.text = @"已点歌曲";
            [self viewChangeInView:orderView outView:tmp InTableView:_tableView_self];
            [view_menu configureView_animetionButton_inViewChange];
            [orderView release];
            _button_before = button_tag;
            break;
        }
        case 1:
        {
            JDMyBuySongView *buyView = [[JDMyBuySongView alloc] init];
            buyView.navigationController_return = _navigationController_return;
            [buyView setTag:20];
            IOS7(buyView);
            [_tableView_self setUserInteractionEnabled:NO];
            UIView *tmp = [self.revealSideViewController.rootViewController.view viewWithTag:20];
            JDMySongViewController *mySongController = (JDMySongViewController *)self.revealSideViewController.rootViewController;
            mySongController.label_title.text = @"已购歌曲";
            [self viewChangeInView:buyView outView:tmp InTableView:_tableView_self];
            [view_menu configureView_animetionButton_inViewChange];
            [buyView release];
            _button_before = button_tag;
            break;
        }
        case 2:
        {
            JDMyFavoriteView *favoriteView = [[JDMyFavoriteView alloc] init];
            favoriteView.navigationController_return = _navigationController_return;
            [favoriteView setTag:20];
            IOS7(favoriteView);
            [_tableView_self setUserInteractionEnabled:NO];
            UIView *tmp = [self.revealSideViewController.rootViewController.view viewWithTag:20];
            JDMySongViewController *mySongController = (JDMySongViewController *)self.revealSideViewController.rootViewController;
            mySongController.label_title.text = @"收藏";
            [self viewChangeInView:favoriteView outView:tmp InTableView:_tableView_self];
            [view_menu configureView_animetionButton_inViewChange];
            [favoriteView release];
            _button_before = button_tag;
            break;
        }
        case 3:
        {
            JDMyHistorySongView *historyView = [[JDMyHistorySongView alloc] init];
            historyView.navigationController_return = _navigationController_return;
            [historyView setTag:20];
            IOS7(historyView);
            [_tableView_self setUserInteractionEnabled:NO];
            UIView *tmp = [self.revealSideViewController.rootViewController.view viewWithTag:20];
            JDMySongViewController *mySongController = (JDMySongViewController *)self.revealSideViewController.rootViewController;
            mySongController.label_title.text = @"最近播放";
            [self viewChangeInView:historyView outView:tmp InTableView:_tableView_self];
            [view_menu configureView_animetionButton_inViewChange];
            [historyView release];
            _button_before = button_tag;
            break;
        }
        case 4:
        {
            JDMyRecordSoundView *recordView = [[JDMyRecordSoundView alloc] init];
            [recordView setTag:20];
            IOS7(recordView);
            [_tableView_self setUserInteractionEnabled:NO];
            UIView *tmp = [self.revealSideViewController.rootViewController.view viewWithTag:20];
            JDMySongViewController *mySongController = (JDMySongViewController *)self.revealSideViewController.rootViewController;
            mySongController.label_title.text = @"我的录音";
            [self viewChangeInView:recordView outView:tmp InTableView:_tableView_self];
            [view_menu configureView_animetionButton_inViewChange];
            [recordView release];
            _button_before = button_tag;
        }break;
        default:
            break;
    }
    
    [UIUtils didLoadImageNotCached:[_array_myMasterData objectAtIndex:button_tag.tag + 5] inButton:button_tag withState:UIControlStateNormal];
}

- (void)reloadViewWhenNext
{
    [UIUtils didLoadImageNotCached:[_array_myMasterData objectAtIndex:_button_before.tag] inButton:_button_before withState:UIControlStateNormal];
    
    [UIUtils didLoadImageNotCached:[_array_myMasterData objectAtIndex:5] inButton:_button_first withState:UIControlStateNormal];
}


#pragma mark - 
#pragma mark ViewChange
- (void)viewChangeInView:(UIView *)inView outView:(UIView *)outView InTableView:(UITableView *)tableView
{
    [UIUtils removeViewWithAnimation:outView inCenterPoint:CGPointMake(1536, 409) withBoolRemoveView:YES];
    [self performSelector:@selector(viewRestoreTouch:) withObject:tableView afterDelay:1.5f];
    [self.revealSideViewController.rootViewController.view addSubview:inView];
    [inView setAlpha:0.0f];
    [UIUtils showView:inView];
    if (IOS7_VERSION)
    {
        [UIUtils addViewWithAnimation:inView inCenterPoint:CGPointMake(512, 424)];
    }
    else
    {
        [UIUtils addViewWithAnimation:inView inCenterPoint:CGPointMake(512, 409)];
    }
}

- (void)viewRestoreTouch:(UIView *)view_table
{
    [view_table setUserInteractionEnabled:YES];
}


@end
