//
//  JDMoreView.h
//  JDKaLa
//
//  Created by zhangminglei on 9/4/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDMoreView : UIView<UITableViewDataSource,UITableViewDelegate>

@property (retain, nonatomic) NSMutableArray *array_data;

/**
 移除消息
 **/
- (void)removeNSNotification;

@end
