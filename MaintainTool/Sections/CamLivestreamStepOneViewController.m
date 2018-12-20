//
//  CamLivestreamStepOneViewController.m
//  Foream
//
//  Created by rongbaohong on 16/4/18.
//  Copyright © 2016年 Foream. All rights reserved.
//

#import "CamLivestreamStepOneViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "CamLivestreamStepTwoViewController.h"
#import "AFNetworkReachabilityManager.h"
#import "KxMenu.h"

@interface CamLivestreamStepOneViewController ()
{
    CGFloat parentViewHeight;
    CGFloat parentViewWidth;
    __block NSInteger networkStatus;
}

@property (nonatomic,strong) NSMutableArray * ssidlistArray;
@property (nonatomic,weak) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (nonatomic,weak) IBOutlet UITextField *passwordTextfield;
@property (nonatomic,weak) IBOutlet UITextField *ssidTextfield;
@property (nonatomic,weak) IBOutlet UIButton *nextButton;
@property (nonatomic,weak) IBOutlet UIButton *changewifiButton;
@property (nonatomic,weak) IBOutlet UIButton *dropButton;

@property (nonatomic,weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextButtonBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionLabelLeftX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionLabelRightX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTopY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionLabelTopY;

@end

@implementation CamLivestreamStepOneViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    parentViewHeight = [[UIScreen mainScreen] bounds].size.height;
    parentViewWidth = [[UIScreen mainScreen] bounds].size.width;
    [self.view setFrame:CGRectMake(0, 0, parentViewWidth, parentViewHeight)];
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    //检测的结果
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         self->networkStatus = status;
         [self detectCurrentConnectedSSid];
     }];
    
    [manager startMonitoring];

    [self initNavgationItemSubviews];
    
    [self initBasicContrlsSetup];
    [_ssidTextfield setUserInteractionEnabled:YES];
    [_ssidTextfield setClearButtonMode:UITextFieldViewModeAlways];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    
    [_ssidTextfield resignFirstResponder];
    [_passwordTextfield resignFirstResponder];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)updateViewConstraints
{
    if(parentViewHeight==480)
    {
        _topViewHeight.constant =220;
        _inputViewMargin.constant = 50;
        _titleLabelTopY.constant = 2;
        _descriptionLabelTopY.constant = 1;
        _descriptionLabelLeftX.constant = 10;
        _descriptionLabelRightX.constant = 10;
        _nextButtonBottomMargin.constant = 50;
    }
    else if(parentViewHeight==568)
    {
        _inputViewMargin.constant = 70;
        _nextButtonBottomMargin.constant = 50;
        _topViewHeight.constant =220;
        _titleLabelTopY.constant = 20;
        _descriptionLabelTopY.constant = 20;
          _descriptionLabelLeftX.constant = 10;
        _descriptionLabelRightX.constant = 10;
    }
    
    [super updateViewConstraints];
}


#pragma mark - initialization
- (void)initNavgationItemSubviews
{
    UIBarButtonItem * backButtonItem = [[UIBarButtonItem alloc] init];
    backButtonItem.tintColor = [UIColor whiteColor];
    backButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = backButtonItem;
    
    self.navigationItem.title = MyLocal(@"输入WiFi密码");
    
    
}

