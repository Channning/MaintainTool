//
//  MTScanQRcodeShotViewController.m
//  MaintainTool
//
//  Created by Channing_rong on 2018/12/28.
//  Copyright © 2018 Channing_rong. All rights reserved.
//

#import "MTScanQRcodeShotViewController.h"
#import "MTUserInfoInputViewController.h"
#import "QRCodeGenerator.h"

@interface MTScanQRcodeShotViewController ()
{
    NSTimer *checkCameraRegisterTimer;
    long tag;
    BOOL didReceiveData;
    BOOL didPushViewController;
    BOOL didDeleteMessage;
    NSString *messageId;
    NSTimer *refreshTimer;
    
}

@property (nonatomic,weak) IBOutlet UIImageView *QRcodeImageView;
@property (nonatomic,weak) IBOutlet UIButton *backButton;
@property (nonatomic,weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic,weak) IBOutlet UILabel *description2Label;
@property (nonatomic,weak) IBOutlet UILabel *userIDLabel;


@end

@implementation MTScanQRcodeShotViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tabBarController.tabBar setHidden:YES];
    [self initBasicContrlsSetup];

    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [AppDelegateHelper saveBool:YES forKey:@"DontPanSlide"];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    NSString *userID = [AppDelegateHelper readData:@"LastLoginUserId"];
    [_userIDLabel setText:[NSString stringWithFormat:@"用户ID: %@", userID]];
    
    //    NSInteger timeStamp = [[[NSDate alloc] init] timeIntervalSince1970];
    NSDate *date=[NSDate date];
    NSDateFormatter *format1=[[NSDateFormatter alloc] init];
    format1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    //2017/11/27 14:46
    [format1 setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *dateStr;
    dateStr=[format1 stringFromDate:date];
    
    _contentInfo = [NSString stringWithFormat:@"4|%@|%@|%@", _ssidInfo, userID, dateStr];
    self.QRcodeImageView.image = [QRCodeGenerator qrImageForString:_contentInfo imageSize:_QRcodeImageView.bounds.size.width];
    
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:20.0f
                                                    target:self
                                                  selector:@selector(refreshQRCode)
                                                  userInfo:nil
                                                   repeats:YES];
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    [refreshTimer invalidate];
    refreshTimer = nil;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

-(IBAction)backButtonDidClick:(id)sender
{
    //    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction)editButtonDidClick:(id)sender
{
    MTUserInfoInputViewController *workerInfoInputView = [[MTUserInfoInputViewController alloc] init];
    [workerInfoInputView setBAddMode:NO];
    [self.navigationController pushViewController:workerInfoInputView animated:YES];
}


#pragma mark - initialization


-(void)initBasicContrlsSetup
{
    if(!self.bOnlyForScan)
    {
       
        [self.descriptionLabel setFont:StandardFONT(17)];
        [self.descriptionLabel setTextColor:UIColorFromRGB(0x6f6f6f)];
        [self.descriptionLabel setText:MyLocal(@"Point your Camera at the code below, the Wi-Fi led light will change to red. Once it has, hit next.")];
    
        
    }
    else
    {
   
        [self.descriptionLabel setFont:StandardFONT(15)];
        [self.descriptionLabel setTextColor:UIColorFromRGB(0x6f6f6f)];

        [self.descriptionLabel setText:[NSString stringWithFormat:@"设备编号: %@", _ssidInfo]];
        
        [self.userIDLabel setFont:StandardFONT(15)];
        [self.userIDLabel setTextColor:UIColorFromRGB(0x6f6f6f)];
   
        [self.description2Label setHidden:NO];
        [self.description2Label setFont:StandardFONT(16)];
        [self.description2Label setTextColor:UIColorFromRGB(0x6f6f6f)];
        
        [self.backButton setHidden:NO];
        [self.backButton setBackgroundColor:UIColorFromRGB(0x26aad1)];
        self.backButton.layer.shadowOffset = CGSizeMake(2,2);
        self.backButton.layer.shadowOpacity = 0.3f;
        self.backButton.layer.shadowRadius = 3.0;
        [self.backButton setTitle:MyLocal(@"返回") forState:UIControlStateNormal];
        
    }
    
    
}
#pragma mark - refresh the QR code.
-(void)refreshQRCode
{
    NSString *userID = [AppDelegateHelper readData:@"LastLoginUserId"];
    [_userIDLabel setText:[NSString stringWithFormat:@"用户ID: %@", userID]];
    
    NSDate *date=[NSDate date];
    NSDateFormatter *format1=[[NSDateFormatter alloc] init];
    format1.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    //2017/11/27 14:46
    [format1 setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *dateStr;
    dateStr=[format1 stringFromDate:date];
    
    _contentInfo = [NSString stringWithFormat:@"4|%@|%@|%@", _ssidInfo, userID, dateStr];
    self.QRcodeImageView.image = [QRCodeGenerator qrImageForString:_contentInfo imageSize:_QRcodeImageView.bounds.size.width];
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
