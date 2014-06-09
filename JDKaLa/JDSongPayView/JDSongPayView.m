//
//  JDSongPayView.m
//  JDKaLa
//
//  Created by zhangminglei on 10/23/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDSongPayView.h"
#import "UIUtils.h"
#import "ClientAgent.h"
#import "JDModel_userInfo.h"
#import "JDModel_time_card.h"
#import "CustomAlertView.h"
#import "JDMenuView.h"

#define PRODUCT_ID_MONTHLY_CARD @"cn.kbar.time_service.month"
#define PRODUCT_ID_WEEKLY_CARD  @"cn.kbar.time_service.week"

typedef enum
{
    JDButtonBuyTag_buySong         = 50,
    JDButtonBuyTag_useCard             ,
    JDButtonBuyTag_back                ,
    JDButtonBuyTag_buy                 ,
    JDButtonBuyTag_buyCancel           ,
    
}JDButtonBuyTag;

#pragma mark - 初始化背景 -
/**
 初始化背景
 **/
@interface JDBackgroundView_songPayView : UIView

@end

@implementation JDBackgroundView_songPayView
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    size_t locationsCount = 2;
    CGFloat locations[2] = {0.0f, 1.0f};
    CGFloat colors[8] = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.75f};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
    CGColorSpaceRelease(colorSpace);
    
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) ;
    CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
}

@end

@implementation JDSongPayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self installView];
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
        self.array_data = array;
    }
    return self;
}

- (void)dealloc
{
    [_array_data release], _array_data = nil;
    [super dealloc];
}

#pragma mark - 初始化界面 -
/**
 初始化界面
 **/
- (void)installView
{
    JDBackgroundView_songPayView *view_back = [[JDBackgroundView_songPayView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [view_back setBackgroundColor:[UIColor clearColor]];
    [self addSubview:view_back];
    [view_back release];
    _view_background = view_back;
   
    UIView *view_con = [[UIView alloc] initWithFrame:CGRectMake(288, 105, 448, 433)];
    view_con.layer.shadowColor = [UIColor blackColor].CGColor;
    view_con.layer.shadowOffset = CGSizeMake(10, 10);
    view_con.layer.shadowOpacity = 0.5;
    view_con.layer.shadowRadius = 2.0;
    [self addSubview:view_con];
    [view_con release];
    _view_content = view_con;
    
    UIImageView *imageView_back = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 448, 283)];
    [UIUtils didLoadImageNotCached:@"pop_up_board_lv1.png" inImageView:imageView_back];
    [view_con addSubview:imageView_back];
    [imageView_back release];
    
    UIImageView *imageView_20 = [[UIImageView alloc] initWithFrame:CGRectMake(300, 15, 51, 20)];
    [UIUtils didLoadImageNotCached:@"pop_up_vip_20.png" inImageView:imageView_20];
    [view_con addSubview:imageView_20];
    [imageView_20 release];
    
    UILabel *label_title = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, 400, 30)];
    [label_title setBackgroundColor:[UIColor clearColor]];
    [label_title setTextColor:[UIColor colorWithWhite:0.1 alpha:0.5]];
    [label_title setFont:[UIFont systemFontOfSize:15.0f]];
    [label_title setText:@"该歌曲需要购买或者开启欢唱卡才可播放,请选择以下操作"];
    [view_con addSubview:label_title];
    [label_title release];
    
    UIButton *button_buy_song = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_buy_song setFrame:CGRectMake(30, 100, 108, 133)];
    button_buy_song.layer.shadowColor = [UIColor blackColor].CGColor;
    button_buy_song.layer.shadowOffset = CGSizeMake(2, 2);
    button_buy_song.layer.shadowOpacity = 0.5;
    button_buy_song.layer.shadowRadius = 2.0;
    [UIUtils didLoadImageNotCached:@"pop_up_btn_k.png" inButton:button_buy_song withState:UIControlStateNormal];
    [button_buy_song setTag:JDButtonBuyTag_buySong];
    [button_buy_song addTarget:self action:@selector(didClickButton_buy:) forControlEvents:UIControlEventTouchUpInside];
    [view_con addSubview:button_buy_song];
    
    UIButton *button_buy_card = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_buy_card setFrame:CGRectMake(153, 100, 108, 133)];
    button_buy_card.layer.shadowColor = [UIColor blackColor].CGColor;
    button_buy_card.layer.shadowOffset = CGSizeMake(2, 2);
    button_buy_card.layer.shadowOpacity = 0.5;
    button_buy_card.layer.shadowRadius = 2.0;
    [UIUtils didLoadImageNotCached:@"pop_up_btn_time.png" inButton:button_buy_card withState:UIControlStateNormal];
    [button_buy_card setTag:JDButtonBuyTag_useCard];
    [button_buy_card addTarget:self action:@selector(didClickButton_buy:) forControlEvents:UIControlEventTouchUpInside];
    [view_con addSubview:button_buy_card];
    
    UIButton *button_back = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_back setFrame:CGRectMake(273, 130, 108, 58)];
    button_back.layer.shadowColor = [UIColor blackColor].CGColor;
    button_back.layer.shadowOffset = CGSizeMake(2, 2);
    button_back.layer.shadowOpacity = 0.5;
    button_back.layer.shadowRadius = 2.0;
    [UIUtils didLoadImageNotCached:@"pop_up_btn_return.png" inButton:button_back withState:UIControlStateNormal];
    [button_back setTag:JDButtonBuyTag_back];
    [button_back addTarget:self action:@selector(didClickButton_buy:) forControlEvents:UIControlEventTouchUpInside];
    [view_con addSubview:button_back];
}

