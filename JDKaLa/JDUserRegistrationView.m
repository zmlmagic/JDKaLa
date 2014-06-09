//
//  JDUserRegistrationView.m
//  JDKaLa
//
//  Created by zhangminglei on 6/14/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDUserRegistrationView.h"
#import "UIUtils.h"
#import "ClientAgent.h"
#import "JDModel_user.h"
#import "UIDevice+IdentifierAddition.h"
#import "CustomAlertView.h"
#import "JDModel_userInfo.h"
#import <QuartzCore/QuartzCore.h>
#import "JDMasterViewController.h"

#pragma mark - JDBackgroundView -

@interface JDBackgroundView_registration : UIView

@end

@implementation JDBackgroundView_registration
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
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
}

@end


typedef enum
{
    JDUserRegistrationView_userName   = 30,
    JDUserRegistrationView_passWord       ,
    JDUserRegistrationView_passAgain      ,
    JDUserRegistrationView_petName        ,
    JDUserRegistrationView_back           ,
    JDUserRegistrationView_yaoqingma      ,
}JDUserRegistrationView_Tag;

@implementation JDUserRegistrationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(handleValidateUserName:)
                                                    name:NOTI_VALIDATE_USERNAME_RESULT
                                                  object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleValidateNickName:)
                                                     name:NOTI_VALIDATE_NICKNAME_RESULT
                                                   object:nil];
        
        [self installView];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
                  name:NOTI_VALIDATE_USERNAME_RESULT
                object:nil];
    [[NSNotificationCenter defaultCenter]
        removeObserver:self
                    name:NOTI_VALIDATE_NICKNAME_RESULT
                object:nil];
   
    [super dealloc];
}

