//
//  RootViewController.m
//  MaintainTool
//
//  Created by Channing_rong on 2018/12/6.
//  Copyright © 2018 Channing_rong. All rights reserved.
//

#import "RootViewController.h"
#import "MTLiveConversationViewController.h"
#import "MTCameraOptionsViewController.h"
#import "MTOwnerRoomInfoApi.h"

@interface RootViewController ()
{
    NSString *playRtmpUrlString;
    NSString *playFlvUrlString;
    NSString *roomid;
    
    NSString *guestPlayRtmpUrlString;
    NSString *guestPlayFlvUrlString;
    
    BOOL isExistLiveRoom;
    BOOL isExistGuestLiveRoom;
}
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UIImageView *statusImageView;
@property (nonatomic,weak) IBOutlet UIButton *videoConversationButton;

@property (nonatomic,weak) IBOutlet UILabel *scanTitleLabel;
@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    isExistLiveRoom = NO;
    isExistGuestLiveRoom = NO;
    [self initNavgationItemSubviews];
    NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"Device UUID = %@", udid);
    [AppDelegateHelper saveData:udid forKey:SavedOpenID];
    [self getOwnerRoomInfo];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    self.navigationController.navigationBarHidden = YES;
    [super viewWillAppear:animated];
}


#pragma mark - initialization
- (void)initNavgationItemSubviews
{
    UIBarButtonItem * backButtonItem = [[UIBarButtonItem alloc] init];
    backButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = backButtonItem;
    
    [self.titleLabel setFont:[UIFont fontWithName:@"Adobe Heiti Std R" size: 14.5]];
    [self.titleLabel setText:@"视频通话"];
    
    [self.scanTitleLabel setFont:[UIFont fontWithName:@"Adobe Heiti Std R" size: 14.5]];
    [self.scanTitleLabel setText:@"扫码二维码拍摄"];
    
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
             NSDictionary *userDic = dataDic[@"user"];
             NSDictionary *owner_streamDic = roomDic[@"owner_stream"];
             self->playRtmpUrlString = owner_streamDic[@"rtmp"];
             self->playFlvUrlString = owner_streamDic[@"flv"];
             self->roomid = roomDic[@"room_id"];
             
             NSNumber *status = userDic[@"stream_status"];
             if (status.intValue == 2)
             {
                 self->isExistLiveRoom = YES;
             }
             
             NSDictionary *guest_streamDic = roomDic[@"guest_stream"];
             NSNumber *guest_status = guest_streamDic[@"status"];
             
             self->guestPlayRtmpUrlString = guest_streamDic[@"rtmp"];
             self->guestPlayFlvUrlString = guest_streamDic[@"flv"];
             
             if (guest_status.intValue == 2)
             {
                 self->isExistGuestLiveRoom = YES;
             }
         }
   
     } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
         DLog(@"failure!%@",request.responseObject);
     }];
}



#pragma mark - IBAction

-(IBAction)connectToCamera:(id)sender
{
    isExistLiveRoom = YES;
    isExistGuestLiveRoom = YES;
    guestPlayRtmpUrlString = @"rtmp://media3.sinovision.net:1935/live/livestream";
    playRtmpUrlString = @"rtmp://58.200.131.2:1935/livetv/hunantv";
    roomid = @"f8ucVWyz";
    if (isExistLiveRoom)
    {
        MTLiveConversationViewController *liveConversationView = [[MTLiveConversationViewController alloc]init];
        [liveConversationView setRtmpLiveUrlString:playRtmpUrlString];
        [liveConversationView setFlvLiveUrlString:playFlvUrlString];
        [liveConversationView setRoomid:roomid];
        if (isExistGuestLiveRoom)
        {
            [liveConversationView setGuestRtmpLiveUrlString:guestPlayRtmpUrlString];
            [liveConversationView setGuestFlvLiveUrlString:guestPlayFlvUrlString];
        }
        [self.navigationController pushViewController:liveConversationView animated:YES];
    }
   else
   {
       MTCameraOptionsViewController *cameraOptionsVC = [[MTCameraOptionsViewController alloc]init];
       [self.navigationController pushViewController:cameraOptionsVC animated:YES];
       
   }
    
}

-(IBAction)scanQRcodeAndShot:(id)sender
{
    [AppDelegateHelper showSuccessWithTitle:@"即将推出,敬请期待" withMessage:nil view:self.view];
}
@end
