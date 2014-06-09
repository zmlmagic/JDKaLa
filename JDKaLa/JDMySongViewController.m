//
//  JDMySongViewController.m
//  JDKaLa
//
//  Created by zhangminglei on 5/27/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDMySongViewController.h"
#import "SKCustomNavigationBar.h"
#import "UIUtils.h"
#import "SKRevealSideViewController.h"
#import "JDMySongMasterController.h"
#import "JDMyOrderSongView.h"
#import "JDModel_userInfo.h"
#import "JDSearchViewController.h"

@implementation JDMySongViewController

- (id)init
{
    self = [super init];
    if(self)
    {
        [self configureView_title];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView_background];
    JDMyOrderSongView *orderSongView = [[JDMyOrderSongView alloc] init];
    IOS7(orderSongView);
    [orderSongView setTag:20];
    [self.view addSubview:orderSongView];
    [orderSongView release];
    self.bool_extension = NO;
    _bool_oneTime = YES;
    [self.view setBackgroundColor:[UIColor blackColor]];
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

#pragma mark -
#pragma mark ConfigureView
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
    
    UILabel *label_titel = [[UILabel alloc]initWithFrame:CGRectMake(135, 0, 200, 50)];
    [label_titel setBackgroundColor:[UIColor clearColor]];
    [label_titel setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:30.0f]];
    [label_titel setTextColor:[UIColor whiteColor]];
    [label_titel setText:@"已点歌曲"];
    _label_title = label_titel;
    [view_title addSubview:label_titel];
    [label_titel release];
    
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
    [view_title addSubview:text_search];
    [text_search release];
}

-(void)didClickButton_master
{
    [JDModel_userInfo sharedModel].bool_hasMaster = ![JDModel_userInfo sharedModel].bool_hasMaster;
    
    JDMySongMasterController *masterViewController = [[JDMySongMasterController alloc] init];
    masterViewController.navigationController_return = _navigationController_return;
    [self.revealSideViewController pushViewController:masterViewController onDirection:PPRevealSideDirectionLeft withOffset:478.0 animated:YES];
    self.revealSideViewController.panInteractionsWhenClosed = PPRevealSideInteractionNone;
    self.revealSideViewController.panInteractionsWhenOpened = PPRevealSideInteractionNone;
    [masterViewController release];
    
    JDMyOrderSongView *orderSongView = (JDMyOrderSongView *)[self.view viewWithTag:20];
    orderSongView.navigationController_return = _navigationController_return;
    
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

- (void)configureView_background
{
    UIImageView *imageView_background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 1024, 749)];
    IOS7(imageView_background);
    [UIUtils didLoadImageNotCached:@"mainView_background.png" inImageView:imageView_background];
    [self.view addSubview:imageView_background];
    [imageView_background release];
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


@end
