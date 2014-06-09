//
//  JDMixerController.m
//  JDKaLa
//
//  Created by zhangminglei on 7/24/13.
//  Copyright (c) 2013 张明磊. All rights reserved.
//

#import "JDMixerController.h"
#import "SKCustomNavigationBar.h"
#import "UIUtils.h"
#import "JDSwitch.h"
#import "JDVolumeBar.h"
//#import "SDMoviePlayerViewController.h"
#import "JDMoviePlayerViewController.h"

#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

typedef enum
{
    JDMixerController_banzou  = 0,
    JDMixerController_rensheng   ,
    JDMixerController_ganshibi   ,
    JDMixerController_zengyi     ,
}JDMixerController_sliderTag;

typedef enum
{
    JDMixerController_buttonCloseOne  =  200,
    JDMixerController_buttonCloseTwo        ,
    JDMixerController_buttonLuyinpeng       ,
    JDMixerController_buttonYanChangHui     ,
    JDMixerController_buttonJingDianNan     ,
    JDMixerController_buttonJingDianNv      ,
    JDMixerController_buttonMySong1         ,
    JDMixerController_buttonMySong2         ,
    JDMixerController_buttonMySong3         ,
    
    JDMixerController_buttonWeak            ,
    JDMixerController_buttonWeak_1          ,
    JDMixerController_buttonMiddle          ,
    JDMixerController_buttonMiddle_1        ,
    JDMixerController_buttonHard            ,
    JDMixerController_buttonHighLevel       ,
}JDMixerController_buttonTag;

typedef enum
{
    JDMixerController_volume0  =  400,
    JDMixerController_volume1        ,
    JDMixerController_volume2        ,
    JDMixerController_volume3        ,
    JDMixerController_volume4        ,
    JDMixerController_volume5        ,
    JDMixerController_volume6        ,
    JDMixerController_volume7        ,
    JDMixerController_volume8        ,
    JDMixerController_volume9        ,
    JDMixerController_volumeA        ,
    JDMixerController_volumeB        ,
    JDMixerController_volumeC        ,
    JDMixerController_volumeD        ,
}JDMixerController_volumeTag;

@implementation JDMixerController

- (id)init
{
    self = [super init];
    if(self)
    {
        //(89, 190, 846, 378)
        [self.view setFrame:CGRectMake(89, -378, 846, 378)];
        [self.view setBackgroundColor:[UIColor whiteColor]];
        [self installMixControlView];
        _bool_zero = NO;
    }
    return self;
}

