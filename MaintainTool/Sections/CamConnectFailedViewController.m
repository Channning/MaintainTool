//
//  CamConnectFailedViewController.m
//  Foream
//
//  Created by rongbaohong on 16/4/19.
//  Copyright © 2016年 Foream. All rights reserved.
//

#import "CamConnectFailedViewController.h"
#import "UIViewController+MaryPopin.h"
#import "CCMPlayNDropView.h"
#import <QuartzCore/QuartzCore.h>

@interface CamConnectFailedViewController ()<CCMPlayNDropViewDelegate>


@property (nonatomic,weak) IBOutlet UIButton *closeButton;
@property (nonatomic,weak) IBOutlet UIButton *tryAgainButton;
@property (nonatomic,weak) IBOutlet UIButton *tryQRAgainButton;
@property (nonatomic,weak) IBOutlet UIButton *tryQRcodeButton;
@property (nonatomic,weak) IBOutlet UIButton *trySmartconfigButton;
@property (nonatomic,weak) IBOutlet UILabel *firstLabel;
@property (nonatomic,weak) IBOutlet UILabel *secondLabel;
@property (nonatomic,weak) IBOutlet UILabel *thirdLabel;
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;

@property (nonatomic,weak) IBOutlet UILabel *qrfirstLabel;
@property (nonatomic,weak) IBOutlet UILabel *qrsecondLabel;
@property (nonatomic,weak) IBOutlet UILabel *qrthirdLabel;
@property (nonatomic,weak) IBOutlet UILabel *qrtitleLabel;
@property (nonatomic,weak) IBOutlet UIButton *qrcloseButton;

@property (nonatomic,weak) IBOutlet UIView *smartconfigView;
@property (nonatomic,weak) IBOutlet UIView *qrCodeView;
@end

@implementation CamConnectFailedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initBasicContrlsSetup];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)CCMPlayNDropViewWillStartDismissAnimationWithDynamics:(CCMPlayNDropView *)view{
    self.view.superview.userInteractionEnabled = NO;
    self.view.userInteractionEnabled = NO;
}

-(void)CCMPlayNDropViewDidFinishDismissAnimationWithDynamics:(CCMPlayNDropView *)view{
    self.view.superview.userInteractionEnabled = YES;
    CGRect frame = self.view.frame;
    frame.origin.y = -1000;
    self.view.frame = frame;
    [self.parentViewController dismissCurrentPopinControllerAnimated:YES];
    if ([_delegate respondsToSelector:@selector(dismissAndrestartCountTimer)]) {
        [_delegate dismissAndrestartCountTimer];
    }
}

#pragma mark - initialization

