//
//  JDMainViewCell.m
//  JDKaLa
//
//  Created by zhangminglei on 4/3/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDMainViewCell.h"
#import "JDSqlDataBase.h"
#import "JDSingerSongViewController.h"
#import "JDAlbum.h"
#import "UIUtils.h"
#import "JDThereSongViewController.h"

typedef enum
{
    JDButtonTag_big =        0,
    JDButtonTag_middle_one    ,
    JDButtonTag_middle_two    ,
    JDButtonTag_small_one     ,
    JDButtonTag_small_two     ,
    JDButtonTag_small_three   ,
    JDButtonTag_small_four    ,
    JDButtonTag_small_five    ,
}
JDButtonTag;


@implementation JDMainViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self configureCell_background];
        [self configureCell_button];
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


- (void)configureCell_background
{
    UIImageView *imageView_background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 1024, 749)];
    [UIUtils didLoadImageNotCached:@"mainView_background.png" inImageView:imageView_background];
    [self setBackgroundView:imageView_background];
    [imageView_background release];
}

- (void)configureCell_button
{
    UIButton *button_big = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_big setFrame:CGRectMake(50, 40, 405, 405)];
    [UIUtils didLoadImageNotCached:@"frame_big.png" inButton:button_big withState:UIControlStateNormal];
    [button_big setTag:JDButtonTag_big];
    [button_big addTarget:self action:@selector(didClickButton_cellButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button_big];
    
    UIButton *button_small_one = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_small_one setFrame:CGRectMake(470, 40, 196, 196)];
    [UIUtils didLoadImageNotCached:@"frame_small_one.png" inButton:button_small_one withState:UIControlStateNormal];
    [button_small_one setTag:JDButtonTag_small_one];
    [button_small_one addTarget:self action:@selector(didClickButton_cellButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button_small_one];
    
    UIButton *button_small_two = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_small_two setFrame:CGRectMake(470, 249, 196, 196)];
    [UIUtils didLoadImageNotCached:@"frame_small_two.png" inButton:button_small_two withState:UIControlStateNormal];
    [button_small_two setTag:JDButtonTag_small_two];
    [button_small_two addTarget:self action:@selector(didClickButton_cellButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button_small_two];
    
    UIButton *button_small_five = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_small_five setFrame:CGRectMake(50, 460, 196, 196)];
    [UIUtils didLoadImageNotCached:@"frame_small_five.png" inButton:button_small_five withState:UIControlStateNormal];
    [button_small_five setTag:JDButtonTag_small_five];
    [button_small_five addTarget:self action:@selector(didClickButton_cellButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button_small_five];
    
    UIButton *button_small_four = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_small_four setFrame:CGRectMake(259, 460, 196, 196)];
    [UIUtils didLoadImageNotCached:@"frame_small_four.png" inButton:button_small_four withState:UIControlStateNormal];
    [button_small_four setTag:JDButtonTag_small_four];
    [button_small_four addTarget:self action:@selector(didClickButton_cellButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button_small_four];
    
    UIButton *button_small_three = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_small_three setFrame:CGRectMake(470, 460, 196, 196)];
    [UIUtils didLoadImageNotCached:@"frame_small_three.png" inButton:button_small_three withState:UIControlStateNormal];
    [button_small_three setTag:JDButtonTag_small_three];
    [button_small_three addTarget:self action:@selector(didClickButton_cellButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button_small_three];
    
    UIButton *button_middle_one = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_middle_one setFrame:CGRectMake(681, 40, 300, 300)];
    [UIUtils didLoadImageNotCached:@"frame_middle_one.png" inButton:button_middle_one withState:UIControlStateNormal];
    [button_middle_one setTag:JDButtonTag_middle_one];
    [button_middle_one addTarget:self action:@selector(didClickButton_cellButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button_middle_one];
    
    UIButton *button_middle_two = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_middle_two setFrame:CGRectMake(681, 356, 300, 300)];
    [UIUtils didLoadImageNotCached:@"frame_middle_two.png" inButton:button_middle_two withState:UIControlStateNormal];
    [button_middle_two setTag:JDButtonTag_middle_two];
    [button_middle_two addTarget:self action:@selector(didClickButton_cellButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button_middle_two];
}

