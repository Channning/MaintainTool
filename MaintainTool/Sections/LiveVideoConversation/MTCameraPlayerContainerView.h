//
//  MTCameraPlayerContainerView.h
//  MaintainTool
//
//  Created by Channing_rong on 2018/12/21.
//  Copyright © 2018 Channing_rong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXLivePlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTCameraPlayerContainerView : UIView
@property (nonatomic,strong) TXLivePlayer * cameraLivePlayer;
-(id)initWithFrame:(CGRect)frame PlayUrl:(NSString *)rtmpUrl;
@end

NS_ASSUME_NONNULL_END
