//
//  JDSongPayView.h
//  JDKaLa
//
//  Created by zhangminglei on 10/23/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JDSongPayViewDelegate <NSObject>

- (void)delegate_didClickButtonBuySong;
- (void)delegate_didClickButtonUseCard:(NSString *)string_CardID;


@end

@interface JDSongPayView : UIView

@property (assign, nonatomic) UIView *view_content;
@property (assign, nonatomic) UIView *view_background;
@property (retain, nonatomic) NSMutableArray *array_data;

@property (nonatomic, retain) id <JDSongPayViewDelegate> delegate;


- (void)showAnimated;
- (void)dismissAnimated;

@end
