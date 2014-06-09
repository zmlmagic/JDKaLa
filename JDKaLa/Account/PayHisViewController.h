//
//  PayHisViewController.h
//  JDKaLa
//
//  Created by 韩 抗 on 13-10-21.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClientAgent.h"
#import "JDSqlDataBase.h"

@interface PayHisViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray  *recordList;
    JDSqlDataBase   *database;
}
@property (retain, nonatomic) UILabel *labelNoRecord;
@property (retain, nonatomic) UITableView *exchangeTable;
@property (assign, nonatomic) BOOL bool_extension;
@property (retain, nonatomic) ClientAgent *agent;
@end