- (void)installMixControlView
{
    UIImageView *imageView_title = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 846, 149)];
    [UIUtils didLoadImageNotCached:@"headbar-background.png" inImageView:imageView_title];
    [self.view addSubview:imageView_title];
    
    UIButton *button_restore = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_restore setFrame:CGRectMake(20, 8, 81, 34)];
    [UIUtils didLoadImageNotCached:@"headbar-button1.png" inButton:button_restore withState:UIControlStateNormal];
    [self.view addSubview:button_restore];
    
    UIButton *button_close = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_close setFrame:CGRectMake(740, 8, 81, 34)];
    [UIUtils didLoadImageNotCached:@"headbar-button2.png" inButton:button_close withState:UIControlStateNormal];
    [button_close setTag:JDMixerController_buttonCloseOne];
    [button_close addTarget:self action:@selector(didClickButton_title:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_close];
    
    UILabel *label_model = [[UILabel alloc] initWithFrame:CGRectMake(45, 70, 130, 50)];
    [label_model setBackgroundColor:[UIColor clearColor]];
    [label_model setTextColor:[UIColor blackColor]];
    [label_model setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:20]];
    [self.view addSubview:label_model];
    _label_model = label_model;
    [_label_model setText:@"混音强度:中"];
    
    JDSwitch *squareThumbSwitch = [[JDSwitch alloc] initWithFrame:CGRectMake(680, 77, 138, 48)];
    squareThumbSwitch.trackImage = [UIUtils didLoadImageNotCached:@"head-back.png"];
    squareThumbSwitch.overlayImage = [UIUtils didLoadImageNotCached:@"square-switch-overlay.png"];
    squareThumbSwitch.thumbImage = [UIUtils didLoadImageNotCached:@"head-turner.png"];
    squareThumbSwitch.thumbHighlightImage = [UIUtils didLoadImageNotCached:@"head-turner.png"];
    
    squareThumbSwitch.trackMaskImage = [UIUtils didLoadImageNotCached:@"head-backgroud.png"];
    squareThumbSwitch.thumbMaskImage = nil; // Set this to nil to override the UIAppearance setting
    
    squareThumbSwitch.thumbInsetX = -3.0f;
    squareThumbSwitch.thumbOffsetY = -6.0f;
    [squareThumbSwitch setChangeHandler:^(BOOL on)
    {
        switch (on)
        {
            case 0:
            {
                [audioFilter initGraphForMic];
                [_label_model setText:@"特效已开启"];
            }break;
            case 1:
            {
                [audioFilter initGraphForMicWithoutEffect];
                [_label_model setText:@"特效已关闭"];
                
                UIButton *button_weak = (UIButton *)[self.view viewWithTag:JDMixerController_buttonWeak];
                UIButton *button_weak_1 = (UIButton *)[self.view viewWithTag:JDMixerController_buttonWeak_1];
                UIButton *button_middle = (UIButton *)[self.view viewWithTag:JDMixerController_buttonMiddle];
                UIButton *button_middle_1 = (UIButton *)[self.view viewWithTag:JDMixerController_buttonMiddle_1];
                UIButton *button_hard = (UIButton *)[self.view viewWithTag:JDMixerController_buttonHard];
                
                [UIUtils didLoadImageNotCached:@"image_1.png" inButton:button_weak withState:UIControlStateNormal];
                [UIUtils didLoadImageNotCached:@"image_2.png" inButton:button_weak_1 withState:UIControlStateNormal];
                [UIUtils didLoadImageNotCached:@"image_3.png" inButton:button_middle withState:UIControlStateNormal];
                [UIUtils didLoadImageNotCached:@"image_4.png" inButton:button_middle_1 withState:UIControlStateNormal];
                [UIUtils didLoadImageNotCached:@"image_5.png" inButton:button_hard withState:UIControlStateNormal];
                
                _integer_now_semgent = 20;
                
                UIButton *button_pressed = (UIButton *)[self.view viewWithTag:_integer_now];
                switch (_integer_now)
                {
                    case JDMixerController_buttonLuyinpeng:
                    {
                        [UIUtils didLoadImageNotCached:@"middle-button1.png" inButton:button_pressed withState:UIControlStateNormal];
                    }break;
                    case JDMixerController_buttonYanChangHui:
                    {
                        [UIUtils didLoadImageNotCached:@"middle-button2.png" inButton:button_pressed withState:UIControlStateNormal];
                    }break;
                    case JDMixerController_buttonJingDianNan:
                    {
                        [UIUtils didLoadImageNotCached:@"middle-button3.png" inButton:button_pressed withState:UIControlStateNormal];
                    }break;
                    case JDMixerController_buttonJingDianNv:
                    {
                        [UIUtils didLoadImageNotCached:@"middle-button4.png" inButton:button_pressed withState:UIControlStateNormal];
                    }break;
                    case JDMixerController_buttonMySong1:
                    {
                        [UIUtils didLoadImageNotCached:@"middle-button5.png" inButton:button_pressed withState:UIControlStateNormal];
                    }break;
                    case JDMixerController_buttonMySong2:
                    {
                        [UIUtils didLoadImageNotCached:@"middle-button6.png" inButton:button_pressed withState:UIControlStateNormal];
                    }break;
                    case JDMixerController_buttonMySong3:
                    {
                        [UIUtils didLoadImageNotCached:@"middle-button7.png" inButton:button_pressed withState:UIControlStateNormal];
                    }break;
                        
                    default:
                        break;
                }

            }
            default:
                break;
        }
    }];
    _thumbSwitch = squareThumbSwitch;
    [self.view addSubview:squareThumbSwitch];
    
    UIImageView *imageView_backTwo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 149, 846, 233)];
    [UIUtils didLoadImageNotCached:@"middle-background.png" inImageView:imageView_backTwo];
    [self.view addSubview:imageView_backTwo];
    
    UIImageView *imageView_banzou = [[UIImageView alloc] initWithFrame:CGRectMake(30, 10, 135, 42)];
    [UIUtils didLoadImageNotCached:@"middle-banzou.png" inImageView:imageView_banzou];
    [imageView_backTwo addSubview:imageView_banzou];
    
    UILabel *label_banzou = [[UILabel alloc] initWithFrame:CGRectMake(75, 3, 60, 30)];
    [label_banzou setBackgroundColor:[UIColor clearColor]];
    [label_banzou setTextColor:[UIColor blackColor]];
    [label_banzou setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:22.0f]];
    
    float volume_acc = _movePlayer.originalPlayer.volume;
    float volume_no = _movePlayer.silentPlayer.volume;
    
    if(volume_acc == 0)
    {
        [label_banzou setText:[NSString stringWithFormat:@"%d%%",(int)(volume_no * 100)]];
    }
    else
    {
        [label_banzou setText:[NSString stringWithFormat:@"%d%%",(int)(volume_acc*100)]];
    }

    _label_banZou = label_banzou;
    [imageView_banzou addSubview:label_banzou];
    
    UIImageView *imageView_slider_banzou = [[UIImageView alloc] initWithFrame:CGRectMake(55, 62, 86, 128)];
    [UIUtils didLoadImageNotCached:@"middle-volumeturner.png" inImageView:imageView_slider_banzou];
    [imageView_backTwo addSubview:imageView_slider_banzou];
    
    UISlider *slider_banzou = [[UISlider alloc] initWithFrame:CGRectMake(32, 264, 132, 7)];
    [slider_banzou setThumbImage:[UIUtils didLoadImageNotCached:@"slider_buttonImage.png"] forState:UIControlStateNormal];
    [slider_banzou setMaximumTrackImage:[UIUtils didLoadImageNotCached:@"player_progress_back_bg.png"]forState:UIControlStateNormal];
    [slider_banzou setMinimumTrackImage:[UIUtils  didLoadImageNotCached:@"progressMix.png"] forState:UIControlStateNormal];
    [slider_banzou addTarget:self action:@selector(didPressSlider:) forControlEvents:UIControlEventValueChanged];
    slider_banzou.maximumValue = 1.0;
    if(volume_acc == 0)
    {
        slider_banzou.value = volume_no;
    }
    else
    {
        slider_banzou.value = volume_acc;
    }
    
    [slider_banzou setTag:JDMixerController_banzou];
    [self.view addSubview:slider_banzou];
    CGAffineTransform rotation = CGAffineTransformMakeRotation(-1.57079633);
    [slider_banzou setTransform:rotation];
    
    UIImageView *imageView_slider_rensheng = [[UIImageView alloc] initWithFrame:CGRectMake(231, 62, 86, 128)];
    [UIUtils didLoadImageNotCached:@"middle-volumeturner.png" inImageView:imageView_slider_rensheng];
    [imageView_backTwo addSubview:imageView_slider_rensheng];
    
    UIImageView *imageView_rensheng = [[UIImageView alloc] initWithFrame:CGRectMake(206, 10, 135, 42)];
    [UIUtils didLoadImageNotCached:@"middle-rensheng.png" inImageView:imageView_rensheng];
    [imageView_backTwo addSubview:imageView_rensheng];
    
    UILabel *label_rensheng = [[UILabel alloc] initWithFrame:CGRectMake(75, 3, 60, 30)];
    [label_rensheng setBackgroundColor:[UIColor clearColor]];
    [label_rensheng setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:22.0f]];
    [label_rensheng setText:@"100%"];
    [label_rensheng setTextColor:[UIColor blackColor]];
    [imageView_rensheng addSubview:label_rensheng];
    _label_renSheng = label_rensheng;

    UISlider *slider_rensheng = [[UISlider alloc] initWithFrame:CGRectMake(208, 264, 132, 7)];
    [slider_rensheng setThumbImage:[UIUtils didLoadImageNotCached:@"slider_buttonImage.png"] forState:UIControlStateNormal];
    [slider_rensheng setMaximumTrackImage:[UIUtils didLoadImageNotCached:@"player_progress_back_bg.png"]forState:UIControlStateNormal];
    [slider_rensheng setMinimumTrackImage:[UIUtils  didLoadImageNotCached:@"progressMix.png"] forState:UIControlStateNormal];
    [slider_rensheng addTarget:self action:@selector(didPressSlider:) forControlEvents:UIControlEventValueChanged];
    [slider_rensheng setTag:JDMixerController_rensheng];
    slider_rensheng.maximumValue = 1.0;
    slider_rensheng.value = 1.0;
    [self.view addSubview:slider_rensheng];
    [slider_rensheng setTransform:rotation];

    UILabel *label_hunyinqiangdu = [[UILabel alloc] initWithFrame:CGRectMake(469, 165, 200, 40)];
    [label_hunyinqiangdu setBackgroundColor:[UIColor clearColor]];
    [label_hunyinqiangdu setTextColor:[UIColor grayColor]];
    [label_hunyinqiangdu setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:24.0f]];
    [label_hunyinqiangdu setText:@"强度调节"];
    [self.view addSubview:label_hunyinqiangdu];
    
    UIButton *button_weak = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_weak setFrame:CGRectMake(360, 220, 63, 66)];
    [UIUtils didLoadImageNotCached:@"image_1_pressed.png" inButton:button_weak withState:UIControlStateNormal];
    [UIUtils didLoadImageNotCached:@"image_1_pressed.png" inButton:button_weak withState:UIControlStateHighlighted];
    [button_weak setTag:JDMixerController_buttonWeak];
    [button_weak addTarget:self action:@selector(didClickButton_level:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_weak];
    
    UIButton *button_weak_1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_weak_1 setFrame:CGRectMake(423, 220, 61, 66)];
    [UIUtils didLoadImageNotCached:@"image_2_pressed.png" inButton:button_weak_1 withState:UIControlStateNormal];
    [UIUtils didLoadImageNotCached:@"image_2_pressed.png" inButton:button_weak_1 withState:UIControlStateHighlighted];
    [button_weak_1 setTag:JDMixerController_buttonWeak_1];
    [button_weak_1 addTarget:self action:@selector(didClickButton_level:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_weak_1];
    
    UIButton *button_middle = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_middle setFrame:CGRectMake(484, 220, 60, 66)];
    [UIUtils didLoadImageNotCached:@"image_3_pressed.png" inButton:button_middle withState:UIControlStateNormal];
    [UIUtils didLoadImageNotCached:@"image_3_pressed.png" inButton:button_middle withState:UIControlStateHighlighted];
    [button_middle setTag:JDMixerController_buttonMiddle];
    [button_middle addTarget:self action:@selector(didClickButton_level:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_middle];
    
    UIButton *button_middle_1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_middle_1 setFrame:CGRectMake(545, 220, 61, 66)];
    [UIUtils didLoadImageNotCached:@"image_4.png" inButton:button_middle_1 withState:UIControlStateNormal];
    [UIUtils didLoadImageNotCached:@"image_4_pressed.png" inButton:button_middle_1 withState:UIControlStateHighlighted];
    [button_middle_1 setTag:JDMixerController_buttonMiddle_1];
    [button_middle_1 addTarget:self action:@selector(didClickButton_level:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_middle_1];
    
    UIButton *button_hard = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_hard setFrame:CGRectMake(606, 220, 62, 66)];
    [UIUtils didLoadImageNotCached:@"image_5.png" inButton:button_hard withState:UIControlStateNormal];
    [UIUtils didLoadImageNotCached:@"image_5_pressed.png" inButton:button_hard withState:UIControlStateHighlighted];
    [button_hard setTag:JDMixerController_buttonHard];
    [button_hard addTarget:self action:@selector(didClickButton_level:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_hard];
    
    UIButton *button_highLevel = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_highLevel setFrame:CGRectMake(695, 215, 100, 80)];
    [UIUtils didLoadImageNotCached:@"button_highLevel.png" inButton:button_highLevel withState:UIControlStateNormal];
    [UIUtils didLoadImageNotCached:@"button_highLevel_pressed.png" inButton:button_highLevel withState:UIControlStateHighlighted];
    [button_highLevel setTag:JDMixerController_buttonHighLevel];
    [button_highLevel addTarget:self action:@selector(didClickButton_level:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_highLevel];
    
    
    
}

#pragma mark -
#pragma mark DidPressSlider
- (void)didPressSlider:(UISlider *)sender
{
    float progress = sender.value;
    switch (sender.tag)
    {
        case JDMixerController_banzou:
        {
            [_label_banZou setText:[NSString stringWithFormat:@"%d%%",(int)(progress*100)]];
            
            float volume_acc = _movePlayer.originalPlayer.volume;
            
            if(volume_acc == 0)
            {
                [_movePlayer.silentPlayer setVolume:progress];
            }
            else
            {
                [_movePlayer.originalPlayer setVolume:progress];
            }

        }break;
        case JDMixerController_rensheng:
        {
            [_label_renSheng setText:[NSString stringWithFormat:@"%d%%",(int)(progress*100)]];
            [self onVolumeChanged:sender];
            
        }break;
        case JDMixerController_zengyi:
        {
            if((progress*100) >= 50)
            {
                float volume = ((progress*100) - 50)/50.0 *20;
                
               // NSLog(@"%f",(progress*100/500.0)*10);
                [audioFilter setReverbGain:volume];
                [_label_zengyi setText:[NSString stringWithFormat:@"%.1f",volume]];
            }
            else
            {
                float volume = ((progress*100) - 50)/50.0 * 20;
                //NSLog(@"%f",(progress*100/50.0)*10 - 20.0);
                [audioFilter setReverbGain:volume];
                [_label_zengyi setText:[NSString stringWithFormat:@"%.1f",volume]];
            }

        }break;
        case JDMixerController_ganshibi:
        {
            [_label_ganshibi setText:[NSString stringWithFormat:@"%d%%",(int)(progress*100)]];
            [audioFilter setWetDry:(progress*100)];
            
        }break;
        default:
            break;
    }
    
}


