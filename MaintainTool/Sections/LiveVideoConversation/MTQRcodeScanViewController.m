//
//  MTQRcodeScanViewController.m
//  MaintainTool
//
//  Created by Channing_rong on 2018/12/21.
//  Copyright © 2018 Channing_rong. All rights reserved.
//

#import "MTQRcodeScanViewController.h"
#import "MTLiveConversationViewController.h"
#import "UIViewController+MaryPopin.h"
#import "QRCodeGenerator.h"
#import <SocketRocket/SRWebSocket.h>
#import "MTGetAppStreamApi.h"
#import "MTOwnerRoomInfoApi.h"
#import "MTCreateLiveRoomApi.h"

@interface MTQRcodeScanViewController ()<SRWebSocketDelegate>
{
    BOOL didEnterLivepReviewPage;
    
    NSString *pushUrlString;
    NSString *playRtmpUrlString;
    NSString *playFlvUrlString;
    NSString *roomIDString;
    NSString *session_key;
    
    NSTimer * heartBeat;
    NSTimeInterval reConnectTime;
    
    NSTimer * checkRoomInfoTimer;
    
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
@property (nonatomic,strong) SRWebSocket *socket;

@end

@implementation MTQRcodeScanViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

    if(iPhone5 || isRetina)
    {
        self = [super initWithNibName:@"MTQRcodeScanViewController_4.0" bundle:nibBundleOrNil];
        
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
    [self addNotifications];
    [self openCheckRoomInfoTimer];
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
    if (![AppDelegateHelper readBool:IsShowTheAlertForHotspotLive])
    {
        NSString* userPhoneName = [[UIDevice currentDevice] name];
        if ([userPhoneName isEqualToString:_ssidInfo])
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示"
                                                                           message:@"使用手机热点进行视频直播，请在扫码成功后，进入手机设置-个人热点界面，确保手机热点开启，并等待手机出现提示”设备已经连接热点“后，再返回APP。"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            
            [alert addAction:[UIAlertAction actionWithTitle:@"不再提示" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                              {
                                  [AppDelegateHelper saveBool:YES forKey:IsShowTheAlertForHotspotLive];
                                  
                              }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"了解" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                              {
                              }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{

    didEnterLivepReviewPage = NO;
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{

    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    [_socket close];
    if (didEnterLivepReviewPage)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
    }
    [self closeRoomInfoTimer];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];

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
             
             /*例如之前显示的二维码为：
             6|foream_test|foream.test|rtmp://livepush.driftlife.co/live/Tzu3JLvWFqct?txSecret=1aebdd547808c3261eecf67290e0def4&txTime=5C3C0BFF
             将标识6改为8，将蓝色字符(rtmp://livepush.driftlife.co/live/)去掉，将红色部分(?txSecret=)替换为“#”
             则最终生成二维码为：
             8|foream_test|foream.test|Tzu3JLvWFqct#1aebdd547808c3261eecf67290e0def4#5C3C0BFF
              */
             NSString *pushUrlString1 = [self->pushUrlString substringFromIndex:34];
             DLog(@"pushUrlString1 is %@",pushUrlString1);
             NSString *pushUrlString2 = [pushUrlString1 stringByReplacingOccurrencesOfString:@"?txSecret=" withString:@"#"];
             DLog(@"pushUrlString2 is %@",pushUrlString2);
             NSString *pushUrlString3 = [pushUrlString2 stringByReplacingOccurrencesOfString:@"&txTime=" withString:@"#"];
             DLog(@"pushUrlString3 is %@",pushUrlString3);
             self.contentInfo = [NSString stringWithFormat:@"8|%@|%@|%@",self->_ssidInfo,self->_passwordInfo,pushUrlString3];
             DLog(@"current contentinfo is %@",self->_contentInfo);
             
             NSString *tips = obj[@"tips"];
             if ([tips isEqualToString:@"no room"])
             {
                 [self createLiveRoom];
             }
             else
             {
                 [self initSRWebSocket];
             }
             
             
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


#pragma mark - 观察者、通知

/**
 *  添加观察者、通知
 */
- (void)addNotifications
{
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayground) name:UIApplicationDidBecomeActiveNotification object:nil];

}

#pragma mark - initialization

-(void)initSRWebSocket
{
    self.socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"wss://wx.driftlife.co?open_id=%@",[AppDelegateHelper readData:SavedOpenID]]]]];
    // 实现这个 SRWebSocketDelegate 协议啊
    self.socket.delegate = self;
    [self.socket open];    // open 就是直接连接了
}

