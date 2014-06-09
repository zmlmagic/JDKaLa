//
//  ProductListViewController.h
//  JDKaLa
//
//  Created by 韩 抗 on 13-10-14.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClientAgent.h"
#import "KCoinRecharge.h"

@interface ProductListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray  *productList;
    KCoinRecharge   *kCoinRecharge;
    NSString        *selectedProductID;
}

@property (assign, nonatomic) BOOL bool_oneTime;

@property (retain, nonatomic) UITableView *productTable;
@property (assign, nonatomic) BOOL bool_extension;
@property (retain, nonatomic) ClientAgent *agent;
@property (assign, nonatomic) UIView *view_infoBack;
@end
