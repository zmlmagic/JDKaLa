//
//  JDUserLoginView.m
//  JDKaLa
//
//  Created by zhangminglei on 6/13/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDUserLoginView.h"
#import "UIUtils.h"
#import "ClientAgent.h"
#import "UIDevice+IdentifierAddition.h"
#import "JDModel_userInfo.h"
#import <QuartzCore/QuartzCore.h>
#import "CustomAlertView.h"
#import "JDMasterViewController.h"

typedef enum
{
    JDUserLoginViewButtonTag_login   =  0,
    JDUserLoginViewButtonTag_recive      ,
    JDUserLoginViewButtonTag_back        ,
    JDUserLoginViewButtonTag_XL          ,
    JDUserLoginViewButtonTag_QQ          ,
    JDUserLoginViewButtonTag_RR          ,
    JDUserLoginViewButtonTag_1s          ,
    
}JDUserLoginViewButtonTag;

#pragma mark - JDUserLoginViewController -

@interface JDBackgroundView : UIView

@property (nonatomic, assign) AlertViewBackgroundStyle style;

@end

@implementation JDBackgroundView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    switch (self.style)
    {
        case AlertViewBackgroundStyleGradient:
        {
            size_t locationsCount = 2;
            CGFloat locations[2] = {0.0f, 1.0f};
            CGFloat colors[8] = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.75f};
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
            CGColorSpaceRelease(colorSpace);
            
            CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
            CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) ;
            CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
            CGGradientRelease(gradient);
            break;
        }
        case AlertViewBackgroundStyleSolid:
        {
            [[UIColor colorWithWhite:0 alpha:0.5] set];
            CGContextFillRect(context, self.bounds);
            break;
        }
    }
}

@end

