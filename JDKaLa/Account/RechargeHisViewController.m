//
//  RechargeHisViewController.m
//  JDKaLa
//
//  Created by 韩 抗 on 13-10-18.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import "RechargeHisViewController.h"
#import "AccountMasterViewController.h"
#import "SKRevealSideViewController.h"
#import "SKCustomNavigationBar.h"
#import "UIUtils.h"
#import "JDModel_userInfo.h"
#import "JDModel_rechageRecord.h"
#import "KCoinRecharge.h"

#define TAG_OF_TIME  10000
#define TAG_OF_PRICE  20000
#define TAG_OF_PRODUCT_NAME 30000
#define TAG_OF_SUCCESS 40000

@interface RechargeHisViewController ()

@end

@implementation RechargeHisViewController

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
        [self createProductInfo];
        [self installView_background];
        [self installView_title];
        [self configureView_table];
        self.agent = [[ClientAgent alloc] init];
        recordList = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)dealloc
{
    [recordList release];
    [productNames release];
    [productPrices release];
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
    [self getRecordList];
    
    [UIUtils view_showProgressHUD:@"正在获取充值记录..." forWaitInView:self.view];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * 创建商品价格、友好名称和ProductID的对照表
 */
- (void)createProductInfo
{
    productNames = [[NSDictionary alloc]initWithObjectsAndKeys:@"300K币", PRODUCT_ID_COIN_300,
                    @"650K币", PRODUCT_ID_COIN_650,
                    @"1000K币", PRODUCT_ID_COIN_1000,
                    @"1500K币", PRODUCT_ID_COIN_1500,
                    @"周卡", PRODUCT_ID_WEEKLY_CARD,
                    @"月卡", PRODUCT_ID_MONTHLY_CARD,nil];
    
    productPrices = [[NSDictionary alloc]initWithObjectsAndKeys:@"￥6.00", PRODUCT_ID_COIN_300,
                     @"￥12.00", PRODUCT_ID_COIN_650,
                     @"￥18.00", PRODUCT_ID_COIN_1000,
                     @"￥25.00", PRODUCT_ID_COIN_1500,
                     @"￥6.00", PRODUCT_ID_WEEKLY_CARD,
                     @"￥18.00", PRODUCT_ID_MONTHLY_CARD,nil];

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
    [label_titel setText:@"充值记录"];
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
 * 获取充值记录列表（异步函数，立即返回）
 */
- (void)getRecordList
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleGetRechargeListResult:)
                                                 name:NOTI_GET_RECHARGE_LIST_RESULT
                                               object:nil];
    [_agent getRechargeList:0 UserID:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
}

/**
 * 获取充值列表的反馈处理
 */
- (void)handleGetRechargeListResult:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    [recordList removeAllObjects];
    if([[state objectForKey:@"result"] length] > 0 && 0 == resultCode)
    {
        NSString    *msg = [state objectForKey:@"msg"];
        
        if([msg hasPrefix:@"522:"])
        {
            [_labelNoRecord setHidden:NO];
        }
        else
        {
            NSArray *billList = [state objectForKey:@"billlist"];
            
            for(NSDictionary* record in billList)
            {
                JDModel_rechageRecord *recharge = [[JDModel_rechageRecord alloc]init];
                recharge.productID = [record objectForKey:@"productid"];
                recharge.time = [record objectForKey:@"buytime"];
                recharge.success = [[record objectForKey:@"issuccess"] isEqualToString:@"1"] ? YES : NO;

                [recordList addObject:recharge];
                [recharge release];
            }
            if(![_labelNoRecord isHidden])
            {
                [_labelNoRecord setHidden:YES];
            }
        }
    }
    else
    {
        NSString    *msg = [state objectForKey:@"msg"];
            
        UIAlertView *alertDialog;
        alertDialog = [[UIAlertView alloc] initWithTitle:@"提示"
                                                 message:msg
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
        [alertDialog show];
    }
    [_rechargeTable reloadData];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTI_GET_RECHARGE_LIST_RESULT
                                                  object:nil];
    [UIUtils view_hideProgressHUDinView:self.view];
    [self didClickButton_master];
}

/**
 * 创建充值记录显示表
 */
- (void)configureView_table
{
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 70, 700, 660) style:UITableViewStylePlain];
    IOS7(table);
    [table setDataSource:self];
    [table setDelegate:self];
    [table setBackgroundColor:[UIColor clearColor]];
    [table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:table];
    _rechargeTable = table;
    [table release];
    
    _labelNoRecord = [[UILabel alloc] initWithFrame:CGRectMake(50,150,600,50)];
    [_labelNoRecord setTextAlignment:NSTextAlignmentCenter];
    [_labelNoRecord setTextColor:[UIColor whiteColor]];
    [_labelNoRecord setBackgroundColor:[UIColor clearColor]];
    [_labelNoRecord setFont:[UIFont systemFontOfSize:28.0f]];
    [_labelNoRecord setText:@"您没有充值记录"];
    [_labelNoRecord setHidden:YES];
    [self.view addSubview:_labelNoRecord];
    [_labelNoRecord release];
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
    return [recordList count];
}

