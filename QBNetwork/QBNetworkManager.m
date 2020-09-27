//
//  QBNetworkManager.m
//  QBNetwork
//
//  Created by 覃斌 卢    on 2020/9/15.
//  Copyright © 2020 覃斌 卢   . All rights reserved.
//

#import "QBNetworkManager.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "QBProtobufRequestSerializer.h"
#import "QBProtobufResponseSerializer.h"
#import "QBNetworkManager+QBRetryPolicy.h"
#import "QBNetworkManager+QBDownloadTask.h"
#import "QBNetworkManager+QBCacheRequest.h"
#import "QBHttpRequest+QBRequestAccessory.h"
#import "QBHttpRequest.h"
#import "QBNetworkUtils.h"
#import <pthread/pthread.h>

#define Lock() pthread_mutex_lock(&_lock)
#define Unlock() pthread_mutex_unlock(&_lock)

@interface QBNetworkManager ()

@property (strong, nonatomic) AFHTTPSessionManager *manager;
@property (strong, nonatomic) QBNetworkConfiguration *configuration;
@property (strong, nonatomic) dispatch_queue_t processingQueue;
@property (nonatomic) pthread_mutex_t lock;
@property (strong, nonatomic) NSIndexSet *allStatusCodes;

@property (nonatomic, assign) AFNetworkReachabilityStatus networkReachabilityStatus;

@end

@implementation QBNetworkManager

#pragma mark - Constructor
+ (QBNetworkManager *)sharedInstance {
    static QBNetworkManager *shareManger;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManger = [[QBNetworkManager alloc] init];
    });
    
    return shareManger;
}

- (id)init {
    self = [super init];
    if (self) {
        _processingQueue = dispatch_queue_create("com.qb.networkManager.processing", DISPATCH_QUEUE_CONCURRENT);
        _allStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(100, 500)];
        pthread_mutex_init(&_lock, NULL);
        
        if (_configuration == nil) {
            _configuration = [[QBNetworkConfiguration alloc]init];
        }
        
        [self setupURLSessionManagerWithConfiguration:_configuration];
        [self setupReachabilityManager];
    }
    
    return self;
}

#pragma mark - Public
- (QBNetworkReachabilityStatus)networkStatus {
    QBNetworkReachabilityStatus state = QBNetworkReachabilityStatusReachableViaWiFi;
    AFNetworkReachabilityStatus reachabilityStatus = self.networkReachabilityStatus;
    if (reachabilityStatus == AFNetworkReachabilityStatusUnknown || reachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        reachabilityStatus = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    }
    switch (reachabilityStatus) {
        case AFNetworkReachabilityStatusNotReachable:
            state = QBNetworkReachabilityStatusNotReachable;
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            state = QBNetworkReachabilityStatusReachableViaWWAN;
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            state = QBNetworkReachabilityStatusReachableViaWiFi;
            break;
        case AFNetworkReachabilityStatusUnknown:
        default:
            state = QBNetworkReachabilityStatusNotReachable;
            break;
    }
    return state;
}

+ (QBNetworkReachabilityStatus)networkStatus {
    return [[QBNetworkManager sharedInstance] networkStatus];
}

- (BOOL)isConnectNetwork {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

+ (BOOL)isConnectNetwork {
    return [[QBNetworkManager sharedInstance] isConnectNetwork];
}

- (void)setupURLSessionManagerWithConfiguration:(QBNetworkConfiguration *)configuration {
    _configuration = configuration;
    _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:_configuration.sessionConfiguration];
    _manager.securityPolicy = _configuration.securityPolicy;
    _manager.completionQueue = _processingQueue;
    [_manager setTaskDidFinishCollectingMetricsBlock:_configuration.collectingMetricsBlock];
}

- (void)addRequest:(QBHttpRequest *)request {
    NSParameterAssert(request != nil);
    
    NSError * __autoreleasing requestSerializationError = nil;
    
    if(request.buildCustomUrlRequest) {
        __block NSURLSessionDataTask *dataTask = nil;
        dataTask = [self.manager dataTaskWithRequest:request.buildCustomUrlRequest
                                      uploadProgress:request.uploadProgressBlock
                                    downloadProgress:request.downloadProgressBlock
                                   completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            [self handleRequestResult:dataTask responseObject:responseObject error:error];
        }];
        request.requestTask = dataTask;
    } else {
        request.requestTask = [self sessionTaskForRequest:request error:&requestSerializationError];
    }
    
    if (requestSerializationError) {
        [self requestDidFailWithRequest:request error:requestSerializationError];
        
        return;
    }
    
    NSAssert(request.requestTask != nil, @"requestTask should not be nil");
    
    // set task priority
    if ([request.requestTask respondsToSelector:@selector(priority)]) {
        switch (request.requestPriority) {
            case QBRequestPriorityHigh:
                request.requestTask.priority = NSURLSessionTaskPriorityHigh;
                break;
            case QBRequestPriorityLow:
                request.requestTask.priority = NSURLSessionTaskPriorityLow;
                break;
            case QBRequestPriorityDefault:
            default:
                request.requestTask.priority = NSURLSessionTaskPriorityDefault;
                break;
        }
    }
    
    if (request.requestTask) {
        QBNetworkLog(@"Add request: %@", NSStringFromClass([request class]));
        
        [self addExecutingRequest:request forKey:[self requestCacheKey:request.requestTask] repeatCancel:YES];
        
        [request toggleAccessoriesWillStartCallBack];
        
        [request.requestTask resume];
    }
}