@implementation JDUserLoginView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.transitionStyle = AlertViewTransitionStyleBounce;
        
        JDBackgroundView *view_back = [[JDBackgroundView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        [view_back setBackgroundColor:[UIColor clearColor]];
        [view_back setStyle:AlertViewBackgroundStyleGradient];
        [self addSubview:view_back];
        [view_back release];
        _view_background = view_back;
     
        UIView *view_con = [[UIView alloc] initWithFrame:CGRectMake(287, 154, 450, 300)];
        [self addSubview:view_con];
        view_con.layer.shadowColor = [UIColor blackColor].CGColor;
        view_con.layer.shadowOffset = CGSizeMake(10, 10);
        view_con.layer.shadowOpacity = 0.5;
        view_con.layer.shadowRadius = 2.0;
        [view_con release];
        _view_content = view_con;
        
        UIImageView *imageView_back = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 450, 300)];
        [UIUtils didLoadImageNotCached:@"alter_back.png" inImageView:imageView_back];
        [view_con addSubview:imageView_back];
        [imageView_back release];
        
        UIButton *button_back = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_back setFrame:CGRectMake(10, 7, 65, 37)];
        [UIUtils didLoadImageNotCached:@"back_btn.png" inButton:button_back withState:UIControlStateNormal];
        [button_back setTag:JDUserLoginViewButtonTag_back];
        [button_back addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [view_con addSubview:button_back];
        
        UILabel *label_titel = [[UILabel alloc]initWithFrame:CGRectMake(120, 0, 200, 50)];
        [label_titel setBackgroundColor:[UIColor clearColor]];
        [label_titel setTextAlignment:NSTextAlignmentCenter];
        label_titel.font = [UIFont fontWithName:@"Helvetica-Bold" size:25];
        [label_titel setTextColor:[UIColor whiteColor]];
        [label_titel setText:@"登入"];
        [view_con addSubview:label_titel];
        [label_titel release];
        
        UIImageView *imageView_userName = [[UIImageView alloc] initWithFrame:CGRectMake(35, 78, 62, 26)];
        [UIUtils didLoadImageNotCached:@"login_text_username.png" inImageView:imageView_userName];
        [view_con addSubview:imageView_userName];
        [imageView_userName release];
        
        UIImageView *imageView_testUserName = [[UIImageView alloc] initWithFrame:CGRectMake(115, 72, 294, 40)];
        [UIUtils didLoadImageNotCached:@"search_field.png" inImageView:imageView_testUserName];
        [view_con addSubview:imageView_testUserName];
        [imageView_testUserName release];
        
        UITextField *text_userName = [[UITextField alloc] initWithFrame:CGRectMake(130, 83, 280, 22)];
        [text_userName setBackgroundColor:[UIColor clearColor]];
        [text_userName setTextColor:[UIColor grayColor]];
        [text_userName setFont:[UIFont fontWithName:@"Helvetica" size:15]];
        [text_userName setDelegate:self];
        [text_userName setKeyboardType:UIKeyboardTypeEmailAddress];
        [text_userName setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [text_userName setClearButtonMode:UITextFieldViewModeWhileEditing];
        [text_userName setPlaceholder:@"请填写您注册时所用的邮箱"];
        [text_userName setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]];
        [view_con addSubview:text_userName];
        [text_userName release];
        _textField_userName = text_userName;
        
        
        if([[NSUserDefaults standardUserDefaults] objectIsForcedForKey:@"userName"])
        {
            [text_userName setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]];
        }
        
        
        UIImageView *imageView_pass = [[UIImageView alloc] initWithFrame:CGRectMake(35, 128, 44, 26)];
        [UIUtils didLoadImageNotCached:@"login_text_password.png" inImageView:imageView_pass];
        [view_con addSubview:imageView_pass];
        [imageView_pass release];
        
        UIImageView *imageView_testPass = [[UIImageView alloc] initWithFrame:CGRectMake(115, 122, 294, 40)];
        [UIUtils didLoadImageNotCached:@"search_field.png" inImageView:imageView_testPass];
        [view_con addSubview:imageView_testPass];
        [imageView_testPass release];
        
        UITextField *text_pass = [[UITextField alloc] initWithFrame:CGRectMake(130, 133, 280, 22)];
        [text_pass setBackgroundColor:[UIColor clearColor]];
        [text_pass setTextColor:[UIColor grayColor]];
        [text_pass setSecureTextEntry:YES];
        [text_pass setKeyboardType:UIKeyboardTypeNumberPad];
        [text_pass setClearButtonMode:UITextFieldViewModeWhileEditing];
        [text_pass setDelegate:self];
        [view_con addSubview:text_pass];
        [text_pass release];
        _textField_passWord = text_pass;
        
        UIButton *button_login = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_login setFrame:CGRectMake(110, 180, 120, 35)];
        [UIUtils didLoadImageNotCached:@"user_profile_btn_login.png" inButton:button_login withState:UIControlStateNormal];
        [button_login setTag:JDUserLoginViewButtonTag_login];
        [button_login addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [view_con addSubview:button_login];
        
        UILabel *label_alter = [[UILabel alloc] initWithFrame:CGRectMake(240, 182, 80, 30)];
        [label_alter setBackgroundColor:[UIColor clearColor]];
        [label_alter setTextColor:[UIColor colorWithWhite:0.8 alpha:0.7]];
        [label_alter setFont:[UIFont fontWithName:@"Helvetica-Bold"size:15]];
        [label_alter setText:@"忘记密码?"];
        [view_con addSubview:label_alter];
        [label_alter release];
        
        UIButton *button_recive = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_recive setFrame:CGRectMake(315, 183, 100, 30)];
        [button_recive setBackgroundColor:[UIColor clearColor]];
        [button_recive setTitleColor:[UIColor colorWithWhite:0.8 alpha:0.7] forState:UIControlStateNormal];
        [button_recive setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [button_recive.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold"size:15]];
        [button_recive setTitle:@"点击这里找回" forState:UIControlStateNormal];
        [button_recive setTag:JDUserLoginViewButtonTag_recive];
        [button_recive addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [view_con addSubview:button_recive];
        
        /*UIImageView *imageView_other = [[UIImageView alloc] initWithFrame:CGRectMake(35, 253, 91, 22)];
        [UIUtils didLoadImageNotCached:@"login_text_other_account.png" inImageView:imageView_other];
        [view_con addSubview:imageView_other];
        [imageView_other release];
        
        UIButton *button_XL = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_XL setFrame:CGRectMake(133, 245, 38, 37)];
        [UIUtils didLoadImageNotCached:@"login_icon_weibo.png" inButton:button_XL withState:UIControlStateNormal];
        [button_XL setTag:JDUserLoginViewButtonTag_XL];
        [button_XL addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [view_con addSubview:button_XL];
        
        UIButton *button_QQ = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_QQ setFrame:CGRectMake(181, 245, 38, 37)];
        [UIUtils didLoadImageNotCached:@"login_icon_tencent.png" inButton:button_QQ withState:UIControlStateNormal];
        [button_QQ setTag:JDUserLoginViewButtonTag_QQ];
        [button_QQ addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [view_con addSubview:button_QQ];
        
        UIButton *button_RR = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_RR setFrame:CGRectMake(229, 245, 38, 37)];
        [UIUtils didLoadImageNotCached:@"login_icon_renren.png" inButton:button_RR withState:UIControlStateNormal];
        [button_RR setTag:JDUserLoginViewButtonTag_RR];
        [button_RR addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [view_con addSubview:button_RR];*/
        
        UIButton *button_1s = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_1s setFrame:CGRectMake(170, 245, 120, 35)];
        [UIUtils didLoadImageNotCached:@"user_profile_btn_registration_1s.png" inButton:button_1s withState:UIControlStateNormal];
        [button_1s setTag:JDUserLoginViewButtonTag_1s];
        [button_1s addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
        [view_con addSubview:button_1s];
    }
    return self;
}


#pragma mark - 点击按钮回调 -
/**
 点击按钮回调
 **/
- (void)didClickButton:(id)sender
{
    UIButton *button_tag = (UIButton *)sender;
    switch (button_tag.tag)
    {
        case JDUserLoginViewButtonTag_recive:
        {
            
            UIView *view_recive_c = [[UIView alloc] initWithFrame:CGRectMake(_view_content.frame.origin.x, _view_content.frame.origin.y + _view_content.frame.size.height, 450, 150)];
            [view_recive_c setBackgroundColor:[UIColor clearColor]];
            [self addSubview:view_recive_c];
            [view_recive_c release];
            _view_recive = view_recive_c;
            
            UIImageView *imageView_recive = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 450, 150)];
            [UIUtils didLoadImageNotCached:@"reciveBack.png" inImageView:imageView_recive];
            [view_recive_c addSubview:imageView_recive];
            [imageView_recive release];
            
            UILabel *label_title = [[UILabel alloc] initWithFrame:CGRectMake(25, 10, 100, 20)];
            [label_title setBackgroundColor:[UIColor clearColor]];
            [label_title setTextColor:[UIColor colorWithWhite:0.8 alpha:0.7]];
            [label_title setFont:[UIFont fontWithName:@"Helvetica-Bold"size:15]];
            [label_title setText:@"找回密码"];
            [imageView_recive addSubview:label_title];
            [label_title release];
    
            UIImageView *imageView_testPass = [[UIImageView alloc] initWithFrame:CGRectMake(25, 40, 400, 40)];
            [UIUtils didLoadImageNotCached:@"search_field.png" inImageView:imageView_testPass];
            [imageView_recive addSubview:imageView_testPass];
            [imageView_testPass release];
            
            UITextField *text_pass = [[UITextField alloc] initWithFrame:CGRectMake(40, 50, 350, 40)];
            [text_pass setBackgroundColor:[UIColor clearColor]];
            [text_pass setTextColor:[UIColor grayColor]];
            [text_pass setFont:[UIFont fontWithName:@"Helvetica" size:15]];
            [text_pass setPlaceholder:@"请填写您注册时所用的邮箱"];
            [text_pass setKeyboardType:UIKeyboardTypeNumberPad];
            [text_pass setDelegate:self];
            [view_recive_c addSubview:text_pass];
            [text_pass release];
            
            UIButton *button_registration = [UIButton buttonWithType:UIButtonTypeCustom];
            [button_registration setFrame:CGRectMake(185, 100, 80, 35)];
            [UIUtils didLoadImageNotCached:@"user_profile_btn_done_small(1).png" inButton:button_registration withState:UIControlStateNormal];
            [button_registration addTarget:self action:@selector(didClickButton_recive:) forControlEvents:UIControlEventTouchUpInside];
            [view_recive_c addSubview:button_registration];
   
        }break;
        case JDUserLoginViewButtonTag_login:
        {
            if([[_textField_userName text] length] == 0 ||
               [[_textField_passWord text] length] == 0)
            {
                [UIUtils view_showProgressHUD:@"请填写完整的登陆信息" inView:self withTime:2.0f];
                return;
            }
            else
            {
                [_clientAgent_resgist login:[_textField_userName text] Password:[_textField_passWord text] Version:@"iPad-1.0" DevID:[[UIDevice currentDevice]uniqueGlobalDeviceIdentifier]];
                
                [JDModel_userInfo sharedModel].string_userName = _textField_userName.text;
                [JDModel_userInfo sharedModel].string_userPass = _textField_passWord.text;
                [JDModel_userInfo sharedModel].string_version = @"iPad-1.0";
                [JDModel_userInfo sharedModel].string_device = [[UIDevice currentDevice]uniqueGlobalDeviceIdentifier];
                
            }
        }break;
            
        case JDUserLoginViewButtonTag_1s:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"JDUserLoginView_1s" object:nil];
            [self dismissAnimated];
            
        }break;
        
        case JDUserLoginViewButtonTag_back:
        {
         
            [self dismissAnimated];
        }
            
        default:
            break;
    }
}

