//
//  CardListViewController.h
//  JDKaLa
//
//  Created by 韩 抗 on 13-10-11.
//  Copyright (c) 2013年 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClientAgent.h"

@interface CardListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray  *cardList;
}

@property (retain, nonatomic) UITableView *cardTable;
@property (retain, nonatomic) UILabel *labelNoCard;
@property (assign, nonatomic) BOOL bool_extension;
@property (retain, nonatomic) ClientAgent *agent;

@end