//关闭连接
- (void)SRWebSocketClose
{
    if (self->_socket)
    {
        [self->_socket close];
        self->_socket = nil;
        //断开连接时销毁心跳
        [self destoryHeartBeat];
    }
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
    [self.connectDescribeLabel setText:MyLocal(@"Once your Camera is connected you'll be ready to start live streaming!")];
    if ([[AppDelegateHelper readData:DidChooseTheCamera] isEqualToString:ForeamX1])
    {
        self.maskView.hidden = NO;
    }
    else
    {
        self.maskView.hidden = YES;
    }
    [self.descriptionLabel setFont:StandardFONT(22)];
    [self.descriptionLabel setText:MyLocal(@"请将相机正对二维码并保持20cm左右的距离，当Wi-Fi灯开始红色闪烁即扫描成功，相机开始连接网络，连接成功后会自动进入视频通话界面。")];
    
    [self.titleLabel setFont:[UIFont fontWithName:@"HaginCapsMedium" size:18]];
    [self.titleLabel setText:MyLocal(@"温馨提示： 如果使用手机热点进行视频直播，请进入手机设置-个人热点界面，确保手机热点开启，并等待手机出现提示“设备已经连接热点”后，再返回App")];
    

    
}


#pragma mark - NSNotification Action
/**
 *  应用退到后台
 */
- (void)appDidEnterBackground
{
    NSLog(@"appDidEnterBackground");
  
}

/**
 *  应用进入前台
 */
- (void)appDidEnterPlayground
{
    NSLog(@"appDidEnterPlayground");
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
             NSDictionary *userDic = dataDic[@"user"];
             NSDictionary *owner_streamDic = roomDic[@"owner_stream"];
             self->playRtmpUrlString = owner_streamDic[@"rtmp"];
             self->playFlvUrlString = owner_streamDic[@"flv"];
             self->roomIDString = roomDic[@"room_id"];
             
             NSNumber *status = userDic[@"stream_status"];
             if (status.intValue == 2)
             {
                 
                 if (self->didEnterLivepReviewPage == NO)
                 {
                     self->didEnterLivepReviewPage = YES;
                     //推流中
                     MTLiveConversationViewController *liveViewController = [[MTLiveConversationViewController alloc]init];
                     [liveViewController setRtmpLiveUrlString:self->playRtmpUrlString];
                     [liveViewController setFlvLiveUrlString:self->playFlvUrlString];
                     [liveViewController setRoomid:self->roomIDString];
                     [self.navigationController pushViewController:liveViewController animated:YES];
                 }
                 
                 
             }
             
        
         }
         
     } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
         DLog(@"failure!%@",request.responseObject);
     }];
    
}

#pragma mark -SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"连接成功，可以立刻登录你公司后台的服务器了，还有开启心跳");
    //每次正常连接的时候清零重连时间
    reConnectTime = 0;
    //开启心跳 心跳是发送pong的消息 我这里根据后台的要求发送data给后台
    [self initHeartBeat];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"连接失败，这里可以实现掉线自动重连，要注意以下几点");
    NSLog(@"1.判断当前网络环境，如果断网了就不要连了，等待网络到来，在发起重连");
    NSLog(@"2.判断调用层是否需要连接，例如用户都没在聊天界面，连接上去浪费流量");
    NSLog(@"3.连接次数限制，如果连接失败了，重试10次左右就可以了，不然就死循环了。或者每隔1，2，4，8，10，10秒重连...f(x) = f(x-1) * 2, (x=5)");
    _socket = nil;
    //连接失败就重连
    [self reConnect];
    
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"连接断开，清空socket对象，清空该清空的东西，还有关闭心跳！");
    //断开连接 同时销毁心跳
    [self SRWebSocketClose];
}

/*
 该函数是接收服务器发送的pong消息，其中最后一个是接受pong消息的，
 在这里就要提一下心跳包，一般情况下建立长连接都会建立一个心跳包，
 用于每隔一段时间通知一次服务端，客户端还是在线，这个心跳包其实就是一个ping消息，
 我的理解就是建立一个定时器，每隔十秒或者十五秒向服务端发送一个ping消息，这个消息可是是空的
 */