-(void)detectCurrentConnectedSSid
{
    NSString* userPhoneName = [[UIDevice currentDevice] name];
    NSLog(@"手机别名: %@", userPhoneName);
 
    NSDictionary *tempDic =[NSDictionary dictionaryWithContentsOfFile:[AppDelegateHelper getWifiArrayPlistDocumentPathWithUid:[AppDelegateHelper readData:SavedOpenID]]];
    
    if (tempDic)
    {
        NSMutableArray *newWifiArray = [NSMutableArray array];
        NSMutableArray *wifiArray = [tempDic objectForKey:@"WifiLists"];
        if(wifiArray.count<=0)
        {
            [_ssidTextfield setText:[AppDelegateHelper fetchSSIDName]];
            _ssidlistArray = [NSMutableArray arrayWithContentsOfFile:[AppDelegateHelper getSSIDArrayPlistDocumentPath]];
            return;
        }
        [wifiArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
        {
            DLog(@"networkStatus is %ld and [AppDelegateHelper fetchSSIDName] is %@, obj.ssid is %@",(long)self->networkStatus,[AppDelegateHelper fetchSSIDName],[obj objectForKey:@"ssid"]);
            if ([[AppDelegateHelper fetchSSIDName] isEqualToString:[obj objectForKey:@"ssid"]])
            {
                
                [self->_ssidTextfield setText:[AppDelegateHelper fetchSSIDName]];
                [self->_passwordTextfield setText:[obj objectForKey:@"password"]];
                
            }
            else if([AppDelegateHelper flagWithOpenHotSpot] && [userPhoneName isEqualToString:[obj objectForKey:@"ssid"]])
            {
                [self->_ssidTextfield setText:userPhoneName];
                [self->_passwordTextfield setText:[obj objectForKey:@"password"]];
           
            }
            else if(self->networkStatus == AFNetworkReachabilityStatusReachableViaWWAN && [userPhoneName isEqualToString:[obj objectForKey:@"ssid"]])
            {
                [self->_ssidTextfield setText:userPhoneName];
                [self->_passwordTextfield setText:[obj objectForKey:@"password"]];
            }
            else if(self->networkStatus == AFNetworkReachabilityStatusReachableViaWiFi && [[AppDelegateHelper fetchSSIDName] isEqualToString:[obj objectForKey:@"ssid"]])
            {
                [self->_ssidTextfield setText:[AppDelegateHelper fetchSSIDName]];
                [self->_passwordTextfield setText:[obj objectForKey:@"password"]];
            }
      
            if (isStringNotNil([obj objectForKey:@"password"]))
            {
                [newWifiArray addObject:obj];
            }
        }];
        _ssidlistArray = [NSMutableArray arrayWithArray:newWifiArray];
        DLog(@"loacl wifi list is %@  all Wi-Fi List is %@",wifiArray,_ssidlistArray);
    }else
    {
        
        [_ssidTextfield setText:[AppDelegateHelper fetchSSIDName]];
    }
    
    if (_ssidlistArray.count == 0)
    {
        [_dropButton setHidden:YES];
    }
    else
    {
        
        [_dropButton setHidden:NO];
    }
    
    
    if(networkStatus == AFNetworkReachabilityStatusReachableViaWWAN && !isStringNotNil(_passwordTextfield.text))
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:MyLocal(@"Prompt") message:MyLocal(@"You haven't connected to any Wi-Fi, would you like to use your mobile phone's hotspot for live stream? if so, please input the name and password of your phone's hotspot.") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAct = [UIAlertAction actionWithTitle:MyLocal(@"NO") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
                                    {
                                        [self.navigationController popToRootViewControllerAnimated:YES];
                                    }];
        
        [alert addAction:cancelAct];
        
        UIAlertAction *confirmAct = [UIAlertAction actionWithTitle:MyLocal(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                     {
                                         [self->_ssidTextfield setText:userPhoneName];
                                         [self->_passwordTextfield becomeFirstResponder];
                                     }];
        
        [alert addAction:confirmAct];
        
        [self presentViewController:alert animated:YES completion:^{}];

    }
    else if (_ssidTextfield.text.length < 3 && networkStatus == AFNetworkReachabilityStatusReachableViaWiFi)
    {
        [_ssidTextfield setText:[AppDelegateHelper fetchSSIDName]];
    }
  
    
   
}

