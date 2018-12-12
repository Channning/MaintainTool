//
//  CamLivestreamQRcodeViewController.m
//  Foream
//
//  Created by rongbaohong on 16/4/19.
//  Copyright © 2016年 Foream. All rights reserved.
//

#import "CamLivestreamQRcodeViewController.h"
#import "CamConnectFailedViewController.h"
//#import "BLLivePreviewViewController.h"
#import "UIViewController+MaryPopin.h"
#import "QRCodeGenerator.h"

@interface CamLivestreamQRcodeViewController ()<CamConnectFailedDelegate>
{
    NSTimer *checkCameraRegisterTimer;
    long tag;
    BOOL didReceiveData;
    BOOL didPushViewController;
    BOOL didDeleteMessage;
    NSString *messageId;
    
}
@property (nonatomic,weak) IBOutlet UIView *connectingView;
@property (nonatomic,weak) IBOutlet UIImageView *QRcodeImageView;
@property (nonatomic,weak) IBOutlet UIView *maskView;
@property (nonatomic,weak) IBOutlet UIView *codeBGView;
@property (nonatomic,weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UILabel *connectingLabel;
@property (nonatomic,weak) IBOutlet UILabel *connectDescribeLabel;

@end

@implementation CamLivestreamQRcodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

    if(iPhone5 || isRetina)
    {
        self = [super initWithNibName:@"CamLivestreamQRcodeViewController_4.0" bundle:nibBundleOrNil];
        
    }else
    {
        
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        
        
    }
    if (self) {
        
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tabBarController.tabBar setHidden:YES];
    [self initBasicContrlsSetup];
    [self initNavgationItemSubviews];
    if (![[AppDelegateHelper readData:DidChooseTheCamera] isEqualToString:GhostX])
    {
        checkCameraRegisterTimer=[NSTimer scheduledTimerWithTimeInterval:5
                                                                  target:self
                                                                selector:@selector(registerLoopThread)
                                                                userInfo:nil
                                                                 repeats:YES];
    
    }
    else
    {

        [self.maskView setAlpha:0.2];
//        if (iPhone6 || iPhone6plus)
//        {
//            [self.QRcodeImageView mas_makeConstraints:^(MASConstraintMaker *make)
//             {
//                 make.bottomMargin.mas_equalTo(self.codeBGView).offset(-30);
//             }];
//        }
     
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{

    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

-(IBAction)backButtonDidClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)helpButtonDidClick:(id)sender
{

    [self failedAndShowPromptInfoView];
    
}
-(IBAction)nextButtonDidClick:(id)sender
{
    DLog(@"_contentInfo is %@ _ssidInfo si %@",_contentInfo,_ssidInfo);
    if ([[AppDelegateHelper readData:DidChooseTheCamera] hasPrefix:GhostX])
    {
//        CamLivestreamStepThreeViewController *scanQRcodeView = [[CamLivestreamStepThreeViewController alloc]init];
//        [scanQRcodeView setConnectType:ConnectingTypeBTLiveOnDriftLife];
//        [scanQRcodeView setContentInfo:_contentInfo];
//        [scanQRcodeView setSsidInfo:_ssidInfo];
//        [scanQRcodeView setPasswordInfo:_passwordInfo];
//        [scanQRcodeView setStreamCreatTime:_streamCreatTime];
//        [self.navigationController pushViewController:scanQRcodeView animated:YES];
    }
    else
    {
//        CamLivestreamStepThreeViewController *scanQRcodeView = [[CamLivestreamStepThreeViewController alloc]init];
//        [scanQRcodeView setConnectType:ConnectingTypeQRcode];
//        [scanQRcodeView setContentInfo:_contentInfo];
//        [scanQRcodeView setSsidInfo:_ssidInfo];
//        [scanQRcodeView setPasswordInfo:_passwordInfo];
//        [self.navigationController pushViewController:scanQRcodeView animated:YES];
    }


    
}

-(IBAction)returnButtonDidClick:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - initialization
- (void)initNavgationItemSubviews
{
    UIBarButtonItem * backButtonItem = [[UIBarButtonItem alloc] init];
    backButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = backButtonItem;
    
    self.navigationItem.title = MyLocal(@"扫描二维码");
    
    
}

-(void)initBasicContrlsSetup
{
   
    [self.connectingLabel setText:MyLocal(@"CONNECTING...")];
    [self.connectingLabel setFont:[UIFont fontWithName:@"HaginCapsMedium" size:29]];
    [self.connectDescribeLabel setFont:StandardFONT(17)];
    [self.connectDescribeLabel setTextColor:UIColorFromRGB(0x6f6f6f)];
    if ([AppDelegateHelper readBool:DidChooseNetdistType])
    {
        
        [self.connectDescribeLabel setText:MyLocal(@"Once your Camera is connected you'll be ready to start sync!")];
    }else
    {
        
        [self.connectDescribeLabel setText:MyLocal(@"Once your Camera is connected you'll be ready to start live streaming!")];
    }
    
    [self.descriptionLabel setFont:StandardFONT(22)];

    if ([[AppDelegateHelper readData:DidChooseTheCamera] isEqualToString:ForeamX1])
    {
        
        [self.descriptionLabel setText:MyLocal(@"请将相机正对二维码并保持20cm左右的距离，当听到Wi-Fi Cloud mode即扫描成功，相机开始连接网络，连接成功后会自动进入视频通话界面。")];
    }else
    {
        
        [self.descriptionLabel setText:MyLocal(@"请将相机正对二维码并保持20cm左右的距离，当Wi-Fi灯开始红色闪烁即扫描成功，相机开始连接网络，连接成功后会自动进入视频通话界面。")];
    }
    
    [self.titleLabel setFont:[UIFont fontWithName:@"HaginCapsMedium" size:18]];
    [self.titleLabel setText:MyLocal(@"温馨提示： 如果使用手机热点进行视频直播，请进入手机设置-个人热点界面，确保手机热点开启，并等待手机出现提示“设备已经连接热点”后，再返回App")];
    
    self.QRcodeImageView.image = [QRCodeGenerator qrImageForString:_contentInfo imageSize:_QRcodeImageView.bounds.size.width];
    
    
}

#pragma mark - Privite Metheds
-(void)failedAndShowPromptInfoView
{
    
    CamConnectFailedViewController *popin = [[CamConnectFailedViewController alloc]init];
    [popin setFailureType:FailedTypeQRcode];
    [popin setDelegate:self];
    [popin setIsResponsedFromHelp:YES];
    BKTBlurParameters *blurParameters = [[BKTBlurParameters alloc] init];
    //blurParameters.alpha = 0.5;
    blurParameters.tintColor = [UIColor colorWithWhite:0 alpha:0.7];
    blurParameters.radius = 15;
    [popin setBlurParameters:blurParameters];
    [popin setPopinTransitionDirection:BKTPopinTransitionDirectionTop];
    popin.view.layer.shadowOffset = CGSizeMake(5,5);
    popin.view.layer.shadowOpacity = 0.7f;
    popin.view.layer.shadowRadius = 25.0;
    //popin.presentingController = self;
    
    //Present popin on the desired controller
    //Note that if you are using a UINavigationController, the navigation bar will be active if you present
    // the popin on the visible controller instead of presenting it on the navigation controller
    [self presentPopinController:popin animated:YES completion:^{
        NSLog(@"Popin presented !");
    }];
}



-(void) checkCameraIsBeenRegistered
{
    
    
//    if(![FOMAPPDELEGATE loginUser])
//        return;
//
//    NSDictionary *parasDic;
//    NSDictionary *searchDir;
//
//    searchDir = [NSDictionary dictionaryWithObject:@"0" forKey:@"state"];
//    parasDic =[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:1],searchDir, nil] forKeys:[NSArray arrayWithObjects:@"limit", @"search",nil]];
//    NSString *paraString = [parasDic JSONString];
//
//    NetdiskGeneralSendCmdApi *generalCmdApi = [[NetdiskGeneralSendCmdApi alloc]initWithSessionId:[FOMAPPDELEGATE loginUser].sid token:[FOMAPPDELEGATE loginUser].token commandString:@"fetchReceivedMessageList" commandParameters:paraString];
//    [generalCmdApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
//        NSDictionary *regResponse = [request.responseString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
//        DLog(@"fetchReceivedMessageList is %@",regResponse);
//        if ([[NSNumber numberWithInt:1] isEqual: [regResponse objectForKey : @"status"]]){
//            NSDictionary * deviceData = [regResponse objectForKey : @"data"];
//            if ([[deviceData objectForKey : @"list"] isKindOfClass:[NSNull class]]) {
//
//            }else{
//                NSArray * listData =  [deviceData objectForKey : @"list"];
//
//                for (NSDictionary *dInfo in listData) {
//
//                    MessageInfo *messageInfo = [[MessageInfo alloc]init];
//                    messageInfo.type =  [dInfo objectForKey:@"type"];
//                    messageInfo.appName =  [dInfo objectForKey:@"appName"];
//                    messageInfo.content =  [dInfo objectForKey:@"content"];
//                    messageInfo.iid =  [dInfo objectForKey:@"id"];
//                    messageId = messageInfo.iid;
//
//                    NSDictionary *contentDic = [messageInfo.content objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
//                    if (messageInfo.type.intValue == 301) {
//                        messageInfo.status = [contentDic objectForKey:@"status"];
//                        messageInfo.cause = [contentDic objectForKey:@"cause"];
//                        if([[NSNumber numberWithInt:1] isEqual: [contentDic objectForKey : @"status"]]){
//
//                            //                            [AppDelegateHelper showLoadingWithTitle:MyLocal(@"Loading") withMessage:nil view:self.view];
//                            _registerCameraId = [contentDic objectForKey:@"cameraId"];
//                            [self getRemoteDeviceList:_registerCameraId];
//                            [self markMessageAsRead:[NSArray arrayWithObject:messageInfo.iid]];
//                            //                            [checkCameraRegisterTimer invalidate];
//                            //                            checkCameraRegisterTimer = nil;
//                        }
//
//
//                    }
//
//                }
//
//            }
//        }
//
//
//
//    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
//    }];
    
}

-(void)registerLoopThread
{
    if(_registerCameraId)
    {
        MyLocal(@"kc smartConfig test: still checking the camera online status.");
        //[self getRemoteDeviceList:_registerCameraId];
    }
    else
        [self checkCameraIsBeenRegistered];
}



#pragma mark - Screen rotation
- (BOOL)shouldAutorotate
{       //IOS6
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
