//
//  MTLiveConversationViewController.h
//  MaintainTool
//
//  Created by Channing_rong on 2018/12/13.
//  Copyright © 2018 Channing_rong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTLiveConversationViewController : UIViewController

@property (nonatomic,copy) NSString *rtmpLiveUrlString;
@property (nonatomic,copy) NSString *flvLiveUrlString;
@property (nonatomic,copy) NSString *guestRtmpLiveUrlString;
@property (nonatomic,copy) NSString *guestFlvLiveUrlString;
@property (nonatomic,copy) NSString *roomid;
@property (nonatomic,copy) NSString *liveSessionKey;

@end

NS_ASSUME_NONNULL_END
