//
//  CamLivestreamQRcodeViewController.m
//  Foream
//
//  Created by rongbaohong on 16/4/19.
//  Copyright © 2016年 Foream. All rights reserved.
//

#import "CamLivestreamQRcodeViewController.h"
#import "CamConnectFailedViewController.h"
#import "MTLiveConversationViewController.h"
#import "UIViewController+MaryPopin.h"
#import "QRCodeGenerator.h"
#import <SocketRocket/SRWebSocket.h>
#import "MTGetAppStreamApi.h"
#import "MTOwnerRoomInfoApi.h"
#import "MTCreateLiveRoomApi.h"

@interface CamLivestreamQRcodeViewController ()<CamConnectFailedDelegate,SRWebSocketDelegate>
{
    NSTimer *checkCameraRegisterTimer;
    long tag;
    BOOL didReceiveData;
    BOOL didPushViewController;
    BOOL didDeleteMessage;
    NSString *messageId;
    
    NSString *pushUrlString;
    NSString *playRtmpUrlString;
    NSString *playFlvUrlString;
    NSString *roomIDString;
    NSString *session_key;
    
    SRWebSocket *socket;
    
}
@property (nonatomic,weak) IBOutlet UIView *connectingView;
@property (nonatomic,weak) IBOutlet UIImageView *QRcodeImageView;
@property (nonatomic,weak) IBOutlet UIView *maskView;
@property (nonatomic,weak) IBOutlet UIView *codeBGView;
@property (nonatomic,weak) IBOutlet UIView *contentView;
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
    [self initBasicContrlsSetup];
    [self initNavgationItemSubviews];
    if (![AppDelegateHelper readData:APPStreamKey])
    {
        [self getUserAppStreamInfo];
    }
    [self getOwnerRoomInfo];

    if (iPhone6plus)
    {
        [self.codeBGView mas_updateConstraints:^(MASConstraintMaker *make)
        {
            make.top.equalTo(self.view).offset(SafeAreaTopHeight);
        }];
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

    [socket close];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getUserAppStreamInfo
{
    DLog(@"SavedOpenID is %@, and LastLoginUserId is %@",[AppDelegateHelper readData:SavedOpenID],[AppDelegateHelper readData:@"LastLoginUserId"]);
    MTGetAppStreamApi *generalCmdApi = [[MTGetAppStreamApi alloc] initWithKey:MTLiveApiKey openID:[AppDelegateHelper readData:SavedOpenID] nickName:[AppDelegateHelper readData:@"LastLoginUserId"]];
    [generalCmdApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request)
     {
         id obj = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:NULL];
         NSNumber *status = obj[@"status"];
         DLog(@"regResponse is %@",request.responseString);
         if(status.intValue == 1)
         {
             
             NSDictionary *dataDic = obj[@"data"];
             [AppDelegateHelper saveData:dataDic[@"stream_key"] forKey:APPStreamKey];
             
        
         }
     } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
         DLog(@"failure!%@",request.responseObject);
     }];
}

-(void)getOwnerRoomInfo
{
    MTOwnerRoomInfoApi *generalCmdApi = [[MTOwnerRoomInfoApi alloc] initWithKey:MTLiveApiKey openID:[AppDelegateHelper readData:SavedOpenID]];
    [generalCmdApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request)
     {
         id obj = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:NULL];
         NSNumber *status = obj[@"status"];
         DLog(@"regResponse is %@",request.responseString);
         if(status.intValue == 1)
         {
             NSDictionary *dataDic = obj[@"data"];
             NSDictionary *roomDic = dataDic[@"room"];
             NSDictionary *owner_streamDic = roomDic[@"owner_stream"];
             self->pushUrlString = owner_streamDic[@"push"];
             self->playRtmpUrlString = owner_streamDic[@"rtmp"];
             self->playFlvUrlString = owner_streamDic[@"flv"];
             self->roomIDString = roomDic[@"room_id"];
             self->session_key = roomDic[@"session_key"];
             DLog(@"pushUrlString is %@,roomIDString is %@,session_key is %@",self->pushUrlString,self->roomIDString,self->session_key);
             
             if ([[AppDelegateHelper readData:DidChooseTheCamera] isEqualToString:ForeamX1])
             {
                 self.contentInfo = [NSString stringWithFormat:@"6|%@|%@|%@",self->_ssidInfo,self->_passwordInfo,self->pushUrlString];
                 
                 
             }else if ([[AppDelegateHelper readData:DidChooseTheCamera] hasPrefix:Compass])
             {
                 self.contentInfo = [NSString stringWithFormat:@"6|%@|%@|%@",self->_ssidInfo,self->_passwordInfo,self->pushUrlString];
             }
             else if ([[AppDelegateHelper readData:DidChooseTheCamera] hasPrefix:GhostX])
             {
                 self.contentInfo = [NSString stringWithFormat:@"3|%@|%@|%@|%@|%@",self->_ssidInfo,self->_passwordInfo,@"720P",@"2000000",self->pushUrlString];
                 
             }

             NSString *tips = obj[@"tips"];
             if ([tips isEqualToString:@"no room"])
             {
                 [self createLiveRoom];
             }
             else
             {
                 [self initSRWebSocket];
             }
             
             DLog(@"current contentinfo is %@",self->_contentInfo);
             MAIN(^{
                 self.QRcodeImageView.image = [QRCodeGenerator qrImageForString:self->_contentInfo imageSize:self->_QRcodeImageView.bounds.size.width];
             });
    
         }
     } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
         DLog(@"failure!%@",request.responseObject);
     }];
}