#pragma mark - 买歌界面按钮回调 -
/**
 买歌界面按钮回调
 **/
- (void)didClickButton_buy:(id)sender
{
    UIButton *button_tmp = (UIButton *)sender;
    switch (button_tmp.tag)
    {
        case JDButtonBuyTag_buySong:
        {
            UIView *view_buySong_before = (UIView *)[_view_content viewWithTag:100];
            UIView *view_useCard_before = (UIView *)[_view_content viewWithTag:101];
            if(view_buySong_before)
            {
                return;
            }
            if(view_useCard_before)
            {
                [view_useCard_before removeFromSuperview];
            }
            
            UIView *view_card = [[UIView alloc] initWithFrame:CGRectMake(0, 283, 448, 110)];
            [UIUtils addView:view_card toView:_view_content];
            [view_card setTag:100];
            
            UIImageView *imageView_card = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 448, 110)];
            [UIUtils didLoadImageNotCached:@"pop_up_board_lv.png" inImageView:imageView_card];
            [view_card addSubview:imageView_card];
            [imageView_card release];
            
            NSString *string_tmp = [NSString stringWithFormat:@"您当前的账户余额为%@K币",[[NSUserDefaults standardUserDefaults] objectForKey:@"money"]];
            UILabel *label_ye = [[UILabel alloc] initWithFrame:CGRectMake(74, 5, 300, 30)];
            [label_ye setTextAlignment:NSTextAlignmentCenter];
            [label_ye setTextColor:[UIColor whiteColor]];
            [label_ye setBackgroundColor:[UIColor clearColor]];
            [label_ye setText:string_tmp];
            [view_card addSubview:label_ye];
            [label_ye release];
            
            UIButton *button_buy = [UIButton buttonWithType:UIButtonTypeCustom];
            [button_buy setFrame:CGRectMake(50, 60, 80, 35)];
            [UIUtils didLoadImageNotCached:@"pop_up_btn_buy.png" inButton:button_buy withState:UIControlStateNormal];
            [button_buy setTag:JDButtonBuyTag_buy];
            [button_buy addTarget:self action:@selector(didClickSongPay:) forControlEvents:UIControlEventTouchUpInside];
            [view_card addSubview:button_buy];
            
            UIButton *button_cancel = [UIButton buttonWithType:UIButtonTypeCustom];
            [button_cancel setFrame:CGRectMake(270, 60, 120, 35)];
            [UIUtils didLoadImageNotCached:@"pop_up_btn_notbuy.png" inButton:button_cancel withState:UIControlStateNormal];
            [button_cancel setTag:JDButtonBuyTag_buyCancel];
            [button_cancel addTarget:self action:@selector(didClickSongPay:) forControlEvents:UIControlEventTouchUpInside];
            [view_card addSubview:button_cancel];
            
        }break;
            
        case JDButtonBuyTag_useCard:
        {
            
            UIView *view_buySong_before = (UIView *)[_view_content viewWithTag:100];
            UIView *view_useCard_before = (UIView *)[_view_content viewWithTag:101];
            if(view_buySong_before)
            {
                [view_buySong_before removeFromSuperview];
            }
            if(view_useCard_before)
            {
                return;
            }
            
            [UIUtils view_showProgressHUD:@"正在读取中" forWaitInView:self];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleGetCardListResult:)
                                                         name:NOTI_GET_TIME_CARD_LIST_RESULT
                                                       object:nil];
            
            ClientAgent *agent = [[ClientAgent alloc] init];
            [agent getTimeCardList:[JDModel_userInfo sharedModel].string_userID
                             Token:[JDModel_userInfo sharedModel].string_token];
            
        }break;
        
        case JDButtonBuyTag_back:
        {
            [self dismissAnimated];
            
        }break;
    }
}

