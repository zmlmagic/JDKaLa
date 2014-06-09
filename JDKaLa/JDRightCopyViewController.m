//
//  JDRightCopyViewController.m
//  JDKaLa
//
//  Created by zhangminglei on 11/8/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDRightCopyViewController.h"
#import "SKCustomNavigationBar.h"
#import "UIUtils.h"

@interface JDRightCopyViewController ()

@end

@implementation JDRightCopyViewController

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
    IOS7(customNavigationBar);
    [self.view addSubview:customNavigationBar];
    [customNavigationBar release];
    
    UILabel *label_titel = [[UILabel alloc]initWithFrame:CGRectMake(412, 0, 200, 50)];
    [label_titel setTextAlignment:NSTextAlignmentCenter];
    [label_titel setBackgroundColor:[UIColor clearColor]];
    [label_titel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:22.0f]];
    [label_titel setTextColor:[UIColor whiteColor]];
    [label_titel setText:@"版权说明"];
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
        
        UIImageView *imageView_rule = [[UIImageView alloc] initWithFrame:CGRectMake(10, 30, 1004, 641)];
        [UIUtils didLoadImageNotCached:@"rule.png" inImageView:imageView_rule];
        [cell addSubview:imageView_rule];
        [imageView_rule release];
        
        UITextView *textView_rule = [[UITextView alloc] initWithFrame:CGRectMake(10, 30, 1004, 641)];
        [textView_rule setBackgroundColor:[UIColor clearColor]];
        [textView_rule setFont:[UIFont fontWithName:@"Helvetica-Bold" size:35.0f]];
        [textView_rule setTextColor:[UIColor whiteColor]];
        [textView_rule setText:@"\n        版权申明:本产品所有歌曲来自于互联网,发生版权问题与苹果公司无关,如有侵权情况请及时通知。\n"];
        [cell addSubview:textView_rule];
        [textView_rule release];
    }
    return cell;
}

@end