#pragma mark - 点击找回密码按钮 -
- (void)didClickButton_recive:(id)sender
{
    CustomAlertView *alter = [[CustomAlertView alloc]initWithTitle:@"暂未开通此功能"
                                                           message:nil
                                                          delegate:nil
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil];
    [alter show];
    [alter release];
}


#pragma mark -
#pragma mark UITextFieldDelegate
#pragma mark - 键盘开始输入 -
/**
 键盘开始输入
 **/
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(_view_content.center.y >= 304.0)
    {
        if(_view_recive)
        {
            [_view_recive setCenter:CGPointMake(_view_recive.center.x, _view_recive.center.y - 160)];
            [_view_content setCenter:CGPointMake(_view_content.center.x, _view_content.center.y - 160)];
        }
        else
        {
            [_view_content setCenter:CGPointMake(_view_content.center.x, _view_content.center.y - 80)];
        }
    }
}

#pragma mark - 键盘结束输入 -
/**
 键盘结束输入
 **/
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(_view_content.center.y < 304.0)
    {
        if(_view_recive)
        {
            [_view_recive setCenter:CGPointMake(_view_recive.center.x, _view_recive.center.y + 160)];
            [_view_content setCenter:CGPointMake(_view_content.center.x, _view_content.center.y + 160)];
        }
        else
        {
            [_view_content setCenter:CGPointMake(_view_content.center.x, _view_content.center.y + 80)];
        }
    }
}

