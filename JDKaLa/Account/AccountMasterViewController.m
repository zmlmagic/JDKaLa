//
//  AccountMasterViewController.m
//  JDKaLa
//
//  Created by 韩 抗 on 13-4-15.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import "AccountMasterViewController.h"
#import "SKRevealSideViewController.h"
#import "RechargeHisViewController.h"
#import "PayHisViewController.h"
#import "CardListViewController.h"
#import "ProductListViewController.h"
#import "JDMenuView.h"
#import "ClientAgent.h"
#import "CustomAlertView.h"
#import "JDSqlDataUser.h"
#import "ClientAgent.h"
#import "JDModel_userInfo.h"
#import "UIUtils.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "JDMasterViewController.h"
#import "UIDevice+IdentifierAddition.h"


@interface AccountMasterViewController ()

@end

@implementation AccountMasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleCommitModify:)
                                                     name:NOTI_MODIFY_INFO_RESULT
                                                   object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleGetUserDetail:)
                                                     name:NOTI_GET_USER_DETAIL_RESULT
                                                   object:nil];
        
        ClientAgent *agent = [[ClientAgent alloc] init];
        _agent = agent;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView_title];
    //[self configureView_kCoinCount];
    [self configureView_table];
    [self reloadKB];
    //NSLog(@"test");
    /*ClientAgent *agent = [[ClientAgent alloc] init];
    [agent getRechargeList:0 UserID:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTI_MODIFY_INFO_RESULT
                                                  object:nil];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTI_GET_USER_DETAIL_RESULT
                                                  object:nil];
    
    
    [_table_master release], _table_master = nil;
    [_array_data_record release], _array_data_record = nil;
    [tableCellPix release];
    [tableCellActivePix release];
    [_label_KCoin release], _label_KCoin = nil;
    [super dealloc];
}

static AccountMasterViewController *masterViewController = nil;

+ (AccountMasterViewController *)sharedController
{
    @synchronized(self)
    {
        if(masterViewController == nil)
        {
            masterViewController = [[[self alloc] init] autorelease];
        }
    }
    return masterViewController;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (masterViewController == nil)
        {
            masterViewController = [super allocWithZone:zone];
            return  masterViewController;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (oneway void)release
{
    
}

- (id)autorelease
{
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if(_label_nickName)
    {
        [_label_nickName setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"]];
    }
    
    if(_label_KCoin)
    {
        [self reloadKB];
    }
    
    if(_imageView_portrait)
    {
        [_imageView_portrait removeFromSuperview];
        _imageView_portrait = nil;
        
        UIImageView *imageView_portrait = [[UIImageView alloc] initWithFrame:CGRectMake(79, 10, 143, 134)];
        UITableViewCell *cell = [_table_master cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [imageView_portrait setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"portrait"]] placeholderImage:[UIUtils didLoadImageNotCached:@"user_profileavatarcenter.png"]];
        [cell addSubview:imageView_portrait];
        [imageView_portrait release];
        _imageView_portrait = imageView_portrait;
    }
    
    if(_label_state)
    {
        [self reloadState];
    }
}

#pragma mark - 刷新按钮 -
/**
 刷新按钮
 **/
- (void)reloadButtonIndex
{
    if(_button_before)
    {
        [UIUtils didLoadImageNotCached:[tableCellPix objectAtIndex:_button_before.tag - 2] inButton:_button_before withState:UIControlStateNormal];
    }
    if(_button_first)
    {
        [UIUtils didLoadImageNotCached:[tableCellActivePix objectAtIndex:0] inButton:_button_first withState:UIControlStateNormal];
    }
}


- (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity
{
    float red = ((float)((hexColor & 0xFF0000) >> 16))/255.0;
    float green = ((float)((hexColor & 0xFF00) >> 8))/255.0;
    float blue = ((float)(hexColor & 0xFF))/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:opacity];
}


