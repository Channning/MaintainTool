//
//  AppDelegateHelper.m
//  Foream
//
//  Created by Channing_rong on 14-5-5.
//  Copyright (c) 2014年 Foneric. All rights reserved.
//

#import "AppDelegateHelper.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#include <net/if.h>
#import "MBProgressHUD.h"

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
//#define IOS_VPN       @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"


static AppDelegateHelper *_sharedInstance = nil;
@implementation AppDelegateHelper

#pragma mark -
#pragma mark NavgationItem info view custom
+ (UILabel*)setTitleLableForNavItem
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    //titleLabel.shadowOffset = CGSizeMake(0, -1);
    [titleLabel setAdjustsFontSizeToFitWidth:YES];
    [titleLabel setMinimumScaleFactor:12.0];
    [titleLabel setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
    return titleLabel;
}
#pragma mark -
#pragma mark Sandbox path
/**
 * 当前应用程序的documents目录
 *
 * 目录结构: <Application_Home>/Documents/
 *
 */
+ (NSString *)appDocumentsDir{
    NSArray * array =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path =[array objectAtIndex:0];
    return path;
    
}
#pragma mark -
#pragma mark UserDefaults Save Data
+(void)saveData:(NSString*)data forKey:(NSString *)key{
    NSUserDefaults *defaults;
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:key];
    [defaults synchronize];
}

+(NSString *)readData:(NSString *)key{
    NSUserDefaults *defaults;
    defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}

+ (void)removeData:(NSString *)key{
    NSUserDefaults *defaults;
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
}

+(void)saveidData:(id)data forKey:(NSString*)key{
    NSUserDefaults *defaults;
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:key];
    [defaults synchronize];
}

+(id)readidData:(NSString *)key{
    NSUserDefaults *defaults;
    defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}

+(void)saveDictionary:(NSDictionary *)array forKey:(NSString*)key{
    NSUserDefaults *defaults;
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:array forKey:key];
    [defaults synchronize];
}

+(NSDictionary *)readADictionary:(NSString *)key{
    NSUserDefaults *defaults;
    defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [defaults dictionaryForKey:key];
    return dic;
}

+(void)saveBool:(BOOL)data forKey:(NSString *)key{
    NSUserDefaults *defaults;
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:data forKey:key];
    [defaults synchronize];
}

+(BOOL)readBool:(NSString *)key{
    NSUserDefaults *defaults;
    defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:key];
}

+(void)removeTheUserDefaultsWithKey:(NSString *)key{
    NSUserDefaults *defaults;
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
}
#pragma mark -
#pragma mark singleton class implemention
+ (AppDelegateHelper *)sharedInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
    
}
+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [super allocWithZone:zone];
            return _sharedInstance;  // assignment and return on first allocation
        }
    }
    
    return nil; //on subsequent allocation attempts return nil
}
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - 
#pragma mark app version type
+ (NSInteger)appVersionType
{
    NSString *versionNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    DLog(@"versionNumber is %@",versionNumber);
    if([versionNumber length] <= 5)
    {
    
        return 1;//distribution
    }
    else
    {
    
        return 0;//development
    }
    


}

