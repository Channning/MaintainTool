//
//  MTCameraPlayerContainerView.m
//  MaintainTool
//
//  Created by Channing_rong on 2018/12/21.
//  Copyright © 2018 Channing_rong. All rights reserved.
//

#import "MTCameraPlayerContainerView.h"
#import "FeThreeDotGlow.h"

@interface MTCameraPlayerContainerView ()<TXLivePlayListener>

@property (nonatomic,copy) NSString *rtmpLiveUrlString;
@property (strong, nonatomic) FeThreeDotGlow *threeDot;
@property (nonatomic,strong) UIImageView *bgimageView;

@end
@implementation MTCameraPlayerContainerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
 
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame PlayUrl:(NSString *)rtmpUrl
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.rtmpLiveUrlString = rtmpUrl;
        [self initCameraLivePlayer];
 
        _bgimageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Live_loading_bg"]];
        [self addSubview:_bgimageView];
        
        [_bgimageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.top.equalTo(self);
            make.bottom.equalTo(self);
        }];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.threeDot removeFromSuperview];
    self.threeDot = nil;
    self->_threeDot = [[FeThreeDotGlow alloc] initWithView:self blur:NO];
    [self addSubview:self->_threeDot];
    [self->_threeDot showWhileExecutingBlock:^{
    }];
    self->_threeDot.hidden = YES;
}

-(void)initCameraLivePlayer
{
    _cameraLivePlayer = [[TXLivePlayer alloc] init];
    _cameraLivePlayer.delegate = self;
    [_cameraLivePlayer setupVideoWidget:CGRectMake(0, 0, 0, 0) containView:self insertIndex:0];
    
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
    
//    _threeDot = [[FeThreeDotGlow alloc] initWithView:self blur:NO];
//    [self addSubview:_threeDot];
//    [_threeDot setFrame:CGRectMake(0, 0, 36, 36)];
//    [_threeDot showWhileExecutingBlock:^{
//
//    }];
}

#pragma mark - TXLivePlayListener

-(void) onPlayEvent:(int)EvtID withParam:(NSDictionary*)param
{
    NSDictionary* dict = param;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (EvtID == PLAY_EVT_RCV_FIRST_I_FRAME)
        {
            self->_threeDot = [[FeThreeDotGlow alloc] initWithView:self blur:NO];
            [self addSubview:self->_threeDot];
            [self->_threeDot showWhileExecutingBlock:^{
            }];
            self->_threeDot.hidden = YES;
        }
        
        if (EvtID == PLAY_EVT_PLAY_BEGIN)
        {
            self->_bgimageView.hidden = YES;
            [self->_threeDot dismiss];
            self->_threeDot.hidden = YES;
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
            NSNotification * notification = [NSNotification notificationWithName:INFORMLIVECONVERSATIONSHOWALERT object:nil];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
        }
        else if (EvtID == PLAY_EVT_PLAY_LOADING)
        {
            
            self->_threeDot.hidden = NO;
            [self->_threeDot showWhileExecutingBlock:^{
                
            }];
        }
        else if (EvtID == PLAY_EVT_CONNECT_SUCC)
        {
            
        }else if (EvtID == PLAY_EVT_CHANGE_ROTATION) {
            return;
        }
        NSLog(@"MTCameraPlayerContainerView evt:%d,%@,EVT_MSG is %@", EvtID, dict,dict[@"EVT_MSG"]);
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