-(void)initBasicContrlsSetup
{
    
    
    //圆角设置
    
    self.view.layer.cornerRadius
    = 10;
    
    self.view.layer.masksToBounds
    = YES;
    self.view.layer.borderWidth = 2;
    self.view.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    if (_failureType == FailedTypeSmartconfig) {
        [self.qrCodeView setHidden:YES];
        [self.smartconfigView setHidden:NO];
        [self.tryAgainButton setBackgroundColor:UIColorFromRGB(0xe4b475)];
        [self.firstLabel setFont:StandardFONT(16)];
        [self.firstLabel setText:MyLocal(@"1. You can click the right button to try again.")];
        [self.firstLabel setTextColor:UIColorFromRGB(0x6f6f6f)];
        [self.secondLabel setFont:StandardFONT(16)];
        [self.secondLabel setTextColor:UIColorFromRGB(0x6f6f6f)];
        [self.secondLabel setText:MyLocal(@"2. Or you can click the left button to try the QR code mode for starting live streaming.")];
        //[self.thirdLabel setFont:StandardFONT(16)];
        //[self.thirdLabel setTextColor:UIColorFromRGB(0x6f6f6f)];
        [self.titleLabel setFont:[UIFont fontWithName:@"HaginCapsMedium" size:29]];
        [self.titleLabel setText:MyLocal(@"CONNECT FAILED")];
        self.tryAgainButton.layer.shadowOffset = CGSizeMake(5,5);
        self.tryAgainButton.layer.shadowOpacity = 0.7f;
        self.tryAgainButton.layer.shadowRadius = 5.0;
        
        NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:MyLocal(@"If you are still having trouble connecting your Camera, please try updating your firmware: https://driftinnovation.com/blogs/support")]];
        
        
        NSUInteger linkLength = 0;
        NSArray *languages = [NSLocale preferredLanguages];
        NSString *_currentLanguage = [languages objectAtIndex:0];
        
        if(([_currentLanguage rangeOfString:@"zh-Hant"].length>0)||([_currentLanguage rangeOfString:@"zh-Hans"].length>0))
        {
            
            linkLength = 23;
        }else
        {
            
            linkLength = 42;
        }
      
        NSRange contentRange = {0,[content length]-linkLength};
        DLog(@"[content length] is %d",(int)[content length]);
        [content addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x6f6f6f) range:contentRange];
        [content addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xe4b475) range:NSMakeRange([content length]-linkLength, linkLength)];
        DLog(@"content is %@",content);
        [self.thirdLabel setFont:StandardFONT(16)];
        self.thirdLabel.attributedText = content;
        
        [self.tryAgainButton setTitle:MyLocal(@"Try Again") forState:UIControlStateNormal];
        [self.tryQRcodeButton setTitle:MyLocal(@"Try QR code") forState:UIControlStateNormal];

    }
    else
    {
        [self.qrCodeView setHidden:NO];
        [self.smartconfigView setHidden:YES];
        [self.qrfirstLabel setFont:StandardFONT(15)];
        [self.qrfirstLabel setTextColor:UIColorFromRGB(0x6f6f6f)];
        [self.qrfirstLabel setText:MyLocal(@"If the front indicator light turns blue but the Wi-Fi light does not flash red, your Compass was unable to scan the code correctly. Try scanning again.")];
        [self.qrsecondLabel setFont:StandardFONT(15)];
        [self.qrsecondLabel setTextColor:UIColorFromRGB(0x6f6f6f)];
        [self.qrsecondLabel setText:MyLocal(@"Your camera will have trouble scaning the code if your device is in direct light, or it's brightness is too low.")];

        [self.qrtitleLabel setFont:[UIFont fontWithName:@"HaginCapsMedium" size:29]];
        [self.qrtitleLabel setText:MyLocal(@"HAVING TROUBLE CONNECTING?")];

        NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:MyLocal(@"If you are still having trouble connecting your Camera, please try updating your firmware: https://driftinnovation.com/blogs/support")]];
        
        NSArray *languages = [NSLocale preferredLanguages];
        NSString *_currentLanguage = [languages objectAtIndex:0];
        NSUInteger linkLength = 0;
        if(([_currentLanguage rangeOfString:@"zh-Hant"].length>0)||([_currentLanguage rangeOfString:@"zh-Hans"].length>0))
        {
            
            linkLength = 23;
        }else
        {
            
            linkLength = 42;
        }
        NSRange contentRange = {0,[content length]-linkLength};
        DLog(@"[content length] is %d",(int)[content length]);
        [content addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x6f6f6f) range:contentRange];
        [content addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xe4b475) range:NSMakeRange([content length]-linkLength, linkLength)];
        DLog(@"content is %@",content);
        [self.qrthirdLabel setFont:[UIFont fontWithName:@"MuseoSans-500" size:15]];
        self.qrthirdLabel.attributedText = content;
        if (_isResponsedFromHelp) {
            [self.qrthirdLabel setHidden:NO];
            [self.tryQRAgainButton setHidden:YES];
            [self.trySmartconfigButton setHidden:YES];
       
        }
        else
        {
        
            [self.qrthirdLabel setHidden:YES];
            [self.tryQRAgainButton setHidden:NO];
            [self.trySmartconfigButton setHidden:NO];
            [self.tryQRAgainButton setBackgroundColor:UIColorFromRGB(0xe4b475)];
            self.tryQRAgainButton.layer.shadowOffset = CGSizeMake(5,5);
            self.tryQRAgainButton.layer.shadowOpacity = 0.7f;
            self.tryQRAgainButton.layer.shadowRadius = 5.0;
            [self.tryQRAgainButton setTitle:MyLocal(@"Try Again") forState:UIControlStateNormal];
        }
        
    }

   
    
}

#pragma mark - IBAction

-(IBAction)closeButtonDidClick:(id)sender
{
    self.view.superview.userInteractionEnabled = YES;
    CGRect frame = self.view.frame;
    frame.origin.y = -1000;
    self.view.frame = frame;
    [self.parentViewController dismissCurrentPopinControllerAnimated:YES];
    if ([_delegate respondsToSelector:@selector(dismissAndrestartCountTimer)]) {
        [_delegate dismissAndrestartCountTimer];
    }

}
-(IBAction)tryQRcode:(id)sender
{
    
    self.view.superview.userInteractionEnabled = YES;
    CGRect frame = self.view.frame;
    frame.origin.y = -1000;
    self.view.frame = frame;
    [self.parentViewController dismissCurrentPopinControllerAnimated:YES];
    
    if ([_delegate respondsToSelector:@selector(dismissAndTryQRcodeMode)]) {
        [_delegate dismissAndTryQRcodeMode];
    }
    
}

-(IBAction)trySmartConfig:(id)sender
{
    
    self.view.superview.userInteractionEnabled = YES;
    CGRect frame = self.view.frame;
    frame.origin.y = -1000;
    self.view.frame = frame;
    [self.parentViewController dismissCurrentPopinControllerAnimated:YES];
    
    if ([_delegate respondsToSelector:@selector(dismissAndTrySmartConfigMode)]) {
        [_delegate dismissAndTrySmartConfigMode];
    }
    
}


#pragma mark - Screen rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{       //IOS4～5
    return NO;
}

- (BOOL)shouldAutorotate
{       //IOS6
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
