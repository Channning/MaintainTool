//
//  MacroDefinition.h
//
//  Created by Channing_rong on 14-5-5.
//  Copyright (c) 2014年 Foneric. All rights reserved.
//

#ifndef MacroDefinition_h
#define MacroDefinition_h


#define Password [SNEGeneralMethedsHelper readData:@"Password"]
#define PhoneNumber [SNEGeneralMethedsHelper readData:@"PhoneNumber"]

//-------------------获取设备大小-------------------------
//NavBar高度
#define NavigationBar_HEIGHT 44
//获取屏幕 宽度、高度
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

/** 弱指针*/
#define WeakSelf(weakSelf)    __weak __typeof(&*self)weakSelf = self;

//-------------------获取设备大小-------------------------

//-------------------防止Block循环-------------------------
#define WEAKSELF __weak typeof(self) weakSelf = self;

#define STRONGSELF __strong typeof(self) strongSelf = weakSelf;


//-------------------打印日志-------------------------
//DEBUG  模式下打印日志,当前行
#ifdef DEBUG
#define DLog( s, ... ) NSLog( @"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#   define DLog(...)
#endif

//#ifdef DEBUG
//#define ELog( s, ... ) NSLog( @"<%p %@:(%d)> %@", strongSelf, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
//#else
//#   define ELog(...)
//#endif


//重写NSLog,Debug模式下打印日志和当前行数
//#if DEBUG
//#define NSLog(FORMAT, ...) fprintf(stderr,"\nfunction:%s line:%d content:%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
//#else
//#define NSLog(FORMAT, ...) nil
//#endif

//DEBUG  模式下打印日志,当前行 并弹出一个警告
#ifdef DEBUG
#   define ULog(fmt, ...)  { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#else
#   define ULog(...)
#endif


#define ITTDEBUG
#define ITTLOGLEVEL_INFO     10
#define ITTLOGLEVEL_WARNING  3
#define ITTLOGLEVEL_ERROR    1

#ifndef ITTMAXLOGLEVEL

#ifdef DEBUG
#define ITTMAXLOGLEVEL ITTLOGLEVEL_INFO
#else
#define ITTMAXLOGLEVEL ITTLOGLEVEL_ERROR
#endif

#endif

// The general purpose logger. This ignores logging levels.
#ifdef ITTDEBUG
#define ITTDPRINT(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define ITTDPRINT(xx, ...)  ((void)0)
#endif

// Prints the current method's name.
#define ITTDPRINTMETHODNAME() ITTDPRINT(@"%s", __PRETTY_FUNCTION__)

// Log-level based logging macros.
#if ITTLOGLEVEL_ERROR <= ITTMAXLOGLEVEL
#define ITTDERROR(xx, ...)  ITTDPRINT(xx, ##__VA_ARGS__)
#else
#define ITTDERROR(xx, ...)  ((void)0)
#endif

#if ITTLOGLEVEL_WARNING <= ITTMAXLOGLEVEL
#define ITTDWARNING(xx, ...)  ITTDPRINT(xx, ##__VA_ARGS__)
#else
#define ITTDWARNING(xx, ...)  ((void)0)
#endif

#if ITTLOGLEVEL_INFO <= ITTMAXLOGLEVEL
#define ITTDINFO(xx, ...)  ITTDPRINT(xx, ##__VA_ARGS__)
#else
#define ITTDINFO(xx, ...)  ((void)0)
#endif

#ifdef ITTDEBUG
#define ITTDCONDITIONLOG(condition, xx, ...) { if ((condition)) { \
ITTDPRINT(xx, ##__VA_ARGS__); \
} \
} ((void)0)
#else
#define ITTDCONDITIONLOG(condition, xx, ...) ((void)0)
#endif

#define ITTAssert(condition, ...)                                       \
do {                                                                      \
if (!(condition)) {                                                     \
[[NSAssertionHandler currentHandler]                                  \
handleFailureInFunction:[NSString stringWithUTF8String:__PRETTY_FUNCTION__] \
file:[NSString stringWithUTF8String:__FILE__]  \
lineNumber:__LINE__                                  \
description:__VA_ARGS__];                             \
}                                                                       \
} while(0)

//---------------------打印日志--------------------------