#pragma mark - 
#pragma mark DidClickButton
- (void)didClickButton_title:(id)sender
{
    UIButton *buttonTag = (UIButton *)sender;
    switch (buttonTag.tag)
    {
        case JDMixerController_buttonCloseOne:
        {
            [UIUtils removeViewWithAnimation:self.view inCenterPoint:CGPointMake(self.view.center.x, -189) withBoolRemoveView:NO];
            _movePlayer.bool_mixViewHave = NO;
            [_movePlayer showMovieController];
        }break;
        case JDMixerController_buttonCloseTwo:
        {
            [UIUtils removeViewWithAnimation:_view_customMix inCenterPoint:CGPointMake(_view_customMix.center.x + 1024, _view_customMix.center.y) withBoolRemoveView:NO];
        }break;
        default:
            break;
    }
}

/**
 强中弱梯度
 **/
- (void)didClickButton_level:(id)sender
{
    UIButton *buttonTag = (UIButton *)sender;
    if(_integer_now_semgent == buttonTag.tag)
    {
        return;
    }
    switch (buttonTag.tag)
    {            
        case JDMixerController_buttonWeak:
        {
            UIButton *button_weak = (UIButton *)[self.view viewWithTag:JDMixerController_buttonWeak];
            UIButton *button_weak_1 = (UIButton *)[self.view viewWithTag:JDMixerController_buttonWeak_1];
            UIButton *button_middle = (UIButton *)[self.view viewWithTag:JDMixerController_buttonMiddle];
            UIButton *button_middle_1 = (UIButton *)[self.view viewWithTag:JDMixerController_buttonMiddle_1];
            UIButton *button_hard = (UIButton *)[self.view viewWithTag:JDMixerController_buttonHard];
            
            [UIUtils didLoadImageNotCached:@"image_1_pressed.png" inButton:button_weak withState:UIControlStateNormal];
            [UIUtils didLoadImageNotCached:@"image_2.png" inButton:button_weak_1 withState:UIControlStateNormal];
            [UIUtils didLoadImageNotCached:@"image_3.png" inButton:button_middle withState:UIControlStateNormal];
            [UIUtils didLoadImageNotCached:@"image_4.png" inButton:button_middle_1 withState:UIControlStateNormal];
            [UIUtils didLoadImageNotCached:@"image_5.png" inButton:button_hard withState:UIControlStateNormal];
            
            _integer_now_semgent = buttonTag.tag;
            [_label_model setText:@"混音强度:弱"];
            [audioFilter setWetDry:10.0];
            [_movePlayer setInteger_mixTag:8];
        }break;
            
        case JDMixerController_buttonWeak_1:
        {
            UIButton *button_weak = (UIButton *)[self.view viewWithTag:JDMixerController_buttonWeak];
            UIButton *button_weak_1 = (UIButton *)[self.view viewWithTag:JDMixerController_buttonWeak_1];
            UIButton *button_middle = (UIButton *)[self.view viewWithTag:JDMixerController_buttonMiddle];
            UIButton *button_middle_1 = (UIButton *)[self.view viewWithTag:JDMixerController_buttonMiddle_1];
            UIButton *button_hard = (UIButton *)[self.view viewWithTag:JDMixerController_buttonHard];
            
            [UIUtils didLoadImageNotCached:@"image_1_pressed.png" inButton:button_weak withState:UIControlStateNormal];
            [UIUtils didLoadImageNotCached:@"image_2_pressed.png" inButton:button_weak_1 withState:UIControlStateNormal];
            [UIUtils didLoadImageNotCached:@"image_3.png" inButton:button_middle withState:UIControlStateNormal];
            [UIUtils didLoadImageNotCached:@"image_4.png" inButton:button_middle_1 withState:UIControlStateNormal];
            [UIUtils didLoadImageNotCached:@"image_5.png" inButton:button_hard withState:UIControlStateNormal];
            
            _integer_now_semgent = buttonTag.tag;
            [audioFilter setWetDry:25.0];
            [_label_model setText:@""];
            [_movePlayer setInteger_mixTag:9];
        }break;
            
            
        case JDMixerController_buttonMiddle:
        {
            UIButton *button_weak = (UIButton *)[self.view viewWithTag:JDMixerController_buttonWeak];
            UIButton *button_weak_1 = (UIButton *)[self.view viewWithTag:JDMixerController_buttonWeak_1];
            UIButton *button_middle = (UIButton *)[self.view viewWithTag:JDMixerController_buttonMiddle];
            UIButton *button_middle_1 = (UIButton *)[self.view viewWithTag:JDMixerController_buttonMiddle_1];
            UIButton *button_hard = (UIButton *)[self.view viewWithTag:JDMixerController_buttonHard];
            
            [UIUtils didLoadImageNotCached:@"image_1_pressed.png" inButton:button_weak withState:UIControlStateNormal];
            [UIUtils didLoadImageNotCached:@"image_2_pressed.png" inButton:button_weak_1 withState:UIControlStateNormal];
            [UIUtils didLoadImageNotCached:@"image_3_pressed.png" inButton:button_middle withState:UIControlStateNormal];
            [UIUtils didLoadImageNotCached:@"image_4.png" inButton:button_middle_1 withState:UIControlStateNormal];
            [UIUtils didLoadImageNotCached:@"image_5.png" inButton:button_hard withState:UIControlStateNormal];
      
            _integer_now_semgent = buttonTag.tag;
            [audioFilter setWetDry:50.0];
            [_label_model setText:@"混音强度:中"];
            [_movePlayer setInteger_mixTag:10];
        }break;
        
        case JDMixerController_buttonMiddle_1:
        {
            UIButton *button_weak = (UIButton *)[self.view viewWithTag:JDMixerController_buttonWeak];
            UIButton *button_weak_1 = (UIButton *)[self.view viewWithTag:JDMixerController_buttonWeak_1];
            UIButton *button_middle = (UIButton *)[self.view viewWithTag:JDMixerController_buttonMiddle];
            UIButton *button_middle_1 = (UIButton *)[self.view viewWithTag:JDMixerController_buttonMiddle_1];
            UIButton *button_hard = (UIButton *)[self.view viewWithTag:JDMixerController_buttonHard];
            
            [UIUtils didLoadImageNotCached:@"image_1_pressed.png" inButton:button_weak withState:UIControlStateNormal];
            [UIUtils didLoadImageNotCached:@"image_2_pressed.png" inButton:button_weak_1 withState:UIControlStateNormal];
            [UIUtils didLoadImageNotCached:@"image_3_pressed.png" inButton:button_middle withState:UIControlStateNormal];
            [UIUtils didLoadImageNotCached:@"image_4_pressed.png" inButton:button_middle_1 withState:UIControlStateNormal];
            [UIUtils didLoadImageNotCached:@"image_5.png" inButton:button_hard withState:UIControlStateNormal];
        
            _integer_now_semgent = buttonTag.tag;
            
            [audioFilter setWetDry:75.0];
            [_label_model setText:@""];
            [_movePlayer setInteger_mixTag:11];
        }break;
            
        case JDMixerController_buttonHard:
        {
            UIButton *button_weak = (UIButton *)[self.view viewWithTag:JDMixerController_buttonWeak];
            UIButton *button_weak_1 = (UIButton *)[self.view viewWithTag:JDMixerController_buttonWeak_1];
            UIButton *button_middle = (UIButton *)[self.view viewWithTag:JDMixerController_buttonMiddle];
            UIButton *button_middle_1 = (UIButton *)[self.view viewWithTag:JDMixerController_buttonMiddle_1];
            UIButton *button_hard = (UIButton *)[self.view viewWithTag:JDMixerController_buttonHard];
            
            [UIUtils didLoadImageNotCached:@"image_1_pressed.png" inButton:button_weak withState:UIControlStateNormal];
            [UIUtils didLoadImageNotCached:@"image_2_pressed.png" inButton:button_weak_1 withState:UIControlStateNormal];
            [UIUtils didLoadImageNotCached:@"image_3_pressed.png" inButton:button_middle withState:UIControlStateNormal];
            [UIUtils didLoadImageNotCached:@"image_4_pressed.png" inButton:button_middle_1 withState:UIControlStateNormal];
            [UIUtils didLoadImageNotCached:@"image_5_pressed.png" inButton:button_hard withState:UIControlStateNormal];
            
            _integer_now_semgent = buttonTag.tag;
            [_label_model setText:@"混音强度:强"];
            [audioFilter setWetDry:100.0];
            [_movePlayer setInteger_mixTag:12];
        }break;
        case JDMixerController_buttonHighLevel:
        {
            [self installModelView];
        }break;
        default:
            break;
    }
}

