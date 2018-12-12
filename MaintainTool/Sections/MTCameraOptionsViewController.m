//
//  MTCameraOptionsViewController.m
//  MaintainTool
//
//  Created by Channing_rong on 2018/12/11.
//  Copyright © 2018 Channing_rong. All rights reserved.
//

#import "MTCameraOptionsViewController.h"
#import "CamLivestreamStepOneViewController.h"
#import "MTCameraOptionCell.h"

@interface MTCameraOptionsViewController ()
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@end

@implementation MTCameraOptionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNavgationItemSubviews];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    
    self.navigationController.navigationBarHidden = NO;
    [super viewWillAppear:animated];
}


#pragma mark -Init Metheds

- (void)initNavgationItemSubviews
{
    UIBarButtonItem * backButtonItem = [[UIBarButtonItem alloc] init];
    backButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = backButtonItem;

    self.navigationItem.title = MyLocal(@"Choose Camera");
    
    
}

-(void)backToLastView
{

   [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return (self.view.frame.size.height-SafeAreaTopHeight-40)/4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MTCameraOptionCell";
    MTCameraOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MTCameraOptionCell" owner:self options:nil] objectAtIndex:0];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *modelImageName = nil;
    NSString *modelNameString = nil;
    switch (indexPath.section)
    {
        case 3:
            modelImageName = @"Connect_ghost4k";
            modelNameString = @"Connect_model_Ghost4K";
            break;
        case 1:
            modelImageName = @"Connect_X1";
            modelNameString = @"Connect_model_x1";
            break;
        case 2:
            modelImageName = @"Connect_compass";
            modelNameString = @"Connect_model_compass";
            break;
        case 0:
            modelImageName = @"Connect_ghostX";
            modelNameString = @"Connect_model_GhostX";
            break;
        default:
            modelImageName = @"Connect_ghostX";
            modelNameString = @"Connect_model_GhostX";
            break;
    }
    
    cell.modelImage.image = [UIImage  imageNamed:modelImageName];
    cell.modelNameView.image = [UIImage imageNamed:modelNameString];
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
    switch (indexPath.section)
    {
        case 0:
            [AppDelegateHelper saveData:GhostX forKey:DidChooseTheCamera];
            break;
        case 1:
            [AppDelegateHelper saveData:ForeamX1 forKey:DidChooseTheCamera];
            break;
        case 2:
            [AppDelegateHelper saveData:Compass forKey:DidChooseTheCamera];
            break;
        case 3:
            [AppDelegateHelper saveData:Ghost4K forKey:DidChooseTheCamera];
            break;

            
        default:
            break;
    }
    
    CamLivestreamStepOneViewController *cameraModalView = [[CamLivestreamStepOneViewController alloc]init];
    [self.navigationController pushViewController:cameraModalView animated:YES];
}


@end