//----------------------系统----------------------------

//获取系统版本
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define CurrentSystemVersion [[UIDevice currentDevice] systemVersion]

//获取当前语言
#define CurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])

//判断是否 Retina屏、设备是否%fhone 5、是否是iPad

#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)) : NO)
#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IOS7_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 )
#define SYSTEM_RUNS_IOS7_OR_LATER IOS7_OR_LATER
#define IOS8_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 )
#define IOS9_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0 )
#define IOS10_OR_LATER  ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0 )
#define SYSTEM_RUNS_IOS8_OR_LATER IOS8_OR_LATER
#define IS_IPHONE_X (SCREEN_HEIGHT == 812.0f) ? YES : NO
#define IS_IPHONE_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
#define IS_IPHONE_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
#define IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)

#define IS_iPhoneX_Series ((IS_IPHONE_X==YES || IS_IPHONE_Xr ==YES || IS_IPHONE_Xs== YES || IS_IPHONE_Xs_Max== YES) ? YES : NO)

#define SafeAreaTopHeight (SCREEN_HEIGHT == 812.0 ? 88 : 64)
#define SafeAreaBottomHeight (SCREEN_HEIGHT == 812.0 ? 34 : 0)
//判断是否支持新的Api
#define isSupportNewApi ([[AppDelegateHelper fetchSSIDName] hasPrefix:@"Compass"] || [[AppDelegateHelper fetchSSIDName] hasPrefix:@"X1-"] || [[AppDelegateHelper fetchSSIDName] hasPrefix:@"GHOST 4K"] || [[AppDelegateHelper fetchSSIDName] hasPrefix:@"GHOST X"])
#define Ghost_S [[AppDelegateHelper fetchSSIDName] hasPrefix:@"Ghost S-"]

//判断是真机还是模拟器
#if TARGET_OS_IPHONE
//iPhone Device
#endif

#if TARGET_IPHONE_SIMULATOR
//iPhone Simulator
#endif

//检查系统版本
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


//----------------------系统----------------------------


//----------------------内存----------------------------

//使用ARC和不使用ARC
#if __has_feature(objc_arc)
//compiling with ARC
#else
// compiling without ARC
#endif

#pragma mark - common functions
#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }

//释放一个对象
#define SAFE_DELETE(P) if(P) { [P release], P = nil; }

#define SAFE_RELEASE(x) [x release];x=nil



//----------------------内存----------------------------


//----------------------图片----------------------------

//读取本地图片
#define LOADIMAGE(file,ext) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:ext]]

//定义UIImage对象
#define IMAGE(A) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:A ofType:nil]]

//定义UIImage对象
#define ImageNamed(_pointer) [UIImage imageNamed:[UIUtil imageName:_pointer]]

//建议使用前两种宏定义,性能高于后者
//----------------------图片----------------------------



//----------------------颜色类---------------------------
// rgb颜色转换（16进制->10进制）
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorFromRGBA(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:0.8]

//带有RGBA的颜色设置
#define COLOR(R, G, B, A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

// 获取RGB颜色
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)

//背景色
#define BACKGROUND_COLOR [UIColor colorWithRed:242.0/255.0 green:236.0/255.0 blue:231.0/255.0 alpha:1.0]

//清除背景色
#define CLEARCOLOR [UIColor clearColor]

#pragma mark - color functions
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

//----------------------颜色类--------------------------
#define UserDefineColorDark [UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f]

#define UserDefineColorGray1 [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f]
#define UserDefineColorGray2 [UIColor colorWithRed:138.0f/255.0f green:138.0f/255.0f blue:138.0f/255.0f alpha:1.0f]
#define UserDefineColorOrange [UIColor colorWithRed:244.0f/255.0f green:147.0f/255.0f blue:33.0f/255.0f alpha:1.0f]
#define UserDefineTextColor646464 UIColorFromRGB(0x646464)
#define UserDefineTextColorf7f7f7 UIColorFromRGB(0xf7f7f7)
#define UserDefineTextColorb5b6ba UIColorFromRGB(0xb5b6ba)
#define UserDefineTextColorcacacb UIColorFromRGB(0xcacacb)
#define UserDefineTextColor323232 UIColorFromRGB(0x323232)
#define UserDefineTextColorColord9d9d9 UIColorFromRGB(0xd9d9d9)
#define UserDefineTextColorc0c0c0 UIColorFromRGB(0xc0c0c0)
#define UserDefineTextColore4b475 UIColorFromRGB(0xe4b475)
//Drift Life字体颜色标准黑
#define FONTCOLOURBLACK UIColorFromRGB(0x404040)

