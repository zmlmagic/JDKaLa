//
//  JDMoreViewController.m
//  JDKaLa
//
//  Created by zhangminglei on 9/4/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDMoreViewController.h"
#import "SKCustomNavigationBar.h"
#import "UIUtils.h"
#import "JDMoreView.h"

@implementation JDMoreViewController

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
    IOS7_STATEBAR;
    [super viewDidLoad];
    [self configureView_background];
    JDMoreView *moreView = [[JDMoreView alloc] init];
    [self.view addSubview:moreView];
    [moreView setTag:20];
    [moreView release];
    [self.view setBackgroundColor:[UIColor blackColor]];
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

- (void)dealloc
{
    JDMoreView *moreView = (JDMoreView *)[self.view viewWithTag:20];
    [moreView removeNSNotification];
    [moreView release];
    [super dealloc];
}

- (void)configureView_title
{
    SKCustomNavigationBar *customNavigationBar = [[SKCustomNavigationBar alloc] initWithFrame:CGRectMake(0, 0, 1024, 50)];
    [self.view addSubview:customNavigationBar];
    IOS7(customNavigationBar);
    [customNavigationBar release];

    UILabel *label_titel = [[UILabel alloc]initWithFrame:CGRectMake(412, 0, 200, 50)];
    [label_titel setTextAlignment:NSTextAlignmentCenter];
    [label_titel setBackgroundColor:[UIColor clearColor]];
    [label_titel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:30.0f]];
    [label_titel setTextColor:[UIColor whiteColor]];
    [label_titel setText:@"更多"];
    _label_title = label_titel;
    [customNavigationBar addSubview:label_titel];
    [label_titel release];
}

- (void)configureView_background
{
    UIImageView *imageView_background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 1024, 749)];
    [UIUtils didLoadImageNotCached:@"mainView_background.png" inImageView:imageView_background];
    [self.view addSubview:imageView_background];
    [imageView_background release];
}


@end
