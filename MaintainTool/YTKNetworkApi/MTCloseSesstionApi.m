//
//  MTCloseSesstionApi.m
//  MaintainTool
//
//  Created by Channing_rong on 2018/12/12.
//  Copyright © 2018 Channing_rong. All rights reserved.
//

#import "MTCloseSesstionApi.h"

@implementation MTCloseSesstionApi
{
    NSString *_key;
    NSString *_room_id;
    NSString *_session_key;
    
}

- (id)initWithKey:(NSString *)key roomID:(NSString *)roomid sessionKey:(NSString *)sessionkey

{
    self = [super init];
    if (self)
    {
        _room_id = roomid;
        _key = key;
        _session_key = sessionkey;
        
        
    }
    return self;
}

- (NSString *)requestUrl
{
    return @"/closeSession";
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
             @"session_key": _session_key,
             };
    
    
}
@end
