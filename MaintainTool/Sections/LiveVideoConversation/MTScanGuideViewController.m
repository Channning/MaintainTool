//
//  MTScanGuideViewController.m
//  MaintainTool
//
//  Created by Channing_rong on 2018/12/21.
//  Copyright © 2018 Channing_rong. All rights reserved.
//

#import "MTScanGuideViewController.h"
#import "MTQRcodeScanViewController.h"
#import "MTCameraOptionsViewController.h"
@interface MTScanGuideViewController ()

@property (nonatomic,weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic,weak) IBOutlet UIButton *nextButton;
@property (nonatomic,weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UIView *bottomView;
@property (nonatomic,weak) IBOutlet UIImageView *bgX1ImageView;
@end

@implementation MTScanGuideViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNavgationItemSubviews];
    [self initBasicContrlsSetup];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - initialization

- (void)initNavgationItemSubviews
{
    UIBarButtonItem * backButtonItem = [[UIBarButtonItem alloc] init];
    backButtonItem.tintColor = [UIColor whiteColor];
    backButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = backButtonItem;
    
    self.navigationItem.title = MyLocal(@"启动扫描");
    
    
}

-(void)initBasicContrlsSetup
{
    [self.titleLabel setTextColor:[UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]];
    [self.descriptionLabel setTextColor:[UIColor colorWithRed:111/255.0 green:111/255.0 blue:111/255.0 alpha:1.0]];
    
    if ([[AppDelegateHelper readData:DidChooseTheCamera] isEqualToString:ForeamX1])
    {
        [self.bgImageView setHidden:NO];
        [self.bgX1ImageView setHidden:YES];
        [self.bgImageView setImage:[UIImage imageNamed:@"Live_guide_x1_scan"]];
        [self.titleLabel setText:@"长按REC按钮"];
        [self.descriptionLabel setText:MyLocal(@"Hold down the REC button until the front indicator light turns blue. When it does, hit next.")];
        
        
    }else if ([[AppDelegateHelper readData:DidChooseTheCamera] hasPrefix:Compass])
    {
        [self.bgImageView setHidden:YES];
        [self.bgX1ImageView setHidden:NO];
        [self.bgX1ImageView setImage:[UIImage imageNamed:@"Live_guide_compass_scan"]];
        [self.titleLabel setText:@"长按Wi-Fi按钮"];
        [self.descriptionLabel setText:MyLocal(@"Hold down the Wi-Fi button until the front indicator light turns blue. When it does, hit next.")];
    }
    else if ([[AppDelegateHelper readData:DidChooseTheCamera] hasPrefix:GhostX])
    {
        [self.bgImageView setHidden:YES];
        [self.bgX1ImageView setHidden:NO];
        [self.bgX1ImageView setImage:[UIImage imageNamed:@"Live_guide_ghost4k_scan"]];
        [self.titleLabel setText:@"长按中间键按钮"];
        [self.descriptionLabel setText:MyLocal(@"Please set camera to Video Mode(Green Light). Press and hold camera's Middle Button for two seconds. Release button when you hear 'Start scanning'. Then, click Next.")];

    }
    
    [self.nextButton setTitle:MyLocal(@"Next") forState:UIControlStateNormal];
    [self.nextButton setBackgroundColor:COLOR(40, 68, 131, 0.7)];
    
    self.nextButton.layer.shadowOffset = CGSizeMake(2,2);
    self.nextButton.layer.shadowOpacity = 0.3f;
    self.nextButton.layer.shadowRadius = 3.0;


    if (iPhone5 || isRetina)
    {
        [self.nextButton mas_updateConstraints:^(MASConstraintMaker *make)
         {
             make.bottom.equalTo(self.bottomView.mas_bottom).offset(-50);
         }];
    }
}

#pragma mark - IBAction

-(IBAction)nextButtonDidClick:(id)sender
{

    MTQRcodeScanViewController * qrcodeView = [[MTQRcodeScanViewController alloc]init];
    [qrcodeView setContentInfo:_contentinfo];
    [qrcodeView setSsidInfo:_ssidInfo];
    [qrcodeView setPasswordInfo:_passwordInfo];
    [self.navigationController pushViewController:qrcodeView animated:YES];
    
}


@end
