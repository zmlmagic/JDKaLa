//
//  JDMyRecordSoundView.m
//  JDKaLa
//
//  Created by zhangminglei on 6/18/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDMyRecordSoundView.h"
#import "UIUtils.h"
#import "JDDataBaseRecordSound.h"
#import "SDRecordSound.h"
#import "JDRecordPlayerViewController.h"


typedef enum
{
    JDCellButtonTag_songName         = 10,
    JDCellButtonTag_singerName           ,
    JDCellButtonTag_background           ,
    JDCellButtonTag_play                 ,
    JDCellButtonTag_delete               ,
}JDCellButtonTag;


@implementation JDMyRecordSoundView

- (id)init
{
    self = [super init];
    if(self)
    {
        [self setFrame:CGRectMake(0, 50, 1024, 718)];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadTableView:)
                                                     name:@"JDSongStateChange_record"
                                                   object:nil];
        [self configureView_tableView];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"JDSongStateChange_record"
                                                  object:nil];
    [_array_data release], _array_data = nil;
    [super dealloc];
}

- (void)configureView_tableView
{
    self.array_data = [JDDataBaseRecordSound reciveDataBaseFromLocal];
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
    static NSString *CellIdentifier = @"RecordCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor clearColor]];
        [self installCell:cell withIndex:indexPath.row];
    }
    SDRecordSound *record = [_array_data objectAtIndex:indexPath.row];
    [self installCell:cell withRecord:record];
    return cell;
}

- (void)installCell:(UITableViewCell *)cell withIndex:(NSInteger)index
{
    UIButton *button_background = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_background setFrame:CGRectMake(20, 5, 956, 75)];
    [UIUtils didLoadImageNotCached:@"songs_bar_bg.png" inButton:button_background withState:UIControlStateNormal];
    [button_background setTag:JDCellButtonTag_background];
    [button_background addTarget:self action:@selector(didClickButton_cell:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:button_background];
    
    UILabel *label_songName = [[UILabel alloc] initWithFrame:CGRectMake(30, 14, 430, 45)];
    [label_songName setBackgroundColor:[UIColor clearColor]];
    [label_songName setFont:[UIFont systemFontOfSize:25.0]];
    [label_songName setTextColor:[UIColor whiteColor]];
    [label_songName setTag:JDCellButtonTag_songName];
    [button_background addSubview:label_songName];
    [label_songName release];
    
    UILabel *label_singer = [[UILabel alloc] initWithFrame:CGRectMake(460, 18, 220, 45)];
    [label_singer setBackgroundColor:[UIColor clearColor]];
    [label_singer setTextColor:[UIColor whiteColor]];
    [label_singer setTag:JDCellButtonTag_singerName];
    [label_singer setFont:[UIFont systemFontOfSize:15.0f]];
    [button_background addSubview:label_singer];
    [label_singer release];
    
    UIButton *button_play = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_play setFrame:CGRectMake(775, 10, 50, 50)];
    [UIUtils didLoadImageNotCached:@"songs_bar_btn_play.png" inButton:button_play withState:UIControlStateNormal];
    [button_play setTag:JDCellButtonTag_play];
    [button_play addTarget:self action:@selector(didClickButton_cell:) forControlEvents:UIControlEventTouchUpInside];
    [button_background addSubview:button_play];
    
    UIButton *button_list = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_list setFrame:CGRectMake(875, 14, 45, 45)];
    [UIUtils didLoadImageNotCached:@"player_list_thumbnail_btn_delete.png" inButton:button_list withState:UIControlStateNormal];
    [button_list setTag:JDCellButtonTag_delete];
    [button_list addTarget:self action:@selector(didClickButton_cell:) forControlEvents:UIControlEventTouchUpInside];
    [button_background addSubview:button_list];
}

- (void)installCell:(UITableViewCell *)cell withRecord:(SDRecordSound *)record
{
    UILabel *label_songName = (UILabel *)[cell viewWithTag:JDCellButtonTag_songName];
    [label_songName setText:record.string_recordName];
    
    UILabel *label_singerName = (UILabel *)[cell viewWithTag:JDCellButtonTag_singerName];
    [label_singerName setText:record.string_dateTime];
}


#pragma mark - DidClickButton
- (void)didClickButton_cell:(id)sender
{
    UIButton *button_singer = (UIButton *)sender;
    UITableViewCell *cell = [self reciveSuperCellWithView:button_singer];
    UITableView *tableView = [self reciveSuperTableWithView:cell];
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    SDRecordSound *record = [_array_data objectAtIndex:indexPath.row];
    
    switch (button_singer.tag)
    {
        case JDCellButtonTag_background:
        {
            JDRecordPlayerViewController *movePlay = [JDRecordPlayerViewController sharedController];
            [movePlay play_movieWithRecord:record];
            [[self reciveSuperViewControllerWithView:self] presentViewController:movePlay animated:NO completion:nil];
            [movePlay release];
        }break;
            
        case JDCellButtonTag_play:
        {
            JDRecordPlayerViewController *movePlay = [JDRecordPlayerViewController sharedController];
            [movePlay play_movieWithRecord:record];
            [[self reciveSuperViewControllerWithView:self] presentViewController:movePlay animated:NO completion:nil];
            [movePlay release];
            
        }break;
            
        case JDCellButtonTag_delete:
        {
            self.delectCellId = indexPath;
            [JDDataBaseRecordSound deleteRecord:record];
            [UIUtils view_showProgressHUD:@"已删除" inView:self withTime:1.0f];
        
        }break;
            
        default:
            break;
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

- (void)reloadTableView:(NSNotification *)note
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
}


@end
