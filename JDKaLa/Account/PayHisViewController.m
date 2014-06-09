//
//  PayHisViewController.m
//  JDKaLa
//
//  Created by 韩 抗 on 13-10-21.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import "PayHisViewController.h"
#import "AccountMasterViewController.h"
#import "SKRevealSideViewController.h"
#import "SKCustomNavigationBar.h"
#import "UIUtils.h"
#import "JDModel_userInfo.h"
#import "JDModel_payRecord.h"

#define TAG_OF_TIME 10000
#define TAG_OF_PAY_TYPE 20000
#define TAG_OF_SONG_NAME 30000
#define TAG_OF_PRICE 40000
#define TAG_OF_SUCCESS 50000

@interface PayHisViewController ()

@end

@implementation PayHisViewController

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
        [self installView_background];
        [self installView_title];
        [self configureView_table];
        self.agent = [[ClientAgent alloc] init];
        recordList = [[NSMutableArray alloc]init];
        database = [[JDSqlDataBase alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [recordList release];
    [database release];
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
    //[self didClickButton_master];
    
    [self getRecordList];
    [UIUtils view_showProgressHUD:@"正在获取消费记录..." forWaitInView:self.view];
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
    [label_titel setText:@"消费记录"];
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
 * 获取消费记录列表（异步函数，立即返回）
 */
- (void)getRecordList
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleGetExchangeListResult:)
                                                 name:NOTI_GET_EXCHANGE_LIST_RESULT
                                               object:nil];
    [_agent getExchangeList:0 UserID:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
}

/**
 * 获取消费列表的反馈处理
 */
