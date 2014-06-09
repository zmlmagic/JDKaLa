//
//  RechargeHisViewController.h
//  JDKaLa
//
//  Created by 韩 抗 on 13-10-18.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClientAgent.h"

@interface RechargeHisViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray  *recordList;
    NSDictionary *productNames;
    NSDictionary *productPrices;
}
@property (retain, nonatomic) UILabel *labelNoRecord;
@property (retain, nonatomic) UITableView *rechargeTable;
@property (assign, nonatomic) BOOL bool_extension;
@property (retain, nonatomic) ClientAgent *agent;
@end