-(void)initBasicContrlsSetup
{
    
    [self.titleLabel setTextColor:[UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]];
    [self.titleLabel setText:@"输入Wi-Fi密码"];
    
    [self.descriptionLabel setTextColor:[UIColor colorWithRed:111/255.0 green:111/255.0 blue:111/255.0 alpha:1.0]];
    [self.descriptionLabel setText:MyLocal(@"In order to live stream, your Camera needs an internet connection. Enter your WiFi password, which will then be shared with your Camera.")];
    
    [self.nextButton setTitle:MyLocal(@"Next") forState:UIControlStateNormal];
    [self.nextButton setBackgroundColor:[UIColor colorWithRed:40/255.0 green:68/255.0 blue:131/255.0 alpha:1.0]];

    self.nextButton.layer.shadowOffset = CGSizeMake(2,2);
    self.nextButton.layer.shadowOpacity = 0.3f;
    self.nextButton.layer.shadowRadius = 3.0;
    
    _passwordTextfield.placeholder =  MyLocal(@"Please input the password",nil);
    [_passwordTextfield setValue:UIColorFromRGB(0x808080) forKeyPath:@"_placeholderLabel.textColor"];
    [_passwordTextfield setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_passwordTextfield setSpellCheckingType:UITextSpellCheckingTypeNo];
    [_passwordTextfield setSecureTextEntry:NO];
    
    _ssidTextfield.clearButtonMode = UITextFieldViewModeNever;  //全部删除按钮
    _passwordTextfield.clearButtonMode = UITextFieldViewModeAlways;
    
    [_changewifiButton setTitle:MyLocal(@"Change Wi-Fi Network") forState:UIControlStateNormal];
    [_changewifiButton setTitleColor:UIColorFromRGB(0x808080) forState:UIControlStateNormal];

    [_dropButton addTarget:self action:@selector(showPopover:forEvent:) forControlEvents:UIControlEventTouchUpInside];

}



#pragma mark - IBAction

-(IBAction)returnButtonDidClick:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction)closeButtonDidClick:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction)nextButtonDidClick:(id)sender
{
    if (_ssidTextfield.text.length<=0) {
    
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:MyLocal(@"Prompt") message:MyLocal(@"SSIDNull") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAct = [UIAlertAction actionWithTitle:MyLocal(@"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        }];
        
        [alert addAction:cancelAct];
        
        [self presentViewController:alert animated:YES completion:^{}];
        return;
        
    }

    else if([self containsChinese:_ssidTextfield.text])
    {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:MyLocal(@"Prompt") message:MyLocal(@"SSID can't contain Chinese") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAct = [UIAlertAction actionWithTitle:MyLocal(@"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        }];
        
        [alert addAction:cancelAct];
        
        [self presentViewController:alert animated:YES completion:^{}];
 
        return;
        
    }else
    {
        
        //Some problems here, so cancel it temperory.
        [self saveThePasswordIntoSandbox];
        if(self.passwordTextfield.text.length==0)
            self.passwordTextfield.text = @"";
     
        DLog(@"LastLoginUserId is %@",[AppDelegateHelper readData:@"LastLoginUserId"]);
        if (isStringNotNil([AppDelegateHelper readData:@"LastLoginUserId"]))
        {
            CamLivestreamStepTwoViewController *scanQRcodeView = [[CamLivestreamStepTwoViewController alloc]init];
            [scanQRcodeView setTryQRcode:YES];
            NSString *contentinfo = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%@",@"1",LastLoginUserId,_ssidTextfield.text,self.passwordTextfield.text,ServerAddress,@"443",[AppDelegateHelper getIPAddress:@"en0"]];
            [scanQRcodeView setContentinfo:contentinfo];
            [scanQRcodeView setSsidInfo:_ssidTextfield.text];
            [scanQRcodeView setPasswordInfo:_passwordTextfield.text];
            [self.navigationController pushViewController:scanQRcodeView animated:YES];
            
        }
        else
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入用户昵称" preferredStyle:UIAlertControllerStyleAlert];
            //以下方法就可以实现在提示框中输入文本；
            
            //在AlertView中添加一个输入框
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                
                textField.placeholder = @"请输入用户昵称";
            }];
            
            //添加一个确定按钮 并获取AlertView中的第一个输入框 将其文本赋值给BUTTON的title
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UITextField *envirnmentNameTextField = alertController.textFields.firstObject;
                [AppDelegateHelper saveData:envirnmentNameTextField.text forKey:@"LastLoginUserId"];
                //输出 检查是否正确无误
                NSLog(@"你输入的文本%@",envirnmentNameTextField.text);
                
                CamLivestreamStepTwoViewController *scanQRcodeView = [[CamLivestreamStepTwoViewController alloc]init];
                [scanQRcodeView setTryQRcode:YES];
                NSString *contentinfo = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%@",@"1",LastLoginUserId,self->_ssidTextfield.text,self.passwordTextfield.text,ServerAddress,@"443",[AppDelegateHelper getIPAddress:@"en0"]];
                [scanQRcodeView setContentinfo:contentinfo];
                [scanQRcodeView setSsidInfo:self->_ssidTextfield.text];
                [scanQRcodeView setPasswordInfo:self->_passwordTextfield.text];
                [self.navigationController pushViewController:scanQRcodeView animated:YES];
                
            }]];
            
            //添加一个取消按钮
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
            
            //present出AlertView
            [self presentViewController:alertController animated:true completion:nil];
        }
    }
}

