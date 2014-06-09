//
//  JDUserInfoChangeView.m
//  JDKaLa
//
//  Created by zhangminglei on 6/28/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDUserInfoChangeView.h"
#import "UIUtils.h"
#import "SIAlertView.h"
#import "UIImage+IF.h"
#import "JDModel_userInfo.h"
#import "ClientAgent.h"
#import "CustomAlertView.h"
#import "AccountMasterViewController.h"
#import "UIButton+WebCache.h"


@implementation JDUserInfoChangeView

- (id)init
{
    self = [super init];
    if(self)
    {
        agent = [[ClientAgent alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
               selector:@selector(handleValidateNickName:)
                   name:NOTI_VALIDATE_NICKNAME_RESULT
                 object:nil];
        
        _bool_text = NO;
        _bool_text_again = NO;
        
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 450, 475)];
        [UIUtils didLoadImageNotCached:@"alter_userInfo.png" inImageView:imageV];
        [self addSubview:imageV];
        [imageV release];
        
        UILabel *label_titel = [[UILabel alloc]initWithFrame:CGRectMake(90, 0, 300, 50)];
        [label_titel setBackgroundColor:[UIColor clearColor]];
        [label_titel setTextAlignment:NSTextAlignmentCenter];
        label_titel.font = [UIFont fontWithName:@"Helvetica-Bold" size:25];
        [label_titel setTextColor:[UIColor whiteColor]];
        [label_titel setText:@"修改个人信息资料"];
        [self addSubview:label_titel];
        [label_titel release];
        
        UIImageView *imageView_userName = [[UIImageView alloc] initWithFrame:CGRectMake(35, 80, 80, 26)];
        [UIUtils didLoadImageNotCached:@"user_profile_title_avatar.png" inImageView:imageView_userName];
        [self addSubview:imageView_userName];
        [imageView_userName release];
        
        UIImageView *imageView_petName = [[UIImageView alloc] initWithFrame:CGRectMake(200, 80, 44, 26)];
        [UIUtils didLoadImageNotCached:@"user_profile_title_nickname.png" inImageView:imageView_petName];
        [self addSubview:imageView_petName];
        [imageView_petName release];
        
        UIButton *button_head = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_head setFrame:CGRectMake(35, 110, 130, 130)];
        UIImage *image_place = [UIUtils didLoadImageNotCached:@"user_profileavatar.png"];
        [button_head setImageWithURL:[NSURL URLWithString:[JDModel_userInfo sharedModel].string_portrait] placeholderImage:image_place];
        [button_head addTarget:self action:@selector(didClickButton_head) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button_head];
        _button_head_change = button_head;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(10, 7, 65, 37)];
        [UIUtils didLoadImageNotCached:@"back_btn.png" inButton:button withState:UIControlStateNormal];
        [button setTitle:nil forState:UIControlStateNormal];
        [button addTarget:self action:@selector(didClickButton_back) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        UIImageView *imageView_testUserName = [[UIImageView alloc] initWithFrame:CGRectMake(200, 110, 200, 40)];
        [UIUtils didLoadImageNotCached:@"search_field.png" inImageView:imageView_testUserName];
        [self addSubview:imageView_testUserName];
        [imageView_testUserName release];
         
        UITextField *text_userName = [[UITextField alloc] initWithFrame:CGRectMake(220, 120, 280, 22)];
        [text_userName setBackgroundColor:[UIColor clearColor]];
        [text_userName setTextColor:[UIColor grayColor]];
        //[text_userName setClearButtonMode:UITextFieldViewModeWhileEditing];
        [text_userName setDelegate:self];
        //[text_userName setKeyboardType:UIKeyboardTypeNumberPad];
        [text_userName setTag:100];
        [text_userName setFont:[UIFont fontWithName:@"Helvetica" size:15]];
        [text_userName setDelegate:self];
        [text_userName setText:[JDModel_userInfo sharedModel].string_nickName];
        [self addSubview:text_userName];
        [text_userName release];
        _field_name = text_userName;
        
        UILabel *label_userName = [[UILabel alloc] initWithFrame:CGRectMake(350, 120, 50, 35)];
        [label_userName setBackgroundColor:[UIColor clearColor]];
        [self addSubview:label_userName];
        [label_userName release];
        _label_pointOut_userName = label_userName;
        
        UIImageView *imageView_sex = [[UIImageView alloc] initWithFrame:CGRectMake(200, 155, 44, 26)];
        [UIUtils didLoadImageNotCached:@"user_profile_title_gender.png" inImageView:imageView_sex];
        [self addSubview:imageView_sex];
        [imageView_sex release];
        
        _integer_sex = [JDModel_userInfo sharedModel].integer_sex;
        
        UIButton *button_m = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_m setFrame:CGRectMake(200, 185, 70, 37)];
        
        [button_m addTarget:self action:@selector(didClickButton_man) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button_m];
        _button_man = button_m;
        
        UIButton *button_w = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_w setFrame:CGRectMake(280, 185, 70, 37)];
        [button_w addTarget:self action:@selector(didClickButton_woman) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button_w];
        _button_woman = button_w;
        
        switch (_integer_sex)
        {
            case 0:
            {
                [UIUtils didLoadImageNotCached:@"user_profile_btn_gender_female_active.png" inButton:button_w withState:UIControlStateNormal];
                [UIUtils didLoadImageNotCached:@"user_profile_btn_gender_male.png" inButton:button_m withState:UIControlStateNormal];
            }break;
            case 1:
            {
                [UIUtils didLoadImageNotCached:@"user_profile_btn_gender_male_active.png" inButton:button_m withState:UIControlStateNormal];
                [UIUtils didLoadImageNotCached:@"user_profile_btn_gender_female.png" inButton:button_w withState:UIControlStateNormal];
            }break;
            case 2:
            {
                [UIUtils didLoadImageNotCached:@"user_profile_btn_gender_male.png" inButton:button_m withState:UIControlStateNormal];
                [UIUtils didLoadImageNotCached:@"user_profile_btn_gender_female.png" inButton:button_w withState:UIControlStateNormal];
            }break;
                
            default:
                break;
        }
        
        UIImageView *imageView_sign = [[UIImageView alloc] initWithFrame:CGRectMake(200, 230, 45, 26)];
        [UIUtils didLoadImageNotCached:@"user_profile_title_signature.png" inImageView:imageView_sign];
        [self addSubview:imageView_sign];
        [imageView_sign release];
        
        UIImageView *imageView_textSign = [[UIImageView alloc] initWithFrame:CGRectMake(200, 270, 200, 75)];
        [UIUtils didLoadImageNotCached:@"search_field_sign.png" inImageView:imageView_textSign];
        [self addSubview:imageView_textSign];
        [imageView_textSign release];
        
        if([[JDModel_userInfo sharedModel].string_signature length] == 0)
        {
            UIImageView *imageView_p = [[UIImageView alloc] initWithFrame:CGRectMake(210, 280, 150, 50)];
            [UIUtils didLoadImageNotCached:@"image_sign_p.png" inImageView:imageView_p];
            [self addSubview:imageView_p];
            [imageView_p release];
            _imageView_sign_p = imageView_p;
        }

        UITextView *textSign = [[UITextView alloc] initWithFrame:CGRectMake(200, 280, 200, 65)];
        [textSign setBackgroundColor:[UIColor clearColor]];
        [textSign setDelegate:self];
        [self addSubview:textSign];
        [textSign setText:[JDModel_userInfo sharedModel].string_signature];
        [textSign release];
        _text_sign = textSign;
        
        UIButton *button_camera = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_camera setFrame:CGRectMake(28, 260, 70, 35)];
        [UIUtils didLoadImageNotCached:@"user_profile_btn_camera.png" inButton:button_camera withState:UIControlStateNormal];
        [button_camera addTarget:self action:@selector(didClickButton_camera) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button_camera];
        
        UIButton *button_album = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_album setFrame:CGRectMake(110, 260, 70, 35)];
        [UIUtils didLoadImageNotCached:@"user_profile_btn_upload.png" inButton:button_album withState:UIControlStateNormal];
        [button_album addTarget:self action:@selector(didClickButton_album) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button_album];
        
        UIButton *button_finish = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_finish setFrame:CGRectMake(165, 415, 120, 35)];
        [UIUtils didLoadImageNotCached:@"user_profile_btn_save.png" inButton:button_finish withState:UIControlStateNormal];
        [button_finish addTarget:self action:@selector(didclickButton_finish) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button_finish];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTI_VALIDATE_NICKNAME_RESULT
                                                  object:nil];
    
    [_string_fileName release], _string_fileName = nil;
    [agent release], agent = nil;
    [super dealloc];
}

