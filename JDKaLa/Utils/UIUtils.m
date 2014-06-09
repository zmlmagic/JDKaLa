//
//  UIUtils.m
//  JDKaLa
//
//  Created by 韩 抗 on 13-4-17.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import "UIUtils.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "Reachability.h"

@implementation UIUtils

+ (UIImage *)didLoadImageNotCached:(NSString *)filename
{
    NSString *imageFile = [[NSString alloc]initWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], filename];
    UIImage *image =  [UIImage imageWithContentsOfFile:imageFile];
    [imageFile release];
    return image;
}

//返回当前时间的字符串
+ (NSString *)getCurrentDateString
{
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    //alloc后对不使用的对象别忘了release
    [dateFormatter release];
    return currentDateStr;
}

//返回若干秒后的时间的字符串
+ (NSString*)getDateStringAfterSeconds:(NSTimeInterval)seconds
{
    NSDate *destDate = [NSDate dateWithTimeIntervalSinceNow:seconds];
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //用[NSDate date]可以获取系统当前时间
    NSString *dateStr = [dateFormatter stringFromDate:destDate];
    //alloc后对不使用的对象别忘了release
    [dateFormatter release];
    return dateStr;

}

//返回文档目录
+ (NSString*)getDocumentDirName
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (void)hiddeView:(UIView *)view
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.1];
    [view setAlpha:0.0f];
    [UIView commitAnimations];
}

+ (void)showView:(UIView *)view
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0];
    [view setAlpha:1.0f];
    [UIView commitAnimations];
}

+ (void)didLoadImageNotCached:(NSString *)filename inImageView:(UIImageView *)imageView
{
    NSString *imageFile = [[NSString alloc]initWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], filename];
    UIImage *image =  [[UIImage alloc] initWithContentsOfFile:imageFile];
    [imageFile release];
    [imageView setImage:image];
    [image release];
}

+ (void)didLoadImageNotCached:(NSString *)filename inButton:(UIButton *)button withState:(UIControlState)state
{
    NSString *imageFile = [[NSString alloc]initWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], filename];
    UIImage *image =  [[UIImage alloc] initWithContentsOfFile:imageFile];
    [imageFile release];
    [button setBackgroundImage:image forState:state];
    [image release];
}

#pragma mark - 
#pragma mark MBProgressHUD
+ (void)view_showProgressHUD:(NSString *) _infoContent inView:(UIView *)view withTime:(float)time
{
    MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    [progressHUD setAnimationType:MBProgressHUDAnimationZoom];
    UIView *view_back = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [view_back setBackgroundColor:[UIColor clearColor]];
    [progressHUD setCustomView:view_back];
    [progressHUD setMode:MBProgressHUDModeCustomView];
    [progressHUD setLabelText:_infoContent];
    [progressHUD setLabelFont:[UIFont fontWithName:@"Helvetica-Bold" size:20.0]];
    [progressHUD setRemoveFromSuperViewOnHide:YES];
    [self performSelector:@selector(view_hideProgressHUDinView:) withObject:view afterDelay:time];
}

+ (void)view_showProgressHUD:(NSString *) _infoContent forWaitInView:(UIView *)view
{
    MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    [progressHUD setAnimationType:MBProgressHUDAnimationZoom];
    [progressHUD setMode:MBProgressHUDModeIndeterminate];
    [progressHUD setLabelText:_infoContent];
    [progressHUD setLabelFont:[UIFont fontWithName:@"Helvetica-Bold" size:20.0]];
    [progressHUD setRemoveFromSuperViewOnHide:YES];
    //[self performSelector:@selector(view_hideProgressHUDinView:) withObject:view afterDelay:time];
}

+ (void)view_hideProgressHUDinView:(UIView *)view
{
    [MBProgressHUD hideHUDForView:view animated:YES];
}

#pragma mark - View
+ (void)addView:(UIView *)view toView:(UIView *)superView
{
    [superView addSubview:view];
    [view setAlpha:0.0f];
    [self showView:view];
    [view release];
}

