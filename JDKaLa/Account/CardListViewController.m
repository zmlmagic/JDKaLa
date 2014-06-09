//
//  CardListViewController.m
//  JDKaLa
//
//  Created by 韩 抗 on 13-10-11.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import "CardListViewController.h"
#import "UIUtils.h"
#import "SKCustomNavigationBar.h"
#import "AccountMasterViewController.h"
#import "SKRevealSideViewController.h"
#import "JDModel_userInfo.h"
#import "JDModel_time_card.h"
#import "KCoinRecharge.h"

#define ITEMS_COUNT_PER_ROW 2
#define TAG_OF_CARD_ICON(x)  (10000 + x)
#define TAG_OF_CARD_INVALID_TIME(x)  (20000 + x)
#define TAG_OF_CARD_INVALID_TIME_TITLE(x)  (40000 + x)
#define TAG_OF_CARD_BTN(x)  (30000 + x)
#define TAG_OF_CARD_STATUS(x) (50000 + x)
#define CARD_IDX_FROM_TAG(x)  (x - 30000)

@interface CardListViewController ()

@end

@implementation CardListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        //[self configureView_title];
        [self installView_background];
        [self installView_title];
        [self configureView_table];
        self.agent = [[ClientAgent alloc] init];
        cardList = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)dealloc
{
    [cardList release];
    [super dealloc];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
    
    [self getCardList];
    [self didClickButton_master];
    [UIUtils view_showProgressHUD:@"正在更新时长卡列表..." forWaitInView:self.view];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DidClickButton
- (void)didClickButton_master
{
    AccountMasterViewController *masterViewController = [AccountMasterViewController sharedController];
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
}


#pragma mark - 初始化Title -
/**
 初始化Title
 **/
- (void)installView_title
{
    SKCustomNavigationBar *customNavigationBar = [[SKCustomNavigationBar alloc] initWithFrame:CGRectMake(0, 0, 1024, 50)];
    [self.view addSubview:customNavigationBar];
    IOS7(customNavigationBar);
    
    [customNavigationBar release];
    
    UIView *view_title = [[UIView alloc] initWithFrame:CGRectMake(300, 0, 700, 50)];
    [view_title setBackgroundColor:[UIColor clearColor]];
    [view_title setTag:70];
    [customNavigationBar addSubview:view_title];
    [view_title release];
    
    UILabel *label_titel = [[UILabel alloc]initWithFrame:CGRectMake(130, 0, 200, 50)];
    [label_titel setBackgroundColor:[UIColor clearColor]];
    [label_titel setTextAlignment:NSTextAlignmentCenter];
    [label_titel setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:30.0f]];
    [label_titel setTextColor:[UIColor whiteColor]];
    [label_titel setText:@"欢唱卡"];
    [view_title addSubview:label_titel];
    [label_titel release];
}

#pragma mark - 初始化背景
/**
 初始化背景
 **/
- (void)installView_background
{
    UIImageView *imageView_background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 1024, 749)];
    IOS7(imageView_background);
    [UIUtils didLoadImageNotCached:@"mainView_background.png" inImageView:imageView_background];
    [self.view addSubview:imageView_background];
    [imageView_background release];
}


/**
 * 获取时长卡列表（异步函数，立即返回）
 */
- (void)getCardList
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleGetCardListResult:)
                                                 name:NOTI_GET_TIME_CARD_LIST_RESULT
                                               object:nil];
    [_agent getTimeCardList:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
}

/**
 * 获取已购时长卡列表的反馈处理
 */
- (void)handleGetCardListResult:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    [cardList removeAllObjects];
    if([[state objectForKey:@"result"] length] > 0 && 0 == resultCode)
    {
        NSArray *billList = [state objectForKey:@"querylist"];

        for(NSDictionary* record in billList)
        {
            JDModel_time_card *card = [[JDModel_time_card alloc]init];
            card.productID = [record objectForKey:@"product_id"];
            card.cardID = [record objectForKey:@"card_id"];
            card.buyTime = [record objectForKey:@"buydate"];
            card.invalidTime = [record objectForKey:@"invaliddate"];
            card.activeDate =[record objectForKey:@"startdate"];
            card.valid = [[record objectForKey:@"valid"] isEqualToString:@"1"];
            [cardList addObject:card];
            [card release];
        }
        if(![_labelNoCard isHidden])
        {
            [_labelNoCard setHidden:YES];
        }
    }
    else
    {
        NSString    *msg = [state objectForKey:@"msg"];

        if([msg hasPrefix:@"546"])
        {
            [_labelNoCard setHidden:NO];
        }
        else
        {

            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc] initWithTitle:@"提示"
                                                     message:[state objectForKey:@"msg"]
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
            [alertDialog show];
        }
    }
    [_cardTable reloadData];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTI_GET_TIME_CARD_LIST_RESULT
                                                  object:nil];
    
    [UIUtils view_hideProgressHUDinView:self.view];

}

