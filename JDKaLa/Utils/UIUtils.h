//
//  UIUtils.h
//  JDKaLa
//
//  Created by 韩 抗 on 13-4-17.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

@interface UIUtils : NSObject

+ (UIImage *)didLoadImageNotCached:(NSString *)filename;
+ (NSString *)getCurrentDateString;
+ (NSString*)getDateStringAfterSeconds:(NSTimeInterval)seconds;
+ (NSString*)getDocumentDirName;
+ (void)hiddeView:(UIView *)view;
+ (void)showView:(UIView *)view;
+ (void)didLoadImageNotCached:(NSString *)filename inImageView:(UIImageView *)imageView;
+ (void)didLoadImageNotCached:(NSString *)filename inButton:(UIButton *)button withState:(UIControlState)state;
#pragma mark - MBProgressHUD
+ (void)view_showProgressHUD:(NSString *) _infoContent inView:(UIView *)view withTime:(float)time;
+ (void)view_showProgressHUD:(NSString *) _infoContent forWaitInView:(UIView *)view;

+ (void)view_hideProgressHUDinView:(UIView *)view;

#pragma mark - View
///渐变添加动画
+ (void)addView:(UIView *)view toView:(UIView *)superView;
+ (void)removeView:(UIView *)view;

#pragma mark - animation
///旋转动画
+ (void)animationWhirlWith:(UIView *)_view withPointMake:(CGPoint)point andRemovedOnCompletion:(BOOL)remove andDirection:(NSInteger)direction;

///移动添加动画
+ (void)addViewWithAnimation:(UIView *)view inCenterPoint:(CGPoint)point;
+ (void)removeViewWithAnimation:(UIView *)view inCenterPoint:(CGPoint)point withBoolRemoveView:(BOOL)_remove;

/**
 清空控件上的视图
 三种参数组合
 目标控件
 删除上面button,imageView,label组合
 **/
+ (void)clearChildViewsInView:(UIView *)view
                withButtonTag:(BOOL)button
               orImageViewTag:(BOOL)imageView
                   orLabelTag:(BOOL)label;


/**
 检测网络
 **/
+ (NSString *)applecationNetworkState;


@end
