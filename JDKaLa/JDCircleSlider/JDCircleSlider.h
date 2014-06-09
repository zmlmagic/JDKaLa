//
//  JDCircleSlider.h
//  JDKaLa
//
//  Created by zhangminglei on 8/20/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//、、

#import <UIKit/UIKit.h>

/** 大小属性 **/
#define TB_SLIDER_SIZE 45                          //The width and the heigth of the slider
#define TB_BACKGROUND_WIDTH 5                      //The width of the dark background
#define TB_LINE_WIDTH 6                            //The width of the active area (the gradient) and the width of the handle


@interface JDCircleSlider : UIControl

@property (nonatomic,assign) int angle;

- (void)setProgressWithAngle:(float)progress;

@end
