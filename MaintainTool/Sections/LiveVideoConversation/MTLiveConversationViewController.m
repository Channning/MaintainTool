
//
//  MTLiveConversationViewController.m
//  MaintainTool
//
//  Created by Channing_rong on 2018/12/13.
//  Copyright © 2018 Channing_rong. All rights reserved.
//

#import "MTLiveConversationViewController.h"
#import "AFNetworkReachabilityManager.h"
#import "TXLivePlayer.h"
#import <SocketRocket/SRWebSocket.h>
#import "MTCameraPlayerContainerView.h"
#import "MTCreateSessionApi.h"
#import "MTCloseSesstionApi.h"
#import <YLGIFImage.h>
#import <YLImageView.h>
#import "FeThreeDotGlow.h"
#import "WXApi.h"

#define kCharCount 6

@interface MTLiveConversationViewController ()<TXLivePlayListener,SRWebSocketDelegate>
{
    
    
    BOOL isExistGuestLiveStream;
    
    NSTimer * heartBeat;
    NSTimeInterval reConnectTime;
}
@property (nonatomic,strong) MTCameraPlayerContainerView *cameraPlayerView;
@property (nonatomic,weak) IBOutlet UIView *topPlayerView;
@property (nonatomic,weak) IBOutlet UIView *bottomPlayerView;

@property (nonatomic,weak) IBOutlet UILabel *inviteLabel;
@property (nonatomic,weak) IBOutlet UIView *titleView;
@property (nonatomic,weak) IBOutlet UIButton *inviteButton;
@property (nonatomic,weak) IBOutlet UIButton *hangupButton;
@property (nonatomic,weak) IBOutlet UIButton *cameraVolumeButton;
@property (nonatomic,weak) IBOutlet YLImageView *gifImageView;
@property (nonatomic,weak) IBOutlet UIImageView *playerbgImageView;
@property (nonatomic,weak) IBOutlet UIView *controlView;
@property (nonatomic,weak) IBOutlet UIView *topVolumeView;

@property (nonatomic,strong) TXLivePlayer * cameraLivePlayer;
@property (nonatomic,strong) TXLivePlayer * phoneLivePlayer;

@property (nonatomic,strong) SRWebSocket *socket;

@property (strong, nonatomic) FeThreeDotGlow *threeDot;
@end

@implementation MTLiveConversationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self initNavgationItemSubviews];
    [self initCameraLivePlayer];
    [self setConstraintsForSubviews];
    [self initSRWebSocket];
    
    if (_guestRtmpLiveUrlString)
    {
        isExistGuestLiveStream = YES;
        [self updateControlsStatusWith:YES];
        [UIView animateWithDuration:1 animations:^{
            [self updateViewConstraintsWith:YES];
        }];
        [self initPhoneLivePlayer];
    }
    else
    {
        [self generateSessionKey];
    }
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    [_socket close];
    [_phoneLivePlayer stopPlay];
    [_phoneLivePlayer removeVideoWidget];
    
    [_cameraLivePlayer stopPlay];
    [_cameraLivePlayer removeVideoWidget];
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_socket close];
    [_phoneLivePlayer stopPlay];
    [_phoneLivePlayer removeVideoWidget];
    
    [_cameraLivePlayer stopPlay];
    [_cameraLivePlayer removeVideoWidget];
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

