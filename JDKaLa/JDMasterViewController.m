//
//  JDMasterViewController.m
//  JDKaLa
//
//  Created by zhangminglei on 3/27/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDMasterViewController.h"
#import "JDMainViewController.h"
#import "JDSingerKindViewController.h"
#import "SKRevealSideViewController.h"
#import "JDSqlDataBase.h"
#import "SDSingers.h"
#import "JDMenuView.h"
#import "JDSingerSongViewController.h"
#import "UIUtils.h"
#import "JDUserLoginView.h"
#import "JDUserRegistrationView.h"
#import "ClientAgent.h"
#import "CustomAlertView.h"
#import "JDModel_userInfo.h"
#import "JDHotOrNewSongViewController.h"
#import "UIImageView+WebCache.h"
#import "SIAlertView.h"
#import "JDCustomLabel.h"
#import "JDUserInfoChangeView.h"
#import "UIDevice+IdentifierAddition.h"
#import "MediaProxy.h"
#import "JDAlreadySongView.h"


typedef enum
{
    JDUserButtonTag_Login        = 0,
    JDUserButtonTag_registration    ,
} JDUserButtonTag;

typedef enum
{
    JDSingerKindTag_hot_china               = 0,
    JDSingerKindTag_hot_japanesekorean         ,
    JDSingerKindTag_hot_europeamerica          ,
    JDSingerKindTag_inlandBoy                  ,
    JDSingerKindTag_inlandGirl                 ,
    JDSingerKindTag_inlandCombined             ,
    JDSingerKindTag_HKBoy                      ,
    JDSingerKindTag_HKGirl                     ,
    JDSingerKindTag_HKCombined                 ,
    JDSingerKindTag_japanesekoreanBoy          ,
    JDSingerKindTag_japanesekoreanGirl         ,
    JDSingerKindTag_japanesekoreanCombined     ,
    JDSingerKindTag_europeamericaBoy           ,
    JDSingerKindTag_europeamericaGirl          ,
    JDSingerKindTag_europeamericaCombined      ,
    JDSingerKindTag_other                      ,
}JDSingerKindTag;


@interface JDMasterViewController ()

@end

@implementation JDMasterViewController

- (id)init
{
    self = [super init];
    if(self)
    {
        [self.view setBackgroundColor:[UIColor blackColor]];
        //[self configureView_table];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRegister1s:)
                                                     name:@"JDUserLoginView_1s"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleLoginResult:)
                                                     name:NOTI_LOGIN_RESULT
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleInviteResult:)
                                                     name:NOTI_APPLY_INVITE_CODE_RESULT
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleRegisterResult:)
                                                     name:NOTI_REGISTER_RESULT
                                                   object:nil];
        
        [self performSelector:@selector(configureView_table) withObject:nil afterDelay:0.5f];
        clientAgent_resgist = [[ClientAgent alloc] init];
        mediaProxy = nil;
        curPrereadVideoUrl = nil;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
        // Custom initialization
    }
    return self;
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:NOTI_REGISTER_RESULT
                                                 object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTI_LOGIN_RESULT
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTI_APPLY_INVITE_CODE_RESULT
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"JDUserLoginView_1s"
                                                  object:nil];
    
    //[_mainViewController_main release], _mainViewController_main = nil;
    [_selectIndex release], _selectIndex = nil;
    [_table_master release], _table_master = nil;
    [_array_childList release], _array_childList = nil;
    [clientAgent_resgist release], clientAgent_resgist = nil;
    //[_imageIndex release], _imageIndex = nil; 
    [_imageView_bar_one release], _imageView_bar_one = nil;
    [_imageView_bar_two release], _imageView_bar_two = nil;
    [_imageView_bar_three release], _imageView_bar_three = nil;
    [_imageView_bar_four release], _imageView_bar_four = nil;
    [super dealloc];
}

- (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity
{
    float red = ((float)((hexColor & 0xFF0000) >> 16))/255.0;
    float green = ((float)((hexColor & 0xFF00) >> 8))/255.0;
    float blue = ((float)(hexColor & 0xFF))/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:opacity];
}

static JDMasterViewController *masterViewController = nil;

+ (JDMasterViewController *)sharedController
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
            return masterViewController;
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

#pragma mark - ConfigureView
/**
 检测token有效性
 **/
- (void)checkTokenValue
{    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleGetUserDetail:)
                                                 name:NOTI_GET_USER_DETAIL_RESULT
                                               object:nil];
    
    [clientAgent_resgist getUserDetail:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
}


- (void)configureView_title
{
    if(_view_user)
    {
        [_view_user removeFromSuperview];
        _view_user = nil;
    }
    
    NSString *string_tourist = [[NSUserDefaults standardUserDefaults] objectForKey:@"tourist"];
    if([string_tourist isEqualToString:@"NO"] || ![[NSUserDefaults standardUserDefaults] objectForKey:@"token"])
    {
        UIView *view_tmp = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, 300, 50)];
        IOS7(view_tmp);
        [view_tmp setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:view_tmp];
        [view_tmp release];
        
        UIImageView *imageView_title = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 310, 50)];
        [UIUtils didLoadImageNotCached:@"menu_title_bg.png" inImageView:imageView_title];
        [view_tmp addSubview:imageView_title];
        [imageView_title release];
        
        UIImageView *imageView_user = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 41, 38)];
        [imageView_user.layer setCornerRadius:0];
        [imageView_user.layer setBorderWidth:0.5];
        [imageView_user.layer setMasksToBounds:NO];
        [imageView_user.layer setShadowOffset:CGSizeMake(0, 0)];
        [imageView_user.layer setShadowRadius:8];
        [imageView_user.layer setShadowOpacity:1];
        [imageView_user.layer setShadowColor:[UIColor whiteColor].CGColor];
        [imageView_user.layer setBorderColor:RGB(235, 235, 235).CGColor];
        [imageView_user setImageWithURL:[NSURL URLWithString:[JDModel_userInfo sharedModel].string_portrait ] placeholderImage:[UIUtils didLoadImageNotCached:@"login_icon.png"]];
        imageView_user.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onUserImageClicked)];
        [imageView_user addGestureRecognizer:singleTap];
        [singleTap release];
        
        [view_tmp addSubview:imageView_user];
        [imageView_user release];
        _imageView_portrait = imageView_user;
        
        JDCustomLabel *label_name = [[JDCustomLabel alloc] initWithFrame:CGRectMake(75, 12, 200, 50)];
        [label_name setBackgroundColor:[UIColor clearColor]];
        [label_name setTextColor:[UIColor grayColor]];
        [label_name setTextAlignment:NSTextAlignmentCenter];
        [label_name setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:22]];
        [label_name setText:[JDModel_userInfo sharedModel].string_nickName];
        [label_name setTag:100];
        [view_tmp addSubview:label_name];
        [label_name release];
        [label_name startAnimating];
        
        _view_user = view_tmp;
    }
    else if([string_tourist isEqualToString:@"YES"])
    {
        UIView *view_tmp = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, 300, 50)];
        IOS7(view_tmp);
        [view_tmp setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:view_tmp];
        [view_tmp release];
        
        UIImageView *imageView_title = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 310, 50)];
        [UIUtils didLoadImageNotCached:@"menu_title_bg.png" inImageView:imageView_title];
        [view_tmp addSubview:imageView_title];
        [imageView_title release];
        
        UIImageView *imageView_user = [[UIImageView alloc] initWithFrame:CGRectMake(75, 7, 41, 38)];
        [UIUtils didLoadImageNotCached:@"login_icon.png" inImageView:imageView_user];
        [view_tmp addSubview:imageView_user];
        [imageView_user release];
        
        UIButton *button_login = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_login setFrame:CGRectMake(120, 8, 86, 34)];
        [UIUtils didLoadImageNotCached:@"goinInfo.png" inButton:button_login withState:UIControlStateNormal];
        [button_login setTag:JDUserButtonTag_Login];
        [button_login addTarget:self action:@selector(didClickButton_user:) forControlEvents:UIControlEventTouchUpInside];
        [view_tmp addSubview:button_login];
        
        /*UIButton *button_registration = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_registration setFrame:CGRectMake(175, 6, 80, 35)];
        [UIUtils didLoadImageNotCached:@"btn_registration_small.png" inButton:button_registration withState:UIControlStateNormal];
        [button_registration setTag:JDUserButtonTag_registration];
        [button_registration addTarget:self action:@selector(didClickButton_user:) forControlEvents:UIControlEventTouchUpInside];
        [view_tmp addSubview:button_registration];*/
        
        _view_user = view_tmp;
    }
}