-(void)createLiveRoom
{
    MTCreateLiveRoomApi *generalCmdApi = [[MTCreateLiveRoomApi alloc] initWithKey:MTLiveApiKey openID:[AppDelegateHelper readData:SavedOpenID]];
    [generalCmdApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request)
     {
         id obj = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:NULL];
         NSNumber *status = obj[@"status"];
         DLog(@"regResponse is %@",request.responseString);
         if(status.intValue == 1)
         {
           [self initSRWebSocket];
         }
     } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
         DLog(@"failure!%@",request.responseObject);
     }];
    
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

-(IBAction)returnButtonDidClick:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - initialization

-(void)initSRWebSocket
{
    socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"wss://wx.driftlife.co?open_id=%@",[AppDelegateHelper readData:SavedOpenID]]]]];
    // 实现这个 SRWebSocketDelegate 协议啊
    socket.delegate = self;
    [socket open];    // open 就是直接连接了
}


- (void)initNavgationItemSubviews
{
    UIBarButtonItem * backButtonItem = [[UIBarButtonItem alloc] init];
    backButtonItem.tintColor = [UIColor whiteColor];
    backButtonItem.title = @"";
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
    [self.descriptionLabel setText:MyLocal(@"请将相机正对二维码并保持20cm左右的距离，当Wi-Fi灯开始红色闪烁即扫描成功，相机开始连接网络，连接成功后会自动进入视频通话界面。")];
    
    [self.titleLabel setFont:[UIFont fontWithName:@"HaginCapsMedium" size:18]];
    [self.titleLabel setText:MyLocal(@"温馨提示： 如果使用手机热点进行视频直播，请进入手机设置-个人热点界面，确保手机热点开启，并等待手机出现提示“设备已经连接热点”后，再返回App")];
    

    
}
#pragma mark -SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"连接成功，可以立刻登录你公司后台的服务器了，还有开启心跳");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"连接失败，这里可以实现掉线自动重连，要注意以下几点");
    NSLog(@"1.判断当前网络环境，如果断网了就不要连了，等待网络到来，在发起重连");
    NSLog(@"2.判断调用层是否需要连接，例如用户都没在聊天界面，连接上去浪费流量");
    NSLog(@"3.连接次数限制，如果连接失败了，重试10次左右就可以了，不然就死循环了。或者每隔1，2，4，8，10，10秒重连...f(x) = f(x-1) * 2, (x=5)");
          
    
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"连接断开，清空socket对象，清空该清空的东西，还有关闭心跳！");
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    DLog(@"Received Message Is %@",message);
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    NSDictionary *messageDic = obj;
    if ([messageDic[@"type"] isEqualToString:@"stream_status"])
    {
        NSDictionary *dataDic = messageDic[@"data"];
        if ([dataDic[@"stream_status"] intValue] == 2)
        {
            //推流中
            MTLiveConversationViewController *liveViewController = [[MTLiveConversationViewController alloc]init];
            [liveViewController setRtmpLiveUrlString:playRtmpUrlString];
            [liveViewController setFlvLiveUrlString:playFlvUrlString];
            [liveViewController setRoomid:roomIDString];
            [self.navigationController pushViewController:liveViewController animated:YES];
        }
    }
    else if ([messageDic[@"type"] isEqualToString:@"join_session"])
    {
        
    }
    else if ([messageDic[@"type"] isEqualToString:@"close_session"])
    {
        
    }
    
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