- (void)installView
{
    JDBackgroundView_registration *view_back = [[JDBackgroundView_registration alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [view_back setBackgroundColor:[UIColor clearColor]];
    [self addSubview:view_back];
    [view_back release];
    _view_background = view_back;
    
    UIView *view_con = [[UIView alloc] initWithFrame:CGRectMake(287, 154, 450, 385)];
    view_con.layer.shadowColor = [UIColor blackColor].CGColor;
    view_con.layer.shadowOffset = CGSizeMake(10, 10);
    view_con.layer.shadowOpacity = 0.5;
    view_con.layer.shadowRadius = 2.0;
    [self addSubview:view_con];
    [view_con release];
    _view_content = view_con;
    
    UIImageView *imageView_back = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 450, 385)];
    [UIUtils didLoadImageNotCached:@"alter_back_r.png" inImageView:imageView_back];
    [view_con addSubview:imageView_back];
    [imageView_back release];
    
    UIButton *button_back = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_back setFrame:CGRectMake(10, 7, 65, 37)];
    [UIUtils didLoadImageNotCached:@"back_btn.png" inButton:button_back withState:UIControlStateNormal];
    [button_back addTarget:self action:@selector(didClickButton_back) forControlEvents:UIControlEventTouchUpInside];
    [view_con addSubview:button_back];
    
    UILabel *label_titel = [[UILabel alloc]initWithFrame:CGRectMake(120, 0, 200, 50)];
    [label_titel setBackgroundColor:[UIColor clearColor]];
    [label_titel setTextAlignment:NSTextAlignmentCenter];
    label_titel.font = [UIFont fontWithName:@"Helvetica-Bold" size:25];
    [label_titel setTextColor:[UIColor whiteColor]];
    [label_titel setText:@"注册"];
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
    
    UITextField *text_userName = [[UITextField alloc] initWithFrame:CGRectMake(130, 82, 280, 22)];
    [text_userName setBackgroundColor:[UIColor clearColor]];
    [text_userName setTextColor:[UIColor grayColor]];
    [text_userName setClearButtonMode:UITextFieldViewModeWhileEditing];
    [text_userName setDelegate:self];
    [text_userName setKeyboardType:UIKeyboardTypeEmailAddress];
    [text_userName setTag:JDUserRegistrationView_userName];
    [text_userName setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    [text_userName setDelegate:self];
    [text_userName setPlaceholder:@"请填写您的邮箱"];
    [view_con addSubview:text_userName];
    [text_userName release];
    _textField_userName = text_userName;
    
    UILabel *label_userName = [[UILabel alloc] initWithFrame:CGRectMake(360, 78, 50, 35)];
    [label_userName setBackgroundColor:[UIColor clearColor]];
    [view_con addSubview:label_userName];
    [label_userName release];
    _label_pointOut_userName = label_userName;
    
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
    [text_pass setClearButtonMode:UITextFieldViewModeWhileEditing];
    [text_pass setDelegate:self];
    [text_pass setSecureTextEntry:YES];
    [text_pass setReturnKeyType:UIReturnKeyDone];
    [text_pass setTag:JDUserRegistrationView_passWord];
    [text_pass setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    [text_pass setPlaceholder:@"请输入数字和字母组合(6-12)"];
    [text_pass setDelegate:self];
    [view_con addSubview:text_pass];
    [text_pass release];
    _textField_passWord = text_pass;
    
    UILabel *label_pass = [[UILabel alloc] initWithFrame:CGRectMake(360, 129, 50, 35)];
    [label_pass setBackgroundColor:[UIColor clearColor]];
    [view_con addSubview:label_pass];
    [label_pass release];
    _label_pointOut_passWord = label_pass;
    
    UIImageView *imageView_pass_right = [[UIImageView alloc] initWithFrame:CGRectMake(35, 178, 43, 25)];
    [UIUtils didLoadImageNotCached:@"user_profile_title_confirm.png" inImageView:imageView_pass_right];
    [view_con addSubview:imageView_pass_right];
    [imageView_pass_right release];
    
    UIImageView *imageView_testPass_right = [[UIImageView alloc] initWithFrame:CGRectMake(115, 172, 294, 40)];
    [UIUtils didLoadImageNotCached:@"search_field.png" inImageView:imageView_testPass_right];
    [view_con addSubview:imageView_testPass_right];
    [imageView_testPass_right release];
    
    UITextField *text_pass_right = [[UITextField alloc] initWithFrame:CGRectMake(130, 183, 280, 22)];
    [text_pass_right setBackgroundColor:[UIColor clearColor]];
    [text_pass_right setDelegate:self];
    [text_pass_right setTag:JDUserRegistrationView_passAgain];
    [text_pass_right setTextColor:[UIColor grayColor]];
    [text_pass_right setClearButtonMode:UITextFieldViewModeWhileEditing];
    [text_pass_right setSecureTextEntry:YES];
    [text_pass_right setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    [text_pass_right setPlaceholder:@"请输保持与输入密码一致"];
    [text_pass_right setDelegate:self];
    [view_con addSubview:text_pass_right];
    [text_pass_right release];
    _textField_passAgain = text_pass_right;
    
    UILabel *label_passAgain = [[UILabel alloc] initWithFrame:CGRectMake(360, 179, 50, 35)];
    [label_passAgain setBackgroundColor:[UIColor clearColor]];
    [view_con addSubview:label_passAgain];
    [label_passAgain release];
    _label_pointOut_passAgain = label_passAgain;
    
    /*UIImageView *imageView_yaoqingma = [[UIImageView alloc] initWithFrame:CGRectMake(35, 228, 59, 27)];
    [UIUtils didLoadImageNotCached:@"button_renzheng.png" inImageView:imageView_yaoqingma];
    [view_con addSubview:imageView_yaoqingma];
    [imageView_yaoqingma release];
    
    UIImageView *imageView_yaoqingma_right = [[UIImageView alloc] initWithFrame:CGRectMake(115, 222, 150, 40)];
    [UIUtils didLoadImageNotCached:@"search_field.png" inImageView:imageView_yaoqingma_right];
    [view_con addSubview:imageView_yaoqingma_right];
    [imageView_yaoqingma_right release];
    
    UITextField *text_yaoqingma_right = [[UITextField alloc] initWithFrame:CGRectMake(130, 233, 130, 22)];
    [text_yaoqingma_right setBackgroundColor:[UIColor clearColor]];
    [text_yaoqingma_right setDelegate:self];
    [text_yaoqingma_right setTag:JDUserRegistrationView_yaoqingma];
    [text_yaoqingma_right setTextColor:[UIColor grayColor]];
    [text_yaoqingma_right setClearButtonMode:UITextFieldViewModeWhileEditing];
    [text_yaoqingma_right setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    [text_yaoqingma_right setPlaceholder:@"如没有请申请"];
    [text_yaoqingma_right setDelegate:self];
    [view_con addSubview:text_yaoqingma_right];
    [text_yaoqingma_right release];
    _textField_yaoqingma = text_yaoqingma_right;
    
    UIButton *button_yaoqingma = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_yaoqingma setFrame:CGRectMake(270, 225, 150, 35)];
    [UIUtils didLoadImageNotCached:@"registration_popup_btn_code.png" inButton:button_yaoqingma withState:UIControlStateNormal];
    [button_yaoqingma addTarget:self action:@selector(didClickButton_yaoqingma) forControlEvents:UIControlEventTouchUpInside];
    [view_con addSubview:button_yaoqingma];*/
    
    
    /*UIImageView *imageView_petName = [[UIImageView alloc] initWithFrame:CGRectMake(35, 228, 44, 26)];
     [UIUtils didLoadImageNotCached:@"user_profile_title_nickname.png" inImageView:imageView_petName];
     [self addSubview:imageView_petName];
     [imageView_petName release];
     
     UIImageView *imageView_textPetName= [[UIImageView alloc] initWithFrame:CGRectMake(115, 222, 294, 40)];
     [UIUtils didLoadImageNotCached:@"search_field.png" inImageView:imageView_textPetName];
     [self addSubview:imageView_textPetName];
     [imageView_textPetName release];
     
     UITextField *text_petName = [[UITextField alloc] initWithFrame:CGRectMake(130, 233, 280, 22)];
     [text_petName setDelegate:self];
     [text_petName setBackgroundColor:[UIColor clearColor]];
     [text_petName setTextColor:[UIColor grayColor]];
     [text_petName setReturnKeyType:UIReturnKeyDone];
     [text_petName setTag:JDUserRegistrationView_petName];
     [text_petName setClearButtonMode:UITextFieldViewModeWhileEditing];
     [text_petName setPlaceholder:@"选填,为空系统为您提供默认昵称"];
     [text_petName setFont:[UIFont fontWithName:@"Helvetica" size:15]];
     [text_petName setDelegate:self];
     [self addSubview:text_petName];
     [text_petName release];
     _textField_userPet = text_petName;
     
     UILabel *label_petName = [[UILabel alloc] initWithFrame:CGRectMake(360, 229, 50, 35)];
     [label_petName setBackgroundColor:[UIColor clearColor]];
     [label_petName setTextColor:[UIColor greenColor]];
     [label_petName setFont:[UIFont systemFontOfSize:30.0]];
     [label_petName setTextAlignment:NSTextAlignmentCenter];
     [label_petName setText:@"✓"];
     [self addSubview:label_petName];
     [label_petName release];
     _label_pointOut_petName = label_petName;*/
    
    UIButton *button_registration = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_registration setFrame:CGRectMake(165, 325, 120, 35)];
    [UIUtils didLoadImageNotCached:@"user_profile_btn_done.png" inButton:button_registration withState:UIControlStateNormal];
    [button_registration addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
    [view_con addSubview:button_registration];
}

- (void)didChangeView
{
    //[self setBackgroundColor:[UIColor clearColor]];
    for (UIView *v in self.subviews)
    {
        if ([v isKindOfClass:[UIImageView class]])
        {
            
        }
        if ([v isKindOfClass:NSClassFromString(@"UIAlertButton")])
        {
            
        }
    }
}


#pragma mark - 点击获取邀请码 -
/**
 点击获取邀请码
 **/
- (void)didClickButton_yaoqingma
{
    UIView *view_yaoqingma = [[UIView alloc] initWithFrame:CGRectMake(1024, 0, 450, 385)];
    [_view_content addSubview:view_yaoqingma];
    [view_yaoqingma setBackgroundColor:[UIColor blackColor]];
    [view_yaoqingma release];
    
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 450, 385)];
    [view_yaoqingma addSubview:imageV];
    [UIUtils didLoadImageNotCached:@"alter_back_r.png" inImageView:imageV];
    [imageV release];
   
    UIButton *button_return = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_return setFrame:CGRectMake(10, 7, 65, 37)];
    [UIUtils didLoadImageNotCached:@"back_btn.png" inButton:button_return withState:UIControlStateNormal];
    [button_return addTarget:self action:@selector(didClickBUtton_return) forControlEvents:UIControlEventTouchUpInside];
    [view_yaoqingma addSubview:button_return];
    
    UILabel *label_titel = [[UILabel alloc]initWithFrame:CGRectMake(120, 0, 200, 50)];
    [label_titel setBackgroundColor:[UIColor clearColor]];
    [label_titel setTextAlignment:NSTextAlignmentCenter];
    label_titel.font = [UIFont fontWithName:@"Helvetica-Bold" size:25];
    [label_titel setTextColor:[UIColor whiteColor]];
    [label_titel setText:@"申请邀请码"];
    [view_yaoqingma addSubview:label_titel];
    [label_titel release];
    
    UILabel *label_name = [[UILabel alloc] initWithFrame:CGRectMake(35, 78, 62, 26)];
    [label_name setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:18.0f]];
    [label_name setBackgroundColor:[UIColor clearColor]];
    [label_name setTextColor:[UIColor blackColor]];
    [label_name setText:@"姓名"];
    [view_yaoqingma addSubview:label_name];
    [label_name release];
    
    UIImageView *imageView_testUserName = [[UIImageView alloc] initWithFrame:CGRectMake(115, 72, 294, 40)];
    [UIUtils didLoadImageNotCached:@"search_field.png" inImageView:imageView_testUserName];
    [view_yaoqingma addSubview:imageView_testUserName];
    [imageView_testUserName release];
    
    UITextField *text_userName = [[UITextField alloc] initWithFrame:CGRectMake(130, 82, 280, 22)];
    [text_userName setBackgroundColor:[UIColor clearColor]];
    [text_userName setTextColor:[UIColor grayColor]];
    [text_userName setClearButtonMode:UITextFieldViewModeWhileEditing];
    [text_userName setDelegate:self];
    [text_userName setKeyboardType:UIKeyboardTypeEmailAddress];
    [text_userName setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    [text_userName setDelegate:self];
    [text_userName setPlaceholder:@"请填写您的真实姓名"];
    [view_yaoqingma addSubview:text_userName];
    [text_userName release];
    _textField_yName = text_userName;
    
    UILabel *label_phone = [[UILabel alloc] initWithFrame:CGRectMake(35, 128, 44, 26)];
    [label_phone setBackgroundColor:[UIColor clearColor]];
    [label_phone setTextColor:[UIColor blackColor]];
    [label_phone setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:18.0f]];
    [label_phone setText:@"手机"];
    [view_yaoqingma addSubview:label_phone];
    [label_phone release];
    
    UIImageView *imageView_testPass = [[UIImageView alloc] initWithFrame:CGRectMake(115, 122, 294, 40)];
    [UIUtils didLoadImageNotCached:@"search_field.png" inImageView:imageView_testPass];
    [view_yaoqingma addSubview:imageView_testPass];
    [imageView_testPass release];
    
    UITextField *text_pass = [[UITextField alloc] initWithFrame:CGRectMake(130, 133, 280, 22)];
    [text_pass setBackgroundColor:[UIColor clearColor]];
    [text_pass setTextColor:[UIColor grayColor]];
    [text_pass setClearButtonMode:UITextFieldViewModeWhileEditing];
    [text_pass setDelegate:self];
    //[text_pass setReturnKeyType:UIReturnKeyDone];
    [text_pass setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    [text_pass setPlaceholder:@"请输入您的电话"];
    [view_yaoqingma addSubview:text_pass];
    [text_pass release];
    _textField_yphone = text_pass;
    
    UILabel *label_email = [[UILabel alloc] initWithFrame:CGRectMake(20, 178, 83, 25)];
    [label_email setBackgroundColor:[UIColor clearColor]];
    [label_email setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:18.0f]];
    [label_email setTextColor:[UIColor blackColor]];
    [label_email setText:@"邮箱(必填)"];
    [view_yaoqingma addSubview:label_email];
    [label_email release];
    
    UIImageView *imageView_testPass_right = [[UIImageView alloc] initWithFrame:CGRectMake(115, 172, 294, 40)];
    [UIUtils didLoadImageNotCached:@"search_field.png" inImageView:imageView_testPass_right];
    [view_yaoqingma addSubview:imageView_testPass_right];
    [imageView_testPass_right release];
    
    UITextField *text_pass_right = [[UITextField alloc] initWithFrame:CGRectMake(130, 183, 280, 22)];
    [text_pass_right setBackgroundColor:[UIColor clearColor]];
    [text_pass_right setDelegate:self];
    [text_pass_right setTextColor:[UIColor grayColor]];
    [text_pass_right setClearButtonMode:UITextFieldViewModeWhileEditing];
    [text_pass_right setKeyboardType:UIKeyboardTypeEmailAddress];
    [text_pass_right setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    [text_pass_right setPlaceholder:@"请输入您的邮箱"];
    [text_pass_right setDelegate:self];
    [view_yaoqingma addSubview:text_pass_right];
    [text_pass_right release];
    _textField_yEemail = text_pass_right;
    
    UILabel *label_why = [[UILabel alloc] initWithFrame:CGRectMake(35, 228, 43, 25)];
    [label_why setBackgroundColor:[UIColor clearColor]];
    [label_why setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:18.0f]];
    [label_why setTextColor:[UIColor blackColor]];
    [label_why setText:@"原因"];
    [view_yaoqingma addSubview:label_why];
    [label_why release];
    
    UIImageView *imageView_why = [[UIImageView alloc] initWithFrame:CGRectMake(115, 222, 294, 40)];
    [UIUtils didLoadImageNotCached:@"search_field.png" inImageView:imageView_why];
    [view_yaoqingma addSubview:imageView_why];
    [imageView_why release];
    
    UITextField *text_why = [[UITextField alloc] initWithFrame:CGRectMake(130, 233, 280, 22)];
    [text_why setBackgroundColor:[UIColor clearColor]];
    [text_why setDelegate:self];
    [text_why setTextColor:[UIColor grayColor]];
    [text_why setClearButtonMode:UITextFieldViewModeWhileEditing];
    //[text_why setSecureTextEntry:YES];
    //[text_why setKeyboardType:UIKeyboardTypeNamePhonePad];
    [text_why setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    [text_why setPlaceholder:@"请输入您申请的原因"];
    [text_why setDelegate:self];
    [view_yaoqingma addSubview:text_why];
    [text_why release];
    _textField_yBecause = text_why;
    
    UIButton *button_registration = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_registration setFrame:CGRectMake(165, 325, 120, 35)];
    [UIUtils didLoadImageNotCached:@"user_profile_btn_done.png" inButton:button_registration withState:UIControlStateNormal];
    [button_registration addTarget:self action:@selector(didClickButtonFinish_yaoqingma) forControlEvents:UIControlEventTouchUpInside];
    [view_yaoqingma addSubview:button_registration];
    
    [UIUtils addViewWithAnimation:view_yaoqingma inCenterPoint:CGPointMake(view_yaoqingma.center.x - 1024, view_yaoqingma.center.y)];
    _view_yaoqingma = view_yaoqingma;
}