- (void)cancelRequest:(QBHttpRequest *)request {
    NSParameterAssert(request != nil);
    
    if (request.resumableDownloadPath && [self incompleteDownloadTempPathForDownloadPath:request.resumableDownloadPath] != nil) {
        [request toggleAccessoriesWillStopCallBack];
        NSURLSessionDownloadTask *requestTask = (NSURLSessionDownloadTask *)request.requestTask;
        [requestTask cancelByProducingResumeData:^(NSData *resumeData) {
            NSURL *localUrl = [self incompleteDownloadTempPathForDownloadPath:request.resumableDownloadPath];
            [resumeData writeToURL:localUrl atomically:YES];
        }];
        [request toggleAccessoriesDidStopCallBack];
    } else {
        [request toggleAccessoriesWillStopCallBack];
        NSString *key = [self requestCacheKey:request.requestTask];
        [self cancelExecutingRequestWithKey:key];
        [request toggleAccessoriesDidStopCallBack];
    }
}

- (void)cancelAllRequests {
    NSArray<QBHttpRequest *> *requests = [self allExecutingRequests];
    for (QBHttpRequest *request in requests) {
        [request stop];
    }
}

#pragma mark - Private
#pragma mark -
- (void)setupReachabilityManager {
    __weak __typeof(self)weakSelf = self;
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        weakSelf.networkReachabilityStatus = status;
    }];
    [manager startMonitoring];
}

#pragma mark - Serializer
- (AFHTTPRequestSerializer *)requestSerializerForRequest:(QBHttpRequest *)request {
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    QBRequestSerializerType requestSerializerType = request.requestSerializerType;
    
    if (requestSerializerType == QBRequestSerializerTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    } else if (requestSerializerType == QBRequestSerializerTypePropertyList) {
        requestSerializer = [AFPropertyListRequestSerializer serializer];
    } else if (requestSerializerType == QBRequestSerializerTypeProtobuf) {
        requestSerializer = [QBProtobufRequestSerializer serializer];
    }
    
    requestSerializer.timeoutInterval = request.requestTimeoutInterval;
    requestSerializer.allowsCellularAccess = request.allowsCellularAccess;

    /// HTTP basic auth
    NSArray<NSString *> *authorizationHeaderFieldArray = request.requestAuthorizationHeaderFieldArray;
    if (authorizationHeaderFieldArray != nil) {
        [requestSerializer setAuthorizationHeaderFieldWithUsername:authorizationHeaderFieldArray.firstObject
                                                          password:authorizationHeaderFieldArray.lastObject];
    }
        
    return requestSerializer;
}

- (AFHTTPResponseSerializer *)responseSerializerForRequest:(QBHttpRequest *)request {
    AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
    QBResponseSerializerType responseSerializerType = request.responseSerializerType;
    
    switch (responseSerializerType) {
        case QBResponseSerializerTypeJSON: {
            serializer = [AFJSONResponseSerializer serializer];
            serializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/plain", @"text/html", @"text/xml", @"text/javascript", nil];
            break;
        }
        case QBResponseSerializerTypeXMLParser: {
            serializer = [AFXMLParserResponseSerializer serializer];
            break;
        }
        case QBResponseSerializerTypePropertyList: {
            serializer = [AFPropertyListResponseSerializer serializer];
            break;
        }
        case QBResponseSerializerTypeImage: {
            serializer = [AFImageResponseSerializer serializer];
            break;
        }
        case QBResponseSerializerTypeCompound: {
            serializer = [AFCompoundResponseSerializer serializer];
            break;
        }
        case QBResponseSerializerTypeProtobuf: {
            serializer = [QBProtobufResponseSerializer serializer];
        }
            break;
        default:
            break;
    }
    return serializer;
}

