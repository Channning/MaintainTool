//
//  MTManualInputViewController.h
//  MaintainTool
//
//  Created by Channing_rong on 2018/12/29.
//  Copyright © 2018 Channing_rong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTManualInputViewController : UIViewController<UITextFieldDelegate>
@property (nonatomic,weak) IBOutlet UITextField *userIDTextField;
@property (nonatomic,weak) IBOutlet UIButton *saveButton;
@property (nonatomic) BOOL bAddMode;

@end

NS_ASSUME_NONNULL_END