#pragma mark - updateViewConstraints
-(void)setConstraintsForSubviews
{
    float playerContrainerHeight = (SCREEN_HEIGHT-SafeAreaTopHeight)/2;
    [self.cameraPlayerView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.and.right.equalTo(self.view);
         make.top.equalTo(self.view).offset(SafeAreaTopHeight);
         make.height.mas_equalTo(playerContrainerHeight);
     }];
    
    float playerbgImageViewHeight = 256*SCREEN_WIDTH/375;
    [self.playerbgImageView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.centerY.equalTo(self->_cameraPlayerView);
         make.left.and.right.equalTo(self->_cameraPlayerView);
         make.height.mas_equalTo(playerbgImageViewHeight);
    }];
    
    [self.bottomPlayerView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.and.right.equalTo(self.view);
         make.top.equalTo(self.cameraPlayerView.mas_bottom);
         make.height.mas_equalTo(playerContrainerHeight);
     }];
    
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.centerX.equalTo(self->_bottomPlayerView);
         make.top.equalTo(self->_bottomPlayerView).offset(40);
         make.height.mas_equalTo(26);
     }];
    
    [self.inviteLabel mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(self->_titleView);
         make.right.equalTo(self->_titleView.mas_right).offset(26);
         make.top.and.bottom.equalTo(self->_titleView);
     }];
    
    [self.gifImageView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.left.equalTo(self->_inviteLabel.mas_right);
         make.centerY.equalTo(self->_titleView);
         make.width.mas_equalTo(20);
         make.height.mas_equalTo(15);
     }];
    [self.inviteButton mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(self->_titleView.mas_bottom).offset(30);
         make.centerX.equalTo(self->_bottomPlayerView);
         make.width.mas_equalTo(166);
         make.height.mas_equalTo(36);
     }];
    
    [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.top.equalTo(self->_titleView.mas_bottom).offset(30);
         make.centerX.equalTo(self->_bottomPlayerView);
         make.width.mas_equalTo(110);
         make.height.mas_equalTo(35);
     }];
    
    [self.controlView mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.bottom.equalTo(self.view.mas_bottom).offset(-30);
         make.centerX.equalTo(self.view);
         make.width.mas_equalTo(180);
         make.height.mas_equalTo(70);
     }];
    
    float cameraVolumeY = SafeAreaTopHeight+20+85;
    [self.cameraVolumeButton mas_makeConstraints:^(MASConstraintMaker *make)
     {
         make.right.equalTo(self.view.mas_right).offset(-30);
         make.top.equalTo(self.view.mas_top).offset(cameraVolumeY);
         make.width.mas_equalTo(40);
         make.height.mas_equalTo(40);
     }];
    
    
    
}

- (void)updateViewConstraintsWith:(BOOL)needUpdate
{
    if (needUpdate)
    {
        float topPlayerViewLeftX = SCREEN_WIDTH-240-10;
        [self.cameraPlayerView mas_updateConstraints:^(MASConstraintMaker *make)
         {
             make.right.equalTo(self.view.mas_right).offset(-20);
             make.left.equalTo(self.view.mas_left).offset(topPlayerViewLeftX);
             make.top.equalTo(self.view.mas_top).offset(SafeAreaTopHeight+20);
             make.width.mas_equalTo(240);
             make.height.mas_equalTo(135);
         }];
        
        [self.playerbgImageView mas_updateConstraints:^(MASConstraintMaker *make)
         {
             make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
         }];
        
        [self.bottomPlayerView mas_updateConstraints:^(MASConstraintMaker *make)
         {
             make.left.and.right.equalTo(self.view);
             make.top.equalTo(self.view.mas_top).offset(SafeAreaTopHeight);
             make.height.mas_equalTo(SCREEN_HEIGHT-SafeAreaTopHeight);
         }];
        
    }
    else
    {
        float playerContrainerHeight = (SCREEN_HEIGHT-SafeAreaTopHeight)/2;
        [self.cameraPlayerView mas_updateConstraints:^(MASConstraintMaker *make)
         {
             make.left.and.right.equalTo(self.view);
             make.top.equalTo(self.view).offset(SafeAreaTopHeight);
             make.height.mas_equalTo(playerContrainerHeight);
         }];
        
        float playerbgImageViewHeight = 256*SCREEN_WIDTH/375;
        [self.playerbgImageView mas_updateConstraints:^(MASConstraintMaker *make)
         {
             make.centerY.equalTo(self->_cameraPlayerView);
             make.left.and.right.equalTo(self->_cameraPlayerView);
             make.height.mas_equalTo(playerbgImageViewHeight);
         }];
        float bottomPlayerViewY = SafeAreaTopHeight+playerContrainerHeight;
        [self.bottomPlayerView mas_updateConstraints:^(MASConstraintMaker *make)
         {
             make.left.and.right.equalTo(self.view);
             make.top.equalTo(self.view).offset(bottomPlayerViewY);
             make.height.mas_equalTo(playerContrainerHeight);
         }];
        
//        [self.titleView mas_updateConstraints:^(MASConstraintMaker *make)
//         {
//             make.centerX.equalTo(self->_bottomPlayerView);
//             make.top.equalTo(self->_bottomPlayerView).offset(40);
//             make.height.mas_equalTo(26);
//         }];
//
//        [self.inviteLabel mas_updateConstraints:^(MASConstraintMaker *make)
//         {
//             make.left.equalTo(self->_titleView);
//             make.right.equalTo(self->_titleView.mas_right).offset(26);
//             make.top.and.bottom.equalTo(self->_titleView);
//         }];
//
//        [self.gifImageView mas_updateConstraints:^(MASConstraintMaker *make)
//         {
//             make.left.equalTo(self->_inviteLabel.mas_right);
//             make.right.equalTo(self->_titleView.mas_right);
//             make.centerY.equalTo(self->_titleView);
//             make.width.mas_equalTo(20);
//             make.height.mas_equalTo(15);
//         }];
//        [self.inviteButton mas_updateConstraints:^(MASConstraintMaker *make)
//         {
//             make.top.equalTo(self->_titleView.mas_bottom).offset(30);
//             make.centerX.equalTo(self->_bottomPlayerView);
//             make.width.mas_equalTo(166);
//             make.height.mas_equalTo(36);
//         }];
//
//        [self.hangupButton mas_updateConstraints:^(MASConstraintMaker *make)
//         {
//             make.top.equalTo(self->_titleView.mas_bottom).offset(30);
//             make.centerX.equalTo(self->_bottomPlayerView);
//             make.width.mas_equalTo(110);
//             make.height.mas_equalTo(35);
//         }];
        
  
    }

}
#pragma mark - Init