#pragma mark - DidClickButton
-(void)didClickButton_cellButton:(id)sender
{
    UIButton *button_tmp = (UIButton *)sender;
    NSString    *fileName = nil;
    
    switch (button_tmp.tag)
    {
        case JDButtonTag_big:
            //fileName = @"http://ep.iktv.tv/albums/recommend.xml";
            fileName = [NSString stringWithFormat:@"%@/recommend.xml", [[NSBundle mainBundle] resourcePath]];
            break;
        case JDButtonTag_middle_one:
            //fileName = @"http://ep.iktv.tv/albums/xuruyun.xml";
            fileName = [NSString stringWithFormat:@"%@/xuruyun.xml", [[NSBundle mainBundle] resourcePath]];
            break;
        case JDButtonTag_middle_two:
            //fileName = @"http://ep.iktv.tv/albums/meinantuan.xml";
            fileName = [NSString stringWithFormat:@"%@/meinantuan.xml", [[NSBundle mainBundle] resourcePath]];
            break;
        case JDButtonTag_small_one:
            //fileName = @"http://ep.iktv.tv/albums/qingsongchang.xml";
            fileName = [NSString stringWithFormat:@"%@/qingsongchang.xml", [[NSBundle mainBundle] resourcePath]];
            break;
        case JDButtonTag_small_two:
            //fileName = @"http://ep.iktv.tv/albums/liuxingqianyan.xml";
            fileName = [NSString stringWithFormat:@"%@/liuxingqianyan.xml", [[NSBundle mainBundle] resourcePath]];
            break;
        case JDButtonTag_small_three:
            //fileName = @"http://ep.iktv.tv/albums/meiguoyuansheng.xml";
            fileName = [NSString stringWithFormat:@"%@/meiguoyuansheng.xml", [[NSBundle mainBundle] resourcePath]];
            break;
        case JDButtonTag_small_four:
            //fileName = @"http://ep.iktv.tv/albums/xiaoyuanminyao.xml";
            fileName = [NSString stringWithFormat:@"%@/xiaoyuanminyao.xml", [[NSBundle mainBundle] resourcePath]];
            break;
        case JDButtonTag_small_five:
            fileName = [NSString stringWithFormat:@"%@/80houjingdian.xml", [[NSBundle mainBundle] resourcePath]];
            break;

        default:
            break;
    }
    
    if(fileName != nil)
    {
        JDAlbum     *album = [[JDAlbum alloc] initWithFileName:fileName];
        NSMutableString *allMd5 = [[NSMutableString alloc]init];
        
        for(int i = 0; i < [album count]; ++i)
        {
            //NSLog(@"Item name:%@", [[album getItemAtIndex:i] title]);
            if(i != 0)
            {
                [allMd5 appendString:@","];
            }
            [allMd5 appendFormat:@"'%@'", [[album getItemAtIndex:i] md5]];
        }
        
        //NSString        *sql = [NSString stringWithFormat:@"select *from songs where md5 in (%@)", allMd5];
        JDSqlDataBase   *dataController = [[JDSqlDataBase alloc] init];
        
        JDThereSongViewController *themeController = [[JDThereSongViewController alloc] initWithTitleFileName:[album albumName]];
        //JDSingerSongViewController *songController = [[JDSingerSongViewController alloc] initWithTitleString:[album albumName]];
        //themeController.array_data = [dataController reciveDataBaseWithString:sql];
        themeController.array_data = [dataController reciveSongArrayWithTag:2];
        //songController.array_data = [dataController reciveDataBaseWithString:sql];
        //[songController configureTable_data];
        [themeController configureTable_data];
        //[_viewController presentViewController:songController animated:NO completion:nil];
        [_viewController presentModalViewController:themeController animated:NO];
        [allMd5 release];
        [album release];
        [dataController release];
        [themeController release];
        //[songController release];
    }
}

@end