#pragma mark - iPhone Model Name
//获得设备型号
+ (NSString *)getCurrentDeviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    if ([deviceString isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    if ([deviceString isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    if ([deviceString isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    if ([deviceString isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    if ([deviceString isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])  return @"iPhone SE";
    
    if ([deviceString isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G";
    
    if ([deviceString isEqualToString:@"iPad1,1"])   return @"iPad 1G";
    if ([deviceString isEqualToString:@"iPad2,1"])   return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,2"])   return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,3"])   return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,4"])   return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G";
    if ([deviceString isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G";
    if ([deviceString isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G";
    if ([deviceString isEqualToString:@"iPad3,1"])   return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,2"])   return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,3"])   return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,4"])   return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad3,5"])   return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad3,6"])   return @"iPad 4";    
    if ([deviceString isEqualToString:@"iPad4,1"])   return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad4,2"])   return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad4,3"])   return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G";
    if ([deviceString isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G";
    if ([deviceString isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G";
    
    if ([deviceString isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([deviceString isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return deviceString;
}


#pragma mark -
#pragma mark switch view animation
+ (void)pushPopAnimation:(NSString *)subType Type:(NSString *)type Time:(float)time layer:(UIView*)view
{
    CATransition *transition = [CATransition animation];
    transition.duration = time;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = type;
    if(subType)
        transition.subtype = subType;
    else
        transition.subtype = kCATransitionFromLeft;
    //transition.delegate = self;
    [view.layer addAnimation:transition forKey:nil];
}

#pragma mark -
#pragma mark loading message
//显示加载消息
+ (void)showLoadingWithTitle:(NSString *)title withMessage:(NSString *)message view:(UIView *) view{
    [MBProgressHUD hideHUDForView:view animated:NO];
    MBProgressHUD *mbProgressHUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    mbProgressHUD.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [mbProgressHUD setMode:MBProgressHUDModeIndeterminate];
    [mbProgressHUD setSquare:YES];
    mbProgressHUD.label.text = title;
    mbProgressHUD.detailsLabel.text = message;
}
//显示成功消息
+ (void)showSuccessWithTitle:(NSString *)title withMessage:(NSString *)message view:(UIView *) view{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark"]];
    
    [MBProgressHUD hideHUDForView:view animated:NO];
    MBProgressHUD *mbProgressHUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    [mbProgressHUD setCustomView:imageView];
    [mbProgressHUD setMode:MBProgressHUDModeCustomView];
    mbProgressHUD.label.text = title;
    mbProgressHUD.detailsLabel.text = message;
	[mbProgressHUD hideAnimated:YES afterDelay:2.5];
}
//显示错误消息
+ (void)showFailedWithTitle:(NSString *)title withMessage:(NSString *)message view:(UIView *)view{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Errormark"]];
    
    [MBProgressHUD hideHUDForView:view animated:NO];
    MBProgressHUD *mbProgressHUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    [mbProgressHUD setCustomView:imageView];
    [mbProgressHUD setMode:MBProgressHUDModeCustomView];
    mbProgressHUD.label.text = title;
    mbProgressHUD.detailsLabel.text = message;
	[mbProgressHUD hideAnimated:YES afterDelay:3];
}
//移除加载消息
+ (void)removLoadingMessage:(UIView *) view{
//    [MBProgressHUD hideHUDForView:view animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:view animated:YES];
    });
}

#pragma mark -
#pragma mark file on disk reading
+ (NSString *)getWifiArrayPlistDocumentPathWithUid:(NSString *)uid
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"WifiArray%@.plist",uid]];
    
    return path;
}

+ (NSString *)getSSIDArrayPlistDocumentPath
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"SSIDArray.plist"];
    
    return path;
}

+ (NSString *)getFirstRegisterStepStatusDocumentPath
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"FirstRegisterStepStatus.plist"];
    
    return path;
}


#pragma mark -
#pragma mark network function

+(void)registerIOSDeviceToken{
    
    NSString *modeString;
    if ([AppDelegateHelper appVersionType] == 0) {
        modeString = @"1";//development
    }else{
    
        modeString = @"0";//distribution
    }

    
    NSDictionary *parasDic =[NSDictionary dictionaryWithObjectsAndKeys: [AppDelegateHelper readData:@"DeviceToken"],@"deviceToken",modeString,@"mode",@"drift",@"iosAppName", nil];
    //NSString *paraString = [parasDic JSONString];
    if (![AppDelegateHelper readBool:@"isRegister"])
    {
//        NetdiskGeneralSendCmdApi *generalCmdApi = [[NetdiskGeneralSendCmdApi alloc]initWithSessionId:[FOMAPPDELEGATE loginUser].sid token:[FOMAPPDELEGATE loginUser].token commandString:@"registerIOSDevice" commandParameters:paraString];
//        [generalCmdApi startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
//            NSDictionary *regResponse = [request.responseString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
//            DLog(@"responsestring is %@ data is %@",regResponse,[regResponse objectForKey:@"data"]);
//            if ([[NSNumber numberWithInt:1] isEqual: [regResponse objectForKey : @"status"] ])
//            {
//                //保存是否注册成功，以便下次登录查询。
//                [AppDelegateHelper saveBool:YES forKey:@"isRegister"];
//            }else{
//                [AppDelegateHelper saveBool:NO forKey:@"isRegister"];
//            }
//        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
//            DLog(@"requestOperationError == %@",request.error);
//            [AppDelegateHelper saveBool:NO forKey:@"isRegister"];
//        }];
    }
}

//fetch current ssid info
+ (NSString *)fetchSSIDName {
//    if([[FOMAPPDELEGATE hostReach] currentReachabilityStatus] == ReachableViaWiFi || [AppDelegateHelper isCameraIPAddress])
//    {
        NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
        DLog(@"Supported interfaces: %@", ifs);
        id info = nil;
        NSString *ssidName = nil;
        for (NSString *ifnam in ifs) {
            info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
            DLog(@"%@ => %@", ifnam, info);
            //DLog(@"SSID: %@", (NSString *)CFDictionaryGetValue ((__bridge CFDictionaryRef)(info), kCNNetworkInfoKeySSID));
            if([info count])
            {
                ssidName = (NSString *)CFDictionaryGetValue ((__bridge CFDictionaryRef)(info), kCNNetworkInfoKeySSID);
                if (info && [info count]) { break; }
            }
        }
        return ssidName;
//    }
//    return nil;
}


// Get IP Address
+(NSString *)getIPAddress:(NSString *)type
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone,//en0--->  Wi-Fi adapter, or bridge0 --> iPhone 4 Personal hotspot
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:type]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
                else
                {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
//    DLog(@"kc test:address = %@", address);
    return address;
}

+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

/**
 判断热点是否开启

 */
+ (BOOL)flagWithOpenHotSpot
{
    NSDictionary *dict = [self getIPAddresses];
    if ( dict ) {
        NSArray *keys = dict.allKeys;
        for ( NSString *key in keys) {
            if ( key && [key containsString:@"bridge"])
                return YES;
        }
    }
    return NO;
}


//if connected to camera
+ (BOOL) isCameraIPAddress{
    //Router may also have the "192.168.42.*"address, we need to
    //test connection at first.
    //We disable it as currentReachabilityStatus can't change quickly.
    //    if([self._hostReach currentReachabilityStatus] == ReachableViaWiFi)
    //    {
    //        return NO;
    //    }
#if 0
    if([[self getIPAddress:@"en0"] hasPrefix: @"192.168.42."])
        return YES;
    else
        return NO;
#else
    NSString * ssidName = [AppDelegateHelper fetchSSIDName];
    if([ssidName hasPrefix:@"Compass"] || [ssidName hasPrefix:@"Ghost"] || [ssidName hasPrefix:@"X1"] || [ssidName hasPrefix:@"Stealth"] || [ssidName hasPrefix:@"GHOST 4K"] || [ssidName hasPrefix:@"GHOST X"])
        return YES;
    else
        return NO;
#endif
}


#pragma mark -- private method


+(NSString*)dataToJsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

+ (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([string isEqualToString:@"<null>"]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
    
}



@end