#pragma mark - 邀请码申请_返回按钮 -
/**
 邀请码申请_返回按钮
 **/
- (void)didClickBUtton_return
{
    [UIUtils removeViewWithAnimation:_view_yaoqingma inCenterPoint:CGPointMake(_view_yaoqingma.center.x + 1024, _view_yaoqingma.center.y) withBoolRemoveView:YES];
}

#pragma mark - 邀请码申请_提交申请按钮 -
/**
 邀请码申请_提交申请按钮
 **/
- (void)didClickButtonFinish_yaoqingma
{
    if(_textField_yEemail.text.length != 0)
    {
        [_clientAgent_resgist applyInviteCode:_textField_yEemail.text Name:_textField_yName.text Mobile:_textField_yphone.text Content:_textField_yBecause.text];
        [self dismissAnimated];
    }
    else
    {
        [UIUtils view_showProgressHUD:@"邮箱不能为空" inView:self withTime:0.5f];
    }
}

#pragma mark - 点击注册界面返回按钮 -
/**
 点击注册界面返回按钮
 **/
- (void)didClickButton_back
{
   
    [self dismissAnimated];
}

#pragma mark -
#pragma mark DidClickButton
- (void)didClickButton:(id)sender
{
    //[self validateUserName:[_textField_userName text]];
    [self validatePassWord];
    [self validatePassWordAgain];

    if([_textField_userName.text length] == 0 ||
       [_textField_passWord.text length] == 0)
    {
        [UIUtils view_showProgressHUD:@"请填写完整的注册信息" inView:self withTime:2.0f];
        return;
    }
    else
    {
        [_clientAgent_resgist register:_textField_userName.text Password:_textField_passWord.text Version:@"iPad-1.0" DevID:[[UIDevice currentDevice]uniqueGlobalDeviceIdentifier]];
        //[_clientAgent_resgist registerWithInviteCode:_textField_yaoqingma.text UserName:_textField_userName.text Password:_textField_passWord.text Version:@"iPad-1.0" DevID:[[UIDevice currentDevice]uniqueGlobalDeviceIdentifier]];
        
        [JDModel_userInfo sharedModel].string_userName = _textField_userName.text;
        [JDModel_userInfo sharedModel].string_userPass = _textField_passWord.text;
        [JDModel_userInfo sharedModel].string_version = @"iPad-1.0";
        [JDModel_userInfo sharedModel].string_device = [[UIDevice currentDevice]uniqueGlobalDeviceIdentifier];
        [self dismissAnimated];
    }
    
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
        [_view_content setCenter:CGPointMake(_view_content.center.x, _view_content.center.y - 80)];
    }
    
    switch (textField.tag)
    {
        case JDUserRegistrationView_userName:
        {
            [_label_pointOut_userName setText:nil];
        }break;
        case JDUserRegistrationView_passWord:
        {
            [_label_pointOut_passWord setText:nil];
        }break;
        case JDUserRegistrationView_passAgain:
        {
            [_label_pointOut_passAgain setText:nil];
        }break;
        case JDUserRegistrationView_petName:
        {
            [_label_pointOut_petName setText:nil];
        }break;
        
        default:
            break;
    }

}

