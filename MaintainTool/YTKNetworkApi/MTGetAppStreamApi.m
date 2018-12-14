//
//  MTGetAppStreamApi.m
//  MaintainTool
//
//  Created by Channing_rong on 2018/12/12.
//  Copyright © 2018 Channing_rong. All rights reserved.
//

#import "MTGetAppStreamApi.h"

@implementation MTGetAppStreamApi
{
    NSString *_key;
    NSString *_open_id;
    NSString *_nickname;
    
}

- (id)initWithKey:(NSString *)key openID:(NSString *)openid nickName:(NSString *)nickname

{
    self = [super init];
    if (self)
    {
        _key = key;
        _open_id = openid;
        _nickname = nickname;
       
    }
    return self;
}

- (NSString *)requestUrl
{
    return @"/appRegister";
}

- (YTKRequestMethod)requestMethod
{
    return YTKRequestMethodPOST;
}


- (id)requestArgument
{
    
    return @{
             @"key": _key,
             @"open_id": _open_id,
             @"nickname": _nickname,
             
             };
    
    
}

@end