- (void)handleGetExchangeListResult:(NSNotification *)note
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
            NSArray *billList = [state objectForKey:@"recordlist"];
            
            for(NSDictionary* record in billList)
            {
                JDModel_payRecord *pay = [[JDModel_payRecord alloc]init];
                int         actid = [[record objectForKey:@"actid"] intValue];
                switch(actid)
                {
                    case 3:
                        pay.type = @"启用月卡";
                        break;
                    case 4:
                        pay.type = @"启用周卡";
                        break;
                    case 13:
                        pay.type = @"购买单曲";
                        pay.songName = [self searchSongNameWithMD5:[record objectForKey:@"param3"]];
                        //pay.songName = [self searchSongNameWithMD5:@"6B1DD9228116F12B65FBAC41F0168454"];
                        break;
                    default:
                        pay.type = @"未知操作";
                        break;
                }
                pay.time = [record objectForKey:@"acttime"];
                pay.success = [[record objectForKey:@"issuccess"] isEqualToString:@"1"] ? YES : NO;
                if([record objectForKey:@"kb"] != nil && [[record objectForKey:@"kb"] length] > 0)
                {
                    pay.price = [NSString stringWithFormat:@"%@ K币",[record objectForKey:@"kb"]];
                }
                [recordList addObject:pay];
                [pay release];
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
        {
            
            UIAlertView *alertDialog;
            alertDialog = [[UIAlertView alloc] initWithTitle:@"提示"
                                                     message:msg
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
            [alertDialog show];
        }
    }
    [_exchangeTable reloadData];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTI_GET_EXCHANGE_LIST_RESULT
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
    _exchangeTable = table;
    [table release];
    
    _labelNoRecord = [[UILabel alloc] initWithFrame:CGRectMake(50,150,600,50)];
    [_labelNoRecord setTextAlignment:NSTextAlignmentCenter];
    [_labelNoRecord setTextColor:[UIColor whiteColor]];
    [_labelNoRecord setBackgroundColor:[UIColor clearColor]];
    [_labelNoRecord setFont:[UIFont systemFontOfSize:28.0f]];
    [_labelNoRecord setText:@"您没有消费记录"];
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
    static NSString *CellIdentifier = @"PayCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createRecordCell:cell];
    }
    
    JDModel_payRecord *record = [recordList objectAtIndex:indexPath.row];
    UILabel *labelType = (UILabel*)[cell viewWithTag:TAG_OF_PAY_TYPE];
    UILabel *labelSongName = (UILabel*)[cell viewWithTag:TAG_OF_SONG_NAME];
    UILabel *labelPrice = (UILabel*)[cell viewWithTag:TAG_OF_PRICE];
    UILabel *labelTime = (UILabel*)[cell viewWithTag:TAG_OF_TIME];
    UILabel *labelSuccess = (UILabel*)[cell viewWithTag:TAG_OF_SUCCESS];
    
    [labelType setText:[record type]];
    [labelSongName setText:[record songName]];
    [labelPrice setText:[record price]];
    [labelTime setText:[record time]];
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
//创建消费记录的表格cell
- (void)createRecordCell:(UITableViewCell *)cell
{
    UIImageView *imageView_back = [[UIImageView alloc] initWithFrame:CGRectMake(35, 0, 660, 90)];
    //[imageView_back setContentMode:UIViewContentModeScaleAspectFit];
    [imageView_back setImage:[UIImage imageNamed:@"rule.png"]];
    [cell addSubview:imageView_back];
    [imageView_back release];
    
    UILabel *label_Type = [[UILabel alloc] initWithFrame:CGRectMake(50, 27, 150, 30)];
    [label_Type setTextAlignment:NSTextAlignmentLeft];
    [label_Type setTextColor:[UIColor whiteColor]];
    [label_Type setBackgroundColor:[UIColor clearColor]];
    [label_Type setShadowColor:[UIColor darkGrayColor]];
    [label_Type setShadowOffset:CGSizeMake(2, 2)];
    [label_Type setFont:[UIFont systemFontOfSize:24.0f]];
    [label_Type setTag:TAG_OF_PAY_TYPE];
    [cell addSubview:label_Type];
    [label_Type release];
    
    UILabel *label_songName = [[UILabel alloc] initWithFrame:CGRectMake(200, 27, 200, 30)];
    [label_songName setTextAlignment:NSTextAlignmentLeft];
    [label_songName setTextColor:[UIColor whiteColor]];
    [label_songName setBackgroundColor:[UIColor clearColor]];
    [label_songName setShadowColor:[UIColor darkGrayColor]];
    [label_songName setShadowOffset:CGSizeMake(2, 2)];
    [label_songName setFont:[UIFont systemFontOfSize:24.0f]];
    [label_songName setTag:TAG_OF_SONG_NAME];
    [cell addSubview:label_songName];
    [label_songName release];
    
    UILabel *label_Minus = [[UILabel alloc] initWithFrame:CGRectMake(400, 25, 20, 30)];
    [label_Minus setTextAlignment:NSTextAlignmentLeft];
    [label_Minus setTextColor:[UIColor redColor]];
    [label_Minus setBackgroundColor:[UIColor clearColor]];
    [label_Minus setShadowColor:[UIColor darkGrayColor]];
    [label_Minus setShadowOffset:CGSizeMake(2, 2)];
    [label_Minus setFont:[UIFont systemFontOfSize:28.0f]];
    [label_Minus setText:@"-"];
    [cell addSubview:label_Minus];
    [label_Minus release];
    
    UILabel *label_price = [[UILabel alloc] initWithFrame:CGRectMake(420, 27, 180, 30)];
    [label_price setTextAlignment:NSTextAlignmentLeft];
    [label_price setTextColor:[UIColor whiteColor]];
    [label_price setBackgroundColor:[UIColor clearColor]];
    [label_price setShadowColor:[UIColor darkGrayColor]];
    [label_price setShadowOffset:CGSizeMake(2, 2)];
    [label_price setFont:[UIFont systemFontOfSize:24.0f]];
    [label_price setTag:TAG_OF_PRICE];
    [cell addSubview:label_price];
    [label_price release];
    
    UILabel *label_Success = [[UILabel alloc] initWithFrame:CGRectMake(605, 25, 100, 15)];
    [label_Success setTextAlignment:NSTextAlignmentLeft];
    [label_Success setTextColor:[UIColor whiteColor]];
    [label_Success setBackgroundColor:[UIColor clearColor]];
    [label_Success setShadowColor:[UIColor darkGrayColor]];
    [label_Success setShadowOffset:CGSizeMake(2, 2)];
    [label_Success setFont:[UIFont systemFontOfSize:16.0f]];
    [label_Success setTag:TAG_OF_SUCCESS];
    [cell addSubview:label_Success];
    [label_Success release];
    
    UILabel *label_Time = [[UILabel alloc] initWithFrame:CGRectMake(520, 45, 250, 15)];
    [label_Time setTextAlignment:NSTextAlignmentLeft];
    [label_Time setTextColor:[UIColor whiteColor]];
    [label_Time setBackgroundColor:[UIColor clearColor]];
    [label_Time setShadowColor:[UIColor darkGrayColor]];
    [label_Time setShadowOffset:CGSizeMake(2, 2)];
    [label_Time setFont:[UIFont systemFontOfSize:16.0f]];
    [label_Time setTag:TAG_OF_TIME];
    [cell addSubview:label_Time];
    [label_Time release];
}

/**
 * 从歌曲表中执行SQL语句进行搜索
 */
- (NSMutableArray *)querySongWithSQL:(NSString *)string
{
    //JDSqlDataBase *dataController = [[JDSqlDataBase alloc] init];
    NSMutableArray *songArray = [database reciveDataBaseWithString:string];
    //[dataController release];
    return songArray;
}

/**
 * 搜曲名
 */
- (NSString*)searchSongNameWithMD5:(NSString*)md5
{
    NSString *songName = nil;
    NSString *sql = [NSString stringWithFormat:
                     @"select * from client_songs where md5='%@' and media_type is not null", md5];
    
    //NSLog(@"sql:%@", sql);
    NSMutableArray *resultArray = [self querySongWithSQL:sql];
    if([resultArray count] > 0)
    {
        songName = [[resultArray objectAtIndex:0] songTitle];
    }
    return songName;
}



@end
