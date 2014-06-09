//
//  JDUserInfoChangeView.h
//  JDKaLa
//
//  Created by zhangminglei on 6/28/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClientAgent;

@interface JDUserInfoChangeView : UIView<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate,UITextViewDelegate>
{
    ClientAgent *agent;
}

@property (assign, nonatomic) UIView *view_back;
@property (assign, nonatomic) UIButton *button_head_change;
@property (assign, nonatomic) UIPopoverController *popVer;

@property (assign, nonatomic) UILabel *label_pointOut_userName;
@property (assign, nonatomic) UIImageView *imageView_sign_p;
@property (assign, nonatomic) UITextView *text_sign;
@property (assign, nonatomic) UITextField *field_name;

///0,1,2 0-女，1-男,2-为保密
@property (assign, nonatomic) NSInteger integer_sex;
@property (assign, nonatomic) UIButton *button_man;
@property (assign, nonatomic) UIButton *button_woman;

@property (assign, nonatomic) BOOL bool_text;
@property (assign, nonatomic) BOOL bool_text_again;

@property (assign, nonatomic) NSString *string_fileName;

@end