#pragma mark - 键盘结束输入 -
/**
 键盘结束输入
 **/
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
        case JDUserRegistrationView_userName:
        {
            [self validateUserName:[textField text]];
        }break;
        case JDUserRegistrationView_passWord:
        {
            [self validatePassWord];
        }break;
        case JDUserRegistrationView_passAgain:
        {
            [self validatePassWordAgain];
        }break;
        case JDUserRegistrationView_petName:
        {
            [self validatePetName];
        }break;
        default:
            break;
    }
    
    if(_view_content.center.y < 304.0)
    {
        
        [_view_content setCenter:CGPointMake(_view_content.center.x, _view_content.center.y + 80)];
        
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
        [_view_content setCenter:CGPointMake(_view_content.center.x, _view_content.center.y + 80)];
    }
    return YES;
}

/**
 * 验证用户名的有效性
 */
- (void)validateUserName:(NSString *)_userName
{
    if([_userName length] == 0)
    {
        //[UIUtils view_showProgressHUD:@"用户名为空" inView:self withTime:1.5f];
        [_label_pointOut_userName setFrame:CGRectMake(345, 73, 60, 35)];
        [_label_pointOut_userName setTextColor:[UIColor redColor]];
        [_label_pointOut_userName setFont:[UIFont fontWithName:@"Helvetica" size:13]];
        [_label_pointOut_userName setBackgroundColor:[UIColor clearColor]];
        [_label_pointOut_userName setTextAlignment:NSTextAlignmentLeft];
        [_label_pointOut_userName setText:@"用户名空"];
    }
    else
    {
        [_clientAgent_resgist validateUserName:_userName];
    }
}