- (void)installModelView
{
    [_label_model setText:@"高级模式"];
    
    UIView *view_tmp = [[UIView alloc] initWithFrame:CGRectMake(355 +1024, 150, 490, 230)];
    [view_tmp setBackgroundColor:RGB(44, 44, 44)];
    _view_level = view_tmp;
    
    [self.view addSubview:view_tmp];
    [UIUtils addViewWithAnimation:view_tmp inCenterPoint:CGPointMake(355+245, view_tmp.center.y)];
    
    UIButton *button_luyinpeng = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_luyinpeng setFrame:CGRectMake(45, 22, 69, 86)];
    [button_luyinpeng setTag:JDMixerController_buttonLuyinpeng];
    [UIUtils didLoadImageNotCached:@"middle-button1.png" inButton:button_luyinpeng withState:UIControlStateNormal];
    [UIUtils didLoadImageNotCached:@"middle-button1_pressed.png" inButton:button_luyinpeng withState:UIControlStateHighlighted];
    [button_luyinpeng addTarget:self action:@selector(didClickButton_moden:) forControlEvents:UIControlEventTouchUpInside];
    [view_tmp addSubview:button_luyinpeng];
    
    UIButton *button_yanchanghui = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_yanchanghui setFrame:CGRectMake(button_luyinpeng.frame.origin.x + 115, button_luyinpeng.frame.origin.y, button_luyinpeng.frame.size.width, button_luyinpeng.frame.size.height)];
    [UIUtils didLoadImageNotCached:@"middle-button2.png" inButton:button_yanchanghui withState:UIControlStateNormal];
    [UIUtils didLoadImageNotCached:@"middle-button2_pressed.png" inButton:button_yanchanghui withState:UIControlStateHighlighted];
    [button_yanchanghui setTag:JDMixerController_buttonYanChangHui];
    [button_yanchanghui addTarget:self action:@selector(didClickButton_moden:) forControlEvents:UIControlEventTouchUpInside];
    [view_tmp addSubview:button_yanchanghui];
    
    UIButton *button_jingdiannan = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_jingdiannan setFrame:CGRectMake(button_yanchanghui.frame.origin.x + 115, button_yanchanghui.frame.origin.y, button_yanchanghui.frame.size.width, button_yanchanghui.frame.size.height)];
    [UIUtils didLoadImageNotCached:@"middle-button3.png" inButton:button_jingdiannan withState:UIControlStateNormal];
    [UIUtils didLoadImageNotCached:@"middle-button3_pressed.png" inButton:button_jingdiannan withState:UIControlStateHighlighted];
    [button_jingdiannan setTag:JDMixerController_buttonJingDianNan];
    [button_jingdiannan addTarget:self action:@selector(didClickButton_moden:) forControlEvents:UIControlEventTouchUpInside];
    [view_tmp addSubview:button_jingdiannan];
    
    UIButton *button_jingdiannv = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_jingdiannv setFrame:CGRectMake(button_jingdiannan.frame.origin.x + 115, button_jingdiannan.frame.origin.y, button_jingdiannan.frame.size.width, button_jingdiannan.frame.size.height)];
    [UIUtils didLoadImageNotCached:@"middle-button4.png" inButton:button_jingdiannv withState:UIControlStateNormal];
    [UIUtils didLoadImageNotCached:@"middle-button4_pressed.png" inButton:button_jingdiannv withState:UIControlStateHighlighted];
    [button_jingdiannv setTag:JDMixerController_buttonJingDianNv];
    [button_jingdiannv addTarget:self action:@selector(didClickButton_moden:) forControlEvents:UIControlEventTouchUpInside];
    [view_tmp addSubview:button_jingdiannv];
    
    UIButton *button_wodeyin1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_wodeyin1 setFrame:CGRectMake(button_luyinpeng.frame.origin.x, button_luyinpeng.frame.origin.y + 95, button_luyinpeng.frame.size.width, button_luyinpeng.frame.size.height)];
    [UIUtils didLoadImageNotCached:@"middle-button5.png" inButton:button_wodeyin1 withState:UIControlStateNormal];
    [UIUtils didLoadImageNotCached:@"middle-button5_pressed.png" inButton:button_wodeyin1 withState:UIControlStateHighlighted];
    [button_wodeyin1 setTag:JDMixerController_buttonMySong1];
    [button_wodeyin1 addTarget:self action:@selector(didClickButton_moden:) forControlEvents:UIControlEventTouchUpInside];
    [view_tmp addSubview:button_wodeyin1];
    
    UIButton *button_wodeyin2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_wodeyin2 setFrame:CGRectMake(button_wodeyin1.frame.origin.x + 115, button_wodeyin1.frame.origin.y, button_wodeyin1.frame.size.width, button_wodeyin1.frame.size.height)];
    [UIUtils didLoadImageNotCached:@"middle-button6.png" inButton:button_wodeyin2 withState:UIControlStateNormal];
    [UIUtils didLoadImageNotCached:@"middle-button6_pressed.png" inButton:button_wodeyin2 withState:UIControlStateHighlighted];
    [button_wodeyin2 setTag:JDMixerController_buttonMySong2];
    [button_wodeyin2 addTarget:self action:@selector(didClickButton_moden:) forControlEvents:UIControlEventTouchUpInside];
    [view_tmp addSubview:button_wodeyin2];
    
    UIButton *button_wodeyin3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_wodeyin3 setFrame:CGRectMake(button_wodeyin2.frame.origin.x + 115, button_wodeyin2.frame.origin.y, button_wodeyin2.frame.size.width, button_wodeyin2.frame.size.height)];
    [UIUtils didLoadImageNotCached:@"middle-button8.png" inButton:button_wodeyin3 withState:UIControlStateNormal];
    [UIUtils didLoadImageNotCached:@"middle-button8_pressed.png" inButton:button_wodeyin3 withState:UIControlStateHighlighted];
    [button_wodeyin3 addTarget:self action:@selector(didClickButton_custom:) forControlEvents:UIControlEventTouchUpInside];
    [view_tmp addSubview:button_wodeyin3];
    
    UIButton *button_zidingyi = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_zidingyi setFrame:CGRectMake(button_wodeyin3.frame.origin.x + 115, button_wodeyin3.frame.origin.y, button_wodeyin3.frame.size.width, button_wodeyin3.frame.size.height)];
    [UIUtils didLoadImageNotCached:@"middle-button9.png" inButton:button_zidingyi withState:UIControlStateNormal];
    //[UIUtils didLoadImageNotCached:@"middle-button8_pressed.png" inButton:button_zidingyi withState:UIControlStateHighlighted];
    [button_zidingyi addTarget:self action:@selector(didClickButton_levelBack) forControlEvents:UIControlEventTouchUpInside];
    [view_tmp addSubview:button_zidingyi];
}

- (void)didClickButton_levelBack
{
    [UIUtils removeViewWithAnimation:_view_level inCenterPoint:CGPointMake(_view_level.center.x + 1024, _view_level.center.y) withBoolRemoveView:NO];
}



/**
 各种模式按钮
 **/