#pragma mark - 键盘点击return -
/**
 键盘点击return
 **/
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(_view_content.center.y < 304.0)
    {
        if(_view_recive)
        {
            [_view_recive setCenter:CGPointMake(_view_recive.center.x, _view_recive.center.y + 160)];
            [_view_content setCenter:CGPointMake(_view_content.center.x, _view_content.center.y + 160)];
        }
        else
        {
            [_view_content setCenter:CGPointMake(_view_content.center.x, _view_content.center.y + 80)];
        }
    }
    return YES;
}

#pragma mark - 弹出视图 -
/**
 弹出视图
 **/
- (void)showAnimated
{
    void (^dismissComplete)(void) = ^{
        
        
        
    };
    
    [self transitionInCompletion:dismissComplete];
    [self showBackgroundAnimated];
}


#pragma mark - 收回视图 -
/**
 收回视图
 **/
- (void)dismissAnimated
{
    void (^dismissComplete)(void) = ^{
        //_view_content = nil;
        //_view_recive = nil;
    
    };
    
    [self transitionOutCompletion:dismissComplete];
    [self hideBackgroundAnimated];
    
}


#pragma mark - 弹出动画 - 
- (void)showBackgroundAnimated
{
    _view_background.alpha = 0;
    [UIView animateWithDuration:0.3
                    animations:^{
                             _view_background.alpha = 1;
                    }];
    
}

#pragma mark - 隐藏动画 -
/**
 隐藏动画
 **/
- (void)hideBackgroundAnimated
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         _view_background.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [_view_background removeFromSuperview];
                         [self removeFromSuperview];
                     }];
}

#pragma  mark - in动画 -
/**
 in动画
 **/
