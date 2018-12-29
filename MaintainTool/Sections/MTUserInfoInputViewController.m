//
//  MTUserInfoInputViewController.m
//  MaintainTool
//
//  Created by Channing_rong on 2018/12/28.
//  Copyright © 2018 Channing_rong. All rights reserved.
//

#import "MTUserInfoInputViewController.h"
#import "MTScanQRcodeShotViewController.h"
#import "MTAvCaptureViewController.h"

#define ALPHANUM @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-"


@interface MTUserInfoInputViewController ()

@end

@implementation MTUserInfoInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initNavgationItemSubviews];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    if(!_bAddMode)
    {
        [_userIDTextField setPlaceholder:LastLoginUserId];
    }
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
    
    self.navigationItem.title = MyLocal(@"请输入用户ID");

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
    else
    {

        NSString *format = @"([A-Z0-9]+)-([A-Z0-9]+)-([A-Z0-9]+)";
        
        BOOL isValid = [self isValidateRegex: _userIDTextField.text Regex: format];
        if(!isValid)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"提示",nil)
                                                           message:NSLocalizedString(@"用户ID只能含有英文字母、数字和'-'，并且符合ID要求的格式",nil)
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                                 otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    [AppDelegateHelper saveData:_userIDTextField.text forKey:@"LastLoginUserId"];
    if(_bAddMode)
    {//跳转到扫描电梯二维码界面
        MTAvCaptureViewController *qrCodeSacnView = [[MTAvCaptureViewController alloc] init];
        [self.navigationController pushViewController:qrCodeSacnView animated:NO];
    }
    else
    {//返回上一级菜单
        [self.navigationController popViewControllerAnimated:YES];
    }
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

- (BOOL)isValidateRegex:(NSString *) string Regex:(NSString *)regex {
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pre evaluateWithObject:string];
}

@end
