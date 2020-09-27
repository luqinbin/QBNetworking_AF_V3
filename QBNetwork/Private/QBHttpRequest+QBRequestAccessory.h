//
//  QBHttpRequest+QBRequestAccessory.h
//  QBNetwork
//
//  Created by 覃斌 卢    on 2020/9/21.
//  Copyright © 2020 覃斌 卢   . All rights reserved.
//

#import "QBHttpRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface QBHttpRequest (QBRequestAccessory)

- (void)toggleAccessoriesWillStartCallBack;
- (void)toggleAccessoriesWillStopCallBack;
- (void)toggleAccessoriesDidStopCallBack;


@end

NS_ASSUME_NONNULL_END
