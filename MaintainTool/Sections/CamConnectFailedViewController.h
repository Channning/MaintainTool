//
//  CamConnectFailedViewController.h
//  Foream
//
//  Created by rongbaohong on 16/4/19.
//  Copyright © 2016年 Foream. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, FailedType) {
    FailedTypeSmartconfig,
    FailedTypeQRcode,
  
};

@protocol CamConnectFailedDelegate <NSObject>
@optional
-(void) dismissAndrestartCountTimer;
-(void) dismissAndTryQRcodeMode;
-(void) dismissAndTrySmartConfigMode;
@end
@interface CamConnectFailedViewController : UIViewController
@property (unsafe_unretained, nonatomic) id<CamConnectFailedDelegate>delegate;
@property (unsafe_unretained, nonatomic) FailedType failureType;
@property (unsafe_unretained, nonatomic) BOOL isResponsedFromHelp;
@end
