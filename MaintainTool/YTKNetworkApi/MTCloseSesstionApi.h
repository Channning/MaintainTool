//
//  MTCloseSesstionApi.h
//  MaintainTool
//
//  Created by Channing_rong on 2018/12/12.
//  Copyright © 2018 Channing_rong. All rights reserved.
//

#import "YTKRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTCloseSesstionApi : YTKRequest
- (id)initWithKey:(NSString *)key roomID:(NSString *)roomid sessionKey:(NSString *)sessionkey;
@end

NS_ASSUME_NONNULL_END
