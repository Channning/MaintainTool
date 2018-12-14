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
    
    BOOL isExistLiveRoom;
}
@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    isExistLiveRoom = NO;
    [self initNavgationItemSubviews];
    NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"Device UUID = %@", udid);
    [AppDelegateHelper saveData:udid forKey:SavedOpenID];
    [self getOwnerRoomInfo];
}


#pragma mark - initialization
- (void)initNavgationItemSubviews
{
    
    self.navigationController.navigationBarHidden = YES;
    
    UIBarButtonItem * backButtonItem = [[UIBarButtonItem alloc] init];
    backButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = backButtonItem;

    
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
             
         }
   
     } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
         DLog(@"failure!%@",request.responseObject);
     }];
}



#pragma mark - IBAction

-(IBAction)connectToCamera:(id)sender
{
    if (isExistLiveRoom)
    {
        MTLiveConversationViewController *liveConversationView = [[MTLiveConversationViewController alloc]init];
        [liveConversationView setRtmpLiveUrlString:playRtmpUrlString];
        [liveConversationView setFlvLiveUrlString:playFlvUrlString];
        [liveConversationView setRoomid:roomid];
        [self.navigationController pushViewController:liveConversationView animated:YES];
    }
   else
   {
       MTCameraOptionsViewController *cameraOptionsVC = [[MTCameraOptionsViewController alloc]init];
       [self.navigationController pushViewController:cameraOptionsVC animated:YES];
       
   }
    
}
@end