-(IBAction)changeToAnotherWifi:(id)sender
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:MyLocal(@"Prompt") message:MyLocal(@"Please go to your mobile phone's Settings Menu to change your Wi-Fi network") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAct = [UIAlertAction actionWithTitle:MyLocal(@"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
    }];
    
    [alert addAction:cancelAct];
    
    [self presentViewController:alert animated:YES completion:^{}];

}

-(IBAction)usingMobileDataToLivestream:(id)sender
{
    
//    CamConnectStepOneViewController *cameraModalView = [[CamConnectStepOneViewController alloc]init];
//    [cameraModalView setTypeIndex:_modelType];
//    cameraModalView.connectType = kMobileDateLiveType;
//    [self.navigationController pushViewController:cameraModalView animated:YES];
}

-(void)showPopover:(UIButton *)sender forEvent:(UIEvent*)event
{
    NSMutableArray *menuItems = [[NSMutableArray alloc]init];
    
    [_ssidlistArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([obj isKindOfClass:[NSString class]]) {
            
            [menuItems addObject:[KxMenuItem menuItem:[NSString stringWithFormat:@"%@",obj]
                                                image:nil
                                               target:self
                                        selectedIndex:idx
                                               action:@selector(pushMenuItem:)]];
        }else{
            [menuItems addObject:[KxMenuItem menuItem:[NSString stringWithFormat:@"%@",[obj objectForKey:@"ssid"]]
                                                image:nil
                                               target:self
                                        selectedIndex:idx
                                               action:@selector(pushMenuItem:)]];
            
        }
        
    }];
    
    [_ssidTextfield resignFirstResponder];
    [_passwordTextfield resignFirstResponder];
    
    CGFloat xMargin = self.inputView.frame.origin.x;
    CGFloat yMargin = self.inputView.frame.origin.y;
    CGFloat topMargin;
    if (iPhone5 || isRetina)
    {
        topMargin = 44;
    }
    else if (IS_iPhoneX_Series)
    {
        topMargin = 88;
    }
    else
    {
        topMargin = 64;
    }
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(xMargin+sender.frame.origin.x, yMargin+sender.frame.origin.y+topMargin, sender.frame.size.width, sender.frame.size.height)
                 menuItems:menuItems];
}

- (void) pushMenuItem:(KxMenuItem *)sender
{
    DLog(@"sender is %@",sender);
    if ([[_ssidlistArray objectAtIndex:sender.selectedIndex] isKindOfClass:[NSString class]]) {
        
        _ssidTextfield.text = [_ssidlistArray objectAtIndex:sender.selectedIndex];
        _passwordTextfield.text = @"";
    }else{
        
        NSMutableDictionary *dic = [_ssidlistArray objectAtIndex:sender.selectedIndex];
        _ssidTextfield.text =[dic objectForKey:@"ssid"];
        _passwordTextfield.text =[dic objectForKey:@"password"];
    }
}

#pragma mark - Private
-(void)updateConnectedSSID
{
    [self detectCurrentConnectedSSid];
    
}

- (BOOL) containsChinese:(NSString *)str {
    for(int i = 0; i < [str length]; i++) {
        int a = [str characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff)
            return TRUE;
    }
    return FALSE;
}