- (void)configureView_title
{
    UIImageView *imageView_title = [[UIImageView alloc] initWithFrame:CGRectMake(-10, 0, 300, 50)];
    IOS7(imageView_title);
    [UIUtils didLoadImageNotCached:@"menu_title_bg_account.png" inImageView:imageView_title];
    [self.view addSubview:imageView_title];
    [imageView_title release];
}

- (void)configureView_table
{
    [self configureData_table];
    _bool_firstConfigure = YES;
    _table_master = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, 300, 704) style:UITableViewStylePlain];
    IOS7(_table_master);
    _table_master.dataSource = self;
    _table_master.delegate = self;
    [_table_master setSeparatorColor:[self colorWithHex:0xCBCBCB alpha:1.0]];
    [_table_master setBackgroundColor:[self colorWithHex:0xCBCBCB alpha:1.0]];
    [self.view addSubview:_table_master];
    [_table_master release];
}


- (void)configureData_table
{
    
    tableCellPix = [[NSArray alloc] initWithObjects:
        @"menu_bar_account_01_buy.png",
        @"menu_bar_account_02_redeem.png",
        @"menu_bar_account_03_recharge_his.png",
        @"menu_bar_account_04_cost.png", nil];
    
    tableCellActivePix = [[NSArray alloc] initWithObjects:
                          @"menu_bar_account_01_buy_active.png",
                          @"menu_bar_account_02_redeem_active.png",
                          @"menu_bar_account_03_recharge_his_active.png",
                          @"menu_bar_account_04_cost_active.png", nil];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableCellPix count] + 2;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        return 250;
    }
    else if(indexPath.row == 1)
    {
        return 150;
    }
    else
    {
        return 75;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AccountCellIdentifier";
    
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
    if(index == 0)
    {
        UIImageView *tempView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_bar_bg"]];
        [cell setBackgroundView:tempView];
        [tempView release];
        
        UIImageView *imageView_portrait = [[UIImageView alloc] initWithFrame:CGRectMake(79, 10, 143, 134)];
        //NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"portrait"]);
        [imageView_portrait setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"portrait"]] placeholderImage:[UIUtils didLoadImageNotCached:@"user_profileavatarcenter.png"]];
        [cell addSubview:imageView_portrait];
        [imageView_portrait release];
        _imageView_portrait = imageView_portrait;
        
        UILabel *label_name = [[UILabel alloc] initWithFrame:CGRectMake(10, 150, 280, 40)];
        [label_name setBackgroundColor:[UIColor clearColor]];
        [label_name setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:25.0f]];
        [label_name setTextAlignment:NSTextAlignmentCenter];
        [label_name setTextColor:[UIColor grayColor]];
        [label_name setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"]];
        [cell addSubview:label_name];
        [label_name release];
        _label_nickName = label_name;
        
        MarqueeLabel *label_state = [[MarqueeLabel alloc] initWithFrame:CGRectMake(70, 190, 180, 30)];
        [label_state setBackgroundColor:[UIColor clearColor]];
        label_state.numberOfLines = 1;
        label_state.opaque = NO;
        label_state.enabled = YES;
        label_state.shadowOffset = CGSizeMake(0.0, -1.0);
        label_state.textAlignment = UITextAlignmentLeft;
        label_state.textColor = [UIColor grayColor];
        label_state.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
        [cell addSubview:label_state];
        [label_state release];
        _label_state = label_state;
        
        UIImageView *imageView_vip = [[UIImageView alloc] initWithFrame:CGRectMake(15, 192, 40, 20)];
        [cell addSubview:imageView_vip];
        [imageView_vip release];
        _imageView_vip = imageView_vip;
        
        [self reloadState];
        /*[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleGetStateResult:)
                                                     name:NOTI_GET_USER_STATUS_RESULT
                                                   object:nil];
        
        ClientAgent *agent = [[ClientAgent alloc] init];
        [agent getUserStatus:[[NSUserDefaults standardUserDefaults] objectForKey:@"userID"] Token:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"]];*/
    }
    else if(index == 1)
    {
        UIImageView *imageView_KCoin = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 300, 150)];
        [imageView_KCoin setImage:[UIImage imageNamed:@"account_menu_bar_bg"]];
        [cell addSubview:imageView_KCoin];
        [imageView_KCoin release];
        
        _label_KCoin = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, 280, 100)];
        [_label_KCoin setTextAlignment:NSTextAlignmentCenter];
        [_label_KCoin setFont:[UIFont fontWithName:@"Helvetica-Bold" size:25.0f]];
        [_label_KCoin setTextColor:[self colorWithHex:0xC1B48F alpha:1.0]];
        [_label_KCoin setShadowColor:[UIColor lightGrayColor]];
        [_label_KCoin setBackgroundColor:[UIColor clearColor]];
        [_label_KCoin setTextAlignment:NSTextAlignmentCenter];
         
        [_label_KCoin setText:@"加载中..."];
        [cell addSubview:_label_KCoin];
        [_label_KCoin release];
    }
    else
    {
        UIImageView *tempView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_bar_bg"]];
        [cell setBackgroundView:tempView];
        [tempView release];
        
        UIButton *button_back = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_back setFrame:CGRectMake(70, 17, 150, 40)];
        if(index == 2)
        {
            _button_first = button_back;
            _button_before = button_back;
            [UIUtils didLoadImageNotCached:[tableCellActivePix objectAtIndex:index - 2] inButton:button_back withState:UIControlStateNormal];
        }
        else
        {
            [UIUtils didLoadImageNotCached:[tableCellPix objectAtIndex:index - 2] inButton:button_back withState:UIControlStateNormal];
        }
        [UIUtils didLoadImageNotCached:[tableCellActivePix objectAtIndex:index - 2] inButton:button_back withState:UIControlStateHighlighted];
        [button_back setBackgroundColor:[UIColor clearColor]];
        [button_back setTag:index];
        [button_back addTarget:self action:@selector(didSelectCell_account:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:button_back];
    }
}

