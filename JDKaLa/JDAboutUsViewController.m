//
//  JDAboutUsViewController.m
//  JDKaLa
//
//  Created by 张明磊 on 13-9-17.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import "JDAboutUsViewController.h"
#import "SKCustomNavigationBar.h"
#import "UIUtils.h"

@interface JDAboutUsViewController ()

@end

@implementation JDAboutUsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    IOS7_STATEBAR;
    [self installView_background];
    [self installView_body];
    [self installView_title];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 状态栏控制 -
/**状态栏控制**/
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
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
    
    UILabel *label_titel = [[UILabel alloc]initWithFrame:CGRectMake(412, 0, 200, 50)];
    [label_titel setTextAlignment:NSTextAlignmentCenter];
    [label_titel setBackgroundColor:[UIColor clearColor]];
    [label_titel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:22.0f]];
    [label_titel setTextColor:[UIColor whiteColor]];
    [label_titel setText:@"关于我们"];
    [customNavigationBar addSubview:label_titel];
    [label_titel release];
    
    UIButton *button_return = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_return setFrame:CGRectMake(10, 7, 65, 37)];
    [UIUtils didLoadImageNotCached:@"back_btn.png" inButton:button_return withState:UIControlStateNormal];
    [customNavigationBar addSubview:button_return];
    [button_return addTarget:self action:@selector(didClickButton_return) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 点击返回按钮回调 -
/**
 点击返回按钮回调
 **/
- (void)didClickButton_return
{
    [_nav_return popViewControllerAnimated:YES];
}

#pragma mark - 初始化背景 -
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

#pragma mark - 初始化页面内容 -
/**
 初始化页面内容
 **/
- (void)installView_body
{
    UITableView *tableView_songShow = [[UITableView alloc] initWithFrame:CGRectMake(0, 57, 1024, 641)];
    IOS7(tableView_songShow);
    [tableView_songShow setBackgroundColor:[UIColor clearColor]];
    [tableView_songShow setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView_songShow setDataSource:self];
    [tableView_songShow setDelegate:self];
    [self.view addSubview:tableView_songShow];
    [tableView_songShow release];
}


#pragma mark - 初始化TableView -
/**
 初始化TableView
 **/
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
    return 641.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"aboutUsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] init]autorelease];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        UIImageView *imageViewBack = [[UIImageView alloc]initWithFrame:CGRectMake(34, 90, 956, 324)];
        [UIUtils didLoadImageNotCached:@"aboutUs.png" inImageView:imageViewBack];
        [cell addSubview:imageViewBack];
        [imageViewBack release];
        
        UILabel *label_title_one = [[UILabel alloc] initWithFrame:CGRectMake(112, 120, 800, 100)];
        [label_title_one setBackgroundColor:[UIColor clearColor]];
        [label_title_one setTextColor:[UIColor whiteColor]];
        [label_title_one setFont:[UIFont fontWithName:@"Helvetica-Bold" size:60]];
        [label_title_one setTextAlignment:NSTextAlignmentCenter];
        [label_title_one setText:@"K吧ipad简体中文版"];
        [cell addSubview:label_title_one];
        [label_title_one release];
        
        UILabel *label_title_two = [[UILabel alloc] initWithFrame:CGRectMake(462, 220, 100, 30)];
        [label_title_two setBackgroundColor:[UIColor clearColor]];
        [label_title_two setTextColor:[UIColor whiteColor]];
        [label_title_two setFont:[UIFont fontWithName:@"Helvetica-Bold" size:22]];
        [label_title_two setTextAlignment:NSTextAlignmentCenter];
        [label_title_two setText:@"V1.0.0"];
        [cell addSubview:label_title_two];
        [label_title_two release];
        
        UILabel *label_title_three = [[UILabel alloc] initWithFrame:CGRectMake(312, 280, 400, 30)];
        [label_title_three setTextColor:[UIColor whiteColor]];
        [label_title_three setTextAlignment:NSTextAlignmentCenter];
        [label_title_three setBackgroundColor:[UIColor clearColor]];
        [label_title_three setFont:[UIFont fontWithName:@"Helvetica-Bold" size:22]];
        [label_title_three setTextAlignment:NSTextAlignmentCenter];
        [label_title_three setText:@"客服电话: 13621001538"];
        [cell addSubview:label_title_three];
        [label_title_three release];
        
        UILabel *label_title_four = [[UILabel alloc] initWithFrame:CGRectMake(312, 320, 400, 30)];
        [label_title_four setTextColor:[UIColor whiteColor]];
        [label_title_four setTextAlignment:NSTextAlignmentCenter];
        [label_title_four setBackgroundColor:[UIColor clearColor]];
        [label_title_four setFont:[UIFont fontWithName:@"Helvetica-Bold" size:22]];
        [label_title_four setTextAlignment:NSTextAlignmentCenter];
        [label_title_four setText:@"客服qq群: 320675106"];
        [cell addSubview:label_title_four];
        [label_title_four release];
        
        UILabel *label_title_five = [[UILabel alloc] initWithFrame:CGRectMake(312, 360, 400, 30)];
        [label_title_five setTextColor:[UIColor whiteColor]];
        [label_title_five setTextAlignment:NSTextAlignmentCenter];
        [label_title_five setBackgroundColor:[UIColor clearColor]];
        [label_title_five setFont:[UIFont fontWithName:@"Helvetica-Bold" size:22]];
        [label_title_five setTextAlignment:NSTextAlignmentCenter];
        [label_title_five setText:BUILD_VERSION];
        [cell addSubview:label_title_five];
        [label_title_five release];
    }
    return cell;
}

@end
