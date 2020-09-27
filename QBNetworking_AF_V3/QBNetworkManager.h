//
//  QBNetworkManager.h
//  QBNetwork
//
//  Created by 覃斌 卢    on 2020/9/15.
//  Copyright © 2020 覃斌 卢   . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBNetworkConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@class AFHTTPSessionManager;
@class QBHttpRequest;

@interface QBNetworkManager : NSObject

@property (strong, nonatomic, readonly) AFHTTPSessionManager *manager;
@property (strong, nonatomic, readonly) QBNetworkConfiguration *configuration;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (QBNetworkManager *)sharedInstance;
- (void)setupURLSessionManagerWithConfiguration:(QBNetworkConfiguration *)configuration;

/// Add request to request cache hashTable and start it.
- (void)addRequest:(QBHttpRequest *)request;

/// Cancel a request task and remove request form request cache hashTable
- (void)cancelRequest:(QBHttpRequest *)request;

/// Cancel all request tasks and clear request cache hashTable
- (void)cancelAllRequests;


#pragma mark - networkStatus
- (BOOL)isConnectNetwork;
+ (BOOL)isConnectNetwork;
+ (QBNetworkReachabilityStatus)networkStatus;


@end

NS_ASSUME_NONNULL_END