- (void)didClickButton_moden:(id)sender
{
    [_thumbSwitch setOn:NO animated:YES];
    UIButton *buttonTag = (UIButton *)sender;
    if(_integer_now == buttonTag.tag)
    {
        return;
    }
    else
    {
        UIButton *button_pressed = (UIButton *)[self.view viewWithTag:_integer_now];
        switch (_integer_now)
        {
            case JDMixerController_buttonLuyinpeng:
            {
                [UIUtils didLoadImageNotCached:@"middle-button1.png" inButton:button_pressed withState:UIControlStateNormal];
            }break;
            case JDMixerController_buttonYanChangHui:
            {
                [UIUtils didLoadImageNotCached:@"middle-button2.png" inButton:button_pressed withState:UIControlStateNormal];
            }break;
            case JDMixerController_buttonJingDianNan:
            {
                [UIUtils didLoadImageNotCached:@"middle-button3.png" inButton:button_pressed withState:UIControlStateNormal];
            }break;
            case JDMixerController_buttonJingDianNv:
            {
                [UIUtils didLoadImageNotCached:@"middle-button4.png" inButton:button_pressed withState:UIControlStateNormal];
            }break;
            case JDMixerController_buttonMySong1:
            {
                [UIUtils didLoadImageNotCached:@"middle-button5.png" inButton:button_pressed withState:UIControlStateNormal];
            }break;
            case JDMixerController_buttonMySong2:
            {
                [UIUtils didLoadImageNotCached:@"middle-button6.png" inButton:button_pressed withState:UIControlStateNormal];
            }break;
            case JDMixerController_buttonMySong3:
            {
                [UIUtils didLoadImageNotCached:@"middle-button7.png" inButton:button_pressed withState:UIControlStateNormal];
            }break;
                
            default:
                break;
        }
    }
    
    switch (buttonTag.tag)
    {
        case JDMixerController_buttonLuyinpeng:
        {
            [UIUtils didLoadImageNotCached:@"middle-button1_pressed.png" inButton:buttonTag withState:UIControlStateNormal];
            _integer_now = buttonTag.tag;
            [_label_model setText:@"录音棚模式"];
            
            [audioFilter setWetDry:50.0];
            [audioFilter setMinDelayTime:0.06];
            [audioFilter setMaxDelayTime:0.12];
            [audioFilter setDecay0HzTime:1.5];
            [audioFilter setDecayNyquistTime:1.5];
            [audioFilter setReverbGain:-5];
            
            [_movePlayer setInteger_mixTag:1];
            
        }break;
        case JDMixerController_buttonYanChangHui:
        {
            [UIUtils didLoadImageNotCached:@"middle-button2_pressed.png" inButton:buttonTag withState:UIControlStateNormal];
            _integer_now = buttonTag.tag;
            [_label_model setText:@"演唱会模式"];
            
            [audioFilter setWetDry:60.0];
            [audioFilter setReverbGain:0];
            [audioFilter setMinDelayTime:0.12];
            [audioFilter setMaxDelayTime:0.48];
            [audioFilter setDecay0HzTime:4];
            [audioFilter setDecayNyquistTime:2];
            
            [_movePlayer setInteger_mixTag:2];
            
        }break;
            
        case JDMixerController_buttonJingDianNan:
        {
            [UIUtils didLoadImageNotCached:@"middle-button3_pressed.png" inButton:buttonTag withState:UIControlStateNormal];
            _integer_now = buttonTag.tag;
            [_label_model setText:@"经典男生模式"];
            
            [audioFilter setWetDry:60];
            [audioFilter setReverbGain:-2];
            [audioFilter setMinDelayTime:0.045];
            [audioFilter setMaxDelayTime:0.09];
            [audioFilter setDecay0HzTime:1.2];
            [audioFilter setDecayNyquistTime:1.2];
            
            [audioFilter setEQBandWidth:1.1 Band:2];
            [audioFilter setEQGain:5 Band:2];
            
            [audioFilter setEQBandWidth:1.0 Band:3];
            [audioFilter setEQGain:-3 Band:3];
            
            [audioFilter setEQBandWidth:0.9 Band:5];
            [audioFilter setEQGain:4 Band:5];
            
            [audioFilter setEQBandWidth:1.3 Band:9];
            [audioFilter setEQGain:-4 Band:9];
            
            [_movePlayer setInteger_mixTag:3];
        }break;
            
        case JDMixerController_buttonJingDianNv:
        {
            [UIUtils didLoadImageNotCached:@"middle-button4_pressed.png" inButton:buttonTag withState:UIControlStateNormal];
            _integer_now = buttonTag.tag;
            [_label_model setText:@"经典女生模式"];
            
            [audioFilter setWetDry:60];
            [audioFilter setReverbGain:-2];
            [audioFilter setMinDelayTime:0.045];
            [audioFilter setMaxDelayTime:0.09];
            [audioFilter setDecay0HzTime:1.2];
            [audioFilter setDecayNyquistTime:1.2];
            
            [audioFilter setEQBandWidth:2.0 Band:1];
            [audioFilter setEQGain:2 Band:1];
            
            [audioFilter setEQBandWidth:0.8 Band:2];
            [audioFilter setEQGain:-4 Band:2];
            
            [audioFilter setEQBandWidth:1.2 Band:5];
            [audioFilter setEQGain:2 Band:5];
            
            [audioFilter setEQBandWidth:1.3 Band:9];
            [audioFilter setEQGain:3 Band:9];
            
            [_movePlayer setInteger_mixTag:4];
            
        }break;
        case JDMixerController_buttonMySong1:
        {
            [UIUtils didLoadImageNotCached:@"middle-button5_pressed.png" inButton:buttonTag withState:UIControlStateNormal];
            _integer_now = buttonTag.tag;
            [_label_model setText:@"我的音效1"];
            
            [_movePlayer setInteger_mixTag:5];
        }break;
        case JDMixerController_buttonMySong2:
        {
            [UIUtils didLoadImageNotCached:@"middle-button6_pressed.png" inButton:buttonTag withState:UIControlStateNormal];
            _integer_now = buttonTag.tag;
            [_label_model setText:@"我的音效2"];
            
            [_movePlayer setInteger_mixTag:6];
        }break;
        case JDMixerController_buttonMySong3:
        {
            [UIUtils didLoadImageNotCached:@"middle-button7_pressed.png" inButton:buttonTag withState:UIControlStateNormal];
            _integer_now = buttonTag.tag;
            [_label_model setText:@"我的音效3"];
            
            [_movePlayer setInteger_mixTag:7];
        }break;
        default:
            break;
    }
}

