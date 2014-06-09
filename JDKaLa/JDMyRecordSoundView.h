//
//  JDMyRecordSoundView.h
//  JDKaLa
//
//  Created by zhangminglei on 6/18/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDMyRecordSoundView : UIView<UITableViewDataSource,UITableViewDelegate>

@property (retain, nonatomic) NSMutableArray *array_data;
@property (assign, nonatomic) NSIndexPath *delectCellId;

@end
