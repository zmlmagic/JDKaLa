//
//  JDSingerKindViewController.h
//  JDKaLa
//
//  Created by zhangminglei on 4/7/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    JDTableViewTag_inlandBoy = 0,
    JDTableViewTag_inlandGirl,
    JDTableViewTag_chineseAll,
    JDTableViewTag_japanesekorean,
    JDTableViewTag_hongkongtaiwan,
    JDTableViewTag_europeamerica ,
    JDTableViewTag_inlandCombind ,
}JDTableViewTag;

@interface JDSingerKindViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    UILabel *label_total;
}

@property (retain, nonatomic) NSArray *array_data;
@property (retain, nonatomic) NSMutableArray *array_tableData;
@property (assign, nonatomic) BOOL bool_extension;
@property (assign, nonatomic) BOOL bool_oneTime;
@property (assign, nonatomic) BOOL bool_already;

@property (assign, nonatomic) UINavigationController *navigationController_return;

- (id)initWithString:(NSString *)_string_title andDataArray:(NSMutableArray *)_array andTag:(JDTableViewTag )_tag;


@end
