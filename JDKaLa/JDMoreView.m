//
//  JDMoreView.m
//  JDKaLa
//
//  Created by zhangminglei on 9/4/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDMoreView.h"
#import "UIUtils.h"
#import "JDSwitch.h"
#import "ClientAgent.h"
#import "CustomAlertView.h"
#import "JDMasterViewController.h"
#import "JDMoreViewController.h"
#import "JDAboutUsViewController.h"
#import "JDRuleViewController.h"
#import "JDHelpViewController.h"
#import "JDSqlDataBase.h"
#import "UIDevice+IdentifierAddition.h"
#import "JDModel_userInfo.h"
#import "JDRightCopyViewController.h"


typedef enum
{
    JDCellButtonTag_title            = 10,
    JDCellButtonTag_background           ,
    JDCellButtonTag_play                 ,
    
}JDCellButtonTag;

@implementation JDMoreView

- (id)init
{
    self = [super init];
    if(self)
    {
        [self setFrame:CGRectMake(0, 50, 1024, 718)];
        IOS7(self);
        [self configureView_tableView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleLogoutResult:)
                                                     name:NOTI_LOGOUT_RESULT object:nil];
    }
    return self;
}

- (void)dealloc
{
    [_array_data release], _array_data = nil;
    [super dealloc];
}

#pragma mark - 移除消息 -
/**
 移除消息
 **/
- (void)removeNSNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTI_LOGOUT_RESULT
                                                  object:nil];
}

- (void)configureView_tableView
{
    self.array_data = [NSMutableArray arrayWithObjects:@"3G网络缓存开关",@"自动登陆",@"清空缓存",@"常见问题",@"使用条款",@"关于",@"评价我们",@"注销登录",nil];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"moreCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] init]autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor clearColor]];
        [self installCell:cell withIndex:indexPath.row];
    }
    return cell;
}

