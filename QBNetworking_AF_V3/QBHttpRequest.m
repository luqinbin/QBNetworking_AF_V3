//
//  QBHttpRequest.m
//  QBNetwork
//
//  Created by 覃斌 卢    on 2020/9/15.
//  Copyright © 2020 覃斌 卢   . All rights reserved.
//

#import "QBHttpRequest.h"
#import "QBNetworkManager.h"

@interface QBHttpRequest ()

@property (strong, nonatomic) QBNetworkConfiguration *configuration;
@property (strong, nonatomic) QBNetworkManager *networkManager;

@end

@implementation QBHttpRequest

#pragma mark - Constructor
- (instancetype)init {
    self = [super init];
    if (self) {
        _networkManager = [QBNetworkManager sharedInstance];
        _configuration = _networkManager.configuration;
        _requestAccessories = [NSMutableArray arrayWithCapacity:1];
        
        [self defaultSetup];
    }
    
    return self;
}

#pragma mark - SubClass Override
- (id)jsonValidator {
    return nil;
}

- (void)requestCompletePreprocessor {
  //
};

- (void)requestFailedPreprocessor {
    //
}

#pragma mark - Public
- (BOOL)statusCodeValidator {
    NSInteger statusCode = [self responseStatusCode];
    return (statusCode >= 200 && statusCode <= 299);
}

- (void)setCompletionBlockWithSuccess:(QBRequestCompletionBlock)success
                              failure:(QBRequestCompletionBlock)failure {
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}

- (void)addAccessory:(id<QBRequestAccessory>)accessory {
    if (!self.requestAccessories) {
        self.requestAccessories = [NSMutableArray array];
    }
    
    [self.requestAccessories addObject:accessory];
}

#pragma mark - Request Action

- (void)start {
    [_networkManager addRequest:self];
}

- (void)stop {
    [_networkManager cancelRequest:self];
}

- (void)startWithSuccess:(QBRequestCompletionBlock)success
                 failure:(QBRequestCompletionBlock)failure {
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self start];
}

#pragma mark - Request and Response Information
- (NSHTTPURLResponse *)response {
    return (NSHTTPURLResponse *)self.requestTask.response;
}

- (NSInteger)responseStatusCode {
    return self.response.statusCode;
}

- (NSDictionary *)responseHeaders {
    return self.response.allHeaderFields;
}

- (NSURLRequest *)currentRequest {
    return self.requestTask.currentRequest;
}

- (NSURLRequest *)originalRequest {
    return self.requestTask.originalRequest;
}

- (BOOL)isExecuting {
    if (!self.requestTask) {
        return NO;
    }
    return self.requestTask.state == NSURLSessionTaskStateRunning;
}

#pragma mark - Private
- (void)defaultSetup {
    _baseUrl = _configuration.baseUrl;
    _cdnUrl = _configuration.cdnUrl;
    _sessionConfiguration = _configuration.sessionConfiguration;
    _securityPolicy = _configuration.securityPolicy;
    _requestMethodType = QBRequestMethodTypeGet;
    _requestSerializerType = _configuration.requestSerializerType;
    _responseSerializerType = _configuration.responseSerializerType;
    _requestAuthorizationHeaderFieldArray = _configuration.requestAuthorizationHeaderFieldArray;
    _requestHeaderFieldValueDictionary = _configuration.requestHeaderFieldValueDictionary;
    _requestPriority = QBRequestPriorityDefault;
    _requestTimeoutInterval = _configuration.requestTimeoutInterval;
    _retryTimes = _configuration.retryTimes;
    _retryInterval = _configuration.retryInterval;
    _retryProgressive = _configuration.retryProgressive;
    _useCDN = NO;
    _allowsCellularAccess = YES;
}

@end