- (void)didLoadImageNotCached:(NSString *)filename inButton:(UIButton *)button withState:(UIControlState)state
{
    NSString *imageFile = [[NSString alloc]initWithFormat:@"%@/%@",[UIUtils getDocumentDirName], filename];
    UIImage *image =  [[UIImage alloc] initWithContentsOfFile:imageFile];
    [imageFile release];
    [button setBackgroundImage:image forState:state];
    [image release];
}

- (void)didClickButton_back
{
    [_text_sign resignFirstResponder];
    [_field_name resignFirstResponder];
    [UIUtils removeViewWithAnimation:self inCenterPoint:CGPointMake(225,-475) withBoolRemoveView:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didClickButton_userInfoReturn" object:nil];
}




- (void)didClickButton_head
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:nil];
    [alertView addButtonWithTitle:@"拍照"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              @try
                              {
                                  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                                  {
                                      __block UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                                      [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
                                      [imagePicker.navigationBar setBarStyle:UIBarStyleBlackOpaque];
                                      [imagePicker setDelegate:self];
                                      //[imagePicker setAllowsEditing:NO];
                                      //显示Camera VC
                                      [[self reciveSuperViewControllerWithView:self]presentViewController:imagePicker animated:NO completion:^(){imagePicker = nil;}];
                                      
                                  }else
                                  {
                                      NSLog(@"Camera is not available.");
                                  }
                              }
                              @catch (NSException *exception)
                              {
                                  NSLog(@"Camera is not available.");
                              }
                          }];
    
    [alertView addButtonWithTitle:@"从本地相册选择"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              @try
                              {
                                  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
                                  {
                                      UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                                      imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                      imagePicker.delegate = self;
                                      [imagePicker setAllowsEditing:YES];
                                      UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
                                      [popover presentPopoverFromRect:CGRectMake(-115, 0, 300, 300) inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                                      _popVer = popover;
                                      [imagePicker release];
                                      //[popover release];
                                  }
                                  else
                                  {
                                      NSLog(@"Album is not available.");
                                  }
                              }
                              @catch (NSException *exception)
                              {
                                  //Error
                                  NSLog(@"Album is not available.");
                              }

                          }];
    [alertView addButtonWithTitle:@"取消"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alertView) {
                              
                          }];

    [alertView show];
}