//返回表格的行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 95;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RechargeCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if(cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createRecordCell:cell];
    }
    
    JDModel_rechageRecord *record = [recordList objectAtIndex:indexPath.row];
    UILabel *labelTime = (UILabel*)[cell viewWithTag:TAG_OF_TIME];
    UILabel *labelProductPrice = (UILabel*)[cell viewWithTag:TAG_OF_PRICE];
    UILabel *labelProductName = (UILabel*)[cell viewWithTag:TAG_OF_PRODUCT_NAME];
    UILabel *labelSuccess = (UILabel*)[cell viewWithTag:TAG_OF_SUCCESS];
    
    [labelTime setText:[record time]];
    [labelProductName setText:[productNames objectForKey:[record productID]]];
    [labelProductPrice setText:[productPrices objectForKey:[record productID]]];
    if([record success])
    {
        [labelSuccess setText:@"交易成功"];
    }
    else
    {
        [labelSuccess setText:@"交易失败"];
    }
    
    return cell;
}

#pragma mark - 创建表格的Cell
//创建充值记录的表格cell
- (void)createRecordCell:(UITableViewCell *)cell
{
    UIImageView *imageView_back = [[UIImageView alloc] initWithFrame:CGRectMake(35, 0, 660, 90)];
    //[imageView_back setContentMode:UIViewContentModeScaleAspectFit];
    [imageView_back setImage:[UIImage imageNamed:@"rule.png"]];
    [cell addSubview:imageView_back];
    [imageView_back release];
    
    UILabel *label_Time = [[UILabel alloc] initWithFrame:CGRectMake(50, 27, 250, 30)];
    [label_Time setTextAlignment:NSTextAlignmentLeft];
    [label_Time setTextColor:[UIColor whiteColor]];
    [label_Time setBackgroundColor:[UIColor clearColor]];
    [label_Time setShadowColor:[UIColor darkGrayColor]];
    [label_Time setShadowOffset:CGSizeMake(2, 2)];
    [label_Time setFont:[UIFont systemFontOfSize:24.0f]];
    [label_Time setTag:TAG_OF_TIME];
    [cell addSubview:label_Time];
    [label_Time release];
    
    UILabel *label_minus = [[UILabel alloc] initWithFrame:CGRectMake(320, 25, 20, 30)];
    [label_minus setTextAlignment:NSTextAlignmentLeft];
    [label_minus setTextColor:[UIColor redColor]];
    [label_minus setBackgroundColor:[UIColor clearColor]];
    [label_minus setShadowColor:[UIColor darkGrayColor]];
    [label_minus setShadowOffset:CGSizeMake(2, 2)];
    [label_minus setFont:[UIFont systemFontOfSize:28.0f]];
    [label_minus setText:@"-"];
    [cell addSubview:label_minus];
    [label_minus release];
    
    UILabel *label_price = [[UILabel alloc] initWithFrame:CGRectMake(335, 27, 180, 30)];
    [label_price setTextAlignment:NSTextAlignmentLeft];
    [label_price setTextColor:[UIColor whiteColor]];
    [label_price setBackgroundColor:[UIColor clearColor]];
    [label_price setShadowColor:[UIColor darkGrayColor]];
    [label_price setShadowOffset:CGSizeMake(2, 2)];
    [label_price setFont:[UIFont systemFontOfSize:24.0f]];
    [label_price setTag:TAG_OF_PRICE];
    [cell addSubview:label_price];
    [label_price release];
    
    
    UILabel *label_plus = [[UILabel alloc] initWithFrame:CGRectMake(450, 25, 20, 30)];
    [label_plus setTextAlignment:NSTextAlignmentLeft];
    [label_plus setTextColor:[UIColor cyanColor]];
    [label_plus setBackgroundColor:[UIColor clearColor]];
    [label_plus setShadowColor:[UIColor darkGrayColor]];
    [label_plus setShadowOffset:CGSizeMake(2, 2)];
    [label_plus setFont:[UIFont systemFontOfSize:28.0f]];
    [label_plus setText:@"+"];
    [cell addSubview:label_plus];
    [label_plus release];
    
    UILabel *label_productName = [[UILabel alloc] initWithFrame:CGRectMake(470, 27, 180, 30)];
    [label_productName setTextAlignment:NSTextAlignmentLeft];
    [label_productName setTextColor:[UIColor whiteColor]];
    [label_productName setBackgroundColor:[UIColor clearColor]];
    [label_productName setShadowColor:[UIColor darkGrayColor]];
    [label_productName setShadowOffset:CGSizeMake(2, 2)];
    [label_productName setFont:[UIFont systemFontOfSize:24.0f]];
    [label_productName setTag:TAG_OF_PRODUCT_NAME];
    [cell addSubview:label_productName];
    [label_productName release];
    
    UILabel *label_Success = [[UILabel alloc] initWithFrame:CGRectMake(600, 29, 90, 30)];
    [label_Success setTextAlignment:NSTextAlignmentLeft];
    [label_Success setTextColor:[UIColor whiteColor]];
    [label_Success setBackgroundColor:[UIColor clearColor]];
    [label_Success setShadowColor:[UIColor darkGrayColor]];
    [label_Success setShadowOffset:CGSizeMake(2, 2)];
    [label_Success setFont:[UIFont systemFontOfSize:18.0f]];
    [label_Success setTag:TAG_OF_SUCCESS];
    [cell addSubview:label_Success];
    [label_Success release];
}


@end