- (void)didSelectCell_account:(id)sender
{
    JDMenuView *view_menu = [JDMenuView sharedView];
    UIButton *button_tag = (UIButton *)sender;
    
    [UIUtils didLoadImageNotCached:[tableCellPix objectAtIndex:_button_before.tag - 2] inButton:_button_before withState:UIControlStateNormal];
    [UIUtils didLoadImageNotCached:[tableCellActivePix objectAtIndex:button_tag.tag -2] inButton:button_tag withState:UIControlStateNormal];

    switch (button_tag.tag)
    {
        case 2:
        {
            _button_before = button_tag;
            ProductListViewController   *productController = [[ProductListViewController alloc] init];
            if(self.revealSideViewController.rootViewController)
            {
                [self.revealSideViewController.rootViewController release];
            }
            [self.revealSideViewController setRootViewController:productController];
            [view_menu configureView_animetionButton_inViewChange];
            [productController release];
        }break;
        case 3:
        {
            CardListViewController *cardListController = [[CardListViewController alloc]init];
            
            if(self.revealSideViewController.rootViewController)
            {
                [self.revealSideViewController.rootViewController release];
            }
            [self.revealSideViewController setRootViewController:cardListController];
            [view_menu configureView_animetionButton_inViewChange];
            [cardListController release];
            
            _button_before = button_tag;
        }break;
        case 4:
        {
            RechargeHisViewController *rechargeHistoryController = [[RechargeHisViewController alloc]init];
            
            if(self.revealSideViewController.rootViewController)
            {
                [self.revealSideViewController.rootViewController release];
            }
            [self.revealSideViewController setRootViewController:rechargeHistoryController];
            [view_menu configureView_animetionButton_inViewChange];
            [rechargeHistoryController release];
            
            _button_before = button_tag;
        }break;
        case 5:
        {
            PayHisViewController *payHistoryController = [[PayHisViewController alloc]init];
            
            if(self.revealSideViewController.rootViewController)
            {
                [self.revealSideViewController.rootViewController release];
            }
            [self.revealSideViewController setRootViewController:payHistoryController];
            [view_menu configureView_animetionButton_inViewChange];
            [payHistoryController release];
            
            _button_before = button_tag;
            
        }break;
            
        default:
            break;
    }
    
}

