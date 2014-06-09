//
//  AppDelegate.h
//  JDKaLa
//
//  Created by zhangminglei on 3/27/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKRevealSideViewController.h"
#import "MediaProxy.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,SKRevealSideViewControllerDelegate>
{
    MediaDownloader         *AdvertiseDownloader;
    NSArray                 *advURLList;
    int                     curDownloadAdvIdx;
}
@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) SKRevealSideViewController * revealSideViewController;

@end
