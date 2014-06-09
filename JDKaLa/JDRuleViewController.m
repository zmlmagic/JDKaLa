//
//  JDRuleViewController.m
//  JDKaLa
//
//  Created by 张明磊 on 13-9-17.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import "JDRuleViewController.h"
#import "SKCustomNavigationBar.h"
#import "UIUtils.h"

@interface JDRuleViewController ()

@end

@implementation JDRuleViewController

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
    [label_titel setText:@"使用条款/版权申明"];
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
    return 661.0f;
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
        
        UITextView *textView_rule = [[UITextView alloc] initWithFrame:CGRectMake(10, 30, 1004, 621)];
        [textView_rule setBackgroundColor:[UIColor clearColor]];
        [textView_rule setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20.0f]];
        [textView_rule setTextColor:[UIColor whiteColor]];
        [textView_rule setText:@"\n版权申明:本产品所有歌曲来自于互联网,发生版权问题与苹果公司无关,如有侵权情况请及时通知。\n\n一、 一般条款 K吧应用软件根据下述使用条款，通过互联网络为K吧用户（以下简称“用户”）提供K吧社区服务。用户在使用K吧所提供的各项服务内容前，应仔细阅读本使用条款，并确保自己明确知悉以下内容:\n1、 本使用条款由K吧制定并随时更新，且条款变更毋需另行通知用户。\n2、 更新后的使用条款，一旦在网页中公布，即有效替代原有的使用条款。\n3、 K吧中包含的所有与服务相关的提示语、帮助信息，均可视为本使用条款组成部分。\n4、 如用户不能同意本使用条款，或不能同意K吧对其进行的随时修改，请立即停止使用K吧所提供的全部服务。\n5、 用户一旦使用K吧服务，即视为已完全同意本使用条款内容。\n二、 K吧的权利义务\n1、 K吧为用户提供内容存储空间，但因无法控制经由本服务上传之内容，因此不保证用户上传内容的正确性、完整性及品质。用户在使用本服务前，应明确可能会接触到不适当或令人反感的内容。在任何情况下，K吧均不为任何内容承担责任，但保留对用户提交内容进行修改、不予发表及删除的权利。\n2、 用户上传至该空间的内容、资料、照片、数据等内容，将受到中国相关法律保护。K吧郑重承诺将尊重并保护用户隐私。\n3、 用户了解并同意，K吧依据法律法规之规定，或出于以下目的，可对用户上传内容进行保存或披露：\na.遵守法律程序；\nb.执行本使用条款；\nc.回应任何第三人提出的权力主张；\nd.保护K吧、用户及公众之权力、财产及人身安全；\ne.其他K吧认为必要的情况。\n三、 用户权利义务\n1、 用户注册：用户在使用K吧服务前，应根据提示完成注册，并确保注册及今后更新的邮箱、密码、头像、昵称等资料的有效性及合法性。如用户提供资料违法或包含不适宜在K吧社区中展示之内容（包括但不限于含有诽谤、低级趣味、种族歧视、影射领袖、诋毁他人名誉等），或K吧有理由怀疑用户资料属于程序或恶意操作，K吧有权随时中止/终止该用户的账户使用，并拒绝该用户现在及未来使用K吧社区服务的权利。\n2、 法律责任：用户同意并遵守中华人民共和国法律及互联网行业相关法规条款。用户对以任何方式使用您本人所注册账号所产生的任何行为及结果承担全部责任，包括由此产生的法律责任。\n3、 账号管理：用户有义务保护好自己的密码，确保账号安全。在此，用户同意：在本人账号遭到盗用时，应立即通知K吧采取补救措施；因用户未保管好自己的账号及密码所产生的任何损失，K吧不承担任何责任；因账户管理不当，导致其所产生的行为对用户本人、K吧或第三方所造成的损失，由用户承担全部责任。\n四、 国际使用用户了解并同意互联网的无国界性，同意并遵守当地所有关于网上行为及内容之法律法规，同意并遵守中国有关的法律法规。\n五、 不可抗力 对于因不可抗力或其他K吧无法控制的原因所造成的服务中断或其它缺陷，包括由于系统问题导致的用户上传数据或信息的丢失，K吧不应承担责任，但将尽可能地协助处理善后事宜，并努力减少用户损失及影响。\n六、 服务的修改与停止用户了解并同意K吧基于自身运营考虑或其他理由，有权在任何时间暂时或永久修改或终止社区服务（或其任何部分），K吧无需因服务的修改与终止对任何第三人承担任何责任。因用户违反本使用协议的文字精神，导致账号关闭或服务终止，账号中内容被移除并删除，K吧无需对用户本人或第三人承担任何责任。\n七、 其他\n1、 K吧有权根据互联网的发展及相关法律法规的变化，不时完善或修改社区的使用条款。用户在使用服务时，有必要对服务条款进行仔细阅读及重新确认。当发生争议时，应以最新的服务条款为准。\n2、 K吧保留因业务增长而提供有偿服务的权利，同时也承诺尊重用户的选择权。\n3、K吧对于本使用条款具有最终解释权。"];
        [cell addSubview:textView_rule];
        [textView_rule release];
    }
    return cell;
}

@end