- (void)installCell:(UITableViewCell *)cell withIndex:(NSInteger)index
{
    NSString *string_title = [_array_data objectAtIndex:index];
    
    if(index <= 2)
    {
        UIImageView *imageView_background = [[UIImageView alloc] initWithFrame:CGRectMake(35, 5, 956, 75)];
        [UIUtils didLoadImageNotCached:@"songs_bar_bg.png" inImageView:imageView_background];
        [cell addSubview:imageView_background];
        [imageView_background release];
        
        if(index == 0)
        {
            JDSwitch *squareThumbSwitch = [[JDSwitch alloc] initWithFrame:CGRectMake(840, 21, 75, 42)];
            [squareThumbSwitch setTag:0];
            squareThumbSwitch.trackImage = [UIUtils didLoadImageNotCached:@"offonback.png"];
            squareThumbSwitch.overlayImage = [UIUtils didLoadImageNotCached:@"offonback_s.png"];
            
            squareThumbSwitch.thumbImage = [UIUtils didLoadImageNotCached:@"button_turn.png"];
            squareThumbSwitch.thumbHighlightImage = [UIUtils didLoadImageNotCached:@"button_turn.png"];
            
            squareThumbSwitch.trackMaskImage = [UIUtils didLoadImageNotCached:@"offonback_k.png"];
            squareThumbSwitch.thumbMaskImage = nil; // Set this to nil to override the UIAppearance setting
            
            squareThumbSwitch.thumbInsetX = 2.0f;
            squareThumbSwitch.thumbOffsetY = 8.0f;
            [squareThumbSwitch setChangeHandler:^(BOOL on)
             {
                 switch (on)
                 {
                     case 0:
                     {
                         [self performSelector:@selector(changeSwitch:) withObject:squareThumbSwitch afterDelay:0.2f];
                     }break;
                     case 1:
                     {
                         [self performSelector:@selector(changeSwitch_pressed:) withObject:squareThumbSwitch afterDelay:0.2f];
                     }break;
                 }
             }];
            [cell addSubview:squareThumbSwitch];
        }
        else if(index == 1)
        {
            JDSwitch *squareThumbSwitch = [[JDSwitch alloc] initWithFrame:CGRectMake(840, 21, 75, 42)];
            squareThumbSwitch.trackImage = [UIUtils didLoadImageNotCached:@"offonback.png"];
            squareThumbSwitch.overlayImage = [UIUtils didLoadImageNotCached:@"offonback_s.png"];
            
            squareThumbSwitch.trackMaskImage = [UIUtils didLoadImageNotCached:@"offonback_k.png"];
            squareThumbSwitch.thumbMaskImage = nil; // Set this to nil to override the UIAppearance setting
            squareThumbSwitch.tag = 1;
            
            NSString *autoLogin = [[NSUserDefaults standardUserDefaults] objectForKey:@"AutoLogin"];
            if(autoLogin)
            {
                if([autoLogin isEqualToString:@"YES"])
                {
                    [squareThumbSwitch setOn:YES];
                    
                    squareThumbSwitch.thumbImage = [UIUtils didLoadImageNotCached:@"button_turn_pressed.png"];
                    squareThumbSwitch.thumbHighlightImage = [UIUtils didLoadImageNotCached:@"button_turn_pressed.png"];
                }
                else
                {
                    [squareThumbSwitch setOn:NO];
                    
                    squareThumbSwitch.thumbImage = [UIUtils didLoadImageNotCached:@"button_turn.png"];
                    squareThumbSwitch.thumbHighlightImage = [UIUtils didLoadImageNotCached:@"button_turn.png"];
                }
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"AutoLogin"];
                [squareThumbSwitch setOn:YES];
            }
            
            squareThumbSwitch.thumbInsetX = 2.0f;
            squareThumbSwitch.thumbOffsetY = 8.0f;
            [squareThumbSwitch setChangeHandler:^(BOOL on)
             {
                 switch (on)
                 {
                     case 0:
                     {
                         [self performSelector:@selector(changeSwitch:) withObject:squareThumbSwitch afterDelay:0.2f];
                     }break;
                     case 1:
                     {
                         [self performSelector:@selector(changeSwitch_pressed:) withObject:squareThumbSwitch afterDelay:0.2f];
                     }break;
                 }
             }];
            [cell addSubview:squareThumbSwitch];
        }
        else
        {
            UIButton *button_play = [UIButton buttonWithType:UIButtonTypeCustom];
            [button_play setFrame:CGRectMake(840, 21, 80, 42)];
            [UIUtils didLoadImageNotCached:@"button_clear.png" inButton:button_play withState:UIControlStateNormal];
            [button_play setTag:index];
            [button_play addTarget:self action:@selector(didClickButton_clear:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button_play];
        }
        
        UILabel *label_title = [[UILabel alloc] initWithFrame:CGRectMake(100, 14, 430, 45)];
        [label_title setBackgroundColor:[UIColor clearColor]];
        [label_title setFont:[UIFont systemFontOfSize:25.0]];
        [label_title setText:string_title];
        [label_title setTextColor:[UIColor whiteColor]];
        [imageView_background addSubview:label_title];
        [label_title release];
    }
    else
    {
        UIButton *button_background = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_background setFrame:CGRectMake(35, 5, 956, 75)];
        [UIUtils didLoadImageNotCached:@"songs_bar_bg.png" inButton:button_background withState:UIControlStateNormal];
        [button_background setTag:index];
        [button_background addTarget:self action:@selector(didClickButtonPlay_cell:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:button_background];
        
        UILabel *label_title = [[UILabel alloc] initWithFrame:CGRectMake(100, 14, 430, 45)];
        [label_title setBackgroundColor:[UIColor clearColor]];
        [label_title setFont:[UIFont systemFontOfSize:25.0]];
        [label_title setText:string_title];
        [label_title setTextColor:[UIColor whiteColor]];
        [button_background addSubview:label_title];
        [label_title release];
    
        UIButton *button_detail = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_detail setFrame:CGRectMake(855, 25, 26, 26)];
        [UIUtils didLoadImageNotCached:@"button_detail.png" inButton:button_detail withState:UIControlStateNormal];
        [button_detail setTag:index];
        [button_detail addTarget:self action:@selector(didClickButtonPlay_cell:) forControlEvents:UIControlEventTouchUpInside];
        [button_background addSubview:button_detail];
    }
}

