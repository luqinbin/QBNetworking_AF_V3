//
//  QBNetworkManager+QBCacheRequest.h
//  QBNetwork
//
//  Created by 覃斌 卢    on 2020/9/17.
//  Copyright © 2020 覃斌 卢   . All rights reserved.
//

#import "QBNetworkManager.h"
#import "objc/runtime.h"

NS_ASSUME_NONNULL_BEGIN

@class QBHttpRequest;

/**
 缓存执行的网络请求，请求之前追加，请求结束后移除
 */
@interface QBNetworkManager (QBCacheRequest)

- (NSArray<QBHttpRequest *> *)allExecutingRequests;

/// 获取key映射的request
/// @param key NSString
- (QBHttpRequest *)executingRequestWithKey:(NSString *)key;

/// 追加request到NSMapTable
/// @param request QBHttpRequest
/// @param key NSString
/// @param repeatCancel 重复请求是否忽略
- (void)addExecutingRequest:(QBHttpRequest *)request forKey:(NSString *)key repeatCancel:(BOOL)repeatCancel;

/// 从缓存中调用取消指定key的task
/// @param key NSString
- (void)cancelExecutingRequestWithKey:(NSString *)key;

/// 移除指定key的request
/// @param key NSString
- (void)removeExecutingRequestWithKey:(NSString *)key;



@end

NS_ASSUME_NONNULL_END
