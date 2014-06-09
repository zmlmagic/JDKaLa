//
//  JDMenuView.m
//  JDKaLa
//
//  Created by zhangminglei on 4/15/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDMenuView.h"
#import "ProductListViewController.h"
#import "JDMainViewController.h"
#import "JDMySongViewController.h"
#import "JDMoreViewController.h"
#import "JDMasterViewController.h"
#import "UIUtils.h"
#import "CustomAlertView.h"

typedef enum
{
    JDMenuButtinTag_animentoinEnd = 303,
    JDMenuButtonTag_more               ,
    JDMenuButtonTag_mySong             ,
    JDMenuButtonTag_account            ,
    JDMenuButtonTag_request            ,
    
}JDMenuButtonTag;

@implementation JDMenuView

static  JDMenuView *shareJDMenuView = nil;

+ (JDMenuView *)sharedView
{
    @synchronized(self)
    {
        if(shareJDMenuView == nil)
        {
            shareJDMenuView = [[self alloc] init];
        }
    }
    return shareJDMenuView;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (shareJDMenuView == nil)
        {
            shareJDMenuView = [super allocWithZone:zone];
            return  shareJDMenuView;
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

- (void)dealloc
{
    [_revealSideViewController release], _revealSideViewController = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _bool_extension = NO;
        // Initialization code
    }
    return self;
}

- (UIImage *)didLoadImageNotCached:(NSString *)filename
{
    NSString *imageFile = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], filename];
    NSData *imageData = [NSData dataWithContentsOfFile:imageFile];
    return [UIImage imageWithData:imageData];
}

- (void)configureView_animetionButton
{
    UIButton *button_begin = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_begin setTag:200];
    [button_begin setFrame:CGRectMake(0, 648, 105, 100)];
    IOS7(button_begin);
    [button_begin setBackgroundImage:[self didLoadImageNotCached:@"button_animetion_begin.png"] forState:UIControlStateNormal];
    [button_begin addTarget:self action:@selector(configureView_animetionInView_extension) forControlEvents:UIControlEventTouchUpInside];
    [_revealSideViewController.view addSubview:button_begin];
}

- (void)configureView_animetionButton_inViewChange
{
    UIButton *button_tmp = (UIButton *)[_revealSideViewController.view viewWithTag:200];
    [button_tmp removeFromSuperview];

    UIButton *button_begin = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_begin setTag:200];
    [button_begin setFrame:CGRectMake(0, 648, 105, 100)];
    IOS7(button_begin);
    [button_begin setBackgroundImage:[self didLoadImageNotCached:@"button_animetion_begin.png"] forState:UIControlStateNormal];
    [button_begin addTarget:self action:@selector(configureView_animetionInView_extension) forControlEvents:UIControlEventTouchUpInside];
    [_revealSideViewController.view addSubview:button_begin];
}

- (void)configureView_animetionInView_extension
{
    [[JDMasterViewController sharedController].table_master setUserInteractionEnabled:NO];
    
    _bool_extension = YES;
    UIButton *button_tmp = (UIButton *)[_revealSideViewController.view viewWithTag:200];
    [button_tmp removeFromSuperview];
    NSMutableArray *array_animetion = [[NSMutableArray alloc]initWithCapacity:22];
    for(int i = 0; i<22 ;i++)
    {
        NSString *string_animetion = [[NSString alloc] initWithFormat:@"menu_anime%d",i + 1];
        UIImage *image_animetion =[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:string_animetion ofType:@"png"]];
        [string_animetion release];
        [array_animetion addObject:image_animetion];
        [image_animetion release];
    }
    UIImageView *imageView_animetion = [[UIImageView alloc] initWithFrame:CGRectMake(0, 448, 210, 300)];
    IOS7(imageView_animetion);
    [_revealSideViewController.view addSubview:imageView_animetion];
    [imageView_animetion release];
    imageView_animetion.animationImages = array_animetion;
    [array_animetion release];
    imageView_animetion.animationDuration = 0.5f;
    imageView_animetion.animationRepeatCount = 1;
    [imageView_animetion startAnimating];
    [self performSelector:@selector(animetionEndInView_fromBegin:) withObject:imageView_animetion afterDelay:0.5f];
}