- (void)didClickButton_camera
{
    @try
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            __block UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [imagePicker.navigationBar setBarStyle:UIBarStyleBlack];
            [imagePicker setDelegate:self];
            [imagePicker setAllowsEditing:YES];
            //显示Camera VC
            [[self reciveSuperViewControllerWithView:self]presentViewController:imagePicker animated:YES completion:^(){imagePicker = nil;}];

    
        }
        else
        {
            NSLog(@"Camera is not available.");
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Camera is not available.");
    }
}


- (void)didClickButton_album
{
    [_text_sign resignFirstResponder];
    [_field_name resignFirstResponder];
    @try
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.delegate = self;
            [imagePicker setAllowsEditing:YES];
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            [popover presentPopoverFromRect:CGRectMake(-115, 0, 300, 300) inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            _popVer = popover;
            [imagePicker release];
            //[popover release];
        }
        else
        {
            NSLog(@"Album is not available.");
        }
    }
    @catch (NSException *exception)
    {
        //Error
        NSLog(@"Album is not available.");
    }

}

- (void)didClickButton_man
{
    switch (_integer_sex)
    {
        case 0:
        {
            [UIUtils didLoadImageNotCached:@"user_profile_btn_gender_male_active.png" inButton:_button_man withState:UIControlStateNormal];
            [UIUtils didLoadImageNotCached:@"user_profile_btn_gender_female.png" inButton:_button_woman withState:UIControlStateNormal];
            
            _integer_sex = 1;
            
        }break;
        case 1:
        {
            [UIUtils didLoadImageNotCached:@"user_profile_btn_gender_male.png" inButton:_button_man withState:UIControlStateNormal];
            
            _integer_sex = 2;
            
        }break;
        case 2:
        {
            [UIUtils didLoadImageNotCached:@"user_profile_btn_gender_male_active.png" inButton:_button_man withState:UIControlStateNormal];
            _integer_sex = 1;
        }break;
        default:
            break;
    }
}

- (void)didClickButton_woman
{
    switch (_integer_sex)
    {
        case 0:
        {
            [UIUtils didLoadImageNotCached:@"user_profile_btn_gender_female.png" inButton:_button_woman withState:UIControlStateNormal];
            _integer_sex = 2;
            
        }break;
        case 1:
        {
            [UIUtils didLoadImageNotCached:@"user_profile_btn_gender_male.png" inButton:_button_man withState:UIControlStateNormal];
            [UIUtils didLoadImageNotCached:@"user_profile_btn_gender_female_active.png" inButton:_button_woman withState:UIControlStateNormal];
            _integer_sex = 0;
        }break;
        case 2:
        {
            [UIUtils didLoadImageNotCached:@"user_profile_btn_gender_female_active.png" inButton:_button_woman withState:UIControlStateNormal];
            _integer_sex = 0;
        }break;
        default:
            break;
    }
}