/**
 * 创建时长卡显示表
 */
- (void)configureView_table
{
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, 700, 700) style:UITableViewStylePlain];
    IOS7(table);
    [table setDataSource:self];
    [table setDelegate:self];
    [table setBackgroundColor:[UIColor clearColor]];
    [table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:table];
    _cardTable = table;
    [table release];
    
    _labelNoCard = [[UILabel alloc] initWithFrame:CGRectMake(50,150,600,50)];
    [_labelNoCard setTextAlignment:NSTextAlignmentCenter];
    [_labelNoCard setTextColor:[UIColor whiteColor]];
    [_labelNoCard setBackgroundColor:[UIColor clearColor]];
    [_labelNoCard setFont:[UIFont systemFontOfSize:28.0f]];
    [_labelNoCard setText:@"您没有未启用的欢唱卡"];
    [_labelNoCard setHidden:YES];
    [self.view addSubview:_labelNoCard];
    [_labelNoCard release];

}

#pragma mark - TableView Delegate

//返回分区个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//返回表格的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([cardList count] % ITEMS_COUNT_PER_ROW == 0)
    {
        return [cardList count] / ITEMS_COUNT_PER_ROW;
    }
    else
    {
        return [cardList count] / ITEMS_COUNT_PER_ROW + 1;
    }
}

