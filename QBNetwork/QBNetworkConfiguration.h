//
//  QBNetworkConfiguration.h
//  QBNetwork
//
//  Created by 覃斌 卢    on 2020/9/15.
//  Copyright © 2020 覃斌 卢   . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBNetworkConstants.h"

NS_ASSUME_NONNULL_BEGIN

@class AFSecurityPolicy;

@interface QBNetworkConfiguration : NSObject

/// eg: "https://www.baidu.com". Default is nil
@property (nonatomic, copy) NSString *baseUrl;
/// CDN URL. Default is nil
@property (nonatomic, copy, nullable) NSString *cdnUrl;
/// 用于初始化 AFHTTPSessionManager.sessionConfiguration 默认为nil, AF默认使用defaultSessionConfiguration
@property (nonatomic, strong) NSURLSessionConfiguration* sessionConfiguration;
/// Default SSLPinningMode is AFSSLPinningModeNone
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;
/// Default is QBRequestSerializerTypeJSON
@property (nonatomic, assign) QBRequestSerializerType requestSerializerType;
/// Default is QBResponseSerializerTypeJSON
@property (nonatomic, assign) QBResponseSerializerType responseSerializerType;
/// Username and password used for HTTP authorization. eg: @[@"Username", @"Password"].
@property (strong, nonatomic, nullable) NSArray<NSString *> *requestAuthorizationHeaderFieldArray;
/// Additional HTTP request header field.
@property (strong, nonatomic, nullable) NSDictionary<NSString *, NSString *> *requestHeaderFieldValueDictionary;
/// Default is QBNetworkRequestTimeoutInterval
@property (nonatomic, assign) NSTimeInterval requestTimeoutInterval;
/// Default is QBNetworkRetryTimes
@property (nonatomic, assign) NSInteger retryTimes;
/// 重试时间间隔 Default is QBNetworkRetryInterval
@property (nonatomic, assign) NSTimeInterval retryInterval;
/// 重试时间间隔是否指数增长 default is NO
@property (nonatomic, assign) BOOL retryProgressive;
@property (nonatomic, strong, nullable) NSArray<NSNumber *> *fatalStatusCodes;
/// debug模式是否print log. Default is YES
@property (nonatomic) BOOL debugLogEnabled;


- (instancetype)initWithBaseUrl:(NSString *)baseUrl cdnUrl:(NSString * _Nullable)cdnUrl;


@end

NS_ASSUME_NONNULL_END
