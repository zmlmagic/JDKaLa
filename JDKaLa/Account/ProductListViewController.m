//
//  ProductListViewController.m
//  JDKaLa
//
//  Created by 韩 抗 on 13-10-14.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import "ProductListViewController.h"
#import "AccountMasterViewController.h"
#import "SKCustomNavigationBar.h"
#import "SKRevealSideViewController.h"
#import "UIUtils.h"
#import "JDModel_productInfo.h"
#import "JDModel_userInfo.h"
#import "KCoinRecharge.h"
#import "JDMenuView.h"
#import "JDUserInfoChangeView.h"
#import "CustomAlertView.h"

#define ITEMS_COUNT_PER_ROW 2
#define TAG_OF_PRODUCT_ICON(x)  (10000 + x)
#define TAG_OF_PRODUCT_PRICE(x)  (20000 + x)
#define TAG_OF_PRODUCT_BTN(x)  (30000 + x)
#define PRODUCT_IDX_FROM_TAG(x)  (x - 30000)


@interface ProductListViewController ()

@end

@implementation ProductListViewController

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
        [self generateProductList];
        self.agent = [[ClientAgent alloc] init];
        _bool_oneTime = YES;
        kCoinRecharge = [[KCoinRecharge alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didClickButton_userInfoReturn)
                                                     name:@"didClickButton_userInfoReturn"
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(_bool_oneTime)
    {
        _bool_oneTime = NO;
        [self didClickButton_master];
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
                                                    name:@"didClickButton_userInfoReturn"
                                                  object:nil];
    
    [[AccountMasterViewController sharedController] stopTimerCheck];
    
    [kCoinRecharge release];
    [super dealloc];
}

/**
 * 创建产品列表
 */
