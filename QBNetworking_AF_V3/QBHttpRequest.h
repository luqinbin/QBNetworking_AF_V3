//
//  QBHttpRequest.h
//  QBNetwork
//
//  Created by 覃斌 卢    on 2020/9/15.
//  Copyright © 2020 覃斌 卢   . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBNetworkConstants.h"

NS_ASSUME_NONNULL_BEGIN

@class AFSecurityPolicy;
@class QBHttpRequest;

@protocol AFMultipartFormData;

typedef void (^QBConstructingBlock)(id<AFMultipartFormData> formData);
typedef void(^QBRequestCompletionBlock)(__kindof QBHttpRequest *request);

@protocol QBHttpRequestDelegate <NSObject>

@optional

- (void)requestFinished:(__kindof QBHttpRequest *)request;
- (void)requestFailed:(__kindof QBHttpRequest *)request;

@end

@protocol QBRequestAccessory <NSObject>

@optional

- (void)requestWillStart:(id)request;
- (void)requestWillStop:(id)request;
- (void)requestDidStop:(id)request;

@end

@interface QBHttpRequest : NSObject

#pragma mark - Request Configuration
/*
 配置参数
 */

/// eg: "https://www.baidu.com". Default is configuration.baseUrl
@property (nonatomic, copy) NSString *baseUrl;
/// CDN URL. Default is configuration.cdnUrl
@property (nonatomic, copy, nullable) NSString *cdnUrl;
/// e.g: /v1/user
@property (nonatomic, copy) NSString *requestUrl;
@property (nonatomic, strong) id requestArgument;
/// 用于初始化 AFHTTPSessionManager.sessionConfiguration,
/// default is configuration.sessionConfiguration
@property (nonatomic, strong) NSURLSessionConfiguration* sessionConfiguration;
/// Default is configuration.securityPolicy
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;
/// HTTP request method, Default is QBRequestMethodTypeGet
@property (nonatomic, assign) QBRequestMethodType requestMethodType;
/// Default is configuration.requestSerializerType
@property (nonatomic, assign) QBRequestSerializerType requestSerializerType;
/// Default is configuration.responseSerializerType
@property (nonatomic, assign) QBResponseSerializerType responseSerializerType;
/// Username and password used for HTTP authorization
/// eg: @[@"Username", @"Password"];
/// Default is configuration.requestAuthorizationHeaderFieldArray
@property (copy, nonatomic, nullable) NSArray<NSString *> *requestAuthorizationHeaderFieldArray;
/// Additional HTTP request header field; Default is configuration.requestHeaderFieldValueDictionary
@property (copy, nonatomic, nullable) NSDictionary<NSString *, NSString *> *requestHeaderFieldValueDictionary;
/// 构建Post HTTP body, Default is nil
@property (nonatomic, copy, nullable) QBConstructingBlock constructingBodyBlock;
/// Default is configuration.requestTimeoutInterval
@property (nonatomic, assign) NSTimeInterval requestTimeoutInterval;
/// Default is configuration.retryTimes
@property (nonatomic, assign) NSInteger retryTimes;
/// 重试时间间隔, Default is configuration.retryInterval
@property (nonatomic, assign) NSTimeInterval retryInterval;
/// 重试时间间隔是否指数增长, default is configuration.retryProgressive
@property (nonatomic, assign) BOOL retryProgressive;
/// Default is  NO
@property (nonatomic, assign) BOOL useCDN;
/// 是否允许使用蜂窝网络， Default is YES.
@property (assign, nonatomic) BOOL allowsCellularAccess;
/// Default is `QBRequestPriorityDefault`.
@property (nonatomic, assign) QBRequestPriority requestPriority;
/// custom request;  如果!= nil, `requestUrl`,
/// `requestTimeoutInterval`、 `requestArgument`, `allowsCellularAccess`, `requestMethodType` ,`requestSerializerType` 等等...将被忽略.
@property (strong, nonatomic, nullable) NSURLRequest *buildCustomUrlRequest;
/// 断点下载文件最终存储路径，使用NSURLSessionDownloadTask
@property (nonatomic, strong, nullable) NSString *resumableDownloadPath;
@property (nonatomic, copy, nullable) QBURLSessionTaskProgressBlock downloadProgressBlock;
@property (nonatomic, copy, nullable) QBURLSessionTaskProgressBlock uploadProgressBlock;


#pragma mark - Request additional info
/// used to identify request. Default value is nil.
@property (nonatomic, copy, nullable) NSString *identifier;
/// The userInfo can be used to store additional info about the request. Default is nil.
@property (nonatomic, strong, nullable) NSDictionary *userInfo;
@property (nonatomic, weak, nullable) id<QBHttpRequestDelegate> delegate;
@property (nonatomic, strong, nullable) NSMutableArray<id<QBRequestAccessory>> *requestAccessories;
@property (nonatomic, copy, nullable) QBRequestCompletionBlock successCompletionBlock;
@property (nonatomic, copy, nullable) QBRequestCompletionBlock failureCompletionBlock;

#pragma mark - Request and Response Information
/*
 请求和响应信息
 */

/// @warning QBHttpRequest start 之后才会有值
@property (nonatomic, strong) NSURLSessionTask *requestTask;
@property (nonatomic, strong, readonly) NSURLRequest *currentRequest;
@property (nonatomic, strong, readonly) NSURLRequest *originalRequest;
@property (nonatomic, strong, readonly) NSHTTPURLResponse *response;
/// The HTTP status code
@property (nonatomic, assign, readonly) NSInteger responseStatusCode;
/// The response header fields.
@property (nonatomic, strong, nullable, readonly) NSDictionary *responseHeaders;
@property (nonatomic, strong, nullable) id responseObject;
@property (nonatomic, strong, nullable) NSString *responseString;
/// If `resumableDownloadPath` and DownloadTask is using, this value will be the path to which file is successfully saved (NSURL)
@property (nonatomic, strong, nullable) NSURL *filePath;
@property (nonatomic, strong, nullable) NSError *error;
@property (nonatomic, assign, getter=isExecuting) BOOL executing;

#pragma mark - response info check
///  responseJSONObject 校验类型
/// @note Subclass Override
- (nullable id)jsonValidator;
/// `responseStatusCode` 是否有效: 200 ~299.
- (BOOL)statusCodeValidator;

#pragma mark -
- (void)setCompletionBlockWithSuccess:(nullable QBRequestCompletionBlock)success failure:(nullable QBRequestCompletionBlock)failure;
- (void)addAccessory:(id<QBRequestAccessory>)accessory;

#pragma mark - response Preprocess
/// @note Subclass Override
- (void)requestCompletePreprocessor;

#pragma mark - Request Action

///  resume NSURLSessionDataTask and add self to requestCache hashTable
- (void)start;
/// cancel NSURLSessionDataTask and remove self from requestCache hashTable
- (void)stop;

- (void)startWithSuccess:(QBRequestCompletionBlock)success failure:(QBRequestCompletionBlock)failure;

@end

NS_ASSUME_NONNULL_END