-(void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload
{
    
    NSString *reply = [[NSString alloc] initWithData:pongPayload encoding:NSUTF8StringEncoding];
    NSLog(@"reply===%@",reply);
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
            if (didEnterLivepReviewPage == NO)
            {
                didEnterLivepReviewPage = YES;
                //推流中
                MTLiveConversationViewController *liveViewController = [[MTLiveConversationViewController alloc]init];
                [liveViewController setRtmpLiveUrlString:playRtmpUrlString];
                [liveViewController setFlvLiveUrlString:playFlvUrlString];
                [liveViewController setRoomid:roomIDString];
                [self.navigationController pushViewController:liveViewController animated:YES];
            }
    
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

//重连机制
- (void)reConnect
{
    [self SRWebSocketClose];
    //超过一分钟就不再重连 所以只会重连5次 2^5 = 64
    if (reConnectTime > 64)
    {
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(reConnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_socket = nil;
        [self initSRWebSocket];
        NSLog(@"重连");
    });
    
    //重连时间2的指数级增长
    if (reConnectTime == 0)
    {
        reConnectTime = 2;
    }else{
        reConnectTime *= 2;
    }
}

//初始化心跳
- (void)initHeartBeat
{
    [self destoryHeartBeat];
    __weak typeof(self) weakSelf = self;
    //心跳设置为3分钟，NAT超时一般为5分钟
    if (@available(iOS 10.0, *)) {
        self->heartBeat = [NSTimer scheduledTimerWithTimeInterval:3*60 repeats:YES block:^(NSTimer * _Nonnull timer) {
            NSLog(@"heart");
            //和服务端约定好发送什么作为心跳标识，尽可能的减小心跳包大小
            [weakSelf ping];
        }];
    } else {
        // Fallback on earlier versions
    }
    [[NSRunLoop currentRunLoop]addTimer:self->heartBeat forMode:NSRunLoopCommonModes];
}

//取消心跳
- (void)destoryHeartBeat
{
    if (self->heartBeat)
    {
        [self->heartBeat invalidate];
        self->heartBeat = nil;
    }
}

//pingPong机制
- (void)ping
{
    NSDictionary *dict =[NSDictionary dictionaryWithObject:@"ping" forKey:@"type"];
    [self->_socket sendPing:[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil]];
}

- (void)sendData:(id)data
{
    
    __weak __typeof(&*self)weakSelf = self;
    dispatch_queue_t queue =  dispatch_queue_create("zy", NULL);
    
    dispatch_async(queue, ^{
        if (weakSelf.socket != nil) {
            // 只有 SR_OPEN 开启状态才能调 send 方法，不然要崩
            if (weakSelf.socket.readyState == SR_OPEN) {
                [weakSelf.socket send:data];    // 发送数据
                
            } else if (weakSelf.socket.readyState == SR_CONNECTING) {
                NSLog(@"正在连接中，重连后其他方法会去自动同步数据");
                // 每隔2秒检测一次 socket.readyState 状态，检测 10 次左右
                // 只要有一次状态是 SR_OPEN 的就调用 [ws.socket send:data] 发送数据
                // 如果 10 次都还是没连上的，那这个发送请求就丢失了，这种情况是服务器的问题了，小概率的
                [self reConnect];
                
            } else if (weakSelf.socket.readyState == SR_CLOSING || weakSelf.socket.readyState == SR_CLOSED) {
                // websocket 断开了，调用 reConnect 方法重连
                [self reConnect];
            }
        } else {
            NSLog(@"没网络，发送失败，一旦断网 socket 会被我设置 nil 的");
        }
    });
}


-(void)openCheckRoomInfoTimer
{
    [self destoryHeartBeat];
    
    __weak typeof(self) weakSelf = self;
    if (@available(iOS 10.0, *))
    {
        checkRoomInfoTimer = [NSTimer scheduledTimerWithTimeInterval:15 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [weakSelf checkRoomInfoAndPresentPreviewPage];
        }];
    }
    else
    {
        // Fallback on earlier versions
        checkRoomInfoTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkRoomInfoAndPresentPreviewPage) userInfo:nil repeats:YES];
    }
    [[NSRunLoop currentRunLoop] addTimer:self->checkRoomInfoTimer forMode:NSRunLoopCommonModes];
}


- (void)closeRoomInfoTimer
{
    if (self->checkRoomInfoTimer)
    {
        [self->checkRoomInfoTimer invalidate];
        self->checkRoomInfoTimer = nil;
    }
}

-(void)checkRoomInfoAndPresentPreviewPage
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
             NSDictionary *userDic = dataDic[@"user"];
             NSDictionary *owner_streamDic = roomDic[@"owner_stream"];
             self->playRtmpUrlString = owner_streamDic[@"rtmp"];
             self->playFlvUrlString = owner_streamDic[@"flv"];
             self->roomIDString = roomDic[@"room_id"];
             
             NSNumber *status = userDic[@"stream_status"];
             if (status.intValue == 2)
             {
                 if (self->didEnterLivepReviewPage == NO)
                 {
                     self->didEnterLivepReviewPage = YES;
                     //推流中
                     MTLiveConversationViewController *liveViewController = [[MTLiveConversationViewController alloc]init];
                     [liveViewController setRtmpLiveUrlString:self->playRtmpUrlString];
                     [liveViewController setFlvLiveUrlString:self->playFlvUrlString];
                     [liveViewController setRoomid:self->roomIDString];
                     [self.navigationController pushViewController:liveViewController animated:YES];
                 }
             }
             
             
         }
         
     } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
         DLog(@"failure!%@",request.responseObject);
     }];
}


@end