- (void)didClickButton_custom:(id)sender
{
    if(_view_customMix)
    {
        [UIUtils addViewWithAnimation:_view_customMix inCenterPoint:CGPointMake(423.5, _view_customMix.center.y)];
        return;
    }
    
    UIView *view_customMix = [[UIView alloc] initWithFrame:CGRectMake(847, 0, 847, 378)];
    [self.view addSubview:view_customMix];
    _view_customMix = view_customMix;
    [UIUtils addViewWithAnimation:view_customMix inCenterPoint:CGPointMake(423.5, view_customMix.center.y)];
    
    UIImageView *imageView_backThree = [[UIImageView alloc] initWithFrame:CGRectMake(0, 37, 847, 378)];
    [UIUtils didLoadImageNotCached:@"buttom-background.png" inImageView:imageView_backThree];
    [view_customMix addSubview:imageView_backThree];
    
    SKCustomNavigationBar *barTitle = [[SKCustomNavigationBar alloc] initWithFrame:CGRectMake(0, 0, 847, 50)];
    [_view_customMix addSubview:barTitle];
    
    UILabel *label_title = [[UILabel alloc] initWithFrame:CGRectMake(250, 5, 347, 40)];
    [label_title setBackgroundColor:[UIColor clearColor]];
    [label_title setTextColor:[UIColor whiteColor]];
    [label_title setFont:[UIFont fontWithName:@"Helvetica-Bold" size:25]];
    [label_title setTextAlignment:NSTextAlignmentCenter];
    [label_title setText:@"自定义模式"];
    [barTitle addSubview:label_title];
    
    UIButton *button_close = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_close setFrame:CGRectMake(740, 8, 81, 34)];
    [UIUtils didLoadImageNotCached:@"headbar-button2.png" inButton:button_close withState:UIControlStateNormal];
    [button_close setTag:JDMixerController_buttonCloseTwo];
    [button_close addTarget:self action:@selector(didClickButton_title:) forControlEvents:UIControlEventTouchUpInside];
    [barTitle addSubview:button_close];
    
    UIButton *button_segment_hunxiang = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_segment_hunxiang setFrame:CGRectMake(0, 50, 423, 37)];
    [UIUtils didLoadImageNotCached:@"buttom-button12.png" inButton:button_segment_hunxiang withState:UIControlStateNormal];
    [button_segment_hunxiang setTitle:@"hunxiang" forState:UIControlStateReserved];
    [button_segment_hunxiang addTarget:self action:@selector(didClickButton_segment:) forControlEvents:UIControlEventTouchUpInside];
    [view_customMix addSubview:button_segment_hunxiang];
    _button_hunxiang = button_segment_hunxiang;
    
    UIButton *button_segment_junheng = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_segment_junheng setFrame:CGRectMake(423, 50, 423, 37)];
    [UIUtils didLoadImageNotCached:@"buttom-button21.png" inButton:button_segment_junheng withState:UIControlStateNormal];
    [button_segment_junheng setTitle:@"junheng" forState:UIControlStateReserved];
    [button_segment_junheng addTarget:self action:@selector(didClickButton_segment:) forControlEvents:UIControlEventTouchUpInside];
    [view_customMix addSubview:button_segment_junheng];
    _button_junheng = button_segment_junheng;
    
    UILabel *label_name1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 163, 50, 30)];
    [label_name1 setBackgroundColor:[UIColor clearColor]];
    [label_name1 setTextColor:[UIColor grayColor]];
    [label_name1 setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:24.0f]];
    [label_name1 setText:@"振幅"];
    [view_customMix addSubview:label_name1];
    
    CGRect frame = CGRectMake(70, 128, 0, 0);/* 大小由背景图决定 */
    JDVolumeBar *bar_one = [[JDVolumeBar alloc] initWithFrame:frame minimumVolume:0 maximumVolume:100];
    [bar_one addTarget:self action:@selector(didVolumeBarChange:) forControlEvents:UIControlEventValueChanged];
    [bar_one setTag:JDMixerController_volume0];
    [view_customMix addSubview:bar_one];
    bar_one.currentVolume = 0;
    /**相距146**/
    
    UITextField *text_one = [[UITextField alloc] initWithFrame:CGRectMake(96, 105, 78, 25)];
    [text_one setTextAlignment:NSTextAlignmentCenter];
    [text_one setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:18]];
    [text_one setBackground:[UIUtils didLoadImageNotCached:@"buttom-coulourback.png"]];
    [text_one setText:[NSString stringWithFormat:@"60 Hz"]];
    [text_one setTextColor:[UIColor blackColor]];
    [view_customMix addSubview:text_one];
    /**相距148**/
    
    CGRect frame_two = CGRectMake(216, 128, 0, 0);/* 大小由背景图决定 */
    JDVolumeBar *bar_two = [[JDVolumeBar alloc] initWithFrame:frame_two minimumVolume:0 maximumVolume:100];
    [bar_two addTarget:self action:@selector(didVolumeBarChange:) forControlEvents:UIControlEventValueChanged];
    [bar_two setTag:JDMixerController_volume1];
    [view_customMix addSubview:bar_two];
    bar_two.currentVolume = 0;
    
    UITextField *text_two = [[UITextField alloc] initWithFrame:CGRectMake(242, 105, 78, 25)];
    [text_two setTextAlignment:NSTextAlignmentCenter];
    [text_two setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:18]];
    [text_two setBackground:[UIUtils didLoadImageNotCached:@"buttom-coulourback.png"]];
    [text_two setText:[NSString stringWithFormat:@"170 Hz"]];
    [text_two setTextColor:[UIColor blackColor]];
    [view_customMix addSubview:text_two];
    
    CGRect frame_three = CGRectMake(362, 128, 0, 0);/* 大小由背景图决定 */
    JDVolumeBar *bar_three = [[JDVolumeBar alloc] initWithFrame:frame_three minimumVolume:0 maximumVolume:100];
    [bar_three addTarget:self action:@selector(didVolumeBarChange:) forControlEvents:UIControlEventValueChanged];
    [bar_three setTag:JDMixerController_volume2];
    [view_customMix addSubview:bar_three];
    bar_three.currentVolume = 0;
    
    UITextField *text_three = [[UITextField alloc] initWithFrame:CGRectMake(388, 105, 78, 25)];
    [text_three setTextAlignment:NSTextAlignmentCenter];
    [text_three setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:18]];
    [text_three setBackground:[UIUtils didLoadImageNotCached:@"buttom-coulourback.png"]];
    [text_three setText:[NSString stringWithFormat:@"370 Hz"]];
    [text_three setTextColor:[UIColor blackColor]];
    [view_customMix addSubview:text_three];
    
    CGRect frame_four = CGRectMake(508, 128, 0, 0);/* 大小由背景图决定 */
    JDVolumeBar *bar_four = [[JDVolumeBar alloc] initWithFrame:frame_four minimumVolume:0 maximumVolume:100];
    [bar_four addTarget:self action:@selector(didVolumeBarChange:) forControlEvents:UIControlEventValueChanged];
    [bar_four setTag:JDMixerController_volume3];
    [view_customMix addSubview:bar_four];
    bar_four.currentVolume = 0;
    
    UITextField *text_four = [[UITextField alloc] initWithFrame:CGRectMake(534, 105, 78, 25)];
    [text_four setTextAlignment:NSTextAlignmentCenter];
    [text_four setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:18]];
    [text_four setBackground:[UIUtils didLoadImageNotCached:@"buttom-coulourback.png"]];
    [text_four setText:[NSString stringWithFormat:@"600 Hz"]];
    [text_four setTextColor:[UIColor blackColor]];
    [view_customMix addSubview:text_four];
    
    CGRect frame_five = CGRectMake(656, 128, 0, 0);/* 大小由背景图决定 */
    JDVolumeBar *bar_five = [[JDVolumeBar alloc] initWithFrame:frame_five minimumVolume:0 maximumVolume:100];
    [bar_five addTarget:self action:@selector(didVolumeBarChange:) forControlEvents:UIControlEventValueChanged];
    [bar_five setTag:JDMixerController_volume4];
    [view_customMix addSubview:bar_five];
    bar_five.currentVolume = 0;
    
    UITextField *text_five = [[UITextField alloc] initWithFrame:CGRectMake(680, 105, 78, 25)];
    [text_five setTextAlignment:NSTextAlignmentCenter];
    [text_five setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:18]];
    [text_five setBackground:[UIUtils didLoadImageNotCached:@"buttom-coulourback.png"]];
    [text_five setText:[NSString stringWithFormat:@"1000 Hz"]];
    [text_five setTextColor:[UIColor blackColor]];
    [view_customMix addSubview:text_five];
    
    UILabel *label_name2 = [[UILabel alloc] initWithFrame:CGRectMake(15, 88 + 245, 50, 30)];
    [label_name2 setBackgroundColor:[UIColor clearColor]];
    [label_name2 setTextColor:[UIColor grayColor]];
    [label_name2 setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:24.0f]];
    [label_name2 setText:@"增益"];
    [view_customMix addSubview:label_name2];
    
    CGRect frame_six = CGRectMake(70, 88+200, 0, 0);/* 大小由背景图决定 */
    JDVolumeBar *bar_six = [[JDVolumeBar alloc] initWithFrame:frame_six minimumVolume:0 maximumVolume:100];
    [bar_six addTarget:self action:@selector(didVolumeBarChange:) forControlEvents:UIControlEventValueChanged];
    [bar_six setTag:JDMixerController_volume5];
    [view_customMix addSubview:bar_six];
    bar_six.currentVolume = 0;
    /**相距146**/
    
    UITextField *text_six = [[UITextField alloc] initWithFrame:CGRectMake(96, 55+205, 78, 25)];
    [text_six setTextAlignment:NSTextAlignmentCenter];
    [text_six setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:18]];
    [text_six setBackground:[UIUtils didLoadImageNotCached:@"buttom-coulourback.png"]];
    [text_six setText:[NSString stringWithFormat:@"3000 Hz"]];
    [text_six setTextColor:[UIColor blackColor]];
    [view_customMix addSubview:text_six];
    /**相距148**/
    
    CGRect frame_seven = CGRectMake(216, 88+200, 0, 0);/* 大小由背景图决定 */
    JDVolumeBar *bar_seven = [[JDVolumeBar alloc] initWithFrame:frame_seven minimumVolume:0 maximumVolume:100];
    [bar_seven addTarget:self action:@selector(didVolumeBarChange:) forControlEvents:UIControlEventValueChanged];
    [bar_seven setTag:JDMixerController_volume6];
    [view_customMix addSubview:bar_seven];
    bar_seven.currentVolume = 0;
    
    UITextField *text_seven = [[UITextField alloc] initWithFrame:CGRectMake(242, 55+205, 78, 25)];
    [text_seven setTextAlignment:NSTextAlignmentCenter];
    [text_seven setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:18]];
    [text_seven setBackground:[UIUtils didLoadImageNotCached:@"buttom-coulourback.png"]];
    [text_seven setText:[NSString stringWithFormat:@"6000 Hz"]];
    [text_seven setTextColor:[UIColor blackColor]];
    [view_customMix addSubview:text_seven];
    
    CGRect frame_eight = CGRectMake(362, 88+200, 0, 0);/* 大小由背景图决定 */
    JDVolumeBar *bar_eight = [[JDVolumeBar alloc] initWithFrame:frame_eight minimumVolume:0 maximumVolume:100];
    [bar_eight addTarget:self action:@selector(didVolumeBarChange:) forControlEvents:UIControlEventValueChanged];
    [bar_eight setTag:JDMixerController_volume7];
    [view_customMix addSubview:bar_eight];
    bar_eight.currentVolume = 0;
    
    UITextField *text_eight = [[UITextField alloc] initWithFrame:CGRectMake(388, 55+205, 78, 25)];
    [text_eight setTextAlignment:NSTextAlignmentCenter];
    [text_eight setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:18]];
    [text_eight setBackground:[UIUtils didLoadImageNotCached:@"buttom-coulourback.png"]];
    [text_eight setText:[NSString stringWithFormat:@"12000 Hz"]];
    [text_eight setTextColor:[UIColor blackColor]];
    [view_customMix addSubview:text_eight];
    
    CGRect frame_nine = CGRectMake(508, 88+200, 0, 0);/* 大小由背景图决定 */
    JDVolumeBar *bar_nine = [[JDVolumeBar alloc] initWithFrame:frame_nine minimumVolume:0 maximumVolume:100];
    [bar_nine addTarget:self action:@selector(didVolumeBarChange:) forControlEvents:UIControlEventValueChanged];
    [bar_nine setTag:JDMixerController_volume8];
    [view_customMix addSubview:bar_nine];
    bar_nine.currentVolume = 0;
    
    UITextField *text_nine = [[UITextField alloc] initWithFrame:CGRectMake(534, 55+205, 78, 25)];
    [text_nine setTextAlignment:NSTextAlignmentCenter];
    [text_nine setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:18]];
    [text_nine setBackground:[UIUtils didLoadImageNotCached:@"buttom-coulourback.png"]];
    [text_nine setText:[NSString stringWithFormat:@"14000 Hz"]];
    [text_nine setTextColor:[UIColor blackColor]];
    [view_customMix addSubview:text_nine];
    
    CGRect frame_ten = CGRectMake(656, 88+200, 0, 0);/* 大小由背景图决定 */
    JDVolumeBar *bar_ten = [[JDVolumeBar alloc] initWithFrame:frame_ten minimumVolume:0 maximumVolume:100];
    [bar_ten addTarget:self action:@selector(didVolumeBarChange:) forControlEvents:UIControlEventValueChanged];
    [bar_ten setTag:JDMixerController_volume9];
    [view_customMix addSubview:bar_ten];
    bar_ten.currentVolume = 0;
    
    UITextField *text_ten = [[UITextField alloc] initWithFrame:CGRectMake(680, 55+205, 78, 25)];
    [text_ten setTextAlignment:NSTextAlignmentCenter];
    [text_ten setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:18]];
    [text_ten setBackground:[UIUtils didLoadImageNotCached:@"buttom-coulourback.png"]];
    [text_ten setText:[NSString stringWithFormat:@"16000 Hz"]];
    [text_ten setTextColor:[UIColor blackColor]];
    [view_customMix addSubview:text_ten];
}