- (void)configureView_table
{
    [self configureData_table];
    _bool_firstConfigure = YES;
    _table_master = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, 300, 698) style:UITableViewStylePlain];
    IOS7(_table_master);
    _table_master.dataSource = self;
    _table_master.delegate = self;
    //[_table_master setSeparatorColor:[self colorWithHex:0xCBCBCB alpha:1.0]];
    [_table_master setBackgroundColor:[self colorWithHex:0xCBCBCB alpha:1.0]];
    //[self.table_master setOpaque:NO];
    [self.view addSubview:_table_master];
    //[_table_master scrollsToTop];
    [_table_master release];
}

- (void)configureData_table
{
    JDSqlDataBase *dataBase = [[JDSqlDataBase alloc] init];
    NSMutableArray *array_beyonce = [dataBase reciveDataBaseWithStringFromSinger:@"select *from client_singers WHERE name = 'Beyonce'"];
    if([array_beyonce count] == 0)
    {
        self.array_childList = [NSMutableArray arrayWithObjects:@"热门华语歌手",@"内地男歌手",@"内地女歌手",@"内地组合",@"港台男歌手",@"港台女歌手",@"港台组合",nil];
    }
    else
    {
        self.array_childList = [NSMutableArray arrayWithObjects:@"热门华语歌手",@"热门日韩歌手",@"热门欧美歌手",@"内地男歌手",@"内地女歌手",@"内地组合",@"港台男歌手",@"港台女歌手",@"港台组合",@"日韩男歌手",@"日韩女歌手",@"日韩组合",@"欧美男歌手",@"欧美女歌手",@"欧美组合",@"其他",nil];
    }
}

#pragma mark - 刷新头像 -
/**
 刷新头像
 **/
- (void)reloadImageViewPortrait
{
    if(_imageView_portrait)
    {
        [_imageView_portrait setImageWithURL:[[NSUserDefaults standardUserDefaults] objectForKey:@"portrait"] placeholderImage:[UIUtils didLoadImageNotCached:@"login_icon.png"]];
    }
}

#pragma mark - 刷新昵称 -
/**
 刷新头像
 **/
- (void)reloadTextNickName
{
    JDCustomLabel *label_nickName = (JDCustomLabel *)[_view_user viewWithTag:100];
    if(label_nickName)
    {
        [label_nickName setText:[JDModel_userInfo sharedModel].string_nickName];
    }
}


#pragma mark - 刷新按钮 -
- (void)reloadViewWhenNext
{
    [UIUtils didLoadImageNotCached:@"menu_bar_one_pressed.png" inImageView:_imageView_bar_one];
    [UIUtils didLoadImageNotCached:@"menu_bar_two.png" inImageView:_imageView_bar_two];
    [UIUtils didLoadImageNotCached:@"menu_bar_three.png" inImageView:_imageView_bar_three];
    [UIUtils didLoadImageNotCached:@"menu_bar_four_up.png" inImageView:_imageView_bar_four];
    
    self.imageIndex = 0;
}


#pragma mark - 点击注册登录按钮回调 -
/**
 点击注册登录按钮回调
 **/
- (void)didClickButton_user:(id)sender
{
    UIButton *button_tag = (UIButton *)sender;
    switch (button_tag.tag)
    {
        case JDUserButtonTag_Login:
        {
            JDUserLoginView *view_login = [[JDUserLoginView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
            [self.revealSideViewController.view addSubview:view_login];
            [view_login setClientAgent_resgist:clientAgent_resgist];
            [view_login showAnimated];
            [view_login release];
            
            _userLogin = view_login;
            
        }break;
        case JDUserButtonTag_registration:
        {
            JDUserRegistrationView *view_registration = [[JDUserRegistrationView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
            [self.revealSideViewController.view addSubview:view_registration];
            [view_registration setClientAgent_resgist:clientAgent_resgist];
            [view_registration showAnimated];
            [view_registration release];
            
        }break;
        default:
            break;
    }
}

#pragma mark - 注册成功消息回调 -
/**
 注册成功消息回调
 **/
- (void)handleRegisterResult:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    CustomAlertView *alertDialog;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    if(0 == resultCode)
    {
        
        alertDialog = [[CustomAlertView alloc] initWithTitle:@"注册成功"
                                                     message:@"新用户已经注册完成"
                                                    delegate:self
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        
        
        [[NSUserDefaults standardUserDefaults] setObject:[JDModel_userInfo sharedModel].string_userName forKey:@"userName"];
        [[NSUserDefaults standardUserDefaults] setObject:[JDModel_userInfo sharedModel].string_userPass forKey:@"passWord"];
        [[NSUserDefaults standardUserDefaults] setObject:[JDModel_userInfo sharedModel].string_device forKey:@"device"];
        [[NSUserDefaults standardUserDefaults] setObject:[JDModel_userInfo sharedModel].string_version forKey:@"version"];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"tourist"];
        
        [clientAgent_resgist login:[JDModel_userInfo sharedModel].string_userName Password:[JDModel_userInfo sharedModel].string_userPass Version:[JDModel_userInfo sharedModel].string_version DevID:[JDModel_userInfo sharedModel].string_device];
       
    }
    else
    {
        alertDialog = [[CustomAlertView alloc] initWithTitle:@"注册失败"
                                                     message:[state objectForKey:@"msg"]
                                                    delegate:self
                                           cancelButtonTitle:@"确定"
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
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    if(0 == resultCode)
    {
        NSString *email = [[[state objectForKey:@"userinfo"]objectForKey:@"userBasic"]objectForKey:@"email"];
        if(email.length > 36)
        {
            [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"tourist"];
            return;
        }
        else
        {
            [[NSUserDefaults standardUserDefaults]setObject:@"NO" forKey:@"tourist"];
        }
        
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"tourist"] isEqualToString:@"YES"])
        {
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
            return;
        }

        
        
        
        if([JDModel_userInfo sharedModel].string_userName)
        {
            [[NSUserDefaults standardUserDefaults] setObject:[JDModel_userInfo sharedModel].string_userName forKey:@"userName"];
        }
        
        if([JDModel_userInfo sharedModel].string_userPass)
        {
            [[NSUserDefaults standardUserDefaults] setObject:[JDModel_userInfo sharedModel].string_userPass forKey:@"passWord"];
        }
        
        if([JDModel_userInfo sharedModel].string_version)
        {
            [[NSUserDefaults standardUserDefaults] setObject:[JDModel_userInfo sharedModel].string_version forKey:@"version"];
        }
        
        if([JDModel_userInfo sharedModel].string_device)
        {
            [[NSUserDefaults standardUserDefaults] setObject:[JDModel_userInfo sharedModel].string_device forKey:@"device"];
        }
        
        if([state objectForKey:@"token"])
        {
            [JDModel_userInfo sharedModel].string_token = [state objectForKey:@"token"];
            [[NSUserDefaults standardUserDefaults] setObject:[JDModel_userInfo sharedModel].string_token forKey:@"token"];
        }
        
        if([[[state objectForKey:@"userinfo"]objectForKey:@"userDetail"]objectForKey:@"headpic"])
        {
            [JDModel_userInfo sharedModel].string_portrait = [[[state objectForKey:@"userinfo"]objectForKey:@"userDetail"]objectForKey:@"headpic"];
            [[NSUserDefaults standardUserDefaults] setObject:[JDModel_userInfo sharedModel].string_portrait forKey:@"portrait"];
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
        
        if([[[state objectForKey:@"userinfo"]objectForKey:@"userDetail"]objectForKey:@"nickname"])
        {
            [JDModel_userInfo sharedModel].string_nickName = [[[state objectForKey:@"userinfo"]objectForKey:@"userDetail"] objectForKey:@"nickname"];
            [[NSUserDefaults standardUserDefaults] setObject:[JDModel_userInfo sharedModel].string_nickName forKey:@"nickName"];
        }
        
        if([[[state objectForKey:@"userinfo"]objectForKey:@"userDetail"]objectForKey:@"resume"])
        {
            [JDModel_userInfo sharedModel].string_signature = [[[state objectForKey:@"userinfo"]objectForKey:@"userDetail"]objectForKey:@"resume"];
            [[NSUserDefaults standardUserDefaults] setObject:[JDModel_userInfo sharedModel].string_signature forKey:@"signature"];
        }
        
        if([[[[state objectForKey:@"userinfo"]
              objectForKey:@"userDetail"]
             objectForKey:@"sex"]integerValue])
        {
            [JDModel_userInfo sharedModel].integer_sex = [[[[state objectForKey:@"userinfo"]
                                                        objectForKey:@"userDetail"]
                                                       objectForKey:@"sex"]integerValue];
        //[[NSUserDefaults standardUserDefaults] setInteger:[JDModel_userInfo sharedModel].integer_sex forKey:@"sex"];
        }
        
        if(_userLogin)
        {
            [_userLogin dismissAnimated];
            _userLogin = nil;
        }
        
        CustomAlertView *alertDialog = [[CustomAlertView alloc] initWithTitle:@"欢迎进入K吧"
                                                                      message:@""
                                                                     delegate:self
                                                            cancelButtonTitle:@"确定"
                                                            otherButtonTitles:nil];
        [alertDialog show];
        [alertDialog release];
        
        JDCustomLabel *label_nickName = (JDCustomLabel *)[_view_user viewWithTag:100];
        [label_nickName stopAnimating];
        [_view_user removeFromSuperview];
        _view_user = nil;
        
        UIView *view_tmp = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, 300, 50)];
        IOS7(view_tmp);
        [view_tmp setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:view_tmp];
        [view_tmp release];
        
        UIImageView *imageView_title = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 310, 50)];
        [UIUtils didLoadImageNotCached:@"menu_title_bg.png" inImageView:imageView_title];
        [view_tmp addSubview:imageView_title];
        [imageView_title release];
        
        UIImageView *imageView_user = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 41, 38)];
        [imageView_user.layer setCornerRadius:0];
        [imageView_user.layer setBorderWidth:0.5];
        [imageView_user.layer setMasksToBounds:NO];
        [imageView_user.layer setShadowOffset:CGSizeMake(0, 0)];
        [imageView_user.layer setShadowRadius:8];
        [imageView_user.layer setShadowOpacity:1];
        [imageView_user.layer setShadowColor:[UIColor whiteColor].CGColor];
        [imageView_user.layer setBorderColor:RGB(235, 235, 235).CGColor];
        [imageView_user setImageWithURL:[NSURL URLWithString:[JDModel_userInfo sharedModel].string_portrait ] placeholderImage:[UIUtils didLoadImageNotCached:@"login_icon.png"]];
        imageView_user.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onUserImageClicked)];
        [imageView_user addGestureRecognizer:singleTap];
        [singleTap release];

        [view_tmp addSubview:imageView_user];
        [imageView_user release];
        _imageView_portrait = imageView_user;
        
        JDCustomLabel *label_name = [[JDCustomLabel alloc] initWithFrame:CGRectMake(75, 12, 200, 50)];
        [label_name setBackgroundColor:[UIColor clearColor]];
        [label_name setTextColor:[UIColor grayColor]];
        [label_name setTextAlignment:NSTextAlignmentCenter];
        [label_name setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:22]];
        [label_name setText:[JDModel_userInfo sharedModel].string_nickName];
        [label_name setTag:100];
        [view_tmp addSubview:label_name];
        [label_name release];
        [label_name startAnimating];
        
        _view_user = view_tmp;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadCount" object:nil];
        
        /*[clientAgent_resgist getUserDetail:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];*/
        
    }
    else
    {
        CustomAlertView *alertDialog = [[CustomAlertView alloc] initWithTitle:[state objectForKey:@"msg"]
                                                                      message:@""
                                                                     delegate:self
                                                            cancelButtonTitle:@"确定"
                                                            otherButtonTitles:nil];
        //[alertDialog setTag:55];
        [alertDialog show];
        [alertDialog release];
    
    }
}