- (void)transitionInCompletion:(void(^)(void))completion
{
    switch (self.transitionStyle) {
        case AlertViewTransitionStyleSlideFromBottom:
        {
            CGRect rect = _view_content.frame;
            CGRect originalRect = rect;
            rect.origin.y = self.bounds.size.height;
            _view_content.frame = rect;
            [UIView animateWithDuration:0.3
                             animations:^{
                                 _view_content.frame = originalRect;
                             }
                             completion:^(BOOL finished) {
                                 if (completion) {
                                     completion();
                                 }
                             }];
        }
            break;
        case AlertViewTransitionStyleSlideFromTop:
        {
            CGRect rect = _view_content.frame;
            CGRect originalRect = rect;
            rect.origin.y = -rect.size.height;
            _view_content.frame = rect;
            [UIView animateWithDuration:0.3
                             animations:^{
                                 _view_content.frame = originalRect;
                             }
                             completion:^(BOOL finished) {
                                 if (completion) {
                                     completion();
                                 }
                             }];
        }
            break;
        case AlertViewTransitionStyleFade:
        {
            _view_content.alpha = 0;
            [UIView animateWithDuration:0.3
                             animations:^{
                                 _view_content.alpha = 1;
                             }
                             completion:^(BOOL finished) {
                                 if (completion) {
                                     completion();
                                 }
                             }];
        }
            break;
        case AlertViewTransitionStyleBounce:
        {
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
            animation.values = @[@(0.01), @(1.2), @(0.9), @(1)];
            animation.keyTimes = @[@(0), @(0.4), @(0.6), @(1)];
            animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            animation.duration = 0.5;
            [animation setValue:completion forKey:@"handler"];
            [_view_content.layer addAnimation:animation forKey:@"bouce"];
        }
            break;
        case AlertViewTransitionStyleDropDown:
        {
            CGFloat y = _view_content.center.y;
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
            animation.values = @[@(y - self.bounds.size.height), @(y + 20), @(y - 10), @(y)];
            animation.keyTimes = @[@(0), @(0.5), @(0.75), @(1)];
            animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            animation.duration = 0.4;
            [animation setValue:completion forKey:@"handler"];
            [_view_content.layer addAnimation:animation forKey:@"dropdown"];
        }
            break;
        default:
            break;
    }
}


#pragma  mark - out动画 -
/**
 out动画
 **/
- (void)transitionOutCompletion:(void(^)(void))completion
{
    switch (self.transitionStyle) {
        case AlertViewTransitionStyleSlideFromBottom:
        {
            CGRect rect = _view_content.frame;
            rect.origin.y = self.bounds.size.height;
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 _view_content.frame = rect;
                             }
                             completion:^(BOOL finished) {
                                 if (completion) {
                                     completion();
                                 }
                             }];
        }break;
        case AlertViewTransitionStyleSlideFromTop:
        {
            CGRect rect = _view_content.frame;
            rect.origin.y = -rect.size.height;
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 _view_content.frame = rect;
                             }
                             completion:^(BOOL finished) {
                                 if (completion) {
                                     completion();
                                 }
                             }];
        }
            break;
        case AlertViewTransitionStyleFade:
        {
            [UIView animateWithDuration:0.25
                             animations:^{
                                 _view_content.alpha = 0;
                             }
                             completion:^(BOOL finished) {
                                 if (completion) {
                                     completion();
                                 }
                             }];
        }
            break;
        case AlertViewTransitionStyleBounce:
        {
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
            animation.values = @[@(1), @(1.2), @(0.01)];
            animation.keyTimes = @[@(0), @(0.4), @(1)];
            animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            animation.duration = 0.35;
            [animation setValue:completion forKey:@"handler"];
            [_view_content.layer addAnimation:animation forKey:@"bounce"];
            
            _view_content.transform = CGAffineTransformMakeScale(0.01, 0.01);
        }
            break;
        case AlertViewTransitionStyleDropDown:
        {
            CGPoint point = _view_content.center;
            point.y += self.bounds.size.height;
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 _view_content.center = point;
                                 CGFloat angle = ((CGFloat)arc4random_uniform(100) - 50.f) / 100.f;
                                 _view_content.transform = CGAffineTransformMakeRotation(angle);
                             }
                             completion:^(BOOL finished) {
                                 if (completion) {
                                     completion();
                                 }
                             }];
        }break;
        default:
            break;
    }
}



@end