- (void)didClickButton_segment:(id)sender
{
    UIButton *button_s = (UIButton *)sender;
    if([[button_s titleForState:UIControlStateReserved] isEqualToString:@"hunxiang"])
    {
        if(_view_viewChange)
        {
            [_view_viewChange setHidden:NO];
        }
        else
        {
            UIView *view_mix2 = [[UIView alloc] initWithFrame:CGRectMake(0, 87, 847, 285)];
            UIImageView *imageView_back = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 847, 325)];
            [UIUtils didLoadImageNotCached:@"buttom-background.png" inImageView:imageView_back];
            [view_mix2 addSubview:imageView_back];
            _view_viewChange = view_mix2;
            [_view_customMix addSubview:view_mix2];
            
            UIImageView *imageView_banzou = [[UIImageView alloc] initWithFrame:CGRectMake(30, 30, 135, 42)];
            [UIUtils didLoadImageNotCached:@"middle-ganshibi.png" inImageView:imageView_banzou];
            [view_mix2 addSubview:imageView_banzou];
            
            UILabel *label_banzou = [[UILabel alloc] initWithFrame:CGRectMake(75, 3, 60, 30)];
            [label_banzou setBackgroundColor:[UIColor clearColor]];
            [label_banzou setTextColor:[UIColor blackColor]];
            [label_banzou setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:22.0f]];
            
            [label_banzou setText:@"0%"];
            
            _label_ganshibi = label_banzou;
            [imageView_banzou addSubview:label_banzou];
            
            UIImageView *imageView_slider_banzou = [[UIImageView alloc] initWithFrame:CGRectMake(55, 122, 86, 128)];
            [UIUtils didLoadImageNotCached:@"middle-volumeturner.png" inImageView:imageView_slider_banzou];
            [view_mix2 addSubview:imageView_slider_banzou];
            
            UISlider *slider_banzou = [[UISlider alloc] initWithFrame:CGRectMake(32, 176, 132, 7)];
            [slider_banzou setThumbImage:[UIUtils didLoadImageNotCached:@"slider_buttonImage.png"] forState:UIControlStateNormal];
            [slider_banzou setMaximumTrackImage:[UIUtils didLoadImageNotCached:@"player_progress_back_bg.png"]forState:UIControlStateNormal];
            [slider_banzou setMinimumTrackImage:[UIUtils  didLoadImageNotCached:@"progressMix.png"] forState:UIControlStateNormal];
            [slider_banzou addTarget:self action:@selector(didPressSlider:) forControlEvents:UIControlEventValueChanged];
            slider_banzou.maximumValue = 1.0;
            slider_banzou.value = 0;
            
            [slider_banzou setTag:JDMixerController_ganshibi];
            [view_mix2 addSubview:slider_banzou];
            CGAffineTransform rotation = CGAffineTransformMakeRotation(-1.57079633);
            [slider_banzou setTransform:rotation];
            
            
            UIImageView *imageView_slider_rensheng = [[UIImageView alloc] initWithFrame:CGRectMake(231, 122, 86, 128)];
            [UIUtils didLoadImageNotCached:@"middle-volumeturner.png" inImageView:imageView_slider_rensheng];
            [view_mix2 addSubview:imageView_slider_rensheng];
            
            UIImageView *imageView_rensheng = [[UIImageView alloc] initWithFrame:CGRectMake(206, 30, 135, 42)];
            [UIUtils didLoadImageNotCached:@"middle-zengyi.png" inImageView:imageView_rensheng];
            [view_mix2 addSubview:imageView_rensheng];
            
            UILabel *label_rensheng = [[UILabel alloc] initWithFrame:CGRectMake(75, 3, 70, 30)];
            [label_rensheng setBackgroundColor:[UIColor clearColor]];
            [label_rensheng setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:21.0f]];
            [label_rensheng setText:@"0"];
            [label_rensheng setTextColor:[UIColor blackColor]];
            [imageView_rensheng addSubview:label_rensheng];
            _label_zengyi = label_rensheng;
            
            UISlider *slider_rensheng = [[UISlider alloc] initWithFrame:CGRectMake(208, 176, 132, 7)];
            [slider_rensheng setThumbImage:[UIUtils didLoadImageNotCached:@"slider_buttonImage.png"] forState:UIControlStateNormal];
            [slider_rensheng setMaximumTrackImage:[UIUtils didLoadImageNotCached:@"player_progress_back_bg.png"]forState:UIControlStateNormal];
            [slider_rensheng setMinimumTrackImage:[UIUtils  didLoadImageNotCached:@"progressMix.png"] forState:UIControlStateNormal];
            [slider_rensheng addTarget:self action:@selector(didPressSlider:) forControlEvents:UIControlEventValueChanged];
            [slider_rensheng setTag:JDMixerController_zengyi];
            slider_rensheng.maximumValue = 1.0;
            slider_rensheng.value = 0.5;
            [view_mix2 addSubview:slider_rensheng];
            [slider_rensheng setTransform:rotation];
            
            CGRect frame_A = CGRectMake(375, 90, 0, 0);/* 大小由背景图决定 */
            JDVolumeBar *bar_A = [[JDVolumeBar alloc] initWithFrame:frame_A minimumVolume:0 maximumVolume:100];
            [bar_A addTarget:self action:@selector(didVolumeBarChange:) forControlEvents:UIControlEventValueChanged];
            [bar_A setTag:JDMixerController_volumeA];
            [view_mix2 addSubview:bar_A];
            bar_A.currentVolume = 0;
           
            UITextField *text_A = [[UITextField alloc] initWithFrame:CGRectMake(400, 60, 78, 30)];
            [text_A setTextAlignment:NSTextAlignmentCenter];
            [text_A setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:22]];
            [text_A setBackground:[UIUtils didLoadImageNotCached:@"buttom-coulourback.png"]];
            [text_A setText:[NSString stringWithFormat:@"0 ms"]];
            [text_A setTextColor:[UIColor blackColor]];
            [view_mix2 addSubview:text_A];
            _text_a = text_A;
            
            CGRect frame_B = CGRectMake(487, 90, 0, 0);/* 大小由背景图决定 */
            JDVolumeBar *bar_B = [[JDVolumeBar alloc] initWithFrame:frame_B minimumVolume:0 maximumVolume:100];
            [bar_B addTarget:self action:@selector(didVolumeBarChange:) forControlEvents:UIControlEventValueChanged];
            [bar_B setTag:JDMixerController_volumeB];
            [view_mix2 addSubview:bar_B];
            bar_B.currentVolume = 0;
            
            UITextField *text_B = [[UITextField alloc] initWithFrame:CGRectMake(513, 60, 78, 30)];
            [text_B setTextAlignment:NSTextAlignmentCenter];
            [text_B setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:22]];
            [text_B setBackground:[UIUtils didLoadImageNotCached:@"buttom-coulourback.png"]];
            [text_B setText:[NSString stringWithFormat:@"0 ms"]];
            [text_B setTextColor:[UIColor blackColor]];
            [view_mix2 addSubview:text_B];
            _text_b = text_B;
            
            CGRect frame_C = CGRectMake(602, 90, 0, 0);/* 大小由背景图决定 */
            JDVolumeBar *bar_C = [[JDVolumeBar alloc] initWithFrame:frame_C minimumVolume:0 maximumVolume:100];
            [bar_C addTarget:self action:@selector(didVolumeBarChange:) forControlEvents:UIControlEventValueChanged];
            [bar_C setTag:JDMixerController_volumeC];
            [view_mix2 addSubview:bar_C];
            bar_C.currentVolume = 0;
            
            UITextField *text_C = [[UITextField alloc] initWithFrame:CGRectMake(626, 60, 78, 30)];
            [text_C setTextAlignment:NSTextAlignmentCenter];
            [text_C setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:22]];
            [text_C setBackground:[UIUtils didLoadImageNotCached:@"buttom-coulourback.png"]];
            [text_C setText:[NSString stringWithFormat:@"0 s"]];
            [text_C setTextColor:[UIColor blackColor]];
            [view_mix2 addSubview:text_C];
            _text_c = text_C;
            
            CGRect frame_D = CGRectMake(714, 90, 0, 0);/* 大小由背景图决定 */
            JDVolumeBar *bar_D = [[JDVolumeBar alloc] initWithFrame:frame_D minimumVolume:0 maximumVolume:100];
            [bar_D addTarget:self action:@selector(didVolumeBarChange:) forControlEvents:UIControlEventValueChanged];
            [bar_D setTag:JDMixerController_volumeD];
            [view_mix2 addSubview:bar_D];
            bar_D.currentVolume = 0;
            
            UITextField *text_D = [[UITextField alloc] initWithFrame:CGRectMake(739, 60, 78, 30)];
            [text_D setTextAlignment:NSTextAlignmentCenter];
            [text_D setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:22]];
            [text_D setBackground:[UIUtils didLoadImageNotCached:@"buttom-coulourback.png"]];
            [text_D setText:[NSString stringWithFormat:@"0 s"]];
            [text_D setTextColor:[UIColor blackColor]];
            [view_mix2 addSubview:text_D];
            _text_d = text_D;
            
            UILabel *label_a = [[UILabel alloc] initWithFrame:CGRectMake(400, 210, 100, 30)];
            [label_a setBackgroundColor:[UIColor clearColor]];
            [label_a setTextColor:[UIColor colorWithWhite:0.8 alpha:0.8]];
            [label_a setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:20.0]];
            [label_a setText:@"最小延迟"];
            [view_mix2 addSubview:label_a];
            
            UILabel *label_b = [[UILabel alloc] initWithFrame:CGRectMake(513, 210, 100, 30)];
            [label_b setBackgroundColor:[UIColor clearColor]];
            [label_b setTextColor:[UIColor colorWithWhite:0.8 alpha:0.8]];
            [label_b setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:20.0]];
            [label_b setText:@"最大延迟"];
            [view_mix2 addSubview:label_b];
            
            UILabel *label_c = [[UILabel alloc] initWithFrame:CGRectMake(626, 210, 100, 30)];
            [label_c setBackgroundColor:[UIColor clearColor]];
            [label_c setTextColor:[UIColor colorWithWhite:0.8 alpha:0.8]];
            [label_c setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:20.0]];
            [label_c setText:@"混响时间"];
            [view_mix2 addSubview:label_c];
            
            UILabel *label_d = [[UILabel alloc] initWithFrame:CGRectMake(739, 210, 100, 30)];
            [label_d setBackgroundColor:[UIColor clearColor]];
            [label_d setTextColor:[UIColor colorWithWhite:0.8 alpha:0.8]];
            [label_d setFont:[UIFont fontWithName:@"ShiShangZhongHeiJianTi" size:20.0]];
            [label_d setText:@"衰减时间"];
            [view_mix2 addSubview:label_d];
        }
        [UIUtils didLoadImageNotCached:@"buttom-button11.png" inButton:button_s withState:UIControlStateNormal];
        [UIUtils didLoadImageNotCached:@"buttom-button22.png" inButton:_button_junheng withState:UIControlStateNormal];
        
    }
    else if([[button_s titleForState:UIControlStateReserved] isEqualToString:@"junheng"])
    {
        [UIUtils didLoadImageNotCached:@"buttom-button21.png" inButton:button_s withState:UIControlStateNormal];
        [UIUtils didLoadImageNotCached:@"buttom-button12.png" inButton:_button_hunxiang withState:UIControlStateNormal];
        
        [_view_viewChange setHidden:YES];
    }
}