#pragma mark - 一秒注册按钮回调 -
/**
 一秒注册按钮回调
 **/
- (void)handleRegister1s:(NSNotification *)note
{
    JDUserRegistrationView *view_registration = [[JDUserRegistrationView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [self.revealSideViewController.view addSubview:view_registration];
    [view_registration setClientAgent_resgist:clientAgent_resgist];
    [view_registration showAnimated];
    [view_registration release];
}

#pragma mark - 登陆后获取用户详细信息回调 -
/**
 登陆后获取用户详细信息回调
 **/
- (void)handleGetUserDetail:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    if([[state objectForKey:@"result"] length] > 0 && 0 == resultCode)
    {
       
    }
    else
    {
        CustomAlertView *alertDialog = [[CustomAlertView alloc]initWithTitle:@"请重新登录"
                                                                     message:@""
                                                                    delegate:nil
                                                           cancelButtonTitle:@"确定"
                                                           otherButtonTitles:nil];
        
        [alertDialog show];
        [alertDialog release];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"tourist"];
        NSString *string_email = [NSString stringWithFormat:@"%@@kod.com",[[UIDevice currentDevice]uniqueGlobalDeviceIdentifier]];
        NSString *string_passWord = [[UIDevice currentDevice]uniqueGlobalDeviceIdentifier];
        ClientAgent *agent = [[ClientAgent alloc] init];
        [agent login:string_email Password:string_passWord Version:@"iPad-1.0" DevID:[[UIDevice currentDevice]uniqueGlobalDeviceIdentifier]];
        
        /*if([[NSUserDefaults standardUserDefaults]objectForKey:@"token"])
        {
        
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
            if([[NSUserDefaults standardUserDefaults] objectForKey:@"token"])
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"token"];
            }
            
            CustomAlertView *alertDialog = [[CustomAlertView alloc]initWithTitle:@"请重新登录"
                                                                         message:@""
                                                                        delegate:nil
                                                               cancelButtonTitle:@"确定"
                                                               otherButtonTitles:nil];

            [alertDialog show];
            [alertDialog release];
        }*/
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTI_GET_USER_DETAIL_RESULT
                                                  object:nil];
   
    [self configureView_title];
    [self startPreread];
}

#pragma mark - 申请邀请码回调 -
/**
 申请邀请码回调
 **/
- (void)handleInviteResult:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    CustomAlertView *alertDialog;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    if(0 == resultCode)
    {
        
        alertDialog = [[CustomAlertView alloc] initWithTitle:@"获取成功"
                                                     message:@"邀请码已发送至您的邮箱"
                                                    delegate:self
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        
    }
    else
    {
       alertDialog = [[CustomAlertView alloc] initWithTitle:[state objectForKey:@"msg"]
                                                                      message:@""
                                                                     delegate:self
                                                            cancelButtonTitle:@"确定"
                                                            otherButtonTitles:nil];
        
    }
    [alertDialog show];
    [alertDialog release];
    
}