#pragma mark - Url
- (NSString *)buildRequestUrl:(QBHttpRequest *)request {
    NSParameterAssert(request != nil);

    NSString *detailUrl = [request requestUrl];
    NSURL *temp = [NSURL URLWithString:detailUrl];
    if (temp && temp.host && temp.scheme) {
        /// valid URL
        return detailUrl;
    }

    NSString *baseUrl;
    if ([request useCDN]) {
        if ([request cdnUrl].length > 0) {
            baseUrl = [request cdnUrl];
        } else {
            baseUrl = [_configuration cdnUrl];
        }
    } else {
        if ([request baseUrl].length > 0) {
            baseUrl = [request baseUrl];
        } else {
            baseUrl = [_configuration baseUrl];
        }
    }
    
    NSURL *url = [NSURL URLWithString:baseUrl];

    if (baseUrl.length > 0 && ![baseUrl hasSuffix:@"/"]) {
        url = [url URLByAppendingPathComponent:@""];
    }

    return [NSURL URLWithString:detailUrl relativeToURL:url].absoluteString;
}

#pragma mark - SessionTask Create
- (NSURLSessionTask *)sessionTaskForRequest:(QBHttpRequest *)request error:(NSError * _Nullable __autoreleasing *)requestSerializationError {
    QBRequestMethodType methodType = request.requestMethodType;
    NSString *url = [self buildRequestUrl:request];
    NSDictionary<NSString *,NSString *> *headers = request.requestHeaderFieldValueDictionary;
    id param = request.requestArgument;
    QBConstructingBlock constructingBlock = request.constructingBodyBlock;
    QBURLSessionTaskProgressBlock uploadProgressBlock = request.uploadProgressBlock;
    QBURLSessionTaskProgressBlock downloadProgressBlock = request.downloadProgressBlock;
    
    self.manager.requestSerializer = [self requestSerializerForRequest:request];
    self.manager.responseSerializer = [self responseSerializerForRequest:request];
    
    NSURLSessionTask *task = nil;
    
    void(^failureBlock)(NSURLSessionDataTask * _Nonnull, NSError * _Nonnull) = ^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error){
        if (task == nil && error) {
            *requestSerializationError = error;
        } else {
            [self handleRequestResult:task responseObject:nil error:error];
        }
    };
    
    switch (methodType) {
        case QBRequestMethodTypeGet: {
            if (request.resumableDownloadPath) {
                task = [self downloadTaskWithDownloadPath:request.resumableDownloadPath URLString:url headers:headers parameters:param downloadProgress:downloadProgressBlock success:^(NSURLSessionDownloadTask * _Nonnull task, id  _Nonnull responseObject) {
                    [self handleRequestResult:task responseObject:responseObject error:nil];
                } failure:^(NSURLSessionDownloadTask * _Nonnull task, NSError * _Nonnull error) {
                    failureBlock((NSURLSessionDataTask *)task, error);
                }];
            } else {
                task = [self GET:url headers:headers parameters:param downloadProgress:downloadProgressBlock retryCount:request.retryTimes retryInterval:request.retryInterval retryProgressive:request.retryProgressive fatalStatusCodes:_configuration.fatalStatusCodes success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                    [self handleRequestResult:task responseObject:responseObject error:nil];
                } failure:failureBlock];
            }
            
            break;
        }
        case QBRequestMethodTypePost: {
            if (constructingBlock) {
                task = [self POST:url headers:headers parameters:param constructingBodyWithBlock:constructingBlock uploadProgress:uploadProgressBlock retryCount:request.retryTimes retryInterval:request.retryInterval retryProgressive:request.retryProgressive fatalStatusCodes:_configuration.fatalStatusCodes success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                    [self handleRequestResult:task responseObject:responseObject error:nil];
                } failure:failureBlock];
            } else {
                task = [self POST:url headers:headers parameters:param uploadProgress:uploadProgressBlock retryCount:request.retryTimes retryInterval:request.retryInterval retryProgressive:request.retryProgressive fatalStatusCodes:_configuration.fatalStatusCodes success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                    [self handleRequestResult:task responseObject:responseObject error:nil];
                } failure:failureBlock];
            }
            
            break;
        }
        case QBRequestMethodTypeHead: {
            task = [self HEAD:url headers:headers parameters:param retryCount:request.retryTimes retryInterval:request.retryInterval retryProgressive:request.retryProgressive fatalStatusCodes:_configuration.fatalStatusCodes success:^(NSURLSessionDataTask * _Nonnull task) {
                [self handleRequestResult:task responseObject:nil error:nil];
            } failure:failureBlock];
            
            break;
        }
        case QBRequestMethodTypePut: {
            task = [self PUT:url headers:headers parameters:param retryCount:request.retryTimes retryInterval:request.retryInterval retryProgressive:request.retryProgressive fatalStatusCodes:_configuration.fatalStatusCodes success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handleRequestResult:task responseObject:responseObject error:nil];
            } failure:failureBlock];
            
            break;
        }
        case QBRequestMethodTypePatch: {
            task = [self PATCH:url headers:headers parameters:param retryCount:request.retryTimes retryInterval:request.retryInterval retryProgressive:request.retryProgressive fatalStatusCodes:_configuration.fatalStatusCodes success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handleRequestResult:task responseObject:responseObject error:nil];
            } failure:failureBlock];
            
            break;
        }
        case QBRequestMethodTypeDelete: {
            task = [self DELETE:url headers:headers parameters:param retryCount:request.retryTimes retryInterval:request.retryInterval retryProgressive:request.retryProgressive fatalStatusCodes:_configuration.fatalStatusCodes success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handleRequestResult:task responseObject:responseObject error:nil];
            } failure:failureBlock];
            
            break;
        }
            
        default:
            break;
    }
            
    return task;
}

