//
//  JDMainViewController.m
//  JDKaLa
//
//  Created by zhangminglei on 3/27/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDMainViewController.h"
#import "SKCustomNavigationBar.h"
#import "JDMasterViewController.h"
#import "SKRevealSideViewController.h"
#import "JDSearchViewController.h"
#import "JDMainViewCell.h"
#import "UIUtils.h"
#import "JDSqlDataBase.h"
#import "JDAlreadySongView.h"
#import "CustomAlertView.h"
#import "JDModel_userInfo.h"
#import "JDAlbum.h"
#import "JDSingerSongViewController.h"
#import "JDThereSongViewController.h"

@interface JDMainViewController ()

@end

@implementation JDMainViewController

- (id)init
{
    self = [super init];
    if(self)
    {
        [self configureView_title];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        UIImageView *imageView_background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 1024, 749)];
        [UIUtils didLoadImageNotCached:@"mainView_background.png" inImageView:imageView_background];
        [self.view addSubview:imageView_background];
        [imageView_background release];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self performSelector:@selector(configureView_tableView) withObject:nil afterDelay:1.0f];
    self.bool_already = NO;
    self.bool_extension = NO;
    _bool_oneTime = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTitleView:)
                                                 name:@"JDSongStateChange_order"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadCount)
                                                 name:@"reloadCount"
                                               object:nil];
	// Do any additional setup after loading the view.
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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"reloadCount"
                                                  object:nil];
    
    [webView_theme release];
    [super dealloc];
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
        }
        _bool_oneTime = NO;
    }
}


#pragma mark - 初始化title -
/**
 初始化title
 **/
- (void)configureView_title
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
    
    UIImageView *imageView_title = [[UIImageView alloc] initWithFrame:CGRectMake(135, 5, 150, 40)];
    [UIUtils didLoadImageNotCached:@"menu_bar_02_remm.png" inImageView:imageView_title];
    [view_title addSubview:imageView_title];
    [imageView_title release];
    
    UIButton *button_master = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_master setFrame:CGRectMake(10, 3, 63, 37)];
    [UIUtils didLoadImageNotCached:@"title_bar_btn_menu.png" inButton:button_master withState:UIControlStateNormal];
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

#pragma mark - 点击播放列表按钮 -
/**
 点击播放列表按钮
 **/
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
            UIImageView *imageView_sanjiao = [[UIImageView alloc] initWithFrame:CGRectMake(673, 50, 20, 9)];
            if([JDModel_userInfo sharedModel].bool_hasMaster)
            {
                [songView setFrame:CGRectMake(363, 59, 348, 593)];
                [imageView_sanjiao setFrame:CGRectMake(363, 50, 20, 9)];
            }
            IOS7(songView);
            IOS7(imageView_sanjiao);
            [songView configureView_table];
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


- (void)configureView_tableView
{
    if(webView_theme == nil)
    {
        webView_theme = [[UIWebView alloc]initWithFrame:CGRectMake(0, 50, 1024, 718)];
        IOS7(webView_theme);
        [webView_theme setBackgroundColor:[UIColor grayColor]];
        [webView_theme setDelegate:self];
        [self.view insertSubview:webView_theme atIndex:1];
        //[self.view addSubview:webView_theme];
    }
    
    //NSString *fileName = [NSString stringWithFormat:@"%@/index.html", [[NSBundle mainBundle] resourcePath]];
    //NSURL *initURL = [NSURL URLWithString:fileName];
    NSURL *initURL = [NSURL URLWithString:@"http://122.49.30.115/topic/"];
    [webView_theme loadRequest:[NSURLRequest requestWithURL:initURL]];
    //[webView release];
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
    masterViewController.navigationController_return = _navigationController_return;
    [masterViewController reloadViewWhenNext];
    [masterViewController setMainViewController_main:self];
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

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 718;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MainCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[JDMainViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [(JDMainViewCell*)cell setViewController:self];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return cell;
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

- (void)reloadTitleView:(NSNotification *)note
{
    NSInteger count1 = [label_total.text integerValue];
    NSInteger count2 = [(NSString *)[note object] integerValue];
    label_total.text = [NSString stringWithFormat:@"%d",count1 + count2];
}

- (void)reloadCount
{
    JDSqlDataBase *base = [[JDSqlDataBase alloc] init];
    NSMutableArray *array_base = [base reciveSongArrayWithTag:2];
    [base release];
    label_total.text = [NSString stringWithFormat:@"%d",[array_base count]];
}


#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //NSString *jsCode = [NSString stringWithFormat:@"alert(1);"];
    //NSString *jsCode = [NSString stringWithFormat:@"test1()"];
    //[webView stringByEvaluatingJavaScriptFromString:jsCode];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //NSLog(@"Receive:%@", [[request URL] absoluteURL]);
    NSString *requestString = [[request URL] relativePath];
    //NSLog(@"requestString:%@", requestString);
    NSArray *components = [requestString componentsSeparatedByString:@"|"];
    if ([components count] > 1 && [(NSString *)[components objectAtIndex:0] hasSuffix:@"web_command"])
    {
        NSString *command = (NSString *)[components objectAtIndex:1];
        NSString *param = (NSString *)[components objectAtIndex:2];
        if([command isEqualToString:@"EnterAlbum"])
        {
            //param = [@"http:" stringByAppendingString:param];
            NSLog(@"收到进入专辑指令，专辑URL是:%@ ",param);
            
            //把这个URL的测试值改为param，就可以了。
            [self enterAlbum: param];
        }
        return NO;
    }
    return YES;
}

/**
 * 进入专辑页面
 * @param: url 专辑XML的地址
 */
- (void)enterAlbum:(NSString*)url
{
    if(url != nil)
    {
        if([[UIUtils applecationNetworkState] isEqualToString:@"no"])
        {
            CustomAlertView *alter = [[CustomAlertView alloc] initWithTitle:@"连接失败" message:@"请检查网络链接" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alter show];
            [alter release];
            return;
        }
        //NSString *fileName = [NSString stringWithFormat:@"%@/generate_test.xml", [[NSBundle mainBundle] resourcePath]];
        JDThereSongViewController *themeController = [[JDThereSongViewController alloc] initWithTitleFileName:url];
        themeController.navigationController_return = _navigationController_return;
        
        //NSString       *sql = [NSString stringWithFormat:@"select *from songs where md5 in (%@)", allMd5];
        //[self presentModalViewController:themeController animated:NO];
        [_navigationController_return pushViewController:themeController animated:YES];
        [themeController release];
    }
}

@end