#pragma mark - 初始化TableView -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.bool_isOpen)
    {
        if (self.selectIndex.section == section)
        {
            return [_array_childList count] + 1;
        }
    }
    return 1;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 3 && indexPath.row == 0)
    {
        self.selectIndex = indexPath;
    }
    return 75;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*if(indexPath.section == 3 && indexPath.row == 0 &&_bool_firstConfigure)
     {
     _bool_firstConfigure = NO;
     [self didSelectCellRowFirstDo:YES nextDo:NO];
     }*/
    if (self.bool_isOpen &&  indexPath.section == 3 && indexPath.row!=0)
    {
        static NSString *CellIdentifier = @"ChildCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell = [[[UITableViewCell alloc] init] autorelease];
            
            UILabel *label_title = [[UILabel alloc] initWithFrame:CGRectMake(95, 12, 180, 50)];
            [label_title setFont:[UIFont systemFontOfSize:20.0f]];
            [label_title setTextColor:[UIColor whiteColor]];
            [label_title setTag:90];
            [label_title setShadowColor:[UIColor grayColor]];
            [label_title setShadowOffset:CGSizeMake(2, 2)];
            [label_title setBackgroundColor:[UIColor clearColor]];
            [cell addSubview:label_title];
            [label_title release];

            [cell setBackgroundColor:[UIColor clearColor]];
        }
        
        UILabel *label_tmp = (UILabel *)[cell viewWithTag:90];
        label_tmp.text = [_array_childList objectAtIndex:indexPath.row - 1];
        
        UIButton *button_tmp = (UIButton *)[cell viewWithTag:205];
        button_tmp.tag = indexPath.row + indexPath.section;
        
        
        UIImageView *imageView_tmp = (UIImageView *)[cell viewWithTag:60];
        if(indexPath.row == 1)
        {
            [UIUtils didLoadImageNotCached:@"sub_menu_bar_bg1.png" inImageView:imageView_tmp];
        }
        else
        {
            [UIUtils didLoadImageNotCached:@"sub_menu_bar_bg.png" inImageView:imageView_tmp];
        }
        
        if(indexPath.section == 3)
        {
            [label_tmp setTextColor:[UIColor whiteColor]];
        }
        
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"MainCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] init] autorelease];
            //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            UIImageView *imageView_background = [[UIImageView alloc] initWithFrame:CGRectMake(50, 0, 300, 75)];
            [imageView_background setTag:91];
            [cell setBackgroundView:imageView_background];
            [imageView_background release];
            
            UIButton *button_back = [UIButton buttonWithType:UIButtonTypeCustom];
            [button_back setBackgroundColor:[UIColor clearColor]];
            //[button_back setShowsTouchWhenHighlighted:YES];
            [button_back setTag:200];
            [button_back setFrame:CGRectMake(0, 0, 300, 75)];
            [button_back addTarget:self action:@selector(didclickButton_tableSelect:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button_back];
            
            [cell setBackgroundColor:[UIColor clearColor]];
        }
        
        UIButton *button_tmp = (UIButton *)[cell viewWithTag:200];
        button_tmp.tag = indexPath.row + indexPath.section;
        
        UIImageView *imageView_tmp = (UIImageView *)[cell viewWithTag:91];
        switch (indexPath.section)
        {
            case 0:
            {
                [UIUtils didLoadImageNotCached:@"menu_bar_one_pressed.png" inImageView:imageView_tmp];
                self.imageView_bar_one = imageView_tmp;
            }break;
            case 1:
            {
                [UIUtils didLoadImageNotCached:@"menu_bar_two.png" inImageView:imageView_tmp];
                self.imageView_bar_two = imageView_tmp;
            }break;
            case 2:
            {
                [UIUtils didLoadImageNotCached:@"menu_bar_three.png" inImageView:imageView_tmp];
                self.imageView_bar_three = imageView_tmp;
            }break;
            case 3:
            {
                [UIUtils didLoadImageNotCached:@"menu_bar_four_up.png" inImageView:imageView_tmp];
                self.imageView_bar_four = imageView_tmp;
            }break;
            default:
                break;
        }
        switch (_imageIndex)
        {
            case 0:
            {
                [UIUtils didLoadImageNotCached:@"menu_bar_one_pressed.png" inImageView:_imageView_bar_one];
                [UIUtils didLoadImageNotCached:@"menu_bar_two.png" inImageView:_imageView_bar_two];
                [UIUtils didLoadImageNotCached:@"menu_bar_three.png" inImageView:_imageView_bar_three];
                [UIUtils didLoadImageNotCached:@"menu_bar_four_up.png" inImageView:_imageView_bar_four];
                
            }break;
            case 1:
            {
                [UIUtils didLoadImageNotCached:@"menu_bar_one.png" inImageView:_imageView_bar_one];
                [UIUtils didLoadImageNotCached:@"menu_bar_two_pressed.png" inImageView:_imageView_bar_two];
                [UIUtils didLoadImageNotCached:@"menu_bar_three.png" inImageView:_imageView_bar_three];
                [UIUtils didLoadImageNotCached:@"menu_bar_four_up.png" inImageView:_imageView_bar_four];
            }break;
            case 2:
            {
                [UIUtils didLoadImageNotCached:@"menu_bar_one.png" inImageView:_imageView_bar_one];
                [UIUtils didLoadImageNotCached:@"menu_bar_two.png" inImageView:_imageView_bar_two];
                [UIUtils didLoadImageNotCached:@"menu_bar_three_pressed.png" inImageView:_imageView_bar_three];
                [UIUtils didLoadImageNotCached:@"menu_bar_four_up.png" inImageView:_imageView_bar_four];
            }break;
            case 3:
            {
                [UIUtils didLoadImageNotCached:@"menu_bar_one.png" inImageView:_imageView_bar_one];
                [UIUtils didLoadImageNotCached:@"menu_bar_two.png" inImageView:_imageView_bar_two];
                [UIUtils didLoadImageNotCached:@"menu_bar_three.png" inImageView:_imageView_bar_three];
                [UIUtils didLoadImageNotCached:@"menu_bar_four_up_pressed.png" inImageView:_imageView_bar_four];
            }break;
            default:
                break;
        }
        if(indexPath.section == 3 && indexPath.row == 0 &&_bool_firstConfigure)
        {
            _bool_firstConfigure = NO;
            [self performSelector:@selector(didExtensionCell) withObject:nil afterDelay:0.5f];
            //[self performSelectorOnMainThread:@selector(didExtensionCell) withObject:nil waitUntilDone:YES];
            //[self didExtensionCell];
            //[self performSelectorInBackground:@selector(didExtensionCell) withObject:nil];
            
        }
        return cell;
    }
}

