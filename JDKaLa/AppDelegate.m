//
//  AppDelegate.m
//  JDKaLa
//
//  Created by zhangminglei on 3/27/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "AppDelegate.h"
#import "JDMainViewController.h"
#import "SDMoviePlayerViewController.h"
#import "JDMenuView.h"
#import "MediaProxyGlobal.h"
#import "UIUtils.h"
#import "JDModel_userInfo.h"
#import "JDSqlDataBaseSongHistory.h"
#import "JDSqlDataBase.h"
#import "JDMasterViewController.h"
#import "ClientAgent.h"
#import "UIDevice+IdentifierAddition.h"
#import "CustomAlertView.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [_revealSideViewController release], _revealSideViewController = nil;
    _revealSideViewController.delegate = nil;
    [super dealloc];
}


- (UIImage *)didLoadImageNotCached:(NSString *)filename
{
    NSString *imageFile = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], filename];
    NSData *imageData = [NSData dataWithContentsOfFile:imageFile];
    return [UIImage imageWithData:imageData];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor blackColor];
    
    JDMainViewController *mainViewController = [[JDMainViewController alloc] init];
    _revealSideViewController = [[SKRevealSideViewController alloc]initWithRootViewController:mainViewController];
    [mainViewController release];
    
    //_revealSideViewController.delegate = self;
    
    UINavigationController *navigationController_main = [[UINavigationController alloc] initWithRootViewController:_revealSideViewController];
    mainViewController.navigationController_return = navigationController_main;
    //[navigationController_main.view setExclusiveTouch:NO];
    [navigationController_main setNavigationBarHidden:YES];
    [navigationController_main setDelegate:nil];
    [_revealSideViewController release];
    
    [self.window setRootViewController:navigationController_main];
    [navigationController_main release];
    
    JDMenuView *muenView = [JDMenuView sharedView];
    muenView.navigationController_return = navigationController_main;
    muenView.revealSideViewController = _revealSideViewController;
    [muenView configureView_animetionButton_inViewChange];
    
    [[JDModel_userInfo sharedModel] configureDataWithTourist];
    
    [self.window makeKeyAndVisible];

    //[self downLoadAD];
    /**数据库刷新**/
    JDSqlDataBase *sql = [[JDSqlDataBase alloc] init];
    [sql sqlDataInstall];
    [sql release];
    
    NSString *autoLogin = [[NSUserDefaults standardUserDefaults] objectForKey:@"AutoLogin"];
    if(autoLogin)
    {
        if([autoLogin isEqualToString:@"YES"])
        {
            
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
        }
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"AutoLogin"];
    }
    
    NSString *string_3G = [[NSUserDefaults standardUserDefaults] objectForKey:@"3G"];
    if(string_3G)
    {
        
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"3G"];
    }
    
    [self upLoadDataBase];

    return YES;
}

#pragma mark - 登陆消息回调 -
/**
 登陆回调函数
 **/
- (void)handleLoginResult:(NSNotification *)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTI_LOGIN_RESULT
                                                  object:nil];
    
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    if(0 == resultCode)
    {
        if([state objectForKey:@"token"])
        {
            [JDModel_userInfo sharedModel].string_token = [state objectForKey:@"token"];
            [[NSUserDefaults standardUserDefaults] setObject:[JDModel_userInfo sharedModel].string_token forKey:@"token"];
        }
      
        if([[[state objectForKey:@"userinfo"]objectForKey:@"userBasic"]objectForKey:@"id"])
        {
            [JDModel_userInfo sharedModel].string_userID = [[[state objectForKey:@"userinfo"]objectForKey:@"userBasic"]objectForKey:@"id"];
            [[NSUserDefaults standardUserDefaults] setObject:[JDModel_userInfo sharedModel].string_userID forKey:@"userID"];
        }
        
        if([[[state objectForKey:@"userinfo"]objectForKey:@"userDetail"]objectForKey:@"kb"])
        {
            [JDModel_userInfo sharedModel].string_money = [[[state objectForKey:@"userinfo"]objectForKey:@"userDetail"]objectForKey:@"kb"];
            [[NSUserDefaults standardUserDefaults] setObject:[JDModel_userInfo sharedModel].string_money forKey:@"money"];
        }
        
        [JDModel_userInfo sharedModel].string_nickName = @"游客";
        [[NSUserDefaults standardUserDefaults] setObject:[JDModel_userInfo sharedModel].string_nickName forKey:@"nickName"];
        [JDModel_userInfo sharedModel].string_tourist = @"YES";
    }
    else
    {
        CustomAlertView *alertDialog = [[CustomAlertView alloc] initWithTitle:@"链接失败"
                                                                      message:@""
                                                                     delegate:self
                                                            cancelButtonTitle:@"确定"
                                                            otherButtonTitles:nil];
        //[alertDialog setTag:55];
        [alertDialog show];
        [alertDialog release];
    }
    
    [[JDMasterViewController sharedController] checkTokenValue];
}