#pragma mark - 点击完成按钮 -
/**
 点击完成按钮
 **/
- (void)didclickButton_finish
{
    if(_string_fileName)
    {
        [[AccountMasterViewController sharedController] upLoadPortraitInBackground:_string_fileName];
    }
    
    [JDModel_userInfo sharedModel].integer_sex = _integer_sex;
    
    [agent modifyUserInfo:[JDModel_userInfo sharedModel].string_nickName Sex:[JDModel_userInfo sharedModel].integer_sex Signature:[JDModel_userInfo sharedModel].string_signature UserID:[JDModel_userInfo sharedModel].string_userID Token:[JDModel_userInfo sharedModel].string_token];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didClickButton_userInfoReturn" object:nil];
    
    [UIUtils removeViewWithAnimation:self inCenterPoint:CGPointMake(225,-475) withBoolRemoveView:YES];
    
}

#pragma mark - 相机回调 -
/**
 相机回调
 **/
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image_user = [self processAlbumPhoto:info];
    
    [_button_head_change setImageWithURL:nil];
    [_button_head_change setBackgroundImage:image_user forState:UIControlStateNormal];
    //[button_head setImageWithURL:[NSURL URLWithString:[JDModel_userInfo sharedModel].string_portrait] placeholderImage:image_place];
    NSString *fullName = [self saveImage:image_user ToFile:@"portrait.jpg"];
    
    self.string_fileName = [[NSString alloc] initWithString:fullName];
    
    if(_popVer)
    {
        [_popVer dismissPopoverAnimated:YES];
        [_popVer release], _popVer = nil;
    }
    else
    {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (NSString*)saveImage:(UIImage*)image ToFile:(NSString*)fileName
{
    NSString *fullName = [NSString stringWithFormat:@"%@/%@", [UIUtils getDocumentDirName], fileName];
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:fullName atomically:YES];
    return fullName;
}

- (UIImage *)processAlbumPhoto:(NSDictionary *)info
{
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    float original_width = originalImage.size.width;
    float original_height = originalImage.size.height;
    if ([info objectForKey:UIImagePickerControllerCropRect] == nil)
    {
        if (original_width < original_height)
        {
            return nil;
        }
        else
        {
            return nil;
        }
    }
    else
    {
        CGRect crop_rect = [[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];
        float crop_width = crop_rect.size.width;
        float crop_height = crop_rect.size.height;
        float crop_x = crop_rect.origin.x;
        float crop_y = crop_rect.origin.y;
        float remaining_width = original_width - crop_x;
        float remaining_height = original_height - crop_y;
        
        // due to a bug in iOS
        if ( (crop_x + crop_width) > original_width) {
            NSLog(@" - a bug in x direction occurred! now we fix it!");
            crop_width = original_width - crop_x;
        }
        if ( (crop_y + crop_height) > original_height) {
            NSLog(@" - a bug in y direction occurred! now we fix it!");
            
            crop_height = original_height - crop_y;
        }
        
        float crop_longer_side = 0.0f;
        
        if (crop_width > crop_height)
        {
            crop_longer_side = crop_width;
        }
        else
        {
            crop_longer_side = crop_height;
        }
        //NSLog(@" - ow = %g, oh = %g", original_width, original_height);
        //NSLog(@" - cx = %g, cy = %g, cw = %g, ch = %g", crop_x, crop_y, crop_width, crop_height);
        //NSLog(@" - cls=%g, rw = %g, rh = %g", crop_longer_side, remaining_width, remaining_height);
        if ( (crop_longer_side <= remaining_width) && (crop_longer_side <= remaining_height) )
        {
            UIImage *tmpImage = [originalImage cropImageWithBounds:CGRectMake(crop_x, crop_y, crop_longer_side, crop_longer_side)];
            
            return tmpImage;
        } else if ( (crop_longer_side <= remaining_width) && (crop_longer_side > remaining_height) ) {
            UIImage *tmpImage = [originalImage cropImageWithBounds:CGRectMake(crop_x, crop_y, crop_longer_side, remaining_height)];
            
            float new_y = (crop_longer_side - remaining_height) / 2.0f;
            //UIGraphicsBeginImageContext(CGSizeMake(crop_longer_side, crop_longer_side));
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(crop_longer_side, crop_longer_side), YES, 1.0f);
            [tmpImage drawAtPoint:CGPointMake(0.0f,new_y)];
            
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return newImage;
        } else if ( (crop_longer_side > remaining_width) && (crop_longer_side <= remaining_height) )
        {
            UIImage *tmpImage = [originalImage cropImageWithBounds:CGRectMake(crop_x, crop_y, remaining_width, crop_longer_side)];
            
            float new_x = (crop_longer_side - remaining_width) / 2.0f;
            //UIGraphicsBeginImageContext(CGSizeMake(crop_longer_side, crop_longer_side));
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(crop_longer_side, crop_longer_side), YES, 1.0f);
            [tmpImage drawAtPoint:CGPointMake(new_x,0.0f)];
            
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return newImage;
        } else {
            return nil;
        }
        
    }
}