# pragma Table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 || indexPath.row == 1)
    {
        return;
    }
    JDMenuView *view_menu = [JDMenuView sharedView];
    switch (indexPath.row)
    {
        case 2:
        {
            ProductListViewController *productController = [[ProductListViewController alloc]init];
            
            if(self.revealSideViewController.rootViewController)
            {
                [self.revealSideViewController.rootViewController release];
            }
            [self.revealSideViewController setRootViewController:productController];
            [view_menu configureView_animetionButton_inViewChange];
            [productController release];
            break;
        }
        case 3:
        {
            CardListViewController *cardController = [[CardListViewController alloc]init];
            if(self.revealSideViewController.rootViewController)
            {
                [self.revealSideViewController.rootViewController release];
            }
            [self.revealSideViewController setRootViewController:cardController];
            [view_menu configureView_animetionButton_inViewChange];
            [cardController release];
            break;
        }
        case 4:
        {
            RechargeHisViewController *rechargeHistoryController = [[RechargeHisViewController alloc] init];
            if(self.revealSideViewController.rootViewController)
            {
                [self.revealSideViewController.rootViewController release];
            }
            [self.revealSideViewController setRootViewController:rechargeHistoryController];
            [[JDMenuView sharedView] configureView_animetionButton_inViewChange];
            [rechargeHistoryController release];
            
        }break;
        case 5:
        {
            PayHisViewController *payHistoryController = [[PayHisViewController alloc]init];
            if(self.revealSideViewController.rootViewController)
            {
                [self.revealSideViewController.rootViewController release];
            }
            [self.revealSideViewController setRootViewController:payHistoryController];
            [[JDMenuView sharedView] configureView_animetionButton_inViewChange];
            [payHistoryController release];
            break;
        }
        default:
            break;
    }
    
    curMenuIdx = indexPath.row;
    [tableView reloadData];
}

#pragma mark - 上传头像 -
/**
 上传头像
 **/
- (void)upLoadPortraitInBackground:(NSString *)fileName
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUploadPortrait:)
                                                 name:NOTI_UPLOAD_PORTRAIT_RESULT
                                               object:nil];
    
    [_agent uploadPortrait:fileName UserID:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
    
}





#pragma mark - 获取充值记录回调 -
/**
 * 获取充值记录的反馈
 */
- (void)handleGetRechargeList:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    UIAlertView     *alertDialog;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    if([[state objectForKey:@"result"] length] > 0 && 0 == resultCode)
    {

        NSArray *billList = [state objectForKey:@"billlist"];
        NSMutableString *resultStr = [[NSMutableString alloc]initWithString:@"充值记录:\n"];
        NSString *isSuccess;
        
        for(NSDictionary* record in billList)
        {
            if([[record objectForKey:@"issuccess"] isEqualToString:@"1"])
            {
                isSuccess = @"购买成功";
            }
            else
            {
                isSuccess = @"购买失败";
            }
            [resultStr appendFormat:@" %@ %@KB Source: %@ %@\n", [record objectForKey:@"buytime"], [record objectForKey:@"buynums"], [record objectForKey:@"billsource"], isSuccess];
        }
        
        
        RechargeHisViewController *rechargeHistoryController = [[RechargeHisViewController alloc] init];
        //[rechargeHistoryController setString_record:resultStr];
        if(self.revealSideViewController.rootViewController)
        {
            [self.revealSideViewController.rootViewController release];
        }
        [self.revealSideViewController setRootViewController:rechargeHistoryController];
        [[JDMenuView sharedView] configureView_animetionButton_inViewChange];
        [rechargeHistoryController release];
        //[_TextConsole setText:resultStr];
    }
    else
    {
        alertDialog = [[UIAlertView alloc] initWithTitle:@"失败"
                                                 message:[state objectForKey:@"msg"]
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
        [alertDialog show];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                name:NOTI_GET_RECHARGE_LIST_RESULT
                                              object:nil];

}

