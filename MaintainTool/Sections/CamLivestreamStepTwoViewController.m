//
//  CamLivestreamStepTwoViewController.m
//  Foream
//
//  Created by rongbaohong on 16/4/18.
//  Copyright © 2016年 Foream. All rights reserved.
//

#import "CamLivestreamStepTwoViewController.h"
#import "CamLivestreamQRcodeViewController.h"
#import "MTCameraOptionsViewController.h"
@interface CamLivestreamStepTwoViewController ()

@property (nonatomic,weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic,weak) IBOutlet UIButton *nextButton;
@property (nonatomic,weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UILabel *anotheCameraLabel;
@property (nonatomic,weak) IBOutlet UIImageView *bgX1ImageView;
@end

@implementation CamLivestreamStepTwoViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

    if(iPhone5 || isRetina)
    {
        self = [super initWithNibName:@"CamLivestreamStepTwoViewController_4.0" bundle:nibBundleOrNil];
        
    }else
    {
        
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        
        
    }
    if (self) {
        
        // Custom initialization
    }
    return self;
}

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
    self.navigationItem.backBarButtonItem = backButtonItem;
    
    self.navigationItem.title = MyLocal(@"启动扫描");
    
    
}

-(void)initBasicContrlsSetup
{
    if ([[AppDelegateHelper readData:DidChooseTheCamera] isEqualToString:ForeamX1]) {
        [self.bgImageView setHidden:YES];
        [self.bgX1ImageView setHidden:NO];
        [self.bgX1ImageView setImage:[UIImage imageNamed:@"Cam_live_X1"]];
        if ([AppDelegateHelper readBool:DidChooseNetdistType])
        {
        
            [self.titleLabel setText:MyLocal(@"SWITCH YOUR CAMERA TO SYNC FILES MODE")];
        }else
        {
        
            [self.titleLabel setText:MyLocal(@"SWITCH YOUR CAMERA TO LIVE STREAM MODE")];
        }
        [self.descriptionLabel setText:MyLocal(@"Hold down the REC button until the front indicator light turns blue. When it does, hit next.")];
        
        
    }else if ([[AppDelegateHelper readData:DidChooseTheCamera] hasPrefix:Compass])
    {
        [self.bgImageView setHidden:NO];
        [self.bgX1ImageView setHidden:YES];
        [self.bgImageView setImage:[UIImage imageNamed:@"Cam_live_light_status"]];
        if ([AppDelegateHelper readBool:DidChooseNetdistType])
        {
            
            [self.titleLabel setText:MyLocal(@"SWITCH YOUR CAMERA TO SYNC FILES MODE")];
        }else
        {
            
            [self.titleLabel setText:MyLocal(@"SWITCH YOUR CAMERA TO LIVE STREAM MODE")];
        }
        [self.descriptionLabel setText:MyLocal(@"Hold down the Wi-Fi button until the front indicator light turns blue. When it does, hit next.")];
    }
    else if ([[AppDelegateHelper readData:DidChooseTheCamera] hasPrefix:GhostX])
    {
        [self.bgImageView setHidden:YES];
        [self.bgX1ImageView setHidden:NO];
        [self.bgX1ImageView setImage:[UIImage imageNamed:@"Cam_Scan_GhostX"]];
        if ([AppDelegateHelper readBool:DidChooseNetdistType])
        {
            
            [self.titleLabel setText:MyLocal(@"SWITCH YOUR CAMERA TO SYNC FILES MODE")];
        }else
        {
            
            [self.titleLabel setText:MyLocal(@"SWITCH YOUR CAMERA TO LIVE STREAM MODE")];
        }
        [self.descriptionLabel setText:MyLocal(@"Please set camera to Video Mode(Green Light). Press and hold camera's Middle Button for two seconds. Release button when you hear 'Start scanning'. Then, click Next.")];

    }
    
    [self.nextButton setTitle:MyLocal(@"Next") forState:UIControlStateNormal];
    [self.nextButton setBackgroundColor:UIColorFromRGB(0xe4b475)];
    [self.descriptionLabel setFont:StandardFONT(16)];
    [self.descriptionLabel setTextColor:UIColorFromRGB(0x6f6f6f)];
    
    
    [self.titleLabel setFont:[UIFont fontWithName:@"HaginCapsMedium" size:29]];
    self.nextButton.layer.shadowOffset = CGSizeMake(2,2);
    self.nextButton.layer.shadowOpacity = 0.3f;
    self.nextButton.layer.shadowRadius = 3.0;
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:MyLocal(@"Exit")]];
    NSRange contentRange = {0,[content length]};
    [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
    _anotheCameraLabel.numberOfLines = 0;
    _anotheCameraLabel.textColor = UIColorFromRGB(0xe4b475);
    _anotheCameraLabel.attributedText = content;
    
    if (self.tryQRcode) {
        [self.titleLabel setText:MyLocal(@"SWITCH YOUR CAMERA TO SCAN QR CODE MODE")];
    }
    
}

#pragma mark - IBAction
-(IBAction)returnButtonDidClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(IBAction)closeButtonDidClick:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction)nextButtonDidClick:(id)sender
{

    if (_tryQRcode) {
        
        CamLivestreamQRcodeViewController * qrcodeView = [[CamLivestreamQRcodeViewController alloc]init];
        [qrcodeView setContentInfo:_contentinfo];
        [qrcodeView setSsidInfo:_ssidInfo];
        [qrcodeView setPasswordInfo:_passwordInfo];
        [self.navigationController pushViewController:qrcodeView animated:YES];
        
    }
    else if (_isGhostX)
    {
        CamLivestreamQRcodeViewController * qrcodeView = [[CamLivestreamQRcodeViewController alloc]init];
        [qrcodeView setContentInfo:_contentinfo];
        [qrcodeView setSsidInfo:_ssidInfo];
        [qrcodeView setPasswordInfo:_passwordInfo];
        [qrcodeView setStreamCreatTime:_streamCreatTime];
        [self.navigationController pushViewController:qrcodeView animated:YES];
    }
    else
    {
//        CamLivestreamStepThreeViewController *scanQRcodeView = [[CamLivestreamStepThreeViewController alloc]init];
//        [scanQRcodeView setConnectType:ConnectingTypeSmartconfig];
//        [scanQRcodeView setContentInfo:_contentinfo];
//        [scanQRcodeView setSsidInfo:_ssidInfo];
//        [scanQRcodeView setPasswordInfo:_passwordInfo];
//        [self.navigationController pushViewController:scanQRcodeView animated:YES];
    
    }
    
}

-(IBAction)chosseAnotherCameraModal:(id)sender
{
    MTCameraOptionsViewController *chooseCameraView = [[MTCameraOptionsViewController alloc]init];
    [self.navigationController pushViewController:chooseCameraView animated:YES];
}


#pragma mark - Screen rotation
- (BOOL)shouldAutorotate
{       //IOS6
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
@end
