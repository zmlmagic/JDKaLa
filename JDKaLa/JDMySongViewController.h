//
//  JDMySongViewController.h
//  JDKaLa
//
//  Created by zhangminglei on 5/27/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface JDMySongViewController : UIViewController<UITextFieldDelegate>

@property (assign, nonatomic) BOOL bool_extension;
@property (assign, nonatomic) UILabel *label_title;
@property (assign, nonatomic) BOOL bool_oneTime;

@property (assign, nonatomic) UINavigationController *navigationController_return;

@end