#pragma mark - 获取兑换记录的反馈 -
/**
 * 获取兑换记录的反馈
 */
- (void)handleGetExchangeList:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    UIAlertView     *alertDialog;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    if([[state objectForKey:@"result"] length] > 0 && 0 == resultCode)
    {
        alertDialog = [[UIAlertView alloc] initWithTitle:@"成功"
                                                 message:@"获取到兑换记录"
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
        
        NSArray *billList = [state objectForKey:@"recordlist"];
        NSMutableString *resultStr = [[NSMutableString alloc]initWithString:@"兑换记录:\n"];
        NSString *isSuccess;
        
        for(NSDictionary* record in billList)
        {
            NSString    *action;
            int         actid = [[record objectForKey:@"actid"] intValue];
            switch(actid)
            {
                case 3:
                    action = @"兑换包月";
                    break;
                case 4:
                    action = @"兑换时长";
                    break;
                case 13:
                    action = @"购买单曲";
                    break;
                default:
                    action = @"未知操作";
                    break;
            }
            
            if([[record objectForKey:@"issuccess"] isEqualToString:@"1"])
            {
                isSuccess = @"兑换成功";
            }
            else
            {
                isSuccess = @"兑换失败";
            }
            [resultStr appendFormat:@" %@ %@ \ndevno: %@ %@\n", [record objectForKey:@"acttime"], action, [record objectForKey:@"devno"], isSuccess];
        }
        
//        PayHistoryViewController *payHistoryController = [[PayHistoryViewController alloc] initWithNibName:@"PayHistoryViewController" bundle:nil];
//        [payHistoryController setString_record:resultStr];
//        if(self.revealSideViewController.rootViewController)
//        {
//            [self.revealSideViewController.rootViewController release];
//        }
//        [self.revealSideViewController setRootViewController:payHistoryController];
//        [[JDMenuView sharedView] configureView_animetionButton_inViewChange];
//        [payHistoryController release];
     
    }
    else
    {
        alertDialog = [[UIAlertView alloc] initWithTitle:@"失败"
                                                 message:[state objectForKey:@"msg"]
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
        [alertDialog show];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTI_GET_EXCHANGE_LIST_RESULT
                                                  object:nil];
}




#pragma mark ClientAgent Notification
- (void)handleCommitModify:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    CustomAlertView *alertDialog;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    if([[state objectForKey:@"result"] length] > 0 && 0 == resultCode)
    {
        alertDialog = [[CustomAlertView alloc] initWithTitle:@"修改完成"
                                                                      message:@"用户信息修改成功"
                                                                     delegate:self
                                                            cancelButtonTitle:@"确定"
                                                            otherButtonTitles:nil];
        [alertDialog show];
        [alertDialog release];
        
        [[NSUserDefaults standardUserDefaults] setObject:[JDModel_userInfo sharedModel].string_nickName forKey:@"nickName"];
        [[NSUserDefaults standardUserDefaults] setInteger:[JDModel_userInfo sharedModel].integer_sex forKey:@"sex"];
        
        [self reloadNickName];
       
        
    }
    else
    {
        alertDialog = [[CustomAlertView alloc] initWithTitle:@"修改失败"
                                                     message:[state objectForKey:@"msg"]
                                                    delegate:self
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [alertDialog show];
        [alertDialog release];
    }
}


#pragma mark - 上传头像回调方法 -

- (void)handleUploadPortrait:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    CustomAlertView     *alertDialog;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    if([[state objectForKey:@"result"] length] > 0 && 0 == resultCode)
    {
        alertDialog = [[CustomAlertView alloc] initWithTitle:@"上传成功"
                                                     message:@"用户头像上传成功。"
                                                    delegate:self
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [alertDialog show];
        [alertDialog release];
        
        
       
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleGetUserPortrait:)
                                                     name:NOTI_LOGIN_RESULT
                                                   object:nil];
        
        [_agent login:[JDModel_userInfo sharedModel].string_userName  Password:[JDModel_userInfo sharedModel].string_userPass Version:@"iPad-1.0" DevID:[[UIDevice currentDevice]uniqueGlobalDeviceIdentifier]];
   
    }
    else
    {
        alertDialog = [[CustomAlertView alloc] initWithTitle:@"上传失败"
                                                     message:[state objectForKey:@"msg"]
                                                    delegate:self
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [alertDialog show];
        [alertDialog release];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTI_UPLOAD_PORTRAIT_RESULT
                                                  object:nil];
}