- (void)initNavgationItemSubviews
{
    
    self.navigationController.navigationBarHidden = NO;
    
    UIBarButtonItem * backButtonItem = [[UIBarButtonItem alloc] init];
    backButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = backButtonItem;
    
    self.navigationItem.title = MyLocal(@"视频通话");
    
    self.inviteLabel.text = @"还未有人参与进来，快来邀请Ta吧~";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareLiveTicketRespond:) name:INFORMLIVECONVERSATIONUPDATEUI object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAlertForCameraIsOffline:) name:INFORMLIVECONVERSATIONSHOWALERT object:nil];
}

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

-(void)initCameraLivePlayer
{
    float playerContrainerHeight = (SCREEN_HEIGHT-SafeAreaTopHeight)/2;
    _cameraPlayerView = [[MTCameraPlayerContainerView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, playerContrainerHeight) PlayUrl:_rtmpLiveUrlString];
    [self.view insertSubview:_cameraPlayerView aboveSubview:_bottomPlayerView];
    
}


-(void)initPhoneLivePlayer
{
    
    _phoneLivePlayer = [[TXLivePlayer alloc] init];
    _phoneLivePlayer.delegate = self;
    [_phoneLivePlayer setupVideoWidget:CGRectMake(0, 0, 0, 0) containView:_bottomPlayerView insertIndex:1];
    
    TXLivePlayConfig* _config = [[TXLivePlayConfig alloc] init];
    //自动模式
    //    _config.bAutoAdjustCacheTime   = YES;
    //    _config.minAutoAdjustCacheTime = 1;
    //    _config.maxAutoAdjustCacheTime = 5;
    //极速模式
    _config.bAutoAdjustCacheTime   = YES;
    _config.minAutoAdjustCacheTime = 0.3;
    _config.maxAutoAdjustCacheTime = 1;
    _config.enableAEC = YES;
    //流畅模式
    //    _config.bAutoAdjustCacheTime   = NO;
    //    _config.minAutoAdjustCacheTime = 5;
    //    _config.maxAutoAdjustCacheTime = 5;
    
    [_phoneLivePlayer setConfig:_config];
    /**
     * 设置画面的裁剪模式
     * @param renderMode 裁剪
     * @see TX_Enum_Type_RenderMode
     */
    [_phoneLivePlayer setRenderRotation:HOME_ORIENTATION_DOWN];
    /**
     * 设置画面的方向
     * @param rotation 方向
     * @see TX_Enum_Type_HomeOrientation
     */
    [_phoneLivePlayer setRenderMode:RENDER_MODE_FILL_SCREEN];
    //设置完成之后再启动播放
    [_phoneLivePlayer startPlay:_guestRtmpLiveUrlString type:PLAY_TYPE_LIVE_RTMP];
    
    _threeDot = [[FeThreeDotGlow alloc] initWithView:self.view blur:NO];
    [self.view addSubview:_threeDot];
    [_threeDot showWhileExecutingBlock:^{
        
    }];
  
}