- (void)handleRequestResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError * _Nullable)error {
    NSString *requestCacheKey = [self requestCacheKey:task];
    QBHttpRequest *request = [self executingRequestWithKey:requestCacheKey];
    
    if (!request) {
        return;
    }
    
    request.responseObject = nil;
    request.responseString = nil;
    request.filePath = nil;
    
    if (error) {
        [self requestDidFailWithRequest:request error:error];
    } else {
        request.responseObject = responseObject;
        if ([request.responseObject isKindOfClass:[NSData class]]) {
            request.responseString = [[NSString alloc] initWithData:responseObject encoding:[self stringEncodingWithRequest:request]];
        } else if ([request.responseObject isKindOfClass:[NSURL class]]) {
            request.filePath = responseObject;
        }
        
        NSError * __autoreleasing validationError = nil;
        if ([self validateResult:request error:&validationError]) {
            [self requestDidSucceedWithRequest:request];
        } else {
            [self requestDidFailWithRequest:request error:validationError];
        }
    }
    
    [self removeExecutingRequestWithKey:requestCacheKey];
}

- (void)requestDidSucceedWithRequest:(QBHttpRequest *)request {
    QBNetworkLog(@"Request: %@ success", NSStringFromClass([request class]));
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (request.delegate != nil) {
            [request.delegate requestFinished:request];
        }
        
        if (request.successCompletionBlock) {
            request.successCompletionBlock(request);
        }
    });
}

- (void)requestDidFailWithRequest:(QBHttpRequest *)request error:(NSError *)error {
    request.error = error;
    
    QBNetworkLog(@"Request %@ failed, error code = %ld, error = %@",
                 NSStringFromClass([request class]), (long)error.code, error.localizedDescription
                 );
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (request.delegate != nil) {
            [request.delegate requestFailed:request];
        }
        
        if (request.successCompletionBlock) {
            request.failureCompletionBlock(request);
        }
    });
}

- (BOOL)validateResult:(QBHttpRequest *)request error:(NSError * _Nullable __autoreleasing *)error {
    BOOL result = [request statusCodeValidator];
    if (!result) {
        if (error) {
            *error = [NSError errorWithDomain:QBRequestValidationErrorDomain code:QBRequestValidationErrorInvalidStatusCode userInfo:@{NSLocalizedDescriptionKey:@"Invalid status code"}];
        }
        
        return result;
    }
    
    id json = nil;
    if (request.responseSerializerType == QBResponseSerializerTypeJSON) {
        json = request.responseObject;
    }

    id validator = [request jsonValidator];
    if (json && validator) {
        result = [QBNetworkUtils validateJSON:json withValidator:validator];
        if (!result) {
            if (error) {
                *error = [NSError errorWithDomain:QBRequestValidationErrorDomain code:QBRequestValidationErrorInvalidJSONFormat userInfo:@{NSLocalizedDescriptionKey:@"Invalid JSON format"}];
            }
            
            return result;
        }
    }
    
    return YES;
}

- (NSStringEncoding)stringEncodingWithRequest:(QBHttpRequest *)request {
    // From AFNetworking
    NSStringEncoding stringEncoding = NSUTF8StringEncoding;
    NSString *encodingName = [request.response.textEncodingName copy];
    if (encodingName) {
        CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)encodingName);
        if (encoding != kCFStringEncodingInvalidId) {
            stringEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
        }
    }
    
    return stringEncoding;
}

- (NSString *)requestCacheKey:(NSURLSessionTask *)task {
    if (task == nil) {
        return nil;
    }
    
    NSString *urlString = task.originalRequest.URL.absoluteString;
    NSString *Method = task.originalRequest.HTTPMethod;
    id httpBody = [[NSString alloc]initWithData:task.originalRequest.HTTPBody encoding:NSUTF8StringEncoding];
    NSString *requestInfo = [NSString stringWithFormat:@"Method:%@ Url:%@ httpBody:%@", Method, urlString, httpBody];
    
    NSString *key = [QBNetworkUtils md5StringFromString:requestInfo];
    
    return key;
}

@end
