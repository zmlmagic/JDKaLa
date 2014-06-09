//
//  JDMenuView.h
//  JDKaLa
//
//  Created by zhangminglei on 4/15/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKRevealSideViewController.h"

@interface JDMenuView : UIView

@property (retain, nonatomic) SKRevealSideViewController *revealSideViewController;
@property (assign, nonatomic) BOOL bool_extension;
@property (assign, nonatomic) UIButton *button_begin;

@property (assign, nonatomic) UINavigationController *navigationController_return;

+ (JDMenuView *)sharedView;
- (void)configureView_animetionButton_inViewChange;
- (void)configureView_animetionInView_shrink;


- (void)setButton_setUserInteractionEnabled:(BOOL)_bool;

@end
