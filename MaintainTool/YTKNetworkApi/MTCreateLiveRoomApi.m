//
//  MTCreateLiveRoomApi.m
//  MaintainTool
//
//  Created by Channing_rong on 2018/12/12.
//  Copyright © 2018 Channing_rong. All rights reserved.
//

#import "MTCreateLiveRoomApi.h"

@implementation MTCreateLiveRoomApi
{
    NSString *_key;
    NSString *_open_id;
    
}

- (id)initWithKey:(NSString *)key openID:(NSString *)openid

{
    self = [super init];
    if (self)
    {
        _open_id = openid;
        _key = key;
        
    }
    return self;
}

- (NSString *)requestUrl
{
    return @"/createRoom";
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
             
             };
    
    
}
@end