-(void)saveThePasswordIntoSandbox
{
    
    if (_ssidlistArray)
    {

        [_ssidlistArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *dictionary = obj;
            NSString *ssid =[dictionary objectForKey:@"ssid"];
            if ([ssid isEqualToString:self->_ssidTextfield.text] && [self->_ssidlistArray containsObject:obj])
            {
                [self->_ssidlistArray removeObject:obj];
                *stop = YES;
            }
            
        }];
       
        
        
    }
    else
    {
        _ssidlistArray = [NSMutableArray array];
    }

    [_ssidlistArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:_ssidTextfield.text,@"ssid",_passwordTextfield.text,@"password", nil]];
    NSInteger timeStamp = [[[NSDate alloc] init] timeIntervalSince1970];
    NSInteger mistiming = [AppDelegateHelper readData:@"Mistiming"].integerValue;
    NSMutableDictionary *settingDic =[[NSMutableDictionary alloc]init];
    [_ssidlistArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *dictionary = obj;
        NSString *ssid =[dictionary objectForKey:@"ssid"];
        NSString *password =[dictionary objectForKey:@"password"];
        NSString *encodedssid = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes( NULL, (__bridge CFStringRef)ssid, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8 );
        [encodedssid stringByReplacingOccurrencesOfString:@"%20" withString:@"+"];
        
        NSString *encodedPassword = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes( NULL, (__bridge CFStringRef)password, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8 );
        [encodedPassword stringByReplacingOccurrencesOfString:@"%20" withString:@"+"];
        if(!encodedPassword && !encodedssid)
            [settingDic setObject:encodedPassword forKey:encodedssid];
        
    }];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:settingDic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (error)
    {
        DLog(@"dic->%@",error);
    }
    
    NSString *jsonString = [NSString stringWithUTF8String:[jsonData bytes]];
    if (!isStringNotNil(jsonString)) {
        return;
    }
    DLog(@"json string is %@ /r  %@",jsonString,@"");
//    if (isStringNotNil([FOMAPPDELEGATE loginUser].sid))
//    {
//        UserSetWifiListApi *setWifiListApi = [[UserSetWifiListApi alloc] initWithSessionId:[FOMAPPDELEGATE loginUser].sid token:[FOMAPPDELEGATE loginUser].token lastTime:[NSString stringWithFormat:@"%ld",timeStamp+mistiming] ssid_password:[_ssidlistArray JSONString] camera_ids:nil];
//        [setWifiListApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
//
//            NSDictionary *wifilistResponse = [request.responseString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
//            DLog(@"responseStr is %@",request.responseString);
//            if([[NSNumber numberWithInt:1]isEqual:[wifilistResponse objectForKey:@"status"]])
//            {
//
                NSDictionary *dic =[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",timeStamp+mistiming],@"Last_modify",_ssidlistArray,@"WifiLists",[AppDelegateHelper readData:SavedOpenID],@"uid",nil];

                NSFileManager *fm = [NSFileManager defaultManager];
                if(![fm fileExistsAtPath:[AppDelegateHelper getWifiArrayPlistDocumentPathWithUid:[NSString stringWithFormat:@"%@",[AppDelegateHelper readData:SavedOpenID]]]]){
                    [fm createFileAtPath:[AppDelegateHelper getWifiArrayPlistDocumentPathWithUid:[NSString stringWithFormat:@"%@",[AppDelegateHelper readData:SavedOpenID]]] contents:nil attributes:nil];
                    [dic writeToFile:[AppDelegateHelper getWifiArrayPlistDocumentPathWithUid:[NSString stringWithFormat:@"%@",[AppDelegateHelper readData:SavedOpenID]]] atomically:YES];
                    DLog(@"wifilists is %@",dic);
                }else{
                    DLog(@"wifilists is %@",dic);
                    [dic writeToFile:[AppDelegateHelper getWifiArrayPlistDocumentPathWithUid:[NSString stringWithFormat:@"%@",[AppDelegateHelper readData:SavedOpenID]]] atomically:YES];
                }
//            }
//            [AppDelegateHelper removLoadingMessage:self.view];
//        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
//            [AppDelegateHelper removLoadingMessage:self.view];
//        }];
//    }
    
    
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



#pragma mark - FOMBTScanViewControllerDelegate
- (void)parentViewPopBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_ssidTextfield resignFirstResponder];
    [_passwordTextfield resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
@end