- (void)configureView_animetionInView_shrink
{
    [[JDMasterViewController sharedController].table_master setUserInteractionEnabled:NO];
    _bool_extension = NO;
    
    UIButton *button_end = (UIButton *)[_revealSideViewController.view viewWithTag:JDMenuButtinTag_animentoinEnd];
    [button_end removeFromSuperview];
    UIButton *button_more = (UIButton *)[_revealSideViewController.view viewWithTag:JDMenuButtonTag_more];
    [button_more removeFromSuperview];
    UIButton *button_mySong = (UIButton *)[_revealSideViewController.view viewWithTag:JDMenuButtonTag_mySong];
    [button_mySong removeFromSuperview];
    UIButton *button_request = (UIButton *)[_revealSideViewController.view viewWithTag:JDMenuButtonTag_request];
    [button_request removeFromSuperview];
    UIButton *button_account = (UIButton *)[_revealSideViewController.view viewWithTag:JDMenuButtonTag_account];
    [button_account removeFromSuperview];
    
    NSMutableArray *array_animetion = [[NSMutableArray alloc] initWithCapacity:22];
    for(int i = 0; i<22 ;i++)
    {
        NSString *string_animetion = [[NSString alloc] initWithFormat:@"menu_anime%d",22 - i];
        UIImage *image_animetion =[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:string_animetion ofType:@"png"]];
        [string_animetion release];
        [array_animetion addObject:image_animetion];
        [image_animetion release];
    }
    UIImageView *imageView_animetion = [[UIImageView alloc] initWithFrame:CGRectMake(0, 448, 210, 300)];
    IOS7(imageView_animetion);
    [_revealSideViewController.view addSubview:imageView_animetion];
    [imageView_animetion release];
    imageView_animetion.animationImages = array_animetion;
    [array_animetion release];
    imageView_animetion.animationDuration = 0.5f ;
    imageView_animetion.animationRepeatCount = 1;
    [imageView_animetion startAnimating];
    [self performSelector:@selector(animetionEndInView_fromEnd:) withObject:imageView_animetion afterDelay:0.5f];
}


- (void)animetionEndInView_fromBegin:(UIImageView *)_imageView
{
    [_imageView stopAnimating];
    [_imageView.animationImages release];
    [self configureView_menuButton];
    
    [[JDMasterViewController sharedController].table_master setUserInteractionEnabled:YES];
}

- (void)animetionEndInView_fromEnd:(UIImageView *)_imageView
{
    [[JDMasterViewController sharedController].table_master setUserInteractionEnabled:YES];
    [_imageView stopAnimating];
    [_imageView.animationImages release];
    [self configureView_animetionButton];
}

- (void)configureView_menuButton
{
    UIButton *button_animetionEnd = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_animetionEnd setFrame:CGRectMake(0, 648, 100, 100)];
    IOS7(button_animetionEnd);
    [button_animetionEnd setBackgroundImage:[self didLoadImageNotCached:@"button_animetion_end.png"] forState:UIControlStateNormal];
    [button_animetionEnd setTag:JDMenuButtinTag_animentoinEnd];
    [button_animetionEnd addTarget:self action:@selector(didClickButton_menu:) forControlEvents:UIControlEventTouchUpInside];
    [_revealSideViewController.view addSubview:button_animetionEnd];
    
    UIButton *button_more = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_more setFrame:CGRectMake(100, 648, 105, 100)];
    IOS7(button_more);
    [button_more setBackgroundImage:[self didLoadImageNotCached:@"button_animetion_more.png"] forState:UIControlStateNormal];
    [button_more setTag:JDMenuButtonTag_more];
    [button_more addTarget:self action:@selector(didClickButton_menu:) forControlEvents:UIControlEventTouchUpInside];
    [_revealSideViewController.view addSubview:button_more];
    
    UIButton *button_mySong = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_mySong setFrame:CGRectMake(0, 548, 100, 100)];
    IOS7(button_mySong);
    [button_mySong setBackgroundImage:[self didLoadImageNotCached:@"button_animetion_mySong.png"] forState:UIControlStateNormal];
    [button_mySong setTag:JDMenuButtonTag_mySong];
    [button_mySong addTarget:self action:@selector(didClickButton_menu:) forControlEvents:UIControlEventTouchUpInside];
    [_revealSideViewController.view addSubview:button_mySong];
    
    UIButton *button_account = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_account setFrame:CGRectMake(100, 548, 105, 100)];
    IOS7(button_account);
    [button_account setBackgroundImage:[self didLoadImageNotCached:@"button_animetion_account.png"] forState:UIControlStateNormal];
    [button_account setTag:JDMenuButtonTag_account];
    [button_account addTarget:self action:@selector(didClickButton_menu:) forControlEvents:UIControlEventTouchUpInside];
    [_revealSideViewController.view addSubview:button_account];
    
    UIButton *button_request = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_request setFrame:CGRectMake(0, 448, 105, 100)];
    IOS7(button_request);
    [button_request setBackgroundImage:[self didLoadImageNotCached:@"button_animetion_request.png"] forState:UIControlStateNormal];
    [button_request setTag:JDMenuButtonTag_request];
    [button_request addTarget:self action:@selector(didClickButton_menu:) forControlEvents:UIControlEventTouchUpInside];
    [_revealSideViewController.view addSubview:button_request];
}

