//
//  MTOwnerRoomInfoApi.m
//  MaintainTool
//
//  Created by Channing_rong on 2018/12/12.
//  Copyright © 2018 Channing_rong. All rights reserved.
//

#import "MTOwnerRoomInfoApi.h"

@implementation MTOwnerRoomInfoApi
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
    return @"/ownerRoomInfo";
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
