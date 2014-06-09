//
//  JDUserRegistrationView.h
//  JDKaLa
//
//  Created by zhangminglei on 6/14/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClientAgent;

@interface JDUserRegistrationView : UIView<UITextFieldDelegate>

@property (assign, nonatomic) UILabel *label_pointOut_userName;
@property (assign, nonatomic) UILabel *label_pointOut_passAgain;
@property (assign, nonatomic) UILabel *label_pointOut_passWord;
@property (assign, nonatomic) UILabel *label_pointOut_petName;

@property (assign, nonatomic) UITextField *textField_userName;
@property (assign, nonatomic) UITextField *textField_passWord;
@property (assign, nonatomic) UITextField *textField_passAgain;
@property (assign, nonatomic) UITextField *textField_userPet;

@property (assign, nonatomic) UITextField *textField_yaoqingma;

@property (assign, nonatomic) ClientAgent *clientAgent_resgist;

/**
 邀请码控件
 **/
@property (assign, nonatomic) UIView *view_yaoqingma;
@property (assign, nonatomic) UITextField *textField_yName;
@property (assign, nonatomic) UITextField *textField_yEemail;
@property (assign, nonatomic) UITextField *textField_yphone;
@property (assign, nonatomic) UITextField *textField_yBecause;

@property (assign, nonatomic) UIView *view_content;
@property (assign, nonatomic) UIView *view_background;


- (void)showAnimated;
- (void)dismissAnimated;

@end