- (void)generateSessionKey
{
    //字符串素材
    NSArray *_dataArray = [[NSArray alloc] initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",nil];
    
    //Step one
    NSMutableString *_authCodeStr = [[NSMutableString alloc] initWithString:@"IOS_"];
    //Step Two
    //随机从数组中选取需要个数的字符串，拼接为验证码字符串
    for (int i = 0; i < kCharCount; i++)
    {
        NSInteger index = arc4random() % (_dataArray.count-1);
        NSString *tempStr = [_dataArray objectAtIndex:index];
        _authCodeStr = (NSMutableString *)[_authCodeStr stringByAppendingString:tempStr];
    }
    //Step Three
    NSDate *datenow = [NSDate date];
    NSString *timeNowString = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    _authCodeStr = (NSMutableString *)[_authCodeStr stringByAppendingString:[NSString stringWithFormat:@"_%@",timeNowString]];
    DLog(@"SessionKey is %@",_authCodeStr);
    _liveSessionKey = _authCodeStr;
    
    if (_liveSessionKey)
    {
        [self createLiveSession];
    }
}

-(void)createLiveSession
{
    MTCreateSessionApi *generalCmdApi = [[MTCreateSessionApi alloc] initWithKey:MTLiveApiKey openID:[AppDelegateHelper readData:SavedOpenID] roomID:_roomid sessionKey:_liveSessionKey];
    [generalCmdApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request)
     {
         id obj = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:NULL];
         NSNumber *status = obj[@"status"];
         DLog(@"regResponse is %@",request.responseString);
         if(status.intValue == 1)
         {
             //[self initSRWebSocket];
         }
     } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
         DLog(@"failure!%@",request.responseObject);
     }];
    
}

#pragma mark - IBActions
-(IBAction)inviteWechatFriend:(UIButton *)sender
{
    if (!_liveSessionKey)
    {
        [self generateSessionKey];
    }
    
    WXMiniProgramObject *object = [WXMiniProgramObject object];
    object.webpageUrl = @"www.foream.com";
    object.userName = @"gh_885fb1cdacb2";
    object.path = [NSString stringWithFormat:@"/pages/livestart/playpush/playpush?room_id=%@&open_id=%@&session_key=%@",_roomid,[AppDelegateHelper readData:SavedOpenID],_liveSessionKey];

    object.hdImageData = UIImagePNGRepresentation([UIImage imageNamed:@"Live_Share_bg"]);
    object.withShareTicket = YES;

    WXMediaMessage *message = [WXMediaMessage message];
    message.title = [NSString stringWithFormat:@"%@%@",LastLoginUserId,@"邀请你进行视频通话"];
    message.description = [NSString stringWithFormat:@"%@%@",LastLoginUserId,@"邀请你进行视频通话"];
    message.thumbData = nil;  //兼容旧版本节点的图片，小于32KB，新版本优先
    //使用WXMiniProgramObject的hdImageData属性
    message.mediaObject = object;

    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;  //目前只支持会话
    [WXApi sendReq:req];
    
 


}

-(IBAction)hangupLiveInvite:(UIButton *)sender
{
    self.inviteLabel.text = @"还未有人参与进来，快来邀请Ta吧~";

    _gifImageView.hidden = YES;
    self.hangupButton.hidden = YES;
    self.inviteButton.hidden = NO;

    

}

-(IBAction)cameraVolumeButton:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected)
    {
        [sender setBackgroundImage:[UIImage imageNamed:@"Conversation_volume_on"] forState:UIControlStateNormal];
        [_cameraLivePlayer setMute:NO];
    }
    else
    {
        [sender setBackgroundImage:[UIImage imageNamed:@"Conversation_volume_off"] forState:UIControlStateNormal];
        [_cameraLivePlayer setMute:YES];
        
    }
}

