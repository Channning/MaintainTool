//
//  MTCreateLiveRoomApi.h
//  MaintainTool
//
//  Created by Channing_rong on 2018/12/12.
//  Copyright © 2018 Channing_rong. All rights reserved.
//

#import "YTKRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTCreateLiveRoomApi : YTKRequest
- (id)initWithKey:(NSString *)key openID:(NSString *)openid;
@end

NS_ASSUME_NONNULL_END
