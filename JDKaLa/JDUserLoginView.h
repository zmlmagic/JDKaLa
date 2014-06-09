//
//  JDUserLoginView.h
//  JDKaLa
//
//  Created by zhangminglei on 6/13/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JDModel_user;
@class ClientAgent;

typedef NS_ENUM(NSInteger, AlertViewBackgroundStyle){
    AlertViewBackgroundStyleGradient = 0,
    AlertViewBackgroundStyleSolid,
};

typedef NS_ENUM(NSInteger, AlertViewTransitionStyle){
    AlertViewTransitionStyleSlideFromBottom = 0,
    AlertViewTransitionStyleSlideFromTop,
    AlertViewTransitionStyleFade,
    AlertViewTransitionStyleBounce,
    AlertViewTransitionStyleDropDown
};

@interface JDUserLoginView : UIView<UITextFieldDelegate>

@property (assign, nonatomic) ClientAgent *clientAgent_resgist;
@property (assign, nonatomic) UITextField *textField_userName;
@property (assign, nonatomic) UITextField *textField_passWord;

@property (assign, nonatomic) UIView *view_content;
@property (assign, nonatomic) UIView *view_background;
@property (assign, nonatomic) UIView *view_recive;
@property (nonatomic, assign) AlertViewTransitionStyle transitionStyle;
@property (nonatomic, assign) AlertViewBackgroundStyle style;

- (void)showAnimated;
- (void)dismissAnimated;

@end
