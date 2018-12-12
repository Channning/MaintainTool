//
//  AppDelegateHelper.h
//  Foream
//
//  Created by Channing_rong on 14-5-5.
//  Copyright (c) 2014年 Foneric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sys/utsname.h"
#import <UIKit/UIKit.h>

@interface AppDelegateHelper : NSObject


+(UILabel*)setTitleLableForNavItem;
+(void)removeTheUserDefaultsWithKey:(NSString *)key;
+(void)saveDictionary:(NSDictionary *)array forKey:(NSString*)key;
+(NSDictionary *)readADictionary:(NSString *)key;
+(void)saveData:(NSString*)data forKey:(NSString *)key;
+(NSString *)readData:(NSString *)key;
+ (void)removeData:(NSString *)key;
+(void)saveidData:(id)data forKey:(NSString*)key;
+(id)readidData:(NSString *)key;
+(void)saveBool:(BOOL)data forKey:(NSString *)key;
+(BOOL)readBool:(NSString *)key;
+ (AppDelegateHelper *)sharedInstance;
+(void) pushPopAnimation:(NSString *)subType Type:(NSString *)type Time:(float)time layer:(UIView*)view;

+ (NSString *)appDocumentsDir;
//显示加载消息
+(void)showSuccessWithTitle:(NSString *)title withMessage:(NSString *)message view:(UIView *) view;
+(void)showLoadingWithTitle:(NSString *)title withMessage:(NSString *)message view:(UIView *) view ;
+(void)showFailedWithTitle:(NSString *)title withMessage:(NSString *)message view:(UIView *)view;
+(void)removLoadingMessage:(UIView *) view;

+(NSInteger)appVersionType;
+ (NSString *)getCurrentDeviceModel;
+(NSString *)getWifiArrayPlistDocumentPathWithUid:(NSString *)uid;
+(NSString *)getSSIDArrayPlistDocumentPath;
+(NSString *)getFirstRegisterStepStatusDocumentPath;

+(NSString *)fetchSSIDName;
+(NSString *)getIPAddress:(NSString *)type;
+(BOOL)isCameraIPAddress;
+(void)registerIOSDeviceToken;

+(NSString*)dataToJsonString:(id)object;
+ (BOOL)flagWithOpenHotSpot;
@end
