//
//  QBNetworkManager+QBDownloadTask.h
//  QBNetwork
//
//  Created by 覃斌 卢    on 2020/9/18.
//  Copyright © 2020 覃斌 卢   . All rights reserved.
//

#import "QBNetworkManager.h"
#import "QBNetworkConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface QBNetworkManager (QBDownloadTask)

- (NSURLSessionDownloadTask *)downloadTaskWithDownloadPath:(NSString *)downloadPath
                                                 URLString:(NSString *)URLString
                                                   headers:(nullable NSDictionary<NSString *,NSString *> *)headers
                                                parameters:(id)parameters
                                          downloadProgress:(QBURLSessionTaskProgressBlock)downloadProgress
                                                   success:(void (^)(NSURLSessionDownloadTask *task, id responseObject))success
                                                   failure:(void (^)(NSURLSessionDownloadTask *task, NSError *error))failure;


#pragma mark - Resumable Download
- (NSString *)incompleteDownloadTempCacheFolder;
- (NSURL *)incompleteDownloadTempPathForDownloadPath:(NSString *)downloadPath;

@end

NS_ASSUME_NONNULL_END