- (void)downLoadAD
{
    NSString *advPath = [NSString stringWithFormat:@"%@/%@", [UIUtils getDocumentDirName], ADVERTISE_PATH];
    
    advURLList = [[NSArray alloc]initWithObjects:@"http://ep.iktv.tv/advertise_video/introduce-ipad.mp4",
                  nil];

//    advURLList = [[NSArray alloc]initWithObjects:@"http://ep.iktv.tv/advertise_video/1.mp4",
//                  @"http://ep.iktv.tv/advertise_video/2.mp4",
//                  @"http://ep.iktv.tv/advertise_video/3.mp4",
//                  @"http://ep.iktv.tv/advertise_video/4.mp4",
//                  @"http://ep.iktv.tv/advertise_video/5.mp4",nil];
    curDownloadAdvIdx = 0;
    
    //如果广告目录不存在，创建广告目录
    if(![[NSFileManager defaultManager] fileExistsAtPath:advPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:advPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if(AdvertiseDownloader != nil)
    {
        [AdvertiseDownloader startDownload];
        [AdvertiseDownloader release];
    }

    NSString *advLocalName = [NSString stringWithFormat:@"%@/%@", advPath, [(NSString*)[advURLList objectAtIndex:curDownloadAdvIdx] lastPathComponent]];
    AdvertiseDownloader = [[MediaDownloader alloc]initWithURL:[advURLList objectAtIndex:curDownloadAdvIdx] WithLocalFileName:advLocalName];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(handleDownloadFinish:)
               name:NOTI_MEDIA_DOWNLOAD_FINISH
             object:AdvertiseDownloader];
    [nc addObserver:self
           selector:@selector(handleDownloadFinish:)
               name:NOTI_MEDIA_DOWNLOAD_FAILED
             object:AdvertiseDownloader];
    
    if([AdvertiseDownloader startDownload])
    {
       // NSLog(@"开始下载广告");
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /**
     home出程序
     **/
    [JDModel_userInfo sharedModel].bool_homeBack = YES;
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /**home进入程序**/
    [JDModel_userInfo sharedModel].bool_homeBack = NO;
    [[JDMasterViewController sharedController] checkTokenValue];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)volumeChanged:(NSNotification *)notification 
{
    float volume =
    [[[notification userInfo]   
      objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"]
     floatValue];
    
    SDMoviePlayerViewController *player = [SDMoviePlayerViewController sharedController];
    player.slider_sound.value = volume;
}

/**
 * 下载失败的消息处理
 */
- (void)handleDownloadFinish:(NSNotification *)note
{
    NSString    *advPath = [NSString stringWithFormat:@"%@/%@", [UIUtils getDocumentDirName], ADVERTISE_PATH];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    

    [nc removeObserver:self
                  name:NOTI_MEDIA_DOWNLOAD_FINISH
                object:AdvertiseDownloader];
    [nc removeObserver:self
                  name:NOTI_MEDIA_DOWNLOAD_FAILED
                object:AdvertiseDownloader];
    [AdvertiseDownloader release];
    
    curDownloadAdvIdx++;
    
    if(curDownloadAdvIdx < [advURLList count])
    {
        NSString *advLocalName = [NSString stringWithFormat:@"%@/%@", advPath, [(NSString*)[advURLList objectAtIndex:curDownloadAdvIdx] lastPathComponent]];
        AdvertiseDownloader = [[MediaDownloader alloc]initWithURL:[advURLList objectAtIndex:curDownloadAdvIdx] WithLocalFileName:advLocalName];
        
        [nc addObserver:self
               selector:@selector(handleDownloadFinish:)
                   name:NOTI_MEDIA_DOWNLOAD_FINISH
                 object:AdvertiseDownloader];
        [nc addObserver:self
               selector:@selector(handleDownloadFinish:)
                   name:NOTI_MEDIA_DOWNLOAD_FAILED
                 object:AdvertiseDownloader];
        [AdvertiseDownloader startDownload];
        NSLog(@"Start download adv:%@", advLocalName);
    }
    else
    {
        NSLog(@"Advertise download finish.");
    }
}

#pragma mark - 更新数据库 -
/**
 更新数据库
 **/
- (void)upLoadDataBase
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleGetClientDBResult:)
                                                 name:NOTI_GET_CLIENT_DB_RESULT
                                               object:nil];
    
    NSString *dbName = [NSString stringWithFormat:@"%@/kod.db",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    
    ClientAgent *mAgent = [[ClientAgent alloc] init];
    [mAgent getClientDB:dbName];
    //[mAgent release];
}

/**
 * 更新客户端数据库的反馈处理
 */
- (void)handleGetClientDBResult:(NSNotification *)note
{
    NSDictionary    *state = (NSMutableDictionary*)note.userInfo;
    //UIAlertView     *alertDialog;
    int             resultCode = [[state objectForKey:@"result"] intValue];
    
    if([[state objectForKey:@"result"] length] > 0 && 0 == resultCode)
    {
        /*alertDialog = [[UIAlertView alloc] initWithTitle:@"成功"
         message:[NSString stringWithFormat:@"新数据库的URL:%@", [state objectForKey:@"downloadurl"]]
         delegate:self
         cancelButtonTitle:@"OK"
         otherButtonTitles:nil];*/
        
        NSString *dbName = [NSString stringWithFormat:@"%@/kod.db",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
        NSString *dbName_tmp = [NSString stringWithFormat:@"%@/kod_tmp.db",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:dbName error:nil];
        
        
        ASIHTTPRequest * asiRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[state objectForKey:@"downloadurl"]]];
        [asiRequest setDelegate:self];
        [asiRequest setDownloadDestinationPath:dbName];
        [asiRequest setTemporaryFileDownloadPath:dbName_tmp];
        [asiRequest setAllowResumeForFileDownloads:YES];
        [asiRequest setNumberOfTimesToRetryOnTimeout:3];
        [asiRequest startAsynchronous];
        
    }
    else
    {
        /*alertDialog = [[UIAlertView alloc] initWithTitle:@"失败"
         message:[state objectForKey:@"msg"]
         delegate:self
         cancelButtonTitle:@"OK"
         otherButtonTitles:nil];*/
    }
    
    //[alertDialog show];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NOTI_GET_CLIENT_DB_RESULT
                                                  object:nil];
    
    
    NSString *string_tourist = [[NSUserDefaults standardUserDefaults] objectForKey:@"tourist"];
    if(string_tourist)
    {
        if([string_tourist isEqualToString:@"YES"])
        {
            [[JDModel_userInfo sharedModel] configureDataWithTourist];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleLoginResult:)
                                                         name:NOTI_LOGIN_RESULT
                                                       object:nil];
            NSString *string_email = [NSString stringWithFormat:@"%@@kod.com",[[UIDevice currentDevice]uniqueGlobalDeviceIdentifier]];
            NSString *string_passWord = [[UIDevice currentDevice]uniqueGlobalDeviceIdentifier];
            //NSLog(@"%@",string_passWord);
            ClientAgent *agent = [[ClientAgent alloc] init];
            [agent login:string_email Password:string_passWord Version:@"iPad-1.0" DevID:[[UIDevice currentDevice]uniqueGlobalDeviceIdentifier]];
            
        }
        else if([string_tourist isEqualToString:@"NO"])
        {
            [[JDModel_userInfo sharedModel]configureDataWithUser];
            [[JDMasterViewController sharedController] checkTokenValue];
        }
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"tourist"];
        [[JDModel_userInfo sharedModel] configureDataWithTourist];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleLoginResult:)
                                                     name:NOTI_LOGIN_RESULT
                                                   object:nil];
        
        NSString *string_email = [NSString stringWithFormat:@"%@@kod.com",[[UIDevice currentDevice]uniqueGlobalDeviceIdentifier]];
        NSString *string_passWord = [[UIDevice currentDevice]uniqueGlobalDeviceIdentifier];
        ClientAgent *agent = [[ClientAgent alloc] init];
        [agent login:string_email Password:string_passWord Version:@"iPad-1.0" DevID:[[UIDevice currentDevice]uniqueGlobalDeviceIdentifier]];
    }
}


@end
