//
//  QBNetworkManager+QBRetryPolicy.m
//  QBNetwork
//
//  Created by 覃斌 卢    on 2020/9/16.
//  Copyright © 2020 覃斌 卢   . All rights reserved.
//

#import "QBNetworkManager+QBRetryPolicy.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "QBNetworkUtils.h"

@implementation QBNetworkManager (QBRetryPolicy)

#pragma mark - Public
- (NSURLSessionDataTask *)GET:(NSString *)URLString
                      headers:(nullable NSDictionary<NSString *,NSString *> *)headers
                   parameters:(id)parameters
             downloadProgress:(QBURLSessionTaskProgressBlock)downloadProgress
                   retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval
             retryProgressive:(BOOL)retryProgressive
             fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSURLSessionDataTask *task = [self requestWithRetryRemaining:retryCount maxRetry:retryCount retryInterval:retryInterval retryProgressive:retryProgressive fatalStatusCodes:fatalStatusCodes originalRequestCreator:^NSURLSessionDataTask *(void (^retryBlock)(NSURLSessionDataTask *, NSError *)) {
        return [self.manager GET:URLString parameters:parameters headers:headers progress:downloadProgress success:success failure:retryBlock];
    } originalFailure:failure];
    
    return task;
}

- (NSURLSessionDataTask *)POST:(NSString * _Nonnull)URLString
                      headers:(nullable NSDictionary<NSString *,NSString *> *)headers
                   parameters:(id _Nullable)parameters
               uploadProgress:(QBURLSessionTaskProgressBlock)uploadProgress
                   retryCount:(NSInteger)retryCount
                retryInterval:(NSTimeInterval)retryInterval
             retryProgressive:(BOOL)retryProgressive
             fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSURLSessionDataTask *task = [self requestWithRetryRemaining:retryCount maxRetry:retryCount retryInterval:retryInterval retryProgressive:retryProgressive fatalStatusCodes:fatalStatusCodes originalRequestCreator:^NSURLSessionDataTask *(void (^retryBlock)(NSURLSessionDataTask *, NSError *)) {
        return [self.manager POST:URLString
                       parameters:parameters
                          headers:headers
                         progress:uploadProgress
                          success:success
                          failure:retryBlock];
    } originalFailure:failure];
    
    return task;
}

- (NSURLSessionDataTask *)POST:(NSString * _Nonnull)URLString
                       headers:(nullable NSDictionary<NSString *,NSString *> *)headers
                    parameters:(id _Nullable)parameters
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))constructingBodyBlock
                uploadProgress:(QBURLSessionTaskProgressBlock)uploadProgress
                    retryCount:(NSInteger)retryCount
                 retryInterval:(NSTimeInterval)retryInterval
              retryProgressive:(BOOL)retryProgressive
              fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes
                       success:(void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSURLSessionDataTask *task = [self requestWithRetryRemaining:retryCount maxRetry:retryCount retryInterval:retryInterval retryProgressive:retryProgressive fatalStatusCodes:fatalStatusCodes originalRequestCreator:^NSURLSessionDataTask *(void (^retryBlock)(NSURLSessionDataTask *, NSError *)) {
        return [self.manager POST:URLString
                       parameters:parameters
                          headers:headers
        constructingBodyWithBlock:constructingBodyBlock
                         progress:uploadProgress
                          success:success
                          failure:retryBlock];
    } originalFailure:failure];
    
    return task;
}

- (NSURLSessionDataTask *)HEAD:(NSString *)URLString
                       headers:(nullable NSDictionary<NSString *,NSString *> *)headers
                    parameters:(id)parameters
                    retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval
              retryProgressive:(BOOL)retryProgressive
              fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes
                       success:(nullable void (^)(NSURLSessionDataTask * _Nonnull task))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSURLSessionDataTask *task = [self requestWithRetryRemaining:retryCount maxRetry:retryCount retryInterval:retryInterval retryProgressive:retryProgressive fatalStatusCodes:fatalStatusCodes originalRequestCreator:^NSURLSessionDataTask *(void (^retryBlock)(NSURLSessionDataTask *, NSError *)) {
        return [self.manager HEAD:URLString
                       parameters:parameters
                          headers:headers
                          success:success
                          failure:retryBlock];
    } originalFailure:failure];
    
    return task;
}

- (NSURLSessionDataTask *)PUT:(NSString *)URLString
                      headers:(nullable NSDictionary<NSString *,NSString *> *)headers
                   parameters:(id)parameters
                   retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval
             retryProgressive:(BOOL)retryProgressive
             fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes
                      success:(void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSURLSessionDataTask *task = [self requestWithRetryRemaining:retryCount maxRetry:retryCount retryInterval:retryInterval retryProgressive:retryProgressive fatalStatusCodes:fatalStatusCodes originalRequestCreator:^NSURLSessionDataTask *(void (^retryBlock)(NSURLSessionDataTask *, NSError *)) {
        return [self.manager PUT:URLString
                       parameters:parameters
                          headers:headers
                          success:success
                          failure:retryBlock];
    } originalFailure:failure];
    
    return task;
}

