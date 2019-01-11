//
//  MTScanQRcodeShotViewController.h
//  MaintainTool
//
//  Created by Channing_rong on 2018/12/28.
//  Copyright © 2018 Channing_rong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTScanQRcodeShotViewController : UIViewController

@property (nonatomic,assign) BOOL bOnlyForScan;
@property (nonatomic,copy)  NSString *contentInfo;
@property (nonatomic,copy)  NSString * ssidInfo;
@property (nonatomic,copy)  NSString * passwordInfo;
@end

NS_ASSUME_NONNULL_END