- (void)setButton_setUserInteractionEnabled:(BOOL)_bool
{
    if(_bool_extension)
    {
        UIButton *button_end = (UIButton *)[_revealSideViewController.view viewWithTag:JDMenuButtinTag_animentoinEnd];
        [button_end setUserInteractionEnabled:_bool];
        UIButton *button_account = (UIButton *)[_revealSideViewController.view viewWithTag:JDMenuButtonTag_account];
        [button_account setUserInteractionEnabled:_bool];
        UIButton *button_more = (UIButton *)[_revealSideViewController.view viewWithTag:JDMenuButtonTag_more];
        [button_more setUserInteractionEnabled:_bool];
        UIButton *button_mySong = (UIButton *)[_revealSideViewController.view viewWithTag:JDMenuButtonTag_mySong];
        [button_mySong setUserInteractionEnabled:_bool];
        UIButton *button_request = (UIButton *)[_revealSideViewController.view viewWithTag:JDMenuButtonTag_request];
        [button_request setUserInteractionEnabled:_bool];
    }
    else
    {
        UIButton *button_begin = (UIButton *)[_revealSideViewController.view viewWithTag:200];
        [button_begin setUserInteractionEnabled:_bool];
    }
}

#pragma mark - DidClickButton
- (void)didClickButton_menu:(id)sender
{
    UIButton *button_tmp = (UIButton *)sender;
    switch (button_tmp.tag)
    {
        case JDMenuButtinTag_animentoinEnd:
        {
            [self configureView_animetionInView_shrink];
            
        }break;
        case JDMenuButtonTag_more:
        {
            JDMoreViewController *moreController = [[JDMoreViewController alloc] init];
            UINavigationController *nav_push = [[UINavigationController alloc] initWithRootViewController:moreController];
            [nav_push setNavigationBarHidden:YES];
            if(_revealSideViewController.rootViewController)
            {
                [_revealSideViewController.rootViewController release];
            }
            [_revealSideViewController setRootViewController:nav_push];
            [nav_push release];
            [moreController setNav_return:nav_push];
            [moreController release];
            [self configureView_animetionInView_shrink];
            
        }break;
        case JDMenuButtonTag_mySong:
        {
            if(![[NSUserDefaults standardUserDefaults] objectForKey:@"token"])
            {
                CustomAlertView *alter = [[CustomAlertView alloc] initWithTitle:@"请先进行登陆" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alter show];
                [alter release];
                return;
            }
            JDMySongViewController *mySongController = [[JDMySongViewController alloc] init];
            mySongController.navigationController_return = _navigationController_return;
            if(_revealSideViewController.rootViewController)
            {
                [_revealSideViewController.rootViewController release];
            }
            [_revealSideViewController setRootViewController:mySongController];
            [mySongController release];
            [self configureView_animetionInView_shrink];
            
        }break;
        case JDMenuButtonTag_account:
        {
            if(![[NSUserDefaults standardUserDefaults] objectForKey:@"token"])
            {
                CustomAlertView *alter = [[CustomAlertView alloc] initWithTitle:@"请先进行登陆" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alter show];
                [alter release];
                return;
            }
            
            ProductListViewController *productController = [[ProductListViewController alloc] init];
            if(_revealSideViewController.rootViewController)
            {
                [_revealSideViewController.rootViewController release];
            }
            [_revealSideViewController setRootViewController:productController];
            [productController release];
            [self configureView_animetionInView_shrink];
            
        }break;
        case JDMenuButtonTag_request:
        {
            JDMainViewController *mainViewController = [[JDMainViewController alloc] init];
            mainViewController.navigationController_return = _navigationController_return;
            
            if(_revealSideViewController.rootViewController)
            {
                [_revealSideViewController.rootViewController release];
            }
            [_revealSideViewController setRootViewController:mainViewController];
            [mainViewController release];
            [self configureView_animetionInView_shrink];
        }break;
        default:
            break;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



@end