- (void)generateProductList
{
    [productList release];
    productList = [[NSMutableArray alloc]init];
    
    JDModel_productInfo *product = [[JDModel_productInfo alloc]init];
    [product setProductID:PRODUCT_ID_COIN_300];
    [product setPrice:@"￥6"];
    [product setIconName:@"account_buy_Kb_300.png"];
    
    [productList addObject:product];
    [product release];
    
    product = [[JDModel_productInfo alloc]init];
    [product setProductID:PRODUCT_ID_COIN_650];
    [product setPrice:@"￥12"];
    [product setIconName:@"account_buy_Kb_650.png"];
    
    [productList addObject:product];
    [product release];
    
    product = [[JDModel_productInfo alloc]init];
    [product setProductID:PRODUCT_ID_COIN_1000];
    [product setPrice:@"￥18"];
    [product setIconName:@"account_buy_Kb_1000.png"];
    
    [productList addObject:product];
    [product release];
    
    product = [[JDModel_productInfo alloc]init];
    [product setProductID:PRODUCT_ID_COIN_1500];
    [product setPrice:@"￥25"];
    [product setIconName:@"account_buy_Kb_1500.png"];
    
    [productList addObject:product];
    [product release];
    
    product = [[JDModel_productInfo alloc]init];
    [product setProductID:PRODUCT_ID_WEEKLY_CARD];
    [product setPrice:@"￥6"];
    [product setIconName:@"account_buy_Kb_week.png"];
    
    [productList addObject:product];
    [product release];
    
    product = [[JDModel_productInfo alloc]init];
    [product setProductID:PRODUCT_ID_MONTHLY_CARD];
    [product setPrice:@"￥18"];
    [product setIconName:@"account_buy_Kb_month.png"];
    
    [productList addObject:product];
    [product release];
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
    [label_titel setText:@"购买"];
    [view_title addSubview:label_titel];
    [label_titel release];
    
    UIButton *button_userInfo = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_userInfo setFrame:CGRectMake(600, 7, 110, 36)];
    [UIUtils didLoadImageNotCached:@"button_userInfo.png" inButton:button_userInfo withState:UIControlStateNormal];
    [button_userInfo.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    [button_userInfo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button_userInfo setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button_userInfo setTitle:@"修改账户资料" forState:UIControlStateNormal];
    [button_userInfo addTarget:self action:@selector(didClickButton_userInfo) forControlEvents:UIControlEventTouchUpInside];
    [view_title addSubview:button_userInfo];
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

#pragma mark - DidClickButton
-(void)didClickButton_master
{
    AccountMasterViewController *masterViewController = [AccountMasterViewController sharedController];
    [masterViewController reloadButtonIndex];
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

/**
 * 创建显示产品的表格
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
    _productTable = table;
    [table release];
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
    if([productList count] % ITEMS_COUNT_PER_ROW == 0)
    {
        return [productList count] / ITEMS_COUNT_PER_ROW;
    }
    else
    {
        return [productList count] / ITEMS_COUNT_PER_ROW + 1;
    }
}

//返回表格的行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 220;
}

//返回表格单元格的视图
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ProductCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    int rowStartIdx = indexPath.row * ITEMS_COUNT_PER_ROW;
    if(cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createProductCell:cell startIdx:rowStartIdx];
    }
    
    int i;
    
    for(i = 0; i < ITEMS_COUNT_PER_ROW; ++i)
    {
        UIImageView *iconView = (UIImageView *)[cell viewWithTag:TAG_OF_PRODUCT_ICON(rowStartIdx + i)];
        UILabel *labelPrice = (UILabel*)[cell viewWithTag:TAG_OF_PRODUCT_PRICE(rowStartIdx + i)];
        UIButton *btnBuy = (UIButton*)[cell viewWithTag:TAG_OF_PRODUCT_BTN(rowStartIdx + i)];
        
        if(rowStartIdx + i < [productList count])
        {
            JDModel_productInfo   *product = [productList objectAtIndex:rowStartIdx + i];
            [iconView setImage:[UIImage imageNamed:[product iconName]]];
            [labelPrice setText:[product price]];
            [UIUtils didLoadImageNotCached:@"account_bar_btn_buy.png"
                                  inButton:btnBuy
                                 withState:UIControlStateNormal];
            [btnBuy addTarget:self
                       action:@selector(didClickBtnBuy:)
             forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            [iconView setImage:nil];
            [labelPrice setText:nil];
            [btnBuy setBackgroundImage:nil forState:UIControlStateNormal];
            [btnBuy removeTarget:self action:@selector(didClickBtnBuy:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return cell;
}

#pragma mark - 创建表格的Cell
- (void)createProductCell:(UITableViewCell *)cell startIdx:(int)idx
{
    for (int i = 0; i < ITEMS_COUNT_PER_ROW; i++)
    {
        UIImageView *imageView_portrait = [[UIImageView alloc] initWithFrame:CGRectMake(20 + i * 350, 25, 323, 191)];
        [imageView_portrait setTag:TAG_OF_PRODUCT_ICON(idx + i)];
        //[imageView_portrait setContentMode:UIViewContentModeScaleAspectFit];
        [cell addSubview:imageView_portrait];
        [imageView_portrait release];
        
        UILabel *label_price = [[UILabel alloc] initWithFrame:CGRectMake(20, 142, 180, 30)];
        [label_price setTextAlignment:NSTextAlignmentLeft];
        [label_price setTextColor:[UIColor whiteColor]];
        [label_price setBackgroundColor:[UIColor clearColor]];
        [label_price setFont:[UIFont systemFontOfSize:24.0f]];
        [label_price setTag:TAG_OF_PRODUCT_PRICE(idx + i)];
        [imageView_portrait addSubview:label_price];
        [label_price release];
        
        UIButton *btnBuy = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnBuy setFrame:CGRectMake(235 + i * 350, 165, 80, 35)];
        [btnBuy setTag:TAG_OF_PRODUCT_BTN(idx + i)];
        [cell addSubview:btnBuy];
    }
}

#pragma mark - 购买操作
//购买按钮被点击的处理函数
- (void)didClickBtnBuy:(id)sender
{
    int idx = PRODUCT_IDX_FROM_TAG([sender tag]);
    
    if(idx >= [productList count])
        return;
    
    JDModel_productInfo *product = [productList objectAtIndex:idx];
    selectedProductID = [product productID];
    
    //先获取用户属性，以确保uid和token有效。
    [[NSNotificationCenter defaultCenter] addObserver:self
           selector:@selector(handleGetUserDetail:)
               name:NOTI_GET_USER_DETAIL_RESULT
             object:nil];
    [_agent getUserDetail:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
}

/**
 * 获取用户属性的反馈处理
 */
- (void)handleGetUserDetail:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTI_GET_USER_DETAIL_RESULT
                                                    object:nil];
    
    if([[state objectForKey:@"result"] length] > 0 && 0 == resultCode)
    {
        NSString *string_tourist = [[NSUserDefaults standardUserDefaults] objectForKey:@"tourist"];
        //NSLog(@"Tourist:%@",[JDModel_userInfo sharedModel].string_tourist);
        //当游客购买时长卡时，提醒游客注册后才能在多个设备间共享已购商品。
        if([string_tourist isEqualToString:@"YES"] &&
           ([selectedProductID isEqualToString:PRODUCT_ID_MONTHLY_CARD] ||
           [selectedProductID isEqualToString:PRODUCT_ID_WEEKLY_CARD]))
        {
            
            CustomAlertView *alertDialog;
            alertDialog = [[CustomAlertView alloc] initWithTitle:@"提示"
                                                             message:@"当您加入K族后，就可以在多个iOS设备上共享这个账号下的所有欢唱卡了。"
                                                            delegate:self
                                                   cancelButtonTitle:@"继续"
                                                   otherButtonTitles:nil];
            [alertDialog show];
            [alertDialog release];
        }
        else
        {
            [self buyProduct];
        }
    }
    else
    {
        UIAlertView     *alertDialog;
        alertDialog = [[UIAlertView alloc] initWithTitle:@"用户认证失败"
                                                 message:[state objectForKey:@"msg"]
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
        [alertDialog show];
    }
}

/**
 * 实际开始购买IAP商品
 */
- (void)buyProduct
{
    //只有能成功获取用户属性，说明token和uid都有效，才开始进行实际的购买。
    if([kCoinRecharge CanMakePay])
    {
        //NSLog(@"%@",[JDModel_userInfo sharedModel].string_userID);
        //NSLog(@"%@",[JDModel_userInfo sharedModel].string_token);
        
        [kCoinRecharge BuyProductWithProductID:selectedProductID UserID:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
    }
    [[AccountMasterViewController sharedController] checkRechargeResult];
}

/**
 * 账号注册提示窗口中“继续”键的处理函数
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
   if(0 == buttonIndex)
   {
       [self buyProduct];
   }
}


#pragma mark - 修改用户资料
- (void)didClickButton_userInfo
{
    NSString *string_tourist = [[NSUserDefaults standardUserDefaults] objectForKey:@"tourist"];
    if([string_tourist isEqualToString:@"YES"])
    {
        CustomAlertView *alter = [[CustomAlertView alloc] initWithTitle:@"请加入K族"
                                                                message:@"只K族才可修改个人资料"
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
        [alter show];
        [alter release];
        return;
    }
    
    _view_infoBack = nil;
    
    UIView *view_black = [[UIView alloc] initWithFrame:CGRectMake(-290, 0, 1024, 768)];
    [view_black setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    [self.view addSubview:view_black];
    [view_black release];
    _view_infoBack = view_black;
    
    [[JDMenuView sharedView]setButton_setUserInteractionEnabled:NO];
    [[AccountMasterViewController sharedController].table_master setUserInteractionEnabled:NO];
    
    JDUserInfoChangeView *view_info = [[JDUserInfoChangeView alloc] init];
    [view_info setFrame:CGRectMake(-13, -475, 450, 475)];
    [self.view addSubview:view_info];
    [UIUtils addViewWithAnimation:view_info inCenterPoint:CGPointMake(212, 384)];
    [view_info release];
}

- (void)didClickButton_userInfoReturn
{
    [UIUtils removeView:_view_infoBack];
    [[JDMenuView sharedView]setButton_setUserInteractionEnabled:YES];
    [[AccountMasterViewController sharedController].table_master setUserInteractionEnabled:YES];
    //[[JDMenuView sharedView].revealSideViewController.view setUserInteractionEnabled:YES];
}


@end
