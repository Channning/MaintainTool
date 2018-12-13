
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
#import "WXApi.h"

@interface MTLiveConversationViewController ()<TXLivePlayListener,SRWebSocketDelegate>

@property (nonatomic,weak) IBOutlet UIView *topPlayerView;
@property (nonatomic,weak) IBOutlet UIView *bottomPlayerView;

@property (nonatomic,strong) TXLivePlayer * cameraLivePlayer;
@property (nonatomic,strong) TXLivePlayer * phoneLivePlayer;
@end

@implementation MTLiveConversationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNavgationItemSubviews];
    [self initCameraLivePlayer];
    [self initSRWebSocket];
    // Do any additional setup after loading the view.
}


#pragma mark - Init

- (void)initNavgationItemSubviews
{
    UIBarButtonItem * backButtonItem = [[UIBarButtonItem alloc] init];
    backButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = backButtonItem;
    
    self.navigationItem.title = MyLocal(@"我的直播");
    
    
}

-(void)initSRWebSocket
{
    SRWebSocket *socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"wss://wx.driftlife.co?open_id=%@",[AppDelegateHelper readData:SavedOpenID]]]]];
    // 实现这个 SRWebSocketDelegate 协议啊
    socket.delegate = self;
    [socket open];    // open 就是直接连接了
}

-(void)initCameraLivePlayer
{
    _cameraLivePlayer = [[TXLivePlayer alloc] init];
    _cameraLivePlayer.delegate = self;
    [_cameraLivePlayer setupVideoWidget:CGRectMake(0, 0, 0, 0) containView:_topPlayerView insertIndex:0];
    
    TXLivePlayConfig* _config = [[TXLivePlayConfig alloc] init];
    //自动模式
//    _config.bAutoAdjustCacheTime   = YES;
//    _config.minAutoAdjustCacheTime = 1;
//    _config.maxAutoAdjustCacheTime = 5;
    //极速模式
    _config.bAutoAdjustCacheTime   = YES;
    _config.minAutoAdjustCacheTime = 1;
    _config.maxAutoAdjustCacheTime = 1;
    //流畅模式
//    _config.bAutoAdjustCacheTime   = NO;
//    _config.minAutoAdjustCacheTime = 5;
//    _config.maxAutoAdjustCacheTime = 5;
    
    [_cameraLivePlayer setConfig:_config];
    /**
     * 设置画面的裁剪模式
     * @param renderMode 裁剪
     * @see TX_Enum_Type_RenderMode
     */
    [_cameraLivePlayer setRenderRotation:HOME_ORIENTATION_DOWN];
    /**
     * 设置画面的方向
     * @param rotation 方向
     * @see TX_Enum_Type_HomeOrientation
     */
    [_cameraLivePlayer setRenderMode:RENDER_MODE_FILL_EDGE];
    //设置完成之后再启动播放
    [_cameraLivePlayer startPlay:_rtmpLiveUrlString type:PLAY_TYPE_LIVE_RTMP];
}

#pragma mark -IBActions
-(IBAction)inviteWechatFriend:(id)sender
{
    WXMiniProgramObject *object = [WXMiniProgramObject object];
    object.webpageUrl = @"www.foream.com";
    object.userName = @"gh_885fb1cdacb2";
    object.path = @"pages/livestart/live_main/livemain";
    object.hdImageData = nil;
    object.withShareTicket = YES;
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"维保印记";
    message.description = @"维保视频会议小程序";
    message.thumbData = nil;  //兼容旧版本节点的图片，小于32KB，新版本优先
    //使用WXMiniProgramObject的hdImageData属性
    message.mediaObject = object;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;  //目前只支持会话
    [WXApi sendReq:req];
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
    if ([message[@"type"] isEqualToString:@"stream_status"])
    {
        NSDictionary *dataDic = message[@"data"];
        if ([dataDic[@"stream_status"] intValue] == 2)
        {
            //推流中
            
        }
    }
    else if ([message[@"type"] isEqualToString:@"join_session"])
    {
        
    }
    else if ([message[@"type"] isEqualToString:@"close_session"])
    {
        
    }
    
}


#pragma ###TXLivePlayListener

-(void) onPlayEvent:(int)EvtID withParam:(NSDictionary*)param
{
//    NSDictionary* dict = param;
//
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (EvtID == PLAY_EVT_RCV_FIRST_I_FRAME)
        {
            //            _publishParam = nil;
        }
        
        if (EvtID == PLAY_EVT_PLAY_BEGIN)
        {
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
//            [self stopRtmp];
//            _play_switch = NO;
//            [_btnPlay setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
//            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
//            [_playProgress setValue:0];
//            _playStart.text = @"00:00";
//            _videoPause = NO;
//
//            if (EvtID == PLAY_ERR_NET_DISCONNECT) {
//                NSString* Msg = (NSString*)[dict valueForKey:EVT_MSG];
//                [self toastTip:Msg];
//            }
            
        }
        else if (EvtID == PLAY_EVT_PLAY_LOADING)
        {
            //[self startLoadingAnimation];
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
        //        NSLog(@"evt:%d,%@", EvtID, dict);
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
        DLog(@"Current status, VideoBitrate:%d, AudioBitrate:%d, FPS:%d, RES:%d*%d, netspeed:%d", vbitrate, abitrate, fps, width, height, netspeed);
    });
}

@end
