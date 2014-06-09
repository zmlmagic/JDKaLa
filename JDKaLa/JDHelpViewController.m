//
//  JDHelpViewController.m
//  JDKaLa
//
//  Created by zhangminglei on 9/18/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDHelpViewController.h"
#import "SKCustomNavigationBar.h"
#import "UIUtils.h"

@implementation JDHelpViewController


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
    [label_titel setText:@"常见问题"];
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
        
        UITextView *textView_rule = [[UITextView alloc] initWithFrame:CGRectMake(10, 30, 1004, 661)];
        [textView_rule setBackgroundColor:[UIColor clearColor]];
        [textView_rule setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20.0f]];
        [textView_rule setTextColor:[UIColor whiteColor]];
        [textView_rule setText:@"\n1. 如何注册K吧账号？\n点击首页左上角“注册”按钮，进入新用户注册界面，输入相关的注册信息即可完成注册。\n2. 如何找回K吧账号密码？\n邮箱是唯一找回K吧账号密码的方式，使用邮箱注册的用户，默认注册邮箱就是您的绑定邮箱。 点击首页“登陆”按钮，找到“点击这里找回”输入注册时的邮箱即可找回密码。\n3. 如何录制出更好的作品？\n录音时点击屏幕左侧的“混音强度”按钮可以进入到音效设置页面，您可以在音效设置首页中调整伴奏和录音声音的大小。插入耳机后，可以开启更多音效功能，我们为您精心设计了4种常用的音效模式，点击某一个预设模式按钮即可马上使用。当然，您也可以通过自定义功能来设置自己的音效并保存为“我的音效”，方便随时使用。\n4. 如何缓存歌曲？\n进入“点歌”目录，选择您喜欢的歌曲后点击“歌曲列表”按钮即可缓存。为避免损耗您的流量建议使用wifi缓存。下载成功的歌曲保存在“我的曲目”页面的“已点歌曲”列表中。\n5. K吧离线状态下能使用吗？\n为了保护版权方的歌曲权益，K吧软件页面内的播放和录制功能不能支持离线使用。\n6. 如何搜索喜欢的歌手或歌曲？\n在页面点击最上方的搜索框即可输入您要搜索的内容。您可以输入关键字或拼音首字母进行搜索。如：想要搜索歌手“周杰伦”，您可以输入“林俊杰”文字或“zjl”三个字母后点击搜索即可。\n7. 录制结束后如何保存作品？\n录音结束后，在“录音结束”页面可以对作品进行保存操作，您录制的歌曲将被保存在“我的曲目”页面中的“我的录音”\n8. 使用中有意见或者建议如何反馈？\n进入“更多”点击“问题反馈”即可直接将您的意见或者建议直接反馈给我们。也可以通过qq群：320675106进行咨询与投诉。"];
        [cell addSubview:textView_rule];
        [textView_rule release];
    }
    return cell;
}


@end
