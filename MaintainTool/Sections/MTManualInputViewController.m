//
//  MTManualInputViewController.m
//  MaintainTool
//
//  Created by Channing_rong on 2018/12/29.
//  Copyright © 2018 Channing_rong. All rights reserved.
//

#import "MTManualInputViewController.h"
#import "MTScanQRcodeShotViewController.h"

@interface MTManualInputViewController ()

@end

@implementation MTManualInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initNavgationItemSubviews];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [_userIDTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNavgationItemSubviews
{
    
    UIBarButtonItem *menuNavItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"common_return_arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBackButtonPress)];
    
    [self.navigationItem setLeftBarButtonItem:menuNavItem];

    self.navigationItem.title = MyLocal(@"请输入电梯信息");
    
}

-(void)leftBackButtonPress
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveAction:(id)sender
{
    if(_userIDTextField.text.length==0)
    {
        return;
    }

    NSString *searialNum = _userIDTextField.text;
    MTScanQRcodeShotViewController * qrcodeView = [[MTScanQRcodeShotViewController alloc]init];
    [qrcodeView setBOnlyForScan:YES];
    [qrcodeView setSsidInfo:searialNum];
    //    [qrcodeView setContentInfo:qrCodeString];
    [self.navigationController pushViewController:qrcodeView animated:YES];
    
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string

{
    
    if (string.length==0)
    {
        return YES;
    }
    
    char commitChar = [string characterAtIndex:0];
    
    if (commitChar > 96 && commitChar < 123)
        
    {
        
        //小写变成大写
        
        NSString * uppercaseString = string.uppercaseString;
        
        NSString * str1 = [textField.text substringToIndex:range.location];
        
        NSString * str2 = [textField.text substringFromIndex:range.location];
        
        textField.text = [NSString stringWithFormat:@"%@%@%@",str1,uppercaseString,str2];
        
        return NO;
        
    }
    
    return YES;
    
}

@end