-(IBAction)phoneVolumeButton:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected)
    {
        [sender setBackgroundImage:[UIImage imageNamed:@"Conversation_volume_off"] forState:UIControlStateNormal];
        [_phoneLivePlayer setMute:YES];
    
    }
    else
    {
        [sender setBackgroundImage:[UIImage imageNamed:@"Conversation_volume_on"] forState:UIControlStateNormal];
        [_phoneLivePlayer setMute:NO];
        
    }
}

-(IBAction)hangupButtonAction:(UIButton *)sender
{
    MTCloseSesstionApi *generalCmdApi = [[MTCloseSesstionApi alloc] initWithKey:MTLiveApiKey roomID:_roomid sessionKey:_liveSessionKey];
    [generalCmdApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request)
     {
         id obj = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:NULL];
         NSNumber *status = obj[@"status"];
         DLog(@"regResponse is %@",request.responseString);
         if(status.intValue == 1)
         {
             self.inviteLabel.text = @"还未有人参与进来，快来邀请Ta吧~";
             
             self->_gifImageView.hidden = YES;
             self.hangupButton.hidden = YES;
             self.inviteButton.hidden = NO;
             self.inviteLabel.hidden = NO;
             self.controlView.hidden = YES;
             self.cameraVolumeButton.hidden = YES;
             [UIView animateWithDuration:1 animations:^
              {
                  [self.cameraPlayerView setFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, (SCREEN_HEIGHT-SafeAreaTopHeight)/2)];
                  [self.bottomPlayerView setFrame:CGRectMake(0, SafeAreaTopHeight+(SCREEN_HEIGHT-SafeAreaTopHeight)/2, SCREEN_WIDTH, (SCREEN_HEIGHT-SafeAreaTopHeight)/2)];
                  //[self.cameraVolumeButton setFrame:CGRectMake(180, 85, 40,40)];
              } completion:^(BOOL finished)
              {
                  if (finished)
                  {
                      [self->_cameraLivePlayer setupVideoWidget:CGRectMake(0, 0, 0, 0) containView:self->_cameraPlayerView insertIndex:2];
                      [self->_phoneLivePlayer removeVideoWidget];
                      self->_liveSessionKey = nil;
                  }
              }];
         }
     } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
         DLog(@"failure!%@",request.responseObject);
     }];
}


-(void)liveCloseSessionRequest
{
    MTCloseSesstionApi *generalCmdApi = [[MTCloseSesstionApi alloc] initWithKey:MTLiveApiKey roomID:_roomid sessionKey:_liveSessionKey];
    [generalCmdApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request)
     {
         id obj = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:NULL];
         NSNumber *status = obj[@"status"];
         DLog(@"regResponse is %@",request.responseString);
         if(status.intValue == 1)
         {
             [self.navigationController popToRootViewControllerAnimated:YES];
         }
     } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
         DLog(@"failure!%@",request.responseObject);
     }];
}

-(void)shareLiveTicketRespond:(NSNotification *)resp
{
    self.inviteLabel.text = @"等待对方进入...";
    
    _gifImageView.hidden = NO;
    _gifImageView.image = [YLGIFImage imageNamed:@"invite_loading.gif"];
    
    self.inviteButton.hidden = YES;
    self.hangupButton.hidden = NO;
}

-(void)showAlertForCameraIsOffline:(NSNotification *)resp
{
    __weak __typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"通话中断"
                                                                   message:@"相机已经离线或者关机"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"离开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                      
                      {
                          [weakSelf liveCloseSessionRequest];
                      }]];
    [self presentViewController:alert animated:YES completion:nil];
}


-(void)updateControlsStatusWith:(BOOL)isExistGuestLive
{
    if (isExistGuestLive)
    {
        self.gifImageView.hidden = YES;
        self.hangupButton.hidden = YES;
        self.inviteButton.hidden = YES;
        self.inviteLabel.hidden = YES;
        self.playerbgImageView.hidden = YES;
        self.controlView.hidden = NO;
        self.cameraVolumeButton.hidden = NO;
    }
    else
    {
        self.gifImageView.hidden = YES;
        self.hangupButton.hidden = YES;
        self.inviteButton.hidden = NO;
        self.inviteLabel.hidden = NO;
        self.controlView.hidden = YES;
        self.cameraVolumeButton.hidden = YES;
    }

}