- (void)handleValidateUserName:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    if(0 == resultCode)
    {
        [_label_pointOut_userName setFrame:CGRectMake(360, 78, 50, 35)];
        [_label_pointOut_userName setTextColor:[UIColor greenColor]];
        [_label_pointOut_userName setFont:[UIFont systemFontOfSize:30.0]];
        [_label_pointOut_userName setTextAlignment:NSTextAlignmentCenter];
        [_label_pointOut_userName setText:@"✓"];
    }
    else if(2 == resultCode)
    {
        [UIUtils view_showProgressHUD:[state objectForKey:@"msg"] inView:self withTime:3.0f];
    }
    else
    {
        NSString *alther = [[state objectForKey:@"msg"] substringToIndex:3];
        if([alther isEqualToString:@"505"])
        {
            //[UIUtils view_showProgressHUD:@"用户名已存在" inView:self withTime:1.5f];
            [_label_pointOut_userName setFrame:CGRectMake(355, 73, 60, 35)];
            [_label_pointOut_userName setTextColor:[UIColor redColor]];
            [_label_pointOut_userName setFont:[UIFont fontWithName:@"Helvetica" size:13]];
            [_label_pointOut_userName setBackgroundColor:[UIColor clearColor]];
            [_label_pointOut_userName setTextAlignment:NSTextAlignmentLeft];
            [_label_pointOut_userName setText:@"已存在"];
        }
        else if([alther isEqualToString:@"506"])
        {
            //[UIUtils view_showProgressHUD:@"邮箱格式有误" inView:self withTime:1.5f];
            [_label_pointOut_userName setFrame:CGRectMake(345, 73, 60, 35)];
            [_label_pointOut_userName setTextColor:[UIColor redColor]];
            [_label_pointOut_userName setFont:[UIFont fontWithName:@"Helvetica" size:13]];
            [_label_pointOut_userName setBackgroundColor:[UIColor clearColor]];
            [_label_pointOut_userName setTextAlignment:NSTextAlignmentLeft];
            [_label_pointOut_userName setText:@"格式有误"];
        }
    }
}