- (void)didVolumeBarChange:(id)sender
{
    JDVolumeBar *bar = sender;
    float volume_bar;
    
    volume_bar = (float)(([bar currentVolume]-50)/50.0)*12;
    switch (bar.tag)
    {
        case JDMixerController_volume0:
        {
            [audioFilter setEQGain:volume_bar Band:0];
        }break;
        case JDMixerController_volume1:
        {
            [audioFilter setEQGain:volume_bar Band:1];
        }break;
        case JDMixerController_volume2:
        {
            [audioFilter setEQGain:volume_bar Band:2];
        }break;
        case JDMixerController_volume3:
        {
            [audioFilter setEQGain:volume_bar Band:3];
        }break;
        case JDMixerController_volume4:
        {
            [audioFilter setEQGain:volume_bar Band:4];
        }break;
        case JDMixerController_volume5:
        {
            [audioFilter setEQGain:volume_bar Band:5];
        }break;
        case JDMixerController_volume6:
        {
            [audioFilter setEQGain:volume_bar Band:6];
        }break;
        case JDMixerController_volume7:
        {
            [audioFilter setEQGain:volume_bar Band:7];
        }break;
        case JDMixerController_volume8:
        {
            [audioFilter setEQGain:volume_bar Band:8];
        }break;
        case JDMixerController_volume9:
        {
            [audioFilter setEQGain:volume_bar Band:9];
        }break;
        case JDMixerController_volumeA:
        {
            float v =[bar currentVolume]/100.0 *1000;
            float v_s =[bar currentVolume]/100.0 *1 +0.001;
            [_text_a setText:[NSString stringWithFormat:@"%.0fms",v]];
            [audioFilter setMaxDelayTime:v_s];
        }break;
        case JDMixerController_volumeB:
        {
            float v =[bar currentVolume]/100.0 *1000;
            float v_s =[bar currentVolume]/100.0 *1 +0.001;
            [_text_b setText:[NSString stringWithFormat:@"%.0fms",v]];
            [audioFilter setMinDelayTime:v_s];
        }break;
        case JDMixerController_volumeC:
        {
            float v =[bar currentVolume]+1/100.0 *4;
            NSLog(@"%f",v);
            [_text_c setText:[NSString stringWithFormat:@"%.1fs",v]];
            [audioFilter setDecay0HzTime:v];
        }break;
        case JDMixerController_volumeD:
        {
            float v =[bar currentVolume]+1/100.0 *4;
            [_text_d setText:[NSString stringWithFormat:@"%.1fs",v]];
            [audioFilter setDecayNyquistTime:v];
        }break;
        default:
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    audioFilter = [[JDAudioFilter alloc]init];
}

/**
 * 开始播放文件
 */
- (void)startPlayFile
{
    [audioFilter stopGraph];
    //[audioFilter initGraphForPlayFile];
}

/**
 * 开启麦克风
 */
- (void)startMicphone
{
    [audioFilter stopGraph];
    [audioFilter initAudioSession];
    [audioFilter initGraphForMic];
}

- (void)installMiddleK
{
    [audioFilter setWetDry:50.0];
    [_movePlayer setInteger_mixTag:10];
}

/**
 * 停止麦克风
 */
- (void)stopMicphone
{
    [audioFilter stopGraph];
    [audioFilter stopAudioSession];
}

/**
 * 最小延迟时间改变时的处理函数
 */
- (void)onMinDelayTimeChanged:(id)sender
{
    //如果最小延迟时间被设定为大于最大延迟时间的值，则随之调整最大延迟时间
    /*if([self.minDelayTime value] >= [self.maxDelayTime value])
    {
        [self.maxDelayTime setValue:[self.minDelayTime value]];
        [audioFilter setMaxDelayTime:[self.minDelayTime value]];
    }
    
    [audioFilter setMinDelayTime:[self.minDelayTime value]];*/
}

/**
 * 最大延迟时间改变时的处理函数
 */
- (void)onMaxDelayTimeChanged:(id)sender
{
    //如果最大延迟时间被设定为小于最小延迟时间的值，则随之调整最小延迟时间
    /*if([self.maxDelayTime value] <= [self.minDelayTime value])
    {
        [self.minDelayTime setValue:[self.maxDelayTime value]];
        [audioFilter setMinDelayTime:[self.maxDelayTime value]];
    }
    
    [audioFilter setMaxDelayTime:[self.maxDelayTime value]];*/
}

/**
 * 调节第一级均衡的值
 */
- (void)eq0Changed:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    [audioFilter setEQGain:[slider value] Band:0];
}

/**
 * 调节第二级均衡的值
 */
- (void)eq1Changed:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    [audioFilter setEQGain:[slider value] Band:1];
}

/**
 * 调节第三级均衡的值
 */
- (void)eq2Changed:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    [audioFilter setEQGain:[slider value] Band:2];
}

/**
 * 调节第四级均衡的值
 */
- (void)eq3Changed:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    [audioFilter setEQGain:[slider value] Band:3];
}

/**
 * 调节第五级均衡的值
 */
- (void)eq4Changed:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    [audioFilter setEQGain:[slider value] Band:4];
}

/**
 * 调节第六级均衡的值
 */
- (void)eq5Changed:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    [audioFilter setEQGain:[slider value] Band:5];
}

/**
 * 调节第七级均衡的值
 */
- (void)eq6Changed:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    [audioFilter setEQGain:[slider value] Band:6];
}

/**
 * 调节第八级均衡的值
 */
- (void)eq7Changed:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    [audioFilter setEQGain:[slider value] Band:7];
}

/**
 * 调节第九级均衡的值
 */
- (void)eq8Changed:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    [audioFilter setEQGain:[slider value] Band:8];
}

/**
 * 调节第十级均衡的值
 */
- (void)eq9Changed:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    [audioFilter setEQGain:[slider value] Band:9];
}

/**
 * 调节音量
 */
- (void)onVolumeChanged:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    if(slider.value == 0)
    {
        [self stopMicphone];
        _bool_zero = YES;
    }
    else
    {
        if(_bool_zero)
        {
            [self startMicphone];
            //[audioFilter initAudioSession];
        }
        [audioFilter initAudioSession];
    }
}

/**
 * 干湿度调整
 */
- (void)onWetDryChanged:(id)sender
{
    //[audioFilter setWetDry:[self.reverbLevel value]];
}

/**
 * 混响增益调整
 */
- (void)onReverbGainChanged:(id)sender
{
    //[audioFilter setReverbGain:[self.gainLevel value]];
}

/**
 * 调整衰减时间1
 */
- (void)onDecayTime1Changed:(id)sender
{
    //[audioFilter setDecay0HzTime:[self.decayTime1 value]];
}

/**
 * 调整衰减时间2
 */
- (void)onDecayTime2Changed:(id)sender
{
    //[audioFilter setDecayNyquistTime:[self.decayTime2 value]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