#pragma mark - SRWebSocketDelegate

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
    //连接失败就重连
    [self reConnect];
    
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"连接断开，清空socket对象，清空该清空的东西，还有关闭心跳！");
    //连接失败就重连
    [self reConnect];
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
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    NSDictionary *messageDic = obj;
    DLog(@"Received Message Is %@",messageDic);
    if ([messageDic[@"type"] isEqualToString:@"stream_status"])
    {
        NSDictionary *dataDic = messageDic[@"data"];
        if ([dataDic[@"stream_status"] intValue] == 2)
        {
            //推流中
            
        }
        else if([dataDic[@"stream_status"] intValue] == 1)
        {
            self.inviteLabel.text = @"还未有人参与进来，快来邀请Ta吧~";
            
            _gifImageView.hidden = YES;
            self.hangupButton.hidden = YES;
            self.inviteButton.hidden = NO;
        }
    }
    else if ([messageDic[@"type"] isEqualToString:@"join_session"])
    {
        NSDictionary *dataDic = messageDic[@"data"];
        NSDictionary *dataDic2 = dataDic[@"data"];
        NSDictionary *roomDic = dataDic2[@"room"];
        NSDictionary *guestStreamDic = roomDic[@"guest_stream"];
        self.roomid = roomDic[@"room_id"];
        self.guestRtmpLiveUrlString = guestStreamDic[@"rtmp"];
        self.guestFlvLiveUrlString = guestStreamDic[@"flv"];
        
        DLog(@"guestRtmpLiveUrlString is %@, and self.roomid is %@",self.guestRtmpLiveUrlString,self.roomid);
        [self updateControlsStatusWith:YES];
        isExistGuestLiveStream = YES;
        
        [UIView animateWithDuration:1 animations:^{
            [self updateViewConstraintsWith:YES];
        }];
        if (!self.phoneLivePlayer)
        {
            [self initPhoneLivePlayer];
        }
        else
        {
            
            [self->_phoneLivePlayer removeVideoWidget];
            [self->_phoneLivePlayer setupVideoWidget:CGRectZero containView:self->_bottomPlayerView insertIndex:0];
            [self->_phoneLivePlayer startPlay:_guestRtmpLiveUrlString type:PLAY_TYPE_LIVE_RTMP];
            _threeDot = [[FeThreeDotGlow alloc] initWithView:self.view blur:NO];
            [self.view addSubview:_threeDot];
            [_threeDot showWhileExecutingBlock:^{

            }];
        }
        
        
    }
    else if ([messageDic[@"type"] isEqualToString:@"close_session"])
    {
        self.inviteLabel.text = @"还未有人参与进来，快来邀请Ta吧~";
        
        [self updateControlsStatusWith:NO];
        isExistGuestLiveStream = NO;
        [_threeDot removeFromSuperview];
        _threeDot = nil;
        [UIView animateWithDuration:1 animations:^{
            [self updateViewConstraintsWith:NO];
        }];
        self->_liveSessionKey = nil;
        if (self.phoneLivePlayer)
        {
            [self->_phoneLivePlayer stopPlay];
            [self->_phoneLivePlayer removeVideoWidget];
        }
        
        
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


#pragma mark - TXLivePlayListener

-(void) onPlayEvent:(int)EvtID withParam:(NSDictionary*)param
{
    NSDictionary* dict = param;

    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (EvtID == PLAY_EVT_RCV_FIRST_I_FRAME)
        {
            if (!self->_threeDot)
            {
                self->_threeDot = [[FeThreeDotGlow alloc] initWithView:self.view blur:NO];
                [self.view addSubview:self->_threeDot];
                [self->_threeDot showWhileExecutingBlock:^{
                    
                }];
            }
            
        }
        
        if (EvtID == PLAY_EVT_PLAY_BEGIN)
        {
            [self->_threeDot dismiss];
            self->_threeDot.hidden = YES;
//            [self stopLoadingAnimation];
//            long long playDelay = [[NSDate date]timeIntervalSince1970]*1000 - _startPlayTS;
//            AppDemoLog(@"AutoMonitor:PlayFirstRender,cost=%lld", playDelay);
        }
        else if (EvtID == PLAY_EVT_PLAY_PROGRESS)
        {
//            if (_startSeek)
//            {
//                return;
//            }
//            // 避免滑动进度条松开的瞬间可能出现滑动条瞬间跳到上一个位置
//            long long curTs = [[NSDate date]timeIntervalSince1970]*1000;
//            if (llabs(curTs - _trackingTouchTS) < 500)
//            {
//                return;
//            }
//            _trackingTouchTS = curTs;
//
//            float progress = [dict[EVT_PLAY_PROGRESS] floatValue];
//            float duration = [dict[EVT_PLAY_DURATION] floatValue];
//
//            int intProgress = progress + 0.5;
//            _playStart.text = [NSString stringWithFormat:@"%02d:%02d", (int)(intProgress / 60), (int)(intProgress % 60)];
//            [_playProgress setValue:progress];
//
//            int intDuration = duration + 0.5;
//            if (duration > 0 && _playProgress.maximumValue != duration) {
//                [_playProgress setMaximumValue:duration];
//                [_playableProgress setMaximumValue:duration];
//                _playDuration.text = [NSString stringWithFormat:@"%02d:%02d", (int)(intDuration / 60), (int)(intDuration % 60)];
//            }
//
//            [_playableProgress setValue:[dict[EVT_PLAYABLE_DURATION] floatValue]];
            return ;
        }
        else if (EvtID == PLAY_ERR_NET_DISCONNECT || EvtID == PLAY_EVT_PLAY_END)
        {

            __weak __typeof(self) weakSelf = self;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"通话中断"
                                                                           message:@"对方已经结束通话"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"离开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
            {
            
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
                              
            {
                self.inviteLabel.text = @"还未有人参与进来，快来邀请Ta吧~";
                
                [self updateControlsStatusWith:NO];
                self->isExistGuestLiveStream = NO;
                [self->_threeDot removeFromSuperview];
                self->_threeDot = nil;
                
                [UIView animateWithDuration:1 animations:^{
                    [self updateViewConstraintsWith:NO];
                }];
                self->_liveSessionKey = nil;
                if (self.phoneLivePlayer)
                {
                    [self->_phoneLivePlayer stopPlay];
                    [self->_phoneLivePlayer removeVideoWidget];
                }
                
            }]];
            [weakSelf presentViewController:alert animated:YES completion:nil];
            
        }
        else if (EvtID == PLAY_EVT_PLAY_LOADING)
        {
            self->_threeDot.hidden = NO;
            [self->_threeDot showWhileExecutingBlock:^{
                
            }];
        }
        else if (EvtID == PLAY_EVT_CONNECT_SUCC)
        {
            BOOL isWifi = [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
            if (!isWifi)
            {
                __weak __typeof(self) weakSelf = self;
                [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//                    if (_playUrl.length == 0) {
//                        return;
//                    }
                    if (status == AFNetworkReachabilityStatusReachableViaWiFi)
                    {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                                       message:@"您要切换到Wifi再观看吗?"
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        [alert addAction:[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [alert dismissViewControllerAnimated:YES completion:nil];
//                            [weakSelf stopRtmp];
//                            [weakSelf startRtmp];
                        }]];
                        [alert addAction:[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            [alert dismissViewControllerAnimated:YES completion:nil];
                        }]];
                        [weakSelf presentViewController:alert animated:YES completion:nil];
                    }
                }];
            }
        }else if (EvtID == PLAY_EVT_CHANGE_ROTATION) {
            return;
        }
        NSLog(@"MTLiveConversationViewController evt:%d,%@,EVT_MSG is %@", EvtID, dict,dict[@"EVT_MSG"]);
