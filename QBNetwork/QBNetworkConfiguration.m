//
//  QBNetworkConfiguration.m
//  QBNetwork
//
//  Created by 覃斌 卢    on 2020/9/15.
//  Copyright © 2020 覃斌 卢   . All rights reserved.
//

#import "QBNetworkConfiguration.h"
#import <AFNetworking/AFSecurityPolicy.h>

@implementation QBNetworkConfiguration

#pragma mark - Constructor
- (instancetype)init {
    self = [super init];
    if (self) {
        [self defaultSetup];
    }
    return self;
}

- (instancetype)initWithBaseUrl:(NSString *)baseUrl cdnUrl:(NSString * _Nullable)cdnUrl {
    self = [super init];
    if (self) {
        _baseUrl = baseUrl;
        _cdnUrl = cdnUrl;
        [self defaultSetup];
    }
    
    return self;
}

#pragma mark - Private
- (void)defaultSetup {
    _securityPolicy = [AFSecurityPolicy defaultPolicy];
    _requestSerializerType = QBRequestSerializerTypeJSON;
    _responseSerializerType = QBResponseSerializerTypeJSON;
    _requestTimeoutInterval = QBNetworkRequestTimeoutInterval;
    _retryTimes = QBNetworkRetryTimes;
    _retryInterval = QBNetworkRetryInterval;
    _retryProgressive = NO;
    _debugLogEnabled = YES;
}

#pragma mark - NSObject protocol
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p>{ baseURL: %@ } { cdnURL: %@ }", NSStringFromClass([self class]), self, self.baseUrl, self.cdnUrl];
}

@end