/**
 密码不为空验证
 **/
- (void)validatePassWord
{
    if([[_textField_passWord text] length] != 0)
    {
        [_label_pointOut_passWord setFrame:CGRectMake(360, 129, 50, 35)];
        [_label_pointOut_passWord setTextColor:[UIColor greenColor]];
        [_label_pointOut_passWord setFont:[UIFont systemFontOfSize:30.0]];
        [_label_pointOut_passWord setTextAlignment:NSTextAlignmentCenter];
        [_label_pointOut_passWord setText:@"✓"];
    }
    else
    {
        //[UIUtils view_showProgressHUD:@"输入密码为空" inView:self withTime:1.5f];
        [_label_pointOut_passWord setFrame:CGRectMake(345, 124, 60, 35)];
        [_label_pointOut_passWord setTextColor:[UIColor redColor]];
        [_label_pointOut_passWord setFont:[UIFont fontWithName:@"Helvetica" size:13]];
        [_label_pointOut_passWord setBackgroundColor:[UIColor clearColor]];
        [_label_pointOut_passWord setTextAlignment:NSTextAlignmentLeft];
        [_label_pointOut_passWord setText:@"密码为空"];
    }
}



/**
 验证比对两次密码是否一致
 **/
- (void)validatePassWordAgain
{
    if([[_textField_passAgain text] length] == 0)
    {
        //[UIUtils view_showProgressHUD:@"输入为空" inView:self withTime:1.5f];
        [_label_pointOut_passAgain setFrame:CGRectMake(345, 174, 60, 35)];
        [_label_pointOut_passAgain setTextColor:[UIColor redColor]];
        [_label_pointOut_passAgain setFont:[UIFont fontWithName:@"Helvetica" size:13]];
        [_label_pointOut_passAgain setBackgroundColor:[UIColor clearColor]];
        [_label_pointOut_passAgain setTextAlignment:NSTextAlignmentLeft];
        [_label_pointOut_passAgain setText:@"密码为空"];
    }
    else
    {
        if([[_textField_passAgain text] isEqual:[_textField_passWord text]])
        {
            [_label_pointOut_passAgain setFrame:CGRectMake(360, 179, 50, 35)];
            [_label_pointOut_passAgain setTextColor:[UIColor greenColor]];
            [_label_pointOut_passAgain setFont:[UIFont systemFontOfSize:30.0]];
            [_label_pointOut_passAgain setTextAlignment:NSTextAlignmentCenter];
            [_label_pointOut_passAgain setText:@"✓"];
        }
        else
        {
            //[UIUtils view_showProgressHUD:@"与密码不一致" inView:self withTime:1.5f];
            [_label_pointOut_passAgain setFrame:CGRectMake(355, 174, 60, 35)];
            [_label_pointOut_passAgain setTextColor:[UIColor redColor]];
            [_label_pointOut_passAgain setFont:[UIFont fontWithName:@"Helvetica" size:13]];
            [_label_pointOut_passAgain setBackgroundColor:[UIColor clearColor]];
            [_label_pointOut_passAgain setTextAlignment:NSTextAlignmentLeft];
            [_label_pointOut_passAgain setText:@"不一致"];
        }
    }
}