//        long long time = [(NSNumber*)[dict valueForKey:EVT_TIME] longLongValue];
//        int mil = time % 1000;
//        NSDate* date = [NSDate dateWithTimeIntervalSince1970:time/1000];
//        NSString* Msg = (NSString*)[dict valueForKey:EVT_MSG];
    });
}

-(void) onNetStatus:(NSDictionary*) param
{
    NSDictionary* dict = param;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        int netspeed  = [(NSNumber*)[dict valueForKey:NET_STATUS_NET_SPEED] intValue];
        int vbitrate  = [(NSNumber*)[dict valueForKey:NET_STATUS_VIDEO_BITRATE] intValue];
        int abitrate  = [(NSNumber*)[dict valueForKey:NET_STATUS_AUDIO_BITRATE] intValue];
//        int cachesize = [(NSNumber*)[dict valueForKey:NET_STATUS_CACHE_SIZE] intValue];
//        int dropsize  = [(NSNumber*)[dict valueForKey:NET_STATUS_DROP_SIZE] intValue];
//        int jitter    = [(NSNumber*)[dict valueForKey:NET_STATUS_NET_JITTER] intValue];
        int fps       = [(NSNumber*)[dict valueForKey:NET_STATUS_VIDEO_FPS] intValue];
        int width     = [(NSNumber*)[dict valueForKey:NET_STATUS_VIDEO_WIDTH] intValue];
        int height    = [(NSNumber*)[dict valueForKey:NET_STATUS_VIDEO_HEIGHT] intValue];
//        float cpu_usage = [(NSNumber*)[dict valueForKey:NET_STATUS_CPU_USAGE] floatValue];
//        float cpu_app_usage = [(NSNumber*)[dict valueForKey:NET_STATUS_CPU_USAGE_D] floatValue];
//        NSString *serverIP = [dict valueForKey:NET_STATUS_SERVER_IP];
//        int codecCacheSize = [(NSNumber*)[dict valueForKey:NET_STATUS_CODEC_CACHE] intValue];
//        int nCodecDropCnt = [(NSNumber*)[dict valueForKey:NET_STATUS_CODEC_DROP_CNT] intValue];
//        int nCahcedSize = [(NSNumber*)[dict valueForKey:NET_STATUS_CACHE_SIZE] intValue]/1000;
//        int nSetVideoBitrate = [(NSNumber *) [dict valueForKey:NET_STATUS_SET_VIDEO_BITRATE] intValue];
//        int videoCacheSize = [(NSNumber *) [dict valueForKey:NET_STATUS_VIDEO_CACHE_SIZE] intValue];
//        int vDecCacheSize = [(NSNumber *) [dict valueForKey:NET_STATUS_V_DEC_CACHE_SIZE] intValue];
//        int playInterval = [(NSNumber *) [dict valueForKey:NET_STATUS_AV_PLAY_INTERVAL] intValue];
//        int avRecvInterval = [(NSNumber *) [dict valueForKey:NET_STATUS_AV_RECV_INTERVAL] intValue];
//        float audioPlaySpeed = [(NSNumber *) [dict valueForKey:NET_STATUS_AUDIO_PLAY_SPEED] floatValue];
//        NSString * audioInfo = [dict valueForKey:NET_STATUS_AUDIO_INFO];
//        int videoGop = (int)([(NSNumber *) [dict valueForKey:NET_STATUS_VIDEO_GOP] doubleValue]+0.5f);
//        NSString* log = [NSString stringWithFormat:@"CPU:%.1f%%|%.1f%%\tRES:%d*%d\tSPD:%dkb/s\nJITT:%d\tFPS:%d\tGOP:%ds\tARA:%dkb/s\nQUE:%d|%d,%d,%d|%d,%d,%0.1f\tVRA:%dkb/s\nSVR:%@\tAUDIO:%@",
//                         cpu_app_usage*100,
//                         cpu_usage*100,
//                         width,
//                         height,
//                         netspeed,
//                         jitter,
//                         fps,
//                         videoGop,
//                         abitrate,
//                         codecCacheSize,
//                         cachesize,
//                         videoCacheSize,
//                         vDecCacheSize,
//                         avRecvInterval,
//                         playInterval,
//                         audioPlaySpeed,
//                         vbitrate,
//                         serverIP,
//                         audioInfo];
//        DLog(@"Current status, VideoBitrate:%d, AudioBitrate:%d, FPS:%d, RES:%d*%d, netspeed:%d", vbitrate, abitrate, fps, width, height, netspeed);
    });
}

@end
