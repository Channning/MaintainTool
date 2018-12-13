//
//  MTCreateSessionApi.m
//  MaintainTool
//
//  Created by Channing_rong on 2018/12/12.
//  Copyright © 2018 Channing_rong. All rights reserved.
//

#import "MTCreateSessionApi.h"

@implementation MTCreateSessionApi
{
    NSString *_key;
    NSString *_open_id;
    NSString *_room_id;
    NSString *_session_key;
    
}

- (id)initWithKey:(NSString *)key openID:(NSString *)openid roomID:(NSString *)roomid sessionKey:(NSString *)sessionkey

{
    self = [super init];
    if (self)
    {
        _open_id = openid;
        _key = key;
        _room_id = roomid;
        _session_key = sessionkey;
        
        
    }
    return self;
}

- (NSString *)requestUrl
{
    return @"/createSession";
}

- (YTKRequestMethod)requestMethod
{
    return YTKRequestMethodPOST;
}


- (id)requestArgument
{
    
    return @{
             @"key": _key,
             @"room_id": _room_id,
             @"owner_open_id": _open_id,
             @"session_key": _session_key,
             };
    
    
}
@end