/**
 * 获取已购时长卡列表的反馈处理
 */
- (void)handleGetCardListResult:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    [_array_data removeAllObjects];
    if([[state objectForKey:@"result"] length] > 0 && 0 == resultCode)
    {
        NSArray *billList = [state objectForKey:@"querylist"];
        
        for(NSDictionary* record in billList)
        {
            JDModel_time_card *card = [[JDModel_time_card alloc]init];
            card.productID = [record objectForKey:@"product_id"];
            card.cardID = [record objectForKey:@"card_id"];
            card.buyTime = [record objectForKey:@"buydate"];
            card.invalidTime = [record objectForKey:@"invaliddate"];
            [_array_data addObject:card];
            [card release];
        }
        
        [self installView_useCard];
    }
    else
    {
        NSString *msg = [state objectForKey:@"msg"];
        if([msg hasPrefix:@"546"])
        {
            CustomAlertView *alter = [[CustomAlertView alloc] initWithTitle:@"无时长卡"
                                                                    message:@"请到账户购买时长卡" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
            
            [alter show];
            [alter release];
        }
        else
        {
            CustomAlertView *alter = [[CustomAlertView alloc] initWithTitle:[state objectForKey:@"msg"]
                                                                    message:nil
                                                                   delegate:nil
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil,nil];
            
            [alter show];
            [alter release];
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTI_GET_TIME_CARD_LIST_RESULT
                                                  object:nil];
    
    [UIUtils view_hideProgressHUDinView:self];
}

#pragma mark - 启用时长卡界面 -
/**
 启用时长卡
 **/
- (void)installView_useCard
{
    UIView *view_card = [[UIView alloc] initWithFrame:CGRectMake(0, 283, 448, 150)];
    [UIUtils addView:view_card toView:_view_content];
    [view_card setTag:101];
    
    UIImageView *imageView_card = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 448, 150)];
    [UIUtils didLoadImageNotCached:@"pop_up_board_lv.png" inImageView:imageView_card];
    [view_card addSubview:imageView_card];
    [imageView_card release];
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 448, 150)];
    [scroll setBackgroundColor:[UIColor clearColor]];
    [scroll setContentSize:CGSizeMake(10 + 10 +[_array_data count]*(235+10), 140.0)];
    [scroll setShowsVerticalScrollIndicator:NO];
    [scroll setShowsHorizontalScrollIndicator:YES];
    [view_card addSubview:scroll];
    [scroll release];
    
    for (int i = 0; i<[_array_data count]; i++)
    {
        JDModel_time_card   *card = [_array_data objectAtIndex:i];
        NSString   *cardType = card.productID;
        UIImageView *imageView_portrait = [[UIImageView alloc] initWithFrame:CGRectMake(5 + i*245, 5, 235, 140)];
        if([cardType isEqualToString:PRODUCT_ID_MONTHLY_CARD])
        {
            [UIUtils didLoadImageNotCached:@"monthly_card.png" inImageView:imageView_portrait];
        }
        else if([cardType isEqualToString:PRODUCT_ID_WEEKLY_CARD])
        {
            [UIUtils didLoadImageNotCached:@"weekly_card.png" inImageView:imageView_portrait];
        }
        [scroll addSubview:imageView_portrait];
        [imageView_portrait release];
        
        UILabel *label_invalidTimeTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 100, 150, 20)];
        [label_invalidTimeTitle setTextAlignment:NSTextAlignmentLeft];
        [label_invalidTimeTitle setTextColor:[UIColor whiteColor]];
        [label_invalidTimeTitle setBackgroundColor:[UIColor clearColor]];
        [label_invalidTimeTitle setFont:[UIFont systemFontOfSize:15.0f]];
        [label_invalidTimeTitle setText:@"失效时间:"];
        [imageView_portrait addSubview:label_invalidTimeTitle];
        [label_invalidTimeTitle release];
        
        UILabel *label_invalidTime = [[UILabel alloc] initWithFrame:CGRectMake(5, 120, 180, 20)];
        [label_invalidTime setTextAlignment:NSTextAlignmentLeft];
        [label_invalidTime setTextColor:[UIColor whiteColor]];
        [label_invalidTime setBackgroundColor:[UIColor clearColor]];
        [label_invalidTime setFont:[UIFont systemFontOfSize:15.0f]];
        [label_invalidTime setText:[card invalidTime]];
        [imageView_portrait addSubview:label_invalidTime];
        [label_invalidTime release];
        
        UIButton *btnUseCard = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnUseCard setFrame:CGRectMake(160 + i*245, 110, 70, 30)];
        [btnUseCard setTag:i];
        [scroll addSubview:btnUseCard];
        [UIUtils didLoadImageNotCached:@"active_time_card.png" inButton:btnUseCard withState:UIControlStateNormal];
        [btnUseCard addTarget:self action:@selector(didClickBtnUse:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - 点击开卡 -
/**
 点击开卡
 **/
- (void)didClickBtnUse:(id)sender
{
    int    cardIdx = ([sender tag]);
    JDModel_time_card *card = [_array_data objectAtIndex:cardIdx];
    [_delegate delegate_didClickButtonUseCard:[card cardID]];
    
    [self dismissAnimated];
}


#pragma mark - 购买单曲函数回调 -
/**
 购买单曲函数回调
 **/
- (void)didClickSongPay:(id)sender
{
    UIButton *button_tmp = (UIButton *)sender;
    switch (button_tmp.tag)
    {
        case JDButtonBuyTag_buy:
        {
            [_delegate delegate_didClickButtonBuySong];
            [self dismissAnimated];
            
        }break;
        case JDButtonBuyTag_buyCancel:
        {
            UIView *view_back = [self reciveSuperViewWithButton:button_tmp];
            [UIUtils removeView:view_back];
            
        }break;
        default:
            break;
    }
}

#pragma mark - 接收父视图 - 
/**
 接收父视图
 **/
- (UIView *)reciveSuperViewWithButton:(UIButton *)button
{
    for (UIView *next = [button superview]; next; next = next.superview)
    {
        if ([next isKindOfClass:[UIView class]])
        {
            return (UIView *)next;
        }
    }
    return nil;
}

#pragma mark - 弹出视图 -
/**
 弹出视图
 **/
- (void)showAnimated
{
    void (^dismissComplete)(void) = ^{
        
    };
    [self transitionInCompletion:dismissComplete];
    [self showBackgroundAnimated];
    [[JDMenuView sharedView] setButton_setUserInteractionEnabled:NO];
}


#pragma mark - 收回视图 -
/**
 收回视图
 **/
- (void)dismissAnimated
{
    void (^dismissComplete)(void) = ^{
        
    };
    
    [self transitionOutCompletion:dismissComplete];
    [self hideBackgroundAnimated];
    [[JDMenuView sharedView] setButton_setUserInteractionEnabled:YES];
    
}


#pragma mark - 弹出动画 -
- (void)showBackgroundAnimated
{
    _view_background.alpha = 0;
    [UIView animateWithDuration:0.3
                     animations:^{
                         _view_background.alpha = 1;
                     }];
    
}

#pragma mark - 隐藏动画 -
/**
 隐藏动画
 **/
- (void)hideBackgroundAnimated
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         _view_background.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [_view_background removeFromSuperview];
                         _view_background = nil;
                         [self removeFromSuperview];
                     }];
}

#pragma  mark - in动画 -
/**
 in动画
 **/
- (void)transitionInCompletion:(void(^)(void))completion
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[@(0.01), @(1.2), @(0.9), @(1)];
    animation.keyTimes = @[@(0), @(0.4), @(0.6), @(1)];
    animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    animation.duration = 0.5;
    [animation setValue:completion forKey:@"handler"];
    [_view_content.layer addAnimation:animation forKey:@"bouce"];
}


#pragma  mark - out动画 -
/**
 out动画
 **/
- (void)transitionOutCompletion:(void(^)(void))completion
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[@(1), @(1.2), @(0.01)];
    animation.keyTimes = @[@(0), @(0.4), @(1)];
    animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    animation.duration = 0.35;
    [animation setValue:completion forKey:@"handler"];
    [_view_content.layer addAnimation:animation forKey:@"bounce"];
    _view_content.transform = CGAffineTransformMakeScale(0.01, 0.01);
}


@end
