//
//  AppDelegate.m
//  MaintainTool
//
//  Created by Channing_rong on 2018/12/6.
//  Copyright © 2018 Channing_rong. All rights reserved.
//

#import "AppDelegate.h"
#import "YTKNetworkConfig.h"
#import "WXApi.h"

@interface AppDelegate ()<WXApiDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    YTKNetworkConfig *config = [YTKNetworkConfig sharedConfig];
    config.baseUrl = @"https://wx.driftlife.co";
    
    //向微信注册
    [WXApi registerApp:@"wxd2ce9740ed97a32a"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    _rootViewController = [[RootViewController alloc]init];
    UINavigationController *mainNav = [[UINavigationController alloc]initWithRootViewController:_rootViewController];
    self.window.rootViewController = mainNav;
    
    [self setupNavBar];
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return  [WXApi handleOpenURL:url delegate:self];
}



#pragma mark -WXApiDelegate

-(void) onReq:(BaseReq*)req
{
    if([req isKindOfClass:[GetMessageFromWXReq class]])
    {
        // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
//        NSString *strTitle = [NSString stringWithFormat:@"微信请求App提供内容"];
//        NSString *strMsg = @"微信请求App提供内容，App要调用sendResp:GetMessageFromWXResp返回给微信";
//
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        alert.tag = 1000;
//        [alert show];
//        [alert release];
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
//        ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
//        WXMediaMessage *msg = temp.message;
        
        //显示微信传过来的内容
//        WXAppExtendObject *obj = msg.mediaObject;
//
//        NSString *strTitle = [NSString stringWithFormat:@"微信请求App显示内容"];
//        NSString *strMsg = [NSString stringWithFormat:@"标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%u bytes\n\n", msg.title, msg.description, obj.extInfo, msg.thumbData.length];
//
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//        [alert release];
    }
    else if([req isKindOfClass:[LaunchFromWXReq class]])
    {
//        //从微信启动App
//        NSString *strTitle = [NSString stringWithFormat:@"从微信启动"];
//        NSString *strMsg = @"这是从微信启动的消息";
//
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//        [alert release];
    }
}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])//分享成功或者关闭分享（没有准确的成功状态）
    {
        //发出通知 从微信回调回来之后,发一个通知,让视频对话的页面接收消息,作出相关UI调整
        NSNotification * notification = [NSNotification notificationWithName:INFORMLIVECONVERSATIONUPDATEUI object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)setupNavBar
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    UINavigationBar *bar = [UINavigationBar appearance];
    bar.barTintColor = [UIColor blackColor];
    bar.tintColor = [UIColor whiteColor];
    bar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
}

#pragma mark - Screen Rotation metheds
-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}
@end