- (void)didclickButton_tableSelect:(id)sender
{
    UIButton *button_tag = (UIButton *)sender;
    if(button_tag.tag > 3)
    {
        [UIUtils didLoadImageNotCached:@"menu_bar_one.png" inImageView:_imageView_bar_one];
        [UIUtils didLoadImageNotCached:@"menu_bar_two.png" inImageView:_imageView_bar_two];
        [UIUtils didLoadImageNotCached:@"menu_bar_three.png" inImageView:_imageView_bar_three];
        [UIUtils didLoadImageNotCached:@"menu_bar_four_up_pressed.png" inImageView:_imageView_bar_four];
        self.imageIndex = 3;
    }
    switch (button_tag.tag)
    {
        case 0:
        {
            JDMainViewController *mainViewController = [[JDMainViewController alloc] init];
            mainViewController.navigationController_return = _navigationController_return;
            if(self.revealSideViewController.rootViewController)
            {
                [self.revealSideViewController.rootViewController release];
            }
            [self.revealSideViewController setRootViewController:mainViewController];
            [mainViewController release];
            JDMenuView *view_menu = [JDMenuView sharedView];
            if(view_menu.bool_extension)
            {
                [view_menu configureView_animetionInView_shrink];
            }
            else
            {
                [view_menu configureView_animetionButton_inViewChange];
            }
                
            [UIUtils didLoadImageNotCached:@"menu_bar_one_pressed.png" inImageView:_imageView_bar_one];
            [UIUtils didLoadImageNotCached:@"menu_bar_two.png" inImageView:_imageView_bar_two];
            [UIUtils didLoadImageNotCached:@"menu_bar_three.png" inImageView:_imageView_bar_three];
            [UIUtils didLoadImageNotCached:@"menu_bar_four_up.png" inImageView:_imageView_bar_four];
                
            self.imageIndex = 0;
                
        }break;
        case 1:
        {
            if(self.revealSideViewController.rootViewController)
            {
                [self.revealSideViewController.rootViewController release];
            }
            JDHotOrNewSongViewController *songController = [[JDHotOrNewSongViewController alloc] initWithTitleString:@"新歌速递"];
            songController.navigationController_return = _navigationController_return;
            songController.array_data = [self installDataArray_new_Content];
            [songController configureTable_data];
            [self.revealSideViewController setRootViewController:songController];
            [songController release];
            JDMenuView *view_menu = [JDMenuView sharedView];
            if(view_menu.bool_extension)
            {
                [view_menu configureView_animetionInView_shrink];
            }
            else
            {
                [view_menu configureView_animetionButton_inViewChange];
            }
                
            [UIUtils didLoadImageNotCached:@"menu_bar_one.png" inImageView:_imageView_bar_one];
            [UIUtils didLoadImageNotCached:@"menu_bar_two_pressed.png" inImageView:_imageView_bar_two];
            [UIUtils didLoadImageNotCached:@"menu_bar_three.png" inImageView:_imageView_bar_three];
            [UIUtils didLoadImageNotCached:@"menu_bar_four_up.png" inImageView:_imageView_bar_four];
            self.imageIndex = 1;
                
        }break;
        case 2:
        {
            JDHotOrNewSongViewController *songController = [[JDHotOrNewSongViewController alloc] initWithTitleString:@"最热歌曲"];
            songController.navigationController_return = _navigationController_return;
            songController.array_data = [self installDataArray_Content];
            [songController configureTable_data];
            if(self.revealSideViewController.rootViewController)
            {
                [self.revealSideViewController.rootViewController release];
            }
            [self.revealSideViewController setRootViewController:songController];
            [songController release];
            JDMenuView *view_menu = [JDMenuView sharedView];
            if(view_menu.bool_extension)
            {
                [view_menu configureView_animetionInView_shrink];
            }
            else
            {
                [view_menu configureView_animetionButton_inViewChange];
            }
                
            [UIUtils didLoadImageNotCached:@"menu_bar_one.png" inImageView:_imageView_bar_one];
            [UIUtils didLoadImageNotCached:@"menu_bar_two.png" inImageView:_imageView_bar_two];
            [UIUtils didLoadImageNotCached:@"menu_bar_three_pressed.png" inImageView:_imageView_bar_three];
            [UIUtils didLoadImageNotCached:@"menu_bar_four_up.png" inImageView:_imageView_bar_four];
            self.imageIndex = 2;
        }break;
        case 3:
        {
            if(_bool_isOpen)
            {
                [self didSelectCellRowFirstDo:NO nextDo:YES];
            }
            else
            {
                [self didSelectCellRowFirstDo:YES nextDo:NO];
            }

        }break;
            
        case 4:
        {
            NSMutableArray *array = [self installDataArrayWithTag:JDSingerKindTag_hot_china];
            JDSingerKindViewController *singerController = [[JDSingerKindViewController alloc] initWithString:@"热门华语歌手" andDataArray:array andTag:JDTableViewTag_chineseAll];
            singerController.navigationController_return = _navigationController_return;
            if(self.revealSideViewController.rootViewController)
            {
                [self.revealSideViewController.rootViewController release];
            }
            [self.revealSideViewController setRootViewController:singerController];
            [singerController release];
            JDMenuView *view_menu = [JDMenuView sharedView];
            if(view_menu.bool_extension)
            {
                [view_menu configureView_animetionInView_shrink];
            }
            else
            {
                [view_menu configureView_animetionButton_inViewChange];
            }
        }break;
            
        case 5:
        {
            if([_array_childList count] == 7)
            {
                NSMutableArray *array = [self installDataArrayWithTag:JDSingerKindTag_inlandBoy];
                JDSingerKindViewController *singerController = [[JDSingerKindViewController alloc] initWithString:@"内地男歌手" andDataArray:array andTag:JDTableViewTag_inlandBoy];
                singerController.navigationController_return = _navigationController_return;
                if(self.revealSideViewController.rootViewController)
                {
                    [self.revealSideViewController.rootViewController release];
                }
                [self.revealSideViewController setRootViewController:singerController];
                [singerController release];
                JDMenuView *view_menu = [JDMenuView sharedView];
                if(view_menu.bool_extension)
                {
                    [view_menu configureView_animetionInView_shrink];
                }
                else
                {
                    [view_menu configureView_animetionButton_inViewChange];
                }
            }
            else
            {
                NSMutableArray *array = [self installDataArrayWithTag:JDSingerKindTag_hot_japanesekorean];
                JDSingerKindViewController *singerController = [[JDSingerKindViewController alloc] initWithString:@"热门日韩歌手" andDataArray:array andTag:JDTableViewTag_japanesekorean];
                singerController.navigationController_return = _navigationController_return;
                if(self.revealSideViewController.rootViewController)
                {
                    [self.revealSideViewController.rootViewController release];
                }
                [self.revealSideViewController setRootViewController:singerController];
                [singerController release];
                JDMenuView *view_menu = [JDMenuView sharedView];
                if(view_menu.bool_extension)
                {
                    [view_menu configureView_animetionInView_shrink];
                }
                else
                {
                    [view_menu configureView_animetionButton_inViewChange];
                }
            }
        }break;
        case 6:
        {
            if([_array_childList count] == 7)
            {
                NSMutableArray *array = [self installDataArrayWithTag:JDSingerKindTag_inlandGirl];
                JDSingerKindViewController *singerController = [[JDSingerKindViewController alloc] initWithString:@"内地女歌手" andDataArray:array andTag:JDTableViewTag_inlandGirl];
                singerController.navigationController_return = _navigationController_return;
                if(self.revealSideViewController.rootViewController)
                {
                    [self.revealSideViewController.rootViewController release];
                    
                }
                [self.revealSideViewController setRootViewController:singerController];
                [singerController release];
                JDMenuView *view_menu = [JDMenuView sharedView];
                if(view_menu.bool_extension)
                {
                    [view_menu configureView_animetionInView_shrink];
                }
                else
                {
                    [view_menu configureView_animetionButton_inViewChange];
                }
            }
            else
            {
                NSMutableArray *array = [self installDataArrayWithTag:JDSingerKindTag_hot_europeamerica];
                JDSingerKindViewController *singerController = [[JDSingerKindViewController alloc] initWithString:@"热门欧美歌手" andDataArray:array andTag:JDTableViewTag_europeamerica];
                singerController.navigationController_return = _navigationController_return;
                if(self.revealSideViewController.rootViewController)
                {
                    [self.revealSideViewController.rootViewController release];
                }
                [self.revealSideViewController setRootViewController:singerController];
                [singerController release];
                JDMenuView *view_menu = [JDMenuView sharedView];
                if(view_menu.bool_extension)
                {
                    [view_menu configureView_animetionInView_shrink];
                }
                else
                {
                    [view_menu configureView_animetionButton_inViewChange];
                }
            }
        }break;
            
        case 7:
        {
            if([_array_childList count] == 7)
            {
                NSMutableArray *array = [self installDataArrayWithTag:JDSingerKindTag_inlandCombined];
                JDSingerKindViewController *singerController = [[JDSingerKindViewController alloc] initWithString:@"内地组合" andDataArray:array andTag:JDTableViewTag_inlandCombind];
                singerController.navigationController_return = _navigationController_return;
                if(self.revealSideViewController.rootViewController)
                {
                    [self.revealSideViewController.rootViewController release];
                }
                [self.revealSideViewController setRootViewController:singerController];
                [singerController release];
                JDMenuView *view_menu = [JDMenuView sharedView];
                if(view_menu.bool_extension)
                {
                    [view_menu configureView_animetionInView_shrink];
                }
                else
                {
                    [view_menu configureView_animetionButton_inViewChange];
                }
            }
            else
            {
                NSMutableArray *array = [self installDataArrayWithTag:JDSingerKindTag_inlandBoy];
                JDSingerKindViewController *singerController = [[JDSingerKindViewController alloc] initWithString:@"内地男歌手" andDataArray:array andTag:JDTableViewTag_inlandBoy];
                singerController.navigationController_return = _navigationController_return;
                if(self.revealSideViewController.rootViewController)
                {
                    [self.revealSideViewController.rootViewController release];
                }
                [self.revealSideViewController setRootViewController:singerController];
                [singerController release];
                JDMenuView *view_menu = [JDMenuView sharedView];
                if(view_menu.bool_extension)
                {
                    [view_menu configureView_animetionInView_shrink];
                }
                else
                {
                    [view_menu configureView_animetionButton_inViewChange];
                }
            }
        }break;
        case 8:
        {
            if([_array_childList count] == 7)
            {
                NSMutableArray *array = [self installDataArrayWithTag:JDSingerKindTag_HKBoy];
                JDSingerKindViewController *singerController = [[JDSingerKindViewController alloc] initWithString:@"港台男歌手" andDataArray:array andTag:JDTableViewTag_inlandCombind];
                singerController.navigationController_return = _navigationController_return;
                if(self.revealSideViewController.rootViewController)
                {
                    [self.revealSideViewController.rootViewController release];
                }
                [self.revealSideViewController setRootViewController:singerController];
                [singerController release];
                JDMenuView *view_menu = [JDMenuView sharedView];
                if(view_menu.bool_extension)
                {
                    [view_menu configureView_animetionInView_shrink];
                }
                else
                {
                    [view_menu configureView_animetionButton_inViewChange];
                }
            }
            else
            {
                NSMutableArray *array = [self installDataArrayWithTag:JDSingerKindTag_inlandGirl];
                JDSingerKindViewController *singerController = [[JDSingerKindViewController alloc] initWithString:@"内地女歌手" andDataArray:array andTag:JDTableViewTag_inlandGirl];
                singerController.navigationController_return = _navigationController_return;
                if(self.revealSideViewController.rootViewController)
                {
                    [self.revealSideViewController.rootViewController release];
                    
                }
                [self.revealSideViewController setRootViewController:singerController];
                [singerController release];
                JDMenuView *view_menu = [JDMenuView sharedView];
                if(view_menu.bool_extension)
                {
                    [view_menu configureView_animetionInView_shrink];
                }
                else
                {
                    [view_menu configureView_animetionButton_inViewChange];
                }
            }
        }break;
        case 9:
        {
            if([_array_childList count] == 7)
            {
                NSMutableArray *array = [self installDataArrayWithTag:JDSingerKindTag_HKGirl];
                JDSingerKindViewController *singerController = [[JDSingerKindViewController alloc] initWithString:@"港台女歌手" andDataArray:array andTag:JDTableViewTag_inlandCombind];
                singerController.navigationController_return = _navigationController_return;
                if(self.revealSideViewController.rootViewController)
                {
                    [self.revealSideViewController.rootViewController release];
                    
                }
                [self.revealSideViewController setRootViewController:singerController];
                [singerController release];
                JDMenuView *view_menu = [JDMenuView sharedView];
                if(view_menu.bool_extension)
                {
                    [view_menu configureView_animetionInView_shrink];
                }
                else
                {
                    [view_menu configureView_animetionButton_inViewChange];
                }
            }
            else
            {
                NSMutableArray *array = [self installDataArrayWithTag:JDSingerKindTag_inlandCombined];
                JDSingerKindViewController *singerController = [[JDSingerKindViewController alloc] initWithString:@"内地组合" andDataArray:array andTag:JDTableViewTag_inlandCombind];
                singerController.navigationController_return = _navigationController_return;
                if(self.revealSideViewController.rootViewController)
                {
                    [self.revealSideViewController.rootViewController release];
                }
                [self.revealSideViewController setRootViewController:singerController];
                [singerController release];
                JDMenuView *view_menu = [JDMenuView sharedView];
                if(view_menu.bool_extension)
                {
                    [view_menu configureView_animetionInView_shrink];
                }
                else
                {
                    [view_menu configureView_animetionButton_inViewChange];
                }
            }
        }break;
        case 10:
        {
            if([_array_childList count] == 7)
            {
                NSMutableArray *array = [self installDataArrayWithTag:JDSingerKindTag_HKCombined];
                JDSingerKindViewController *singerController = [[JDSingerKindViewController alloc] initWithString:@"港台组合" andDataArray:array andTag:JDTableViewTag_inlandCombind];
                singerController.navigationController_return = _navigationController_return;
                if(self.revealSideViewController.rootViewController)
                {
                    [self.revealSideViewController.rootViewController release];
                }
                [self.revealSideViewController setRootViewController:singerController];
                [singerController release];
                JDMenuView *view_menu = [JDMenuView sharedView];
                if(view_menu.bool_extension)
                {
                    [view_menu configureView_animetionInView_shrink];
                }
                else
                {
                    [view_menu configureView_animetionButton_inViewChange];
                }
            }
            else
            {
                NSMutableArray *array = [self installDataArrayWithTag:JDSingerKindTag_HKBoy];
                JDSingerKindViewController *singerController = [[JDSingerKindViewController alloc] initWithString:@"港台男歌手" andDataArray:array andTag:JDTableViewTag_inlandCombind];
                singerController.navigationController_return = _navigationController_return;
                if(self.revealSideViewController.rootViewController)
                {
                    [self.revealSideViewController.rootViewController release];
                }
                [self.revealSideViewController setRootViewController:singerController];
                [singerController release];
                JDMenuView *view_menu = [JDMenuView sharedView];
                if(view_menu.bool_extension)
                {
                    [view_menu configureView_animetionInView_shrink];
                }
                else
                {
                    [view_menu configureView_animetionButton_inViewChange];
                }
            }
        }break;
        case 11:
        {
            NSMutableArray *array = [self installDataArrayWithTag:JDSingerKindTag_HKGirl];
            JDSingerKindViewController *singerController = [[JDSingerKindViewController alloc] initWithString:@"港台女歌手" andDataArray:array andTag:JDTableViewTag_inlandCombind];
            singerController.navigationController_return = _navigationController_return;
            if(self.revealSideViewController.rootViewController)
            {
                [self.revealSideViewController.rootViewController release];
                    
            }
            [self.revealSideViewController setRootViewController:singerController];
            [singerController release];
            JDMenuView *view_menu = [JDMenuView sharedView];
            if(view_menu.bool_extension)
            {
                [view_menu configureView_animetionInView_shrink];
            }
            else
            {
                [view_menu configureView_animetionButton_inViewChange];
            }
        }break;
        case 12:
        {
            NSMutableArray *array = [self installDataArrayWithTag:JDSingerKindTag_HKCombined];
            JDSingerKindViewController *singerController = [[JDSingerKindViewController alloc] initWithString:@"港台组合" andDataArray:array andTag:JDTableViewTag_inlandCombind];
            singerController.navigationController_return = _navigationController_return;
            if(self.revealSideViewController.rootViewController)
            {
                [self.revealSideViewController.rootViewController release];
            }
            [self.revealSideViewController setRootViewController:singerController];
            [singerController release];
            JDMenuView *view_menu = [JDMenuView sharedView];
            if(view_menu.bool_extension)
            {
                [view_menu configureView_animetionInView_shrink];
            }
            else
            {
                [view_menu configureView_animetionButton_inViewChange];
            }
        }break;
        case 13:
        {
            NSMutableArray *array = [self installDataArrayWithTag:JDSingerKindTag_japanesekoreanBoy];
                JDSingerKindViewController *singerController = [[JDSingerKindViewController alloc] initWithString:@"日韩男歌手" andDataArray:array andTag:JDTableViewTag_inlandCombind];
            singerController.navigationController_return = _navigationController_return;
            if(self.revealSideViewController.rootViewController)
            {
                [self.revealSideViewController.rootViewController release];
                    
            }
            [self.revealSideViewController setRootViewController:singerController];
            [singerController release];
            JDMenuView *view_menu = [JDMenuView sharedView];
            if(view_menu.bool_extension)
            {
                [view_menu configureView_animetionInView_shrink];
            }
            else
            {
                [view_menu configureView_animetionButton_inViewChange];
            }
        }break;
        case 14:
        {
            NSMutableArray *array = [self installDataArrayWithTag:JDSingerKindTag_japanesekoreanGirl];
            JDSingerKindViewController *singerController = [[JDSingerKindViewController alloc] initWithString:@"日韩女歌手" andDataArray:array andTag:JDTableViewTag_inlandCombind];
            singerController.navigationController_return = _navigationController_return;
            if(self.revealSideViewController.rootViewController)
            {
                [self.revealSideViewController.rootViewController release];
            }
            [self.revealSideViewController setRootViewController:singerController];
            [singerController release];
            JDMenuView *view_menu = [JDMenuView sharedView];
            if(view_menu.bool_extension)
            {
                [view_menu configureView_animetionInView_shrink];
            }
            else
            {
                [view_menu configureView_animetionButton_inViewChange];
            }
        }break;
        case 15:
        {
            NSMutableArray *array = [self installDataArrayWithTag:JDSingerKindTag_japanesekoreanCombined];
            JDSingerKindViewController *singerController = [[JDSingerKindViewController alloc] initWithString:@"日韩组合" andDataArray:array andTag:JDTableViewTag_inlandCombind];
            singerController.navigationController_return = _navigationController_return;
            if(self.revealSideViewController.rootViewController)
            {
                [self.revealSideViewController.rootViewController release];
            }
            [self.revealSideViewController setRootViewController:singerController];
            [singerController release];
            JDMenuView *view_menu = [JDMenuView sharedView];
            if(view_menu.bool_extension)
            {
                [view_menu configureView_animetionInView_shrink];
            }
            else
            {
                [view_menu configureView_animetionButton_inViewChange];
            }
        }break;
        case 16:
        {
            NSMutableArray *array = [self installDataArrayWithTag:JDSingerKindTag_europeamericaBoy];
            JDSingerKindViewController *singerController = [[JDSingerKindViewController alloc] initWithString:@"欧美男歌手" andDataArray:array andTag:JDTableViewTag_inlandCombind];
            singerController.navigationController_return = _navigationController_return;
            if(self.revealSideViewController.rootViewController)
            {
                [self.revealSideViewController.rootViewController release];
            }
            [self.revealSideViewController setRootViewController:singerController];
            [singerController release];
            JDMenuView *view_menu = [JDMenuView sharedView];
            if(view_menu.bool_extension)
            {
                [view_menu configureView_animetionInView_shrink];
            }
            else
            {
                [view_menu configureView_animetionButton_inViewChange];
            }
        }break;
        case 17:
        {
            NSMutableArray *array = [self installDataArrayWithTag:JDSingerKindTag_europeamericaGirl];
            JDSingerKindViewController *singerController = [[JDSingerKindViewController alloc] initWithString:@"欧美女歌手" andDataArray:array andTag:JDTableViewTag_inlandCombind];
            singerController.navigationController_return = _navigationController_return;
            if(self.revealSideViewController.rootViewController)
            {
                [self.revealSideViewController.rootViewController release];
                    
            }
            [self.revealSideViewController setRootViewController:singerController];
            [singerController release];
            JDMenuView *view_menu = [JDMenuView sharedView];
            if(view_menu.bool_extension)
            {
                [view_menu configureView_animetionInView_shrink];
            }
            else
            {
                [view_menu configureView_animetionButton_inViewChange];
            }
        }break;
        case 18:
        {
            NSMutableArray *array = [self installDataArrayWithTag:JDSingerKindTag_europeamericaCombined];
            JDSingerKindViewController *singerController = [[JDSingerKindViewController alloc] initWithString:@"欧美组合" andDataArray:array andTag:JDTableViewTag_inlandCombind];
            singerController.navigationController_return = _navigationController_return;
            if(self.revealSideViewController.rootViewController)
            {
                [self.revealSideViewController.rootViewController release];
            }
            [self.revealSideViewController setRootViewController:singerController];
            [singerController release];
                JDMenuView *view_menu = [JDMenuView sharedView];
            if(view_menu.bool_extension)
            {
                [view_menu configureView_animetionInView_shrink];
            }
            else
            {
                [view_menu configureView_animetionButton_inViewChange];
            }
        }break;
        case 19:
        {
            NSMutableArray *array = [self installDataArrayWithTag:JDSingerKindTag_other];
            JDSingerKindViewController *singerController = [[JDSingerKindViewController alloc] initWithString:@"其他" andDataArray:array andTag:JDTableViewTag_inlandCombind];
            singerController.navigationController_return = _navigationController_return;
            if(self.revealSideViewController.rootViewController)
            {
                [self.revealSideViewController.rootViewController release];
            }
            [self.revealSideViewController setRootViewController:singerController];
            [singerController release];
            JDMenuView *view_menu = [JDMenuView sharedView];
            if(view_menu.bool_extension)
            {
                [view_menu configureView_animetionInView_shrink];
            }
            else
            {
                [view_menu configureView_animetionButton_inViewChange];
            }
        }break;
    }
}
- (void)didExtensionCell
{
    [self didSelectCellRowFirstDo:YES nextDo:NO];
}

