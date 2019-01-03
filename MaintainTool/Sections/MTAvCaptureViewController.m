//
//  MTAvCaptureViewController.m
//  MaintainTool
//
//  Created by Channing_rong on 2018/12/29.
//  Copyright © 2018 Channing_rong. All rights reserved.
//

#import "MTAvCaptureViewController.h"
#import "MTUserInfoInputViewController.h"
#import "MTScanQRcodeShotViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MTManualInputViewController.h"

/**
 *  屏幕 高 宽 边界
 */
//#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
//#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_BOUNDS  [UIScreen mainScreen].bounds

#define TOP (SCREEN_HEIGHT-220)/2
#define LEFT (SCREEN_WIDTH-220)/2

#define kScanRect CGRectMake(LEFT, TOP, 220, 220)

#define INPUT_BUTTON_Y TOP+220+20
#define INPUT_BUTTON_X LEFT

#define kInputButtonRect CGRectMake(INPUT_BUTTON_X, INPUT_BUTTON_Y, 220, 40)

@interface MTAvCaptureViewController ()<AVCaptureMetadataOutputObjectsDelegate>{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
    CAShapeLayer *cropLayer;
    NSString *qrCodeString;
    BOOL bFirstInit;
}
@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;

@property (nonatomic, strong) UIImageView * line;
@property (nonatomic, strong) UIButton * inputButton;

@end

@implementation MTAvCaptureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    bFirstInit = YES;
    [self initNavgationItemSubviews];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self configView];
}

-(void)configView{
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:kScanRect];
    imageView.image = [UIImage imageNamed:@"pick_bg"];
    [self.view addSubview:imageView];
    
    upOrdown = NO;
    num =0;
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT, TOP+10, 220, 2)];
    _line.image = [UIImage imageNamed:@"line.png"];
    [self.view addSubview:_line];
    
    [self setCropRect:kScanRect];
    
    _inputButton = [[UIButton alloc]initWithFrame:kInputButtonRect];
    [_inputButton setBackgroundColor:UIColorFromRGB(0x26aad1)];
    [_inputButton setTitle:@"手动输入" forState:UIControlStateNormal];
    [_inputButton addTarget:self action:@selector(enterManualInputView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_inputButton];
    
    //    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    //    [self setCropRect:kScanRect];
    
    NSString *mediaType = AVMediaTypeVideo;
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        
        UIAlertView *alert =[[UIAlertView alloc]initWithTitle:MyLocal(@"温馨提示") message:MyLocal(@"请在iPhone的\"设置\"-\"隐私\"-\"相机\"功能中，找到\"维修印记\"打开相机访问权限") delegate:nil cancelButtonTitle:MyLocal(@"确定") otherButtonTitles: nil];
        
        [alert show];
        
        return;
    }
    
    [self performSelector:@selector(setupCamera) withObject:nil afterDelay:0.3];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [timer invalidate];
}

- (void)initNavgationItemSubviews
{
    
    UIBarButtonItem *menuNavItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"common_return_arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBackButtonPress)];
    
    [self.navigationItem setLeftBarButtonItem:menuNavItem];
    
    self.navigationItem.title = MyLocal(@"扫描设备二维码");

}

-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(LEFT, TOP+10+2*num, 220, 2);
        if (2*num == 200) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(LEFT, TOP+10+2*num, 220, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
    
}

-(void)leftBackButtonPress
{
    [self.navigationController popViewControllerAnimated:NO];
}


- (void)setCropRect:(CGRect)cropRect{
    cropLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, cropRect);
    CGPathAddRect(path, nil, self.view.bounds);
    
    [cropLayer setFillRule:kCAFillRuleEvenOdd];
    [cropLayer setPath:path];
    [cropLayer setFillColor:[UIColor blackColor].CGColor];
    [cropLayer setOpacity:0.6];
    
    
    [cropLayer setNeedsDisplay];
    
    [self.view.layer addSublayer:cropLayer];
}

- (void)setupCamera
{
    if(bFirstInit)
    {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (device==nil) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"设备没有摄像头" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        // Device
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        // Input
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
        
        // Output
        _output = [[AVCaptureMetadataOutput alloc]init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        //设置扫描区域
        CGFloat top = TOP/SCREEN_HEIGHT;
        CGFloat left = LEFT/SCREEN_WIDTH;
        CGFloat width = 220/SCREEN_WIDTH;
        CGFloat height = 220/SCREEN_HEIGHT;
        ///top 与 left 互换  width 与 height 互换
        [_output setRectOfInterest:CGRectMake(top,left, height, width)];
        
        
        // Session
        _session = [[AVCaptureSession alloc]init];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        if ([_session canAddInput:self.input])
        {
            [_session addInput:self.input];
        }
        
        if ([_session canAddOutput:self.output])
        {
            [_session addOutput:self.output];
        }
        
        // 条码类型 AVMetadataObjectTypeQRCode
        [_output setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode, nil]];
        
        // Preview
        _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
        _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _preview.frame =self.view.layer.bounds;
        [self.view.layer insertSublayer:_preview atIndex:0];
        
        bFirstInit = NO;
    }
    
    // Start
    [_session startRunning];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        //停止扫描
        [_session stopRunning];
        [timer setFireDate:[NSDate distantFuture]];
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        NSLog(@"扫描结果：%@",stringValue);
        
        NSArray *arry = metadataObject.corners;
        for (id temp in arry) {
            NSLog(@"%@",temp);
        }
        
        
        //        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"扫描结果" message:stringValue preferredStyle:UIAlertControllerStyleAlert];
        //        [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //            if (_session != nil && timer != nil) {
        //                [_session startRunning];
        //                [timer setFireDate:[NSDate date]];
        //            }
        //
        //        }]];
        //        [self presentViewController:alert animated:YES completion:nil];
        //需要对数据进行加工
        //1 先取出数据
        NSArray *array =[stringValue componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"?=&"]];
        
        //2 判断下二维码的内容
        if([array count]<3)
            return;
        NSString *searialNum = [array objectAtIndex:2];
        NSLog(@"searialNum is %@", searialNum);
        
        //3 封装数据
        //        qrCodeString = [@"4|" stringByAppendingString:searialNum];
        
        MTScanQRcodeShotViewController * qrcodeView = [[MTScanQRcodeShotViewController alloc]init];
        [qrcodeView setBOnlyForScan:YES];
        [qrcodeView setSsidInfo:searialNum];
        //        [qrcodeView setContentInfo:qrCodeString];
        [self.navigationController pushViewController:qrcodeView animated:YES];
    } else {
        NSLog(@"无扫描信息");
        return;
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)enterManualInputView:(UIButton *)button
{
    MTManualInputViewController *manualInputView = [[MTManualInputViewController alloc]init];
    [self.navigationController pushViewController:manualInputView animated:YES];
}
@end