- (NSURLSessionDataTask *)PATCH:(NSString *)URLString
                        headers:(nullable NSDictionary<NSString *,NSString *> *)headers
                     parameters:(id)parameters
                     retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval
               retryProgressive:(BOOL)retryProgressive
               fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes
                        success:(void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject))success
                        failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSURLSessionDataTask *task = [self requestWithRetryRemaining:retryCount maxRetry:retryCount retryInterval:retryInterval retryProgressive:retryProgressive fatalStatusCodes:fatalStatusCodes originalRequestCreator:^NSURLSessionDataTask *(void (^retryBlock)(NSURLSessionDataTask *, NSError *)) {
        return [self.manager PATCH:URLString
                        parameters:parameters
                           headers:headers
                           success:success
                           failure:retryBlock];
    } originalFailure:failure];
    
    return task;
}

- (NSURLSessionDataTask *)DELETE:(NSString *)URLString
                         headers:(nullable NSDictionary<NSString *,NSString *> *)headers
                      parameters:(id)parameters
                      retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval
                retryProgressive:(BOOL)retryProgressive
                fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes
                         success:(void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject))success
                         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSURLSessionDataTask *task = [self requestWithRetryRemaining:retryCount maxRetry:retryCount retryInterval:retryInterval retryProgressive:retryProgressive fatalStatusCodes:fatalStatusCodes originalRequestCreator:^NSURLSessionDataTask *(void (^retryBlock)(NSURLSessionDataTask *, NSError *)) {
        return [self.manager DELETE:URLString
                         parameters:parameters
                            headers:headers
                            success:success
                            failure:retryBlock];
    } originalFailure:failure];
    
    return task;
}


#pragma mark - Private
- (NSURLSessionDataTask *)requestWithRetryRemaining:(NSInteger)retryRemaining
                                           maxRetry:(NSInteger)maxRetry
                                      retryInterval:(NSTimeInterval)retryInterval
                                   retryProgressive:(BOOL)retryProgressive
                                   fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes
                             originalRequestCreator:(NSURLSessionDataTask *(^)(void (^)(NSURLSessionDataTask *, NSError *)))taskCreator
                                    originalFailure:(void(^)(NSURLSessionDataTask *task, NSError *))failure {
    void(^retryBlock)(NSURLSessionDataTask *, NSError *) = ^(NSURLSessionDataTask *task, NSError *error) {
        if ([QBNetworkUtils isErrorFatal:error]) {
            QBNetworkLog(@"Request failed with fatal error: %@ - Will not try again!", error.localizedDescription);
            failure(task, error);
            
            return;
        }

        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        for (NSNumber *fatalStatusCode in fatalStatusCodes) {
            if (response.statusCode == fatalStatusCode.integerValue) {
                QBNetworkLog(@"Request failed with fatal error: %@ - Will not try again!", error.localizedDescription);
                failure(task, error);
                
                return;
            }
        }

        QBNetworkLog(@"Request failed: %@, %ld attempt/s left", error.localizedDescription, retryRemaining);
        
        if (retryRemaining > 0) {
            void (^addRetryOperation)(void) = ^{
                [self requestWithRetryRemaining:retryRemaining - 1
                                       maxRetry:maxRetry
                                  retryInterval:retryInterval
                               retryProgressive:retryProgressive
                               fatalStatusCodes:fatalStatusCodes
                         originalRequestCreator:taskCreator
                                originalFailure:failure];
            };
            
            if (retryInterval > 0.0) {
                dispatch_time_t delay;
                if (retryProgressive) {
                    delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(retryInterval * pow(2, maxRetry - retryRemaining) * NSEC_PER_SEC));
                    QBNetworkLog(@"Delaying the next attempt by %.0f seconds …", retryInterval * pow(2, maxRetry - retryRemaining));
                } else {
                    delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(retryInterval * NSEC_PER_SEC));
                    QBNetworkLog(@"Delaying the next attempt by %.0f seconds …", retryInterval);
                }

                dispatch_after(delay, dispatch_get_main_queue(), ^(void){
                    addRetryOperation();
                });
            } else {
                addRetryOperation();
            }

        } else {
            QBNetworkLog(@"No more attempts left! Will execute the failure block.");
            failure(task, error);
        }
    };
    
    NSURLSessionDataTask *task = taskCreator(retryBlock);
    
    return task;
}

@end