//----------------------其他----------------------------

//Drift Life字体定义

#define StandardFONT(F) [UIFont fontWithName:@"MuseoSans-500" size:F]
#define FONT(F) [UIFont fontWithName:@"FZHTJW--GB1-0" size:F]


//定义一个API
#define APIURL                @"http://112.124.98.104"
//登陆API
#define APILogin              [APIURL stringByAppendingString:@"Login"]

//设置View的tag属性
#define VIEWWITHTAG(_OBJECT, _TAG)    [_OBJECT viewWithTag : _TAG]
//程序的本地化,引用国际化的文件
#define MyLocal(x, ...) NSLocalizedString(x, nil)

//G－C－D
#define BACK(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define MAIN(block) dispatch_async(dispatch_get_main_queue(),block)




//由角度获取弧度 有弧度获取角度
#define degreesToRadian(x) (M_PI * (x) / 180.0)
#define radianToDegrees(radian) (radian*180.0)/(M_PI)

#define LOCALALBUM_PATH [[FileHelper documentPath] stringByAppendingPathComponent:@"LoacalAlbum"]

#define kNGFadeDuration                     0.33

#define WIFIDirectUpdateCamStatus @"WIFIDirectUpdateCamStatus"

//FMDB path
#define DBPATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]stringByAppendingString:@"/NewsMessage"]

#define IsBlankString(x) [AppDelegateHelper isBlankString:x]

#define MaxSizeForFileToWarning 3*1024*1024 //3Mb file size warning on cellular data mode


#ifndef isDictWithCountMoreThan0

#define isDictWithCountMoreThan0(__dict__) \
(__dict__!=nil && \
[__dict__ isKindOfClass:[NSDictionary class] ] && \
__dict__.count>0)

#endif

#ifndef isArrayWithCountMoreThan0

#define isArrayWithCountMoreThan0(__array__) \
(__array__!=nil && \
[__array__ isKindOfClass:[NSArray class] ] && \
__array__.count>0)

#endif

#define isStringNotNil(__string__) \
(__string__!=nil && \
[__string__ isKindOfClass:[NSString class] ])

typedef NS_ENUM(NSInteger, CameraModalStyle) {
    CameraModalStyleGhostS,
    CameraModalStyleStealth2,
    CameraModalStyleX1,
    CameraModalStyleCompass,
    CameraModalStyleGhost4K,
    CameraModalStyleGhostX,
};

typedef NS_ENUM(NSInteger, ConnectType) {
    kWifiDirectType,
    kMobileDateLiveType,
    kFirmwareUpgradeType,
    kBTLiveType,
};

//Drift
#define GhostHD       @"Drift HD GHOST"
#define GhostS        @"Ghost S"
#define Ghost4K       @"GHOST 4K"
#define GhostX        @"GHOST X"
#define Stealth2      @"Stealth 2"
#define Compass       @"Compass"
#define CompassB      @"CompassB"
//Foream
#define HDSpider      @"HD Spider"
#define HDFinder      @"HD Finder"
#define ForeamX1      @"X1"
#define LocalPhoneCamera      @"LocalPhoneCamera"

//NSUserDefaults 实例化
#define USER_DEFAULT [NSUserDefaults standardUserDefaults]
#define DidChooseTheCamera @"DidChooseTheCamera"
#define DidChooseNetdistType @"DidChooseNetdistType"
#define SavedOpenID @"UserStreamOpenID"
#define APPStreamKey @"APPStreamKey"
#define LastLoginUserId  [AppDelegateHelper readData:@"LastLoginUserId"]

//NSNotification
#define INFORMLIVECONVERSATIONUPDATEUI @"InformLiveConversationUpdateUI"

//接口HOST地址
#define ServerAddress @"wx.driftlife.co"
#define MTLiveApiKey @"foream2018"
#endif
