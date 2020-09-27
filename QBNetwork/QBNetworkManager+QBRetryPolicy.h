//
//  QBNetworkManager+QBRetryPolicy.h
//  QBNetwork
//
//  Created by 覃斌 卢    on 2020/9/16.
//  Copyright © 2020 覃斌 卢   . All rights reserved.
//

#import "QBNetworkManager.h"
#import "QBNetworkConstants.h"

@protocol AFMultipartFormData;

NS_ASSUME_NONNULL_BEGIN

@interface QBNetworkManager (QBRetryPolicy)

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                      headers:(nullable NSDictionary<NSString *,NSString *> *)headers
                   parameters:(id)parameters
             downloadProgress:(QBURLSessionTaskProgressBlock)downloadProgress
                   retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval
             retryProgressive:(BOOL)retryProgressive
             fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask *)POST:(NSString * _Nonnull)URLString
                  headers:(nullable NSDictionary<NSString *,NSString *> *)headers
               parameters:(id _Nullable)parameters
           uploadProgress:(QBURLSessionTaskProgressBlock)uploadProgress
               retryCount:(NSInteger)retryCount
            retryInterval:(NSTimeInterval)retryInterval
         retryProgressive:(BOOL)retryProgressive
         fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes
                  success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                  failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask *)POST:(NSString * _Nonnull)URLString
                       headers:(nullable NSDictionary<NSString *,NSString *> *)headers
                    parameters:(id _Nullable)parameters
     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))constructingBodyBlock
                uploadProgress:(QBURLSessionTaskProgressBlock)uploadProgress
                    retryCount:(NSInteger)retryCount
                 retryInterval:(NSTimeInterval)retryInterval
              retryProgressive:(BOOL)retryProgressive
              fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask *)HEAD:(NSString *)URLString
                       headers:(nullable NSDictionary<NSString *,NSString *> *)headers
                    parameters:(id)parameters
                    retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval
              retryProgressive:(BOOL)retryProgressive
              fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes
                       success:(nullable void (^)(NSURLSessionDataTask * _Nonnull task))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask *)PUT:(NSString *)URLString
                      headers:(nullable NSDictionary<NSString *,NSString *> *)headers
                   parameters:(id)parameters
                   retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval
             retryProgressive:(BOOL)retryProgressive
             fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes
                      success:(void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask *)PATCH:(NSString *)URLString
                        headers:(nullable NSDictionary<NSString *,NSString *> *)headers
                     parameters:(id)parameters
                     retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval
               retryProgressive:(BOOL)retryProgressive
               fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes
                        success:(void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject))success
                        failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask *)DELETE:(NSString *)URLString
                         headers:(nullable NSDictionary<NSString *,NSString *> *)headers
                      parameters:(id)parameters
                      retryCount:(NSInteger)retryCount retryInterval:(NSTimeInterval)retryInterval
                retryProgressive:(BOOL)retryProgressive
                fatalStatusCodes:(NSArray<NSNumber *> *)fatalStatusCodes
                         success:(void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject))success
                         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;


@end

NS_ASSUME_NONNULL_END