#pragma mark - 开 -
/**开**/
- (void)changeSwitch:(JDSwitch *)squareThumbSwitch
{
    squareThumbSwitch.thumbImage = [UIUtils didLoadImageNotCached:@"button_turn.png"];
    squareThumbSwitch.thumbHighlightImage = [UIUtils didLoadImageNotCached:@"button_turn.png"];
    if(squareThumbSwitch.tag == 0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"3G"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"AutoLogin"];
        
    }
}

#pragma mark - 关 -
/**关**/
- (void)changeSwitch_pressed:(JDSwitch *)squareThumbSwitch
{
    squareThumbSwitch.thumbImage = [UIUtils didLoadImageNotCached:@"button_turn_pressed.png"];
    squareThumbSwitch.thumbHighlightImage = [UIUtils didLoadImageNotCached:@"button_turn_pressed.png"];
    if(squareThumbSwitch.tag == 0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"3G"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"AutoLogin"];
    }
}

#pragma mark - 点击详情按钮回调 -
/**
 点击详情按钮回调
 **/
- (void)didClickButtonPlay_cell:(id)sender
{
    UIButton *button_tag = (UIButton *)sender;
    switch (button_tag.tag)
    {
        case 3:
        {
            JDMoreViewController *moreViewController = [self reciveSuperViewControllerWithView:self];
            JDHelpViewController *helpViewController = [[JDHelpViewController alloc] init];
            helpViewController.nav_return = moreViewController.nav_return;
            [moreViewController.nav_return pushViewController:helpViewController animated:YES];
            [helpViewController release];
        }break;
        case 4:
        {
            JDMoreViewController *moreViewController = [self reciveSuperViewControllerWithView:self];
            JDRuleViewController *ruleViewController = [[JDRuleViewController alloc] init];
            ruleViewController.nav_return = moreViewController.nav_return;
            [moreViewController.nav_return pushViewController:ruleViewController animated:YES];
            [ruleViewController release];
        }break;
            
        /*case 5:
        {
            JDMoreViewController *moreViewController = [self reciveSuperViewControllerWithView:self];
            JDRightCopyViewController *rightViewController = [[JDRightCopyViewController alloc] init];
            rightViewController.nav_return = moreViewController.nav_return;
            [moreViewController.nav_return pushViewController:rightViewController animated:YES];
            [rightViewController release];
            
        }break;*/
        case 5:
        {
            JDMoreViewController *moreViewController = [self reciveSuperViewControllerWithView:self];
            JDAboutUsViewController *aboutViewController = [[JDAboutUsViewController alloc] init];
            aboutViewController.nav_return = moreViewController.nav_return;
            [moreViewController.nav_return pushViewController:aboutViewController animated:YES];
            [aboutViewController release];
            
        }break;
            
        case 6:
        {
            [self evaluateForApp];
        }break;
        case 7:
        {
            NSString *string_tourist = [[NSUserDefaults standardUserDefaults] objectForKey:@"tourist"];
            if([string_tourist isEqualToString:@"YES"])
            {
                CustomAlertView *alter = [[CustomAlertView alloc] initWithTitle:@"您当前身份为游客"
                                                                        message:nil
                                                                       delegate:self
                                                              cancelButtonTitle:@"确定"
                                                              otherButtonTitles:nil];
                [alter show];
                [alter release];
            }
            else
            {
                ClientAgent *client = [[ClientAgent alloc] init];
                [client logout:[[NSUserDefaults standardUserDefaults]  objectForKey:@"userID"] Token:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"]];
            }
        }break;
            
        default:
            break;
    }
}

#pragma mark - 评分 -
/**评分**/
- (void)evaluateForApp
{
    NSString *urlPath = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",@"694939768"];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}


#pragma mark - 点击清空按钮 -
/**
 点击清空按钮
 **/
- (void)didClickButton_clear:(id)sender
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"preread_buffer"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL pathExist = [fileManager removeItemAtPath:path error:nil];;
    if(pathExist)
    {
        CustomAlertView *alter = [[CustomAlertView alloc] initWithTitle:@"成功" message:@"已清空缓存"
                                                               delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alter show];
        [alter release];
    }
}


#pragma mark - 寻找父视图 -
/**
 寻找父视图
 **/
- (JDMoreViewController *)reciveSuperViewControllerWithView:(UIView *)view
{
    for (UIView *next = [view superview]; next; next = next.superview)
    {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[JDMoreViewController class]])
        {
            return (JDMoreViewController *)nextResponder;
        }
    }
    return nil;
}