#pragma mark - 检测头像 -
/**
 检测头像
 **/
- (void)handleGetUserPortrait:(NSNotification *)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTI_LOGIN_RESULT
                                                  object:nil];
    
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    if(0 == resultCode)
    {
        if([[[state objectForKey:@"userinfo"]objectForKey:@"userDetail"]objectForKey:@"headpic"])
        {
            [JDModel_userInfo sharedModel].string_portrait = [[[state objectForKey:@"userinfo"]objectForKey:@"userDetail"]objectForKey:@"headpic"];
            [[NSUserDefaults standardUserDefaults] setObject:[JDModel_userInfo sharedModel].string_portrait forKey:@"portrait"];
            [self reloadPortrait];
        }
    }
}


#pragma mark - 刷新K余额 -
/**
 刷新K余额
 **/
- (void)reloadKB
{
    [_agent getUserDetail:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
}

#pragma mark  - 查询余额消息回调 -
/**
 查询余额消息回调
 **/
- (void)handleGetUserDetail:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    if([[state objectForKey:@"result"] length] > 0 && 0 == resultCode)
    {
        NSDictionary *accountInfo = [state objectForKey:@"account"];
        _label_KCoin.text = [accountInfo objectForKey:@"kb"];
        [[NSUserDefaults standardUserDefaults] setObject:[accountInfo objectForKey:@"kb"] forKey:@"money"];
        [_label_KCoin setFont:[UIFont fontWithName:@"Helvetica-Bold" size:70.0f]];
    }
    else
    {
        _label_KCoin.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"money"];
        [_label_KCoin setFont:[UIFont fontWithName:@"Helvetica-Bold" size:70.0f]];
    }
}

/**
 刷新用户名和头像
 **/
- (void)reloadPortrait
{
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] clearMemory];
    
    [_imageView_portrait setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"portrait"]] placeholderImage:[UIUtils didLoadImageNotCached:@"user_profileavatarcenter.png"]];
    [[JDMasterViewController sharedController] reloadImageViewPortrait];
}

- (void)reloadNickName
{
    [[JDMasterViewController sharedController] reloadTextNickName];
    [_label_nickName setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"]];
}

/**
 刷新欢唱卡状态
 **/
- (void)reloadState
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleGetStateResult:)
                                                 name:NOTI_GET_USER_STATUS_RESULT
                                               object:nil];
    
    ClientAgent *agent = [[ClientAgent alloc] init];
    [agent getUserStatus:[[NSUserDefaults standardUserDefaults] objectForKey:@"userID"] Token:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"]];
}

#pragma mark - 检查充值完成情况 -
/**
 * 检查充值完成情况
 */
- (void)checkRechargeResult
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCheckRechargeResult:)
                                                 name:NOTI_CHECK_RECHARGE_RESULT
                                               object:nil];
    
    if(_timer_check)
    {
        [_timer_check invalidate];
        _timer_check = nil;
    }
    
    NSTimer *time_checkMoney = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                                target:self
                                                              selector:@selector(checkRechargeForManyTimes)
                                                              userInfo:nil
                                                               repeats:YES];
    
    [self performSelector:@selector(stopTimerCheck) withObject:nil afterDelay:180];
    
    _timer_check = time_checkMoney;
    [time_checkMoney fire];
}