#pragma mark -
#pragma mark ReciveSuperViewController

- (UIViewController *)reciveSuperViewControllerWithView:(UIView *)view
{
    for (UIView *next = [view superview]; next; next = next.superview)
    {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

#pragma mark -
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _bool_text_again = YES;
    [UIUtils addViewWithAnimation:self inCenterPoint:CGPointMake(212, 224)];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if([[textField text] length] == 0)
    {
        [textField setText:[JDModel_userInfo sharedModel].string_nickName];
    }
    else
    {
        [agent validateNickName:[textField text]];
    }
    
    if(!_bool_text)
    {
        [textField resignFirstResponder];
        [UIUtils addViewWithAnimation:self inCenterPoint:CGPointMake(212, 384)];
    }
    _bool_text_again = NO;
}

#pragma mark -
#pragma mark UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    _bool_text = YES;
    [UIUtils addViewWithAnimation:self inCenterPoint:CGPointMake(212, 224)];
    [_imageView_sign_p setHidden:YES];
    [textView resignFirstResponder];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if(!_bool_text_again)
    {
        [UIUtils addViewWithAnimation:self inCenterPoint:CGPointMake(212, 384)];
        [JDModel_userInfo sharedModel].string_signature = [textView text];
        [textView resignFirstResponder];
    }
    if([[textView text] length] == 0)
    {
        [_imageView_sign_p setHidden:NO];
    }
    _bool_text = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_text_sign resignFirstResponder];
    [_field_name resignFirstResponder];
    _bool_text = NO;
    _bool_text_again = NO;
}

#pragma mark ClientAgent Notification
- (void)handleValidateNickName:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    if([[state objectForKey:@"result"] length] > 0 && 0 == resultCode)
    {
        [_label_pointOut_userName setFrame:CGRectMake(350, 114, 50, 35)];
        [_label_pointOut_userName setTextColor:[UIColor greenColor]];
        [_label_pointOut_userName setFont:[UIFont systemFontOfSize:30.0]];
        [_label_pointOut_userName setTextAlignment:NSTextAlignmentCenter];
        [_label_pointOut_userName setText:@"✓"];
        [JDModel_userInfo sharedModel].string_nickName = [_field_name text];
        //user.string_userName = [_textField_userName text];
    }
    else if(2 == resultCode)
    {
        [UIUtils view_showProgressHUD:[state objectForKey:@"msg"] inView:self withTime:3.0f];
    }
    else
    {
        NSString *alther = [[state objectForKey:@"msg"] substringToIndex:3];
        if([alther isEqualToString:@"511"])
        {
            //[UIUtils view_showProgressHUD:@"用户名已存在" inView:self withTime:1.5f];
            [_label_pointOut_userName setFrame:CGRectMake(355, 112, 60, 35)];
            [_label_pointOut_userName setTextColor:[UIColor redColor]];
            [_label_pointOut_userName setFont:[UIFont fontWithName:@"Helvetica" size:13]];
            [_label_pointOut_userName setBackgroundColor:[UIColor clearColor]];
            [_label_pointOut_userName setTextAlignment:NSTextAlignmentLeft];
            [_label_pointOut_userName setText:@"已存在"];
        }
        else if([alther isEqualToString:@"521"])
        {
            [UIUtils view_showProgressHUD:@"请输入1-10位字母和数字,或中文组合" inView:self withTime:1.5f];
            [_label_pointOut_userName setFrame:CGRectMake(345, 112, 60, 35)];
            [_label_pointOut_userName setTextColor:[UIColor redColor]];
            [_label_pointOut_userName setFont:[UIFont fontWithName:@"Helvetica" size:13]];
            [_label_pointOut_userName setBackgroundColor:[UIColor clearColor]];
            [_label_pointOut_userName setTextAlignment:NSTextAlignmentLeft];
            [_label_pointOut_userName setText:@"格式有误"];
        }
    }
}




@end
