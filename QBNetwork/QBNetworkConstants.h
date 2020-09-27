//
//  QBNetworkConstants.h
//  QBNetwork
//
//  Created by 覃斌 卢    on 2020/9/15.
//  Copyright © 2020 覃斌 卢   . All rights reserved.
//

#ifndef QBNetworkConstants_h
#define QBNetworkConstants_h

/// 网络请求超时时间，默认为20.f
static NSTimeInterval const QBNetworkRequestTimeoutInterval = 20.f;
/// 网络请求重试次数，默认为2次
static NSInteger const QBNetworkRetryTimes = 1;
/// 重试时间间隔
static NSTimeInterval const QBNetworkRetryInterval = 0.0f;

static NSString *const QBRequestValidationErrorDomain = @"com.qbnetwork.request.validation";

NS_ENUM(NSInteger) {
    QBRequestValidationErrorInvalidStatusCode = -8,
    QBRequestValidationErrorInvalidJSONFormat = -9,
};

typedef void (^QBURLSessionTaskProgressBlock)(NSProgress *);

typedef NS_ENUM(NSInteger, QBNetworkReachabilityStatus) {
    QBNetworkReachabilityStatusUnknown          = -1,
    QBNetworkReachabilityStatusNotReachable     = 0,
    QBNetworkReachabilityStatusReachableViaWWAN = 1,
    QBNetworkReachabilityStatusReachableViaWiFi = 2,
};

/// 请求类型
typedef NS_ENUM(NSUInteger, QBRequestMethodType) {
    QBRequestMethodTypeGet,
    QBRequestMethodTypeHead,
    QBRequestMethodTypePost,
    QBRequestMethodTypePut,
    QBRequestMethodTypePatch,
    QBRequestMethodTypeDelete
};

/// 请求序列化类型
typedef NS_ENUM(NSUInteger, QBRequestSerializerType) {
    QBRequestSerializerTypeHTTP,
    QBRequestSerializerTypeJSON,
    QBRequestSerializerTypePropertyList,
    QBRequestSerializerTypeProtobuf
};

/// 响应序列化类型
typedef NS_ENUM(NSUInteger, QBResponseSerializerType) {
    QBResponseSerializerTypeHTTP,
    QBResponseSerializerTypeJSON,
    QBResponseSerializerTypeXMLParser,
    QBResponseSerializerTypePropertyList,
    QBResponseSerializerTypeImage,
    QBResponseSerializerTypeCompound,
    QBResponseSerializerTypeProtobuf
};

///  请求优先级
typedef NS_ENUM(NSInteger, QBRequestPriority) {
    QBRequestPriorityLow = -4L,
    QBRequestPriorityDefault = 0,
    QBRequestPriorityHigh = 4,
};


#endif /* QBNetworkConstants_h */