/**
 验证昵称
 **/
- (void)validatePetName
{
    if([[_textField_userPet text] length] == 0)
    {
        [_label_pointOut_petName setFrame:CGRectMake(360, 229, 50, 35)];
        [_label_pointOut_petName setTextColor:[UIColor greenColor]];
        [_label_pointOut_petName setFont:[UIFont systemFontOfSize:30.0]];
        [_label_pointOut_petName setTextAlignment:NSTextAlignmentCenter];
        [_label_pointOut_petName setText:@"✓"];
    }
    else
    {
        [_clientAgent_resgist validateNickName:[_textField_userPet text]];
    }
}

- (void)handleValidateNickName:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    if(0 == resultCode)
    {
        [_label_pointOut_petName setFrame:CGRectMake(360, 229, 50, 35)];
        [_label_pointOut_petName setTextColor:[UIColor greenColor]];
        [_label_pointOut_petName setFont:[UIFont systemFontOfSize:30.0]];
        [_label_pointOut_petName setTextAlignment:NSTextAlignmentCenter];
        [_label_pointOut_petName setText:@"✓"];
    }
    else if(2 == resultCode)
    {
        [UIUtils view_showProgressHUD:[state objectForKey:@"msg"] inView:self withTime:3.0f];
    }
    else
    {
        NSString *alther = [[state objectForKey:@"msg"] substringToIndex:3];
        if([alther isEqualToString:@"511"])
        {
            [UIUtils view_showProgressHUD:@"昵称已存在" inView:self withTime:1.5f];
            [_label_pointOut_petName setFrame:CGRectMake(360, 224, 50, 35)];
            [_label_pointOut_petName setTextColor:[UIColor redColor]];
            [_label_pointOut_petName setFont:[UIFont fontWithName:@"Helvetica" size:13]];
            [_label_pointOut_petName setTextAlignment:NSTextAlignmentCenter];
            [_label_pointOut_petName setText:@"已存在"];
        }
    }
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
        
        //[_view_content removeFromSuperview];
        //_view_content = nil;
        
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
                         _view_background = nil;
                         [self removeFromSuperview];
                     }];
}

#pragma  mark - in动画 -
/**
 in动画
 **/
- (void)transitionInCompletion:(void(^)(void))completion
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[@(0.01), @(1.2), @(0.9), @(1)];
    animation.keyTimes = @[@(0), @(0.4), @(0.6), @(1)];
    animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    animation.duration = 0.5;
    [animation setValue:completion forKey:@"handler"];
    [_view_content.layer addAnimation:animation forKey:@"bouce"];
}


#pragma  mark - out动画 -
/**
 out动画
 **/
- (void)transitionOutCompletion:(void(^)(void))completion
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
@end