//返回表格的行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 220;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TimeCardCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    int rowStartIdx = indexPath.row * ITEMS_COUNT_PER_ROW;
    if(cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createTimeCardCell:cell startIdx:rowStartIdx];
    }
    
    int i;
    
    for(i = 0; i < ITEMS_COUNT_PER_ROW; ++i)
    {
        UIImageView *iconView = (UIImageView *)[cell viewWithTag:TAG_OF_CARD_ICON(i)];
        UIImageView *statusView = (UIImageView*)[cell viewWithTag:TAG_OF_CARD_STATUS(i)];
        UILabel *labelInvalidTime = (UILabel*)[cell viewWithTag:TAG_OF_CARD_INVALID_TIME(i)];
        UILabel *labelInvalidTimeTitle = (UILabel*)[cell viewWithTag:TAG_OF_CARD_INVALID_TIME_TITLE(i)];
        UIButton *btnUseCard = (UIButton*)[cell viewWithTag:TAG_OF_CARD_BTN(i)];
        
        if(rowStartIdx + i < [cardList count])
        {
            JDModel_time_card   *card = [cardList objectAtIndex:rowStartIdx + i];
            NSString    *cardType = [[cardList objectAtIndex:rowStartIdx + i] productID];
            if([cardType isEqualToString:PRODUCT_ID_MONTHLY_CARD])
            {
                [iconView setImage:[UIImage imageNamed:@"monthly_card.png"]];
            }
            else if([cardType isEqualToString:PRODUCT_ID_WEEKLY_CARD])
            {
                [iconView setImage:[UIImage imageNamed:@"weekly_card.png"]];
            }
            
            if([card.activeDate length] > 0)    //如果有“启用日期”，说明卡已经使用过。
            {
                [labelInvalidTimeTitle setText:@"启用时间:"];
                [labelInvalidTime setText:[card activeDate]];

                [btnUseCard setHidden:YES];
                [statusView setHidden:NO];
                [statusView setImage:[UIImage imageNamed:@"time_card_used.png"]];
            }
            else                                //否则，说明卡未启用。
            {
                if([card valid])
                {
                    [labelInvalidTimeTitle setText:@"请在此时间之前启用:"];
                    [labelInvalidTime setText:[card invalidTime]];

                    [UIUtils didLoadImageNotCached:@"active_time_card.png" inButton:btnUseCard withState:UIControlStateNormal];
                    [btnUseCard addTarget:self action:@selector(didClickBtnUse:) forControlEvents:UIControlEventTouchUpInside];
                    //[btnUseCard setValue:card forKey:@"card"];
                    [btnUseCard setHidden:NO];
                    [btnUseCard setTitle:[NSString stringWithFormat:@"%d", rowStartIdx + i] forState:UIControlStateDisabled];
                    [statusView setHidden:YES];
                }
                else
                {
                    [labelInvalidTimeTitle setText:@"失效时间:"];
                    [labelInvalidTime setText:[card invalidTime]];
                    [btnUseCard setHidden:YES];
                    [statusView setHidden:NO];
                    [statusView setImage:[UIImage imageNamed:@"time_card_outdate.png"]];
                }
            }
        }
        else
        {
            [iconView setImage:nil];
            [statusView setImage:nil];
            [labelInvalidTime setText:nil];
            [labelInvalidTimeTitle setText:nil];
            [btnUseCard setBackgroundImage:nil forState:UIControlStateNormal];
            [btnUseCard removeTarget:self action:@selector(didClickBtnUse:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return cell;
}

#pragma mark - 创建表格的Cell
//创建显示时长卡的表格cell
- (void)createTimeCardCell:(UITableViewCell *)cell startIdx:(int)idx
{
    for (int i = 0; i < ITEMS_COUNT_PER_ROW; i++)
    {
        UIImageView *imageView_portrait = [[UIImageView alloc] initWithFrame:CGRectMake(20 + i * 350, 25, 323, 191)];
        [imageView_portrait setTag:TAG_OF_CARD_ICON(i)];
        //[imageView_portrait setContentMode:UIViewContentModeScaleAspectFit];
        [cell addSubview:imageView_portrait];
        [imageView_portrait release];
        
        UILabel *label_invalidTimeTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 130, 180, 30)];
        [label_invalidTimeTitle setTextAlignment:NSTextAlignmentLeft];
        [label_invalidTimeTitle setTextColor:[UIColor whiteColor]];
        [label_invalidTimeTitle setBackgroundColor:[UIColor clearColor]];
        [label_invalidTimeTitle setFont:[UIFont systemFontOfSize:18.0f]];
        [label_invalidTimeTitle setTag:TAG_OF_CARD_INVALID_TIME_TITLE(i)];
        [imageView_portrait addSubview:label_invalidTimeTitle];
        [label_invalidTimeTitle release];
        
        UILabel *label_invalidTime = [[UILabel alloc] initWithFrame:CGRectMake(20, 155, 180, 30)];
        [label_invalidTime setTextAlignment:NSTextAlignmentLeft];
        [label_invalidTime setTextColor:[UIColor whiteColor]];
        [label_invalidTime setBackgroundColor:[UIColor clearColor]];
        [label_invalidTime setFont:[UIFont systemFontOfSize:18.0f]];
        [label_invalidTime setTag:TAG_OF_CARD_INVALID_TIME(i)];
        [imageView_portrait addSubview:label_invalidTime];
        [label_invalidTime release];
        
        UIButton *btnUseCard = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnUseCard setFrame:CGRectMake(235 + i * 350, 165, 80, 35)];
        [btnUseCard setTag:TAG_OF_CARD_BTN(i)];
        [cell addSubview:btnUseCard];
        
        UIImageView *imageStatus = [[UIImageView alloc]initWithFrame:CGRectMake(215, 140, 80, 35)];
        [imageStatus setTag:TAG_OF_CARD_STATUS(i)];
        [imageView_portrait addSubview:imageStatus];
        [imageStatus release];
    }
}

#pragma mark - 启用时长卡
//启用按钮被点击的处理函数
- (void)didClickBtnUse:(id)sender
{
    //NSIndexPath *indexPath = [_cardTable indexPathForSelectedRow];
    NSString* cellIndex = [sender titleForState:UIControlStateDisabled];
    JDModel_time_card *card = [cardList objectAtIndex:[cellIndex intValue]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleStartTimeCardResult:)
                                                 name:NOTI_START_TIME_CARD_RESULT
                                               object:nil];
    [UIUtils view_showProgressHUD:@"开启中，请稍候..." forWaitInView:self.view];
    [_agent startTimeCard:[card cardID]
                   UserID:[JDModel_userInfo sharedModel].string_userID
                    Token:[JDModel_userInfo sharedModel].string_token];
}

/**
 * 启用时长卡的反馈处理
 */
- (void)handleStartTimeCardResult:(NSNotification *)note
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                  name:NOTI_START_TIME_CARD_RESULT
                object:nil];
    
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    UIAlertView     *alertDialog;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    if([[state objectForKey:@"result"] length] > 0 && 0 == resultCode)
    {
        alertDialog = [[UIAlertView alloc] initWithTitle:@"成功"
                                                 message:@"激活时长卡成功"
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
        [[AccountMasterViewController sharedController]reloadState];
    }
    else
    {
        
        alertDialog = [[UIAlertView alloc] initWithTitle:@"失败"
                                                 message:[state objectForKey:@"msg"]
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];

    }

    [alertDialog show];
    
    //刷新时长卡列表
    [self getCardList];
}


@end
