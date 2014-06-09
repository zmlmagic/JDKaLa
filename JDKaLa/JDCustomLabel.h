//
//  JDCustomLabel.h
//  JDKaLa
//
//  Created by zhangminglei on 10/22/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDCustomLabel : UILabel

@property (assign, nonatomic) CGFloat animationDuration;
@property (assign, nonatomic) CGFloat gradientWidth;
@property (assign, nonatomic) UIColor *tint;
@property (assign, nonatomic) CATextLayer *textLayer;


- (void)startAnimating;
- (void)stopAnimating;

@end