- (void)checkRechargeForManyTimes
{
    //NSLog(@"正在轮训");
    [_agent checkRechargeResult:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
}

- (void)stopTimerCheck
{
    if(_timer_check)
    {
        [_timer_check invalidate];
        _timer_check = nil;
    }
}

#pragma mark - 检查购买是否完成的反馈接口 -
/**
 * 检查购买是否完成的反馈接口
 */
- (void)handleCheckRechargeResult:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    CustomAlertView     *alertDialog;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    if([[state objectForKey:@"result"] length] > 0 && 0 == resultCode)
    {
        NSArray *billList = [state objectForKey:@"querylist"];
        for(NSDictionary* record in billList)
        {
            if([[record objectForKey:@"status"] isEqualToString:@"0"])
            {
                alertDialog = [[CustomAlertView alloc] initWithTitle:@"购买已成功"
                                                             message:nil
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
                [alertDialog show];
                [alertDialog release];
                
                [_timer_check invalidate];
                _timer_check = nil;
                [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                name:NOTI_CHECK_RECHARGE_RESULT
                                                              object:nil];
                
                [self reloadKB];
                
            }
            else
            {
                alertDialog = [[CustomAlertView alloc] initWithTitle:@"购买已失败"
                                                             message:nil
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
                [alertDialog show];
                [alertDialog release];
                
                [_timer_check invalidate];
                _timer_check = nil;
                [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                name:NOTI_CHECK_RECHARGE_RESULT
                                                              object:nil];
            }
        }
    }
    else
    {
        /*alertDialog = [[CustomAlertView alloc] initWithTitle:@"失败"
                                                 message:[state objectForKey:@"msg"]
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];*/
        //[alertDialog show];
    }
}

- (void)handleGetStateResult:(NSNotification *)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTI_GET_USER_STATUS_RESULT
                                                  object:nil];
    
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    if([[state objectForKey:@"result"] length] > 0 && 0 == resultCode)
    {
        if([state objectForKey:@"invaliddate"])
        {
            //NSLog(@"%@",[state objectForKey:@"invaliddate"]);
            [UIUtils didLoadImageNotCached:@"VIP_gold.png" inImageView:_imageView_vip];
            [_label_state setText:[NSString stringWithFormat:@"您可使用全部曲库,截止日期%@",[state objectForKey:@"invaliddate"]]];
            
            NSString *string_tmp = [state objectForKey:@"remaintime"];
            NSRange rage = [string_tmp rangeOfString:@":"];
            NSString *string_time = [string_tmp substringToIndex:rage.location];
            NSString *string_time_warn = [NSString stringWithFormat:@"您的vip剩余时长为:%@小时\n请及时充值",string_time];
            
            if([string_time integerValue] <= 48)
            {
               CustomAlertView *alertDialog = [[CustomAlertView alloc] initWithTitle:@"提示"
                                                             message:string_time_warn
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
                [alertDialog show];
                [alertDialog release];
            }
        }
    }
    else
    {
        if([state objectForKey:@"msg"])
        {
            NSRange range = [[state objectForKey:@"msg"] rangeOfString:@"548"];
            if(range.location != NSNotFound)
            {
                //NSLog(@"用户为处于时长状态");
                [_label_state setText:@"您还未开卡,可使用免费曲目"];
                [UIUtils didLoadImageNotCached:@"" inImageView:_imageView_vip];
            }
            else
            {
                [_label_state setText:@"链接失败"];
                [UIUtils didLoadImageNotCached:@"" inImageView:_imageView_vip];
                //NSLog(@"链接失败");
            }
        }
        //548
    }
}

@end