+ (void)removeView:(UIView *)view
{
    [self hiddeView:view];
    [self performSelector:@selector(removeViewWithAnimation:) withObject:view afterDelay:1.f];
}

+ (void)removeViewWithAnimation:(UIView *)view
{
    [view removeFromSuperview];
}

+ (void)animationWhirlWith:(UIView *)_view withPointMake:(CGPoint)point andRemovedOnCompletion:(BOOL)remove andDirection:(NSInteger)direction
{
    CABasicAnimation *aAnimation = [CABasicAnimation animation];
    aAnimation.keyPath = @"position";
    aAnimation.keyPath = @"transform.rotation.z";
    //aAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(28, 23)];
    aAnimation.toValue = [NSNumber numberWithFloat:M_PI * direction];
    aAnimation.duration = 0.3f;
    aAnimation.removedOnCompletion = remove;//完成后停止
    aAnimation.fillMode = kCAFillModeForwards;
    aAnimation.autoreverses = NO;
    _view.layer.position = point;
    [_view.layer addAnimation: aAnimation forKey:@"rotation"];
}

+ (void)addViewWithAnimation:(UIView *)view inCenterPoint:(CGPoint)point
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationRepeatCount:1];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [view setCenter:point];
    [UIView commitAnimations];
}

+ (void)removeViewWithAnimation:(UIView *)view inCenterPoint:(CGPoint)point withBoolRemoveView:(BOOL)_remove
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationRepeatCount:1];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [view setCenter:point];
    [UIView commitAnimations];
    if(_remove)
    {
        [self performSelector:@selector(removeViewWithAnimation:) withObject:view afterDelay:1.0f];
    }
}

/**
 清空控件上的视图
 三种参数组合
 目标控件
 删除上面button,imageView,label组合
 **/
+ (void)clearChildViewsInView:(UIView *)view
                withButtonTag:(BOOL)button
               orImageViewTag:(BOOL)imageView
                   orLabelTag:(BOOL)label
{
    if(button && imageView && label)
    {
        [self clearChildButtonInView:view];
        [self clearChildImageViewInView:view];
        [self clearChildLabelViewInView:view];
    }
    else if(button && imageView && !label)
    {
        [self clearChildButtonInView:view];
        [self clearChildImageViewInView:view];
    }
    else if(button && !imageView &&label)
    {
        [self clearChildButtonInView:view];
        [self clearChildLabelViewInView:view];
    }
    else if(!button && imageView &&label)
    {
        [self clearChildImageViewInView:view];
        [self clearChildLabelViewInView:view];
    }
    else if(button && !imageView && !label)
    {
        [self clearChildButtonInView:view];
    }
    else if(!button && imageView && !label)
    {
        [self clearChildImageViewInView:view];
    }
    else if(!button && !imageView && label)
    {
        [self clearChildLabelViewInView:view];
    }
}


+ (void)clearChildButtonInView:(UIView *)view
{
    for(id button in view.subviews)
    {
        if([button isKindOfClass:[UIButton class]])
        {
            UIButton *button_remove = (UIButton *)button;
            [button_remove removeFromSuperview];
        }
    }
}

+ (void)clearChildImageViewInView:(UIView *)view
{
    for(id imageView in view.subviews)
    {
        if([imageView isKindOfClass:[UIImageView class]])
        {
            UIImageView *imageView_remove = (UIImageView *)imageView;
            [imageView_remove removeFromSuperview];
        }
    }
}

+ (void)clearChildLabelViewInView:(UIView *)view
{
    for(id label in view.subviews)
    {
        if([label isKindOfClass:[UILabel class]])
        {
            UILabel *label_remove = (UILabel *)label;
            [label_remove removeFromSuperview];
        }
    }
}

#pragma mark - 检测网络 -
/**
 检测网络
 **/
+ (NSString *)applecationNetworkState
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [hostReach currentReachabilityStatus];
    switch (netStatus)
    {
        case ReachableViaWWAN:
        {
            return @"3g";
        }break;
        case ReachableViaWiFi:
        {
            return @"wifi";
        }
        case NotReachable:
        {
            return @"no";
        }break;
        default:
            return nil;
            break;
    }
}

@end