- (void)didSelectCellRowFirstDo:(BOOL)firstDoInsert nextDo:(BOOL)nextDoInsert
{
    self.bool_isOpen = firstDoInsert;
    UITableViewCell *cell = (UITableViewCell *)[_table_master cellForRowAtIndexPath:self.selectIndex];
    [self.table_master beginUpdates];
    int section = self.selectIndex.section;
    int contentCount = [_array_childList count];
    NSMutableArray* rowToInsert = [[NSMutableArray alloc] init];
    for (NSUInteger i = 1; i < contentCount + 1; i++)
    {
        NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:i inSection:section];
        [rowToInsert addObject:indexPathToInsert];
    }
    
    if (firstDoInsert)
    {   [_table_master insertRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
    else
    {
        [_table_master deleteRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
    [rowToInsert release];
    
    [self.table_master endUpdates];
    [self changArrowWithUpInCell:cell withBool:firstDoInsert];
    /*if (nextDoInsert)
     {
     self.bool_isOpen = YES;
     self.selectIndex = [self.table_master indexPathForSelectedRow];
     [self didSelectCellRowFirstDo:YES nextDo:NO];
     }*/
    if (self.bool_isOpen)
    {
        [self.table_master scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}


- (void)changArrowWithUpInCell:(UITableViewCell *)_cell withBool:(BOOL)_bool
{
    if(_bool)
    {
        UIImageView *imageView = (UIImageView *)[_cell viewWithTag:91];
        [UIUtils didLoadImageNotCached:@"menu_bar_four_up.png" inImageView:imageView];
    }
    else
    {
        UIImageView *imageView = (UIImageView *)[_cell viewWithTag:91];
        [UIUtils didLoadImageNotCached:@"menu_bar_four_down.png" inImageView:imageView];
    }
}

#pragma mark - ConfigureSingerData
- (NSMutableArray *)installSingerArrayWithString:(NSString *)string
{
    JDSqlDataBase *dataController = [[JDSqlDataBase alloc] init];
    NSMutableArray *singerArray = [dataController reciveDataBaseWithStringFromSinger:string];
    [dataController release];
    return singerArray;
}

- (NSMutableArray *)installDataArray_Content
{
    NSString *sql = @"select * from client_songs where is_hot = 1";
    NSMutableArray *content = [self installDataArrayWithString:sql];
    return content;
}

- (NSMutableArray *)installDataArray_new_Content
{
    NSString *sql = @"select * from client_songs where is_new = 1";
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

- (NSMutableArray *)installDataArrayWithTag:(JDSingerKindTag)tag
{
    NSMutableArray *array_first = [NSMutableArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#",nil];
    NSMutableArray *arrayData = [NSMutableArray arrayWithCapacity:27];
    JDSqlDataBase *dataController = [[JDSqlDataBase alloc] init];
    [dataController openDataBase];
    switch (tag)
    {
        case JDSingerKindTag_hot_china:
        {
            for(int i = 0; i < 27; i++)
            {
                NSString *sql = [[NSString alloc]initWithFormat:@"select * from client_singers where area in (1,2,3,4) and tags like '%@%%%%' and is_hot = 1",[array_first objectAtIndex:i]];
                NSMutableArray *array_second = [dataController reciveManyWithString:sql];
                [arrayData addObject:array_second];
                [sql release];
            }
        }break;
        case JDSingerKindTag_hot_japanesekorean:
        {
            for(int i = 0; i < 27; i++)
            {
                NSString *sql = [[NSString alloc]initWithFormat:@"select * from client_singers where area in (8,9) and tags like '%@%%%%'",[array_first objectAtIndex:i]];
                NSMutableArray *array_second = [dataController reciveManyWithString:sql];
                [arrayData addObject:array_second];
                [sql release];
            }
        }break;
        case JDSingerKindTag_hot_europeamerica:
        {
            for(int i = 0; i < 27; i++)
            {
                NSString *sql = [[NSString alloc]initWithFormat:@"select * from client_singers where area in (6,7) and name like '%@%%%%'",[array_first objectAtIndex:i]];
                NSMutableArray *array_second = [dataController reciveManyWithString:sql];
                [arrayData addObject:array_second];
                [sql release];
            }
        }break;
        case JDSingerKindTag_inlandBoy:
        {
            for(int i = 0; i < 27; i++)
            {
                NSString *sql = [[NSString alloc]initWithFormat:@"select * from client_singers where sex = '1' and area = '1'and tags like '%@%%%%'",[array_first objectAtIndex:i]];
                NSMutableArray *array_second = [dataController reciveManyWithString:sql];
                [arrayData addObject:array_second];
                [sql release];
            }
        }break;
        case JDSingerKindTag_inlandGirl:
        {
            for(int i = 0; i < 27; i++)
            {
                NSString *sql = [[NSString alloc]initWithFormat:@"select * from client_singers where sex = '0' and area = '1'and tags like '%@%%%%'",[array_first objectAtIndex:i]];
                NSMutableArray *array_second = [dataController reciveManyWithString:sql];
                [arrayData addObject:array_second];
                [sql release];
            }
        }break;
        case JDSingerKindTag_inlandCombined:
        {
            for(int i = 0; i < 27; i++)
            {
                NSString *sql = [[NSString alloc]initWithFormat:@"select * from client_singers where sex = '2' and area = '1'and tags like '%@%%%%'",[array_first objectAtIndex:i]];
                NSMutableArray *array_second = [dataController reciveManyWithString:sql];
                [arrayData addObject:array_second];
                [sql release];
            }
        }break;
        case JDSingerKindTag_HKBoy:
        {
            for(int i = 0; i < 27; i++)
            {
                NSString *sql = [[NSString alloc]initWithFormat:@"select * from client_singers where sex = '1' and area = '2' and tags like '%@%%%%'",[array_first objectAtIndex:i]];
                NSMutableArray *array_second = [dataController reciveManyWithString:sql];
                [arrayData addObject:array_second];
                [sql release];
            }
        }break;
        case JDSingerKindTag_HKGirl:
        {
            for(int i = 0; i < 27; i++)
            {
                NSString *sql = [[NSString alloc]initWithFormat:@"select * from client_singers where sex = '0' and  area = '2' and tags like '%@%%%%'",[array_first objectAtIndex:i]];
                NSMutableArray *array_second = [dataController reciveManyWithString:sql];
                [arrayData addObject:array_second];
                [sql release];
            }
        }break;
        case JDSingerKindTag_HKCombined:
        {
            for(int i = 0; i < 27; i++)
            {
                NSString *sql = [[NSString alloc]initWithFormat:@"select * from client_singers where sex = '2' and area = '2' and tags like '%@%%%%'",[array_first objectAtIndex:i]];
                NSMutableArray *array_second = [dataController reciveManyWithString:sql];
                [arrayData addObject:array_second];
                [sql release];
            }
        }break;
        case JDSingerKindTag_japanesekoreanBoy:
        {
            for(int i = 0; i < 27; i++)
            {
                NSString *sql = [[NSString alloc]initWithFormat:@"select * from client_singers where sex = '1' and area in (8,9) and tags like '%@%%%%'",[array_first objectAtIndex:i]];
                NSMutableArray *array_second = [dataController reciveManyWithString:sql];
                [arrayData addObject:array_second];
                [sql release];
            }
        }break;
        case JDSingerKindTag_japanesekoreanGirl:
        {
            for(int i = 0; i < 27; i++)
            {
                NSString *sql = [[NSString alloc]initWithFormat:@"select * from client_singers where sex = '0' and area in (8,9) and tags like '%@%%%%'",[array_first objectAtIndex:i]];
                NSMutableArray *array_second = [dataController reciveManyWithString:sql];
                [arrayData addObject:array_second];
                [sql release];
            }
        }break;
        case JDSingerKindTag_japanesekoreanCombined:
        {
            for(int i = 0; i < 27; i++)
            {
                NSString *sql = [[NSString alloc]initWithFormat:@"select * from client_singers where sex = '2' and area in (8,9) and tags like '%@%%%%'",[array_first objectAtIndex:i]];
                NSMutableArray *array_second = [dataController reciveManyWithString:sql];
                [arrayData addObject:array_second];
                [sql release];
            }
        }break;
        case JDSingerKindTag_europeamericaBoy:
        {
            for(int i = 0; i < 27; i++)
            {
                NSString *sql = [[NSString alloc]initWithFormat:@"select * from client_singers where sex = '1' and area in (6,7) and name like '%@%%%%'",[array_first objectAtIndex:i]];
                NSMutableArray *array_second = [dataController reciveManyWithString:sql];
                [arrayData addObject:array_second];
                [sql release];
            }
        }break;
        case JDSingerKindTag_europeamericaGirl:
        {
            for(int i = 0; i < 27; i++)
            {
                NSString *sql = [[NSString alloc]initWithFormat:@"select * from client_singers where sex = '0' and area in (6,7) and name like '%@%%%%'",[array_first objectAtIndex:i]];
                NSMutableArray *array_second = [dataController reciveManyWithString:sql];
                [arrayData addObject:array_second];
                [sql release];
            }
        }break;
        case JDSingerKindTag_europeamericaCombined:
        {
            for(int i = 0; i < 27; i++)
            {
                NSString *sql = [[NSString alloc]initWithFormat:@"select * from client_singers where sex = '2' and area in (6,7) and name like '%@%%%%'",[array_first objectAtIndex:i]];
                NSMutableArray *array_second = [dataController reciveManyWithString:sql];
                [arrayData addObject:array_second];
                [sql release];
            }
        }break;
        case JDSingerKindTag_other:
        {
            for(int i = 0; i < 27; i++)
            {
                NSString *sql = [[NSString alloc]initWithFormat:@"select * from client_singers where area = '5' and tags like '%@%%%%'",[array_first objectAtIndex:i]];
                NSMutableArray *array_second = [dataController reciveManyWithString:sql];
                [arrayData addObject:array_second];
                [sql release];
            }
        }break;
        default:
            break;
    }
    //JDSingerKindTag_europeamericaBoy           ,
    //JDSingerKindTag_europeamericaGirl          ,
    //JDSingerKindTag_europeamericaCombined      ,
    //JDSingerKindTag_other                      ,
    [dataController closeDataBase];
    [dataController release];
    return arrayData;
}

#pragma mark - 退出登陆,刷新界面 -
/**
 退出登陆,刷新界面
 **/
- (void)loginOutReloadView
{
    JDCustomLabel *label_nickName = (JDCustomLabel *)[_view_user viewWithTag:100];
    [label_nickName stopAnimating];
    
    [_view_user removeFromSuperview];
    _view_user = nil;
    
    UIView *view_tmp = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, 300, 50)];
    IOS7(view_tmp);
    [view_tmp setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:view_tmp];
    [view_tmp release];
    
    UIImageView *imageView_title = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 310, 50)];
    [UIUtils didLoadImageNotCached:@"menu_title_bg.png" inImageView:imageView_title];
    [view_tmp addSubview:imageView_title];
    [imageView_title release];
    
    UIImageView *imageView_user = [[UIImageView alloc] initWithFrame:CGRectMake(75, 5, 41, 38)];
    [UIUtils didLoadImageNotCached:@"login_icon.png" inImageView:imageView_user];
    [view_tmp addSubview:imageView_user];
    [imageView_user release];
    _imageView_portrait = imageView_user;
    
    UIButton *button_login = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_login setFrame:CGRectMake(120, 8, 86, 34)];
    [UIUtils didLoadImageNotCached:@"goinInfo.png" inButton:button_login withState:UIControlStateNormal];
    [button_login setTag:JDUserButtonTag_Login];
    [button_login addTarget:self action:@selector(didClickButton_user:) forControlEvents:UIControlEventTouchUpInside];
    [view_tmp addSubview:button_login];
    
    /*UIButton *button_registration = [UIButton buttonWithType:UIButtonTypeCustom];
     [button_registration setFrame:CGRectMake(175, 6, 80, 35)];
     [UIUtils didLoadImageNotCached:@"btn_registration_small.png" inButton:button_registration withState:UIControlStateNormal];
     [button_registration setTag:JDUserButtonTag_registration];
     [button_registration addTarget:self action:@selector(didClickButton_user:) forControlEvents:UIControlEventTouchUpInside];
     [view_tmp addSubview:button_registration];*/
    
    _view_user = view_tmp;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadCount" object:nil];
}

-(void)onUserImageClicked{
    NSLog(@"User imageview is clicked!");
}

/**
 开始预读
 **/
- (void)startPreread
{
    NSLog(@"Start preread in master view");
    
    if(mediaProxy != nil)
    {
        [mediaProxy release];
    }
    mediaProxy = [[MediaProxy alloc]init];
    curPrereadVideoUrl = nil;
    
    [prereadTimer invalidate];
    prereadTimer = [NSTimer scheduledTimerWithTimeInterval:(5.0) target:self selector:@selector(checkPreread) userInfo:nil repeats:YES];
}

/**
 停止预读
 **/
- (void)stopPreread
{
    NSLog(@"Stop preread in master view");
    if(mediaProxy != nil)
    {
        [mediaProxy release];
        mediaProxy = nil;
    }
    
    if([prereadTimer isValid]){
        [prereadTimer invalidate];
        prereadTimer = nil;
    }
    [curPrereadVideoUrl release];
    curPrereadVideoUrl = nil;
}

- (void)checkPreread
{
    JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
    self.array_alreadySong = [base reciveSongArrayWithTag:2];
    [base release];
    
    int videoPercent;
    for(SDSongs *song in _array_alreadySong)
    {
        videoPercent = [mediaProxy getPrereadPercent:[song string_videoUrl]];
        if(videoPercent != 100)
        {
            //如果检查发现应该预读的歌曲已经在预读中，则退出本次循环。
            if(curPrereadVideoUrl != nil && [[song string_videoUrl] isEqualToString:curPrereadVideoUrl])
            {
                break;
            }
            NSLog(@"Start preread: %@", [song songTitle]);
            NSArray *audioArray = [NSArray arrayWithObjects:song.string_audio0Url,song.string_audio1Url,nil];
            [mediaProxy prereadWithURL:[song string_videoUrl] WithAudioUrls:audioArray];
            [curPrereadVideoUrl release];
            curPrereadVideoUrl = [[NSString alloc]initWithString:[song string_videoUrl]];
            break;
        }
        //NSLog(@"Song audio0: %@", [song string_audio0Url]);
        //NSLog(@"Song audio1: %@", [song string_audio1Url]);
    }
    
}

@end