//
//  RootViewController.m
//  MaintainTool
//
//  Created by Channing_rong on 2018/12/6.
//  Copyright © 2018 Channing_rong. All rights reserved.
//

#import "RootViewController.h"
//#import "TXLiteAVSDK_Professional/TXLiveBase.h"
#import "MTCameraOptionsViewController.h"

@interface RootViewController ()

//@property (nonatomic, strong) TXLivePush * txLivePublisher;
@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNavgationItemSubviews];
    NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    // 􏳌􏳍SDK􏰹􏰀􏰁􏱙􏱚
    //NSLog(@"SDK Version = %@", [TXLiveBase getSDKVersionStr]);
    NSLog(@"Device UUID = %@", udid);
    [AppDelegateHelper saveData:udid forKey:SavedOpenID];
    // 创建 LivePushConfig 对象，该对象默认初始化为基础配置
    //TXLivePushConfig* _config = [[TXLivePushConfig alloc] init];
    //在 _config中您可以对推流的参数（如：美白，硬件加速，前后置摄像头等）做一些初始化操作，需要注意 _config不能为nil
    //_txLivePush = [[TXLivePush alloc] initWithConfig: _config];
    // Do any additional setup after loading the view, typically from a nib.
}


#pragma mark - initialization
- (void)initNavgationItemSubviews
{
    
    self.navigationController.navigationBarHidden = YES;
    
    UIBarButtonItem * backButtonItem = [[UIBarButtonItem alloc] init];
    backButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = backButtonItem;

    
}




#pragma mark - IBAction

-(IBAction)connectToCamera:(id)sender
{
    MTCameraOptionsViewController *cameraOptionsVC = [[MTCameraOptionsViewController alloc]init];
    [self.navigationController pushViewController:cameraOptionsVC animated:YES];
}
@end
