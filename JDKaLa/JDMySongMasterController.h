//
//  JDMySongMasterController.h
//  JDKaLa
//
//  Created by zhangminglei on 5/31/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JDMySongViewController;

@interface JDMySongMasterController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (retain, nonatomic) NSMutableArray *array_myMasterData;
@property (assign, nonatomic) UITableView *tableView_self;

@property (assign, nonatomic) UIButton *button_before;
@property (assign, nonatomic) UIButton *button_first;

@property (assign, nonatomic) UINavigationController *navigationController_return;

@end