#pragma mark - 退出登陆消息通知 -
/**
 退出登陆消息通知
 **/
- (void)handleLogoutResult:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    CustomAlertView     *alertDialog;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    if([[state objectForKey:@"result"] length] > 0 && 0 == resultCode)
    {
        alertDialog = [[CustomAlertView alloc] initWithTitle:@"退出系统"
                                                 message:@"正常退出系统"
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
        
        //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userName"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"passWord"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"nickName"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"money"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"device"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"portrait"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"token"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"token"];
        }
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"signature"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userID"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sex"];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"tourist"];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleLoginResult:)
                                                     name:NOTI_LOGIN_RESULT
                                                   object:nil];
        NSString *string_email = [NSString stringWithFormat:@"%@@kod.com",[[UIDevice currentDevice]uniqueGlobalDeviceIdentifier]];
        NSString *string_passWord = [[UIDevice currentDevice]uniqueGlobalDeviceIdentifier];
        ClientAgent *agent = [[ClientAgent alloc] init];
        [agent login:string_email Password:string_passWord Version:@"iPad-1.0" DevID:[[UIDevice currentDevice]uniqueGlobalDeviceIdentifier]];
        
        [[JDMasterViewController sharedController] loginOutReloadView];
    }
    else
    {
        alertDialog = [[CustomAlertView alloc] initWithTitle:@"已退出"
                                                 message:nil
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
        
    }
    [alertDialog show];
    [alertDialog release];
}


#pragma mark - 登陆消息回调 -
/**
 登陆回调函数
 **/
- (void)handleLoginResult:(NSNotification *)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTI_LOGIN_RESULT
                                                  object:nil];
    
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    if(0 == resultCode)
    {
        if([state objectForKey:@"token"])
        {
            [JDModel_userInfo sharedModel].string_token = [state objectForKey:@"token"];
            [[NSUserDefaults standardUserDefaults] setObject:[JDModel_userInfo sharedModel].string_token forKey:@"token"];
        }
        
        if([[[state objectForKey:@"userinfo"]objectForKey:@"userBasic"]objectForKey:@"id"])
        {
            [JDModel_userInfo sharedModel].string_userID = [[[state objectForKey:@"userinfo"]objectForKey:@"userBasic"]objectForKey:@"id"];
            [[NSUserDefaults standardUserDefaults] setObject:[JDModel_userInfo sharedModel].string_userID forKey:@"userID"];
        }
        
        if([[[state objectForKey:@"userinfo"]objectForKey:@"userDetail"]objectForKey:@"kb"])
        {
            [JDModel_userInfo sharedModel].string_money = [[[state objectForKey:@"userinfo"]objectForKey:@"userDetail"]objectForKey:@"kb"];
            [[NSUserDefaults standardUserDefaults] setObject:[JDModel_userInfo sharedModel].string_money forKey:@"money"];
        }
        
        [JDModel_userInfo sharedModel].string_nickName = @"游客";
        [[NSUserDefaults standardUserDefaults] setObject:[JDModel_userInfo sharedModel].string_nickName forKey:@"nickName"];
        [JDModel_userInfo sharedModel].string_tourist = @"YES";
    }
    else
    {
        CustomAlertView *alertDialog = [[CustomAlertView alloc] initWithTitle:@"链接失败"
                                                                      message:@""
                                                                     delegate:self
                                                            cancelButtonTitle:@"确定"
                                                            otherButtonTitles:nil];
        [alertDialog show];
        [alertDialog release];
    }
}


@end
