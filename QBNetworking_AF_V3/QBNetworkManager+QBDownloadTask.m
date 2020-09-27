//
//  QBNetworkManager+QBDownloadTask.m
//  QBNetwork
//
//  Created by 覃斌 卢    on 2020/9/18.
//  Copyright © 2020 覃斌 卢   . All rights reserved.
//

#import "QBNetworkManager+QBDownloadTask.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "QBNetworkUtils.h"

#define QBNetworkIncompleteDownloadFolderName @"QBNetworkDownloadIncomplete"

@implementation QBNetworkManager (QBDownloadTask)

- (NSURLSessionDownloadTask *)downloadTaskWithDownloadPath:(NSString *)downloadPath
                                                 URLString:(NSString *)URLString
                                                   headers:(nullable NSDictionary<NSString *,NSString *> *)headers
                                                parameters:(id)parameters
                                          downloadProgress:(QBURLSessionTaskProgressBlock)downloadProgress
                                                   success:(void (^)(NSURLSessionDownloadTask *task, id responseObject))success
                                                   failure:(void (^)(NSURLSessionDownloadTask *task, NSError *error))failure {
    NSError * __autoreleasing requestSerializationError = nil;
    
    if (headers != nil) {
        for (NSString *httpHeaderField in headers.allKeys) {
            NSString *value = headers[httpHeaderField];
            [self.manager.requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
        }
    }
    
    NSMutableURLRequest *urlRequest = [self.manager.requestSerializer requestWithMethod:@"GET" URLString:URLString parameters:parameters error:&requestSerializationError];
    
    if (requestSerializationError) {
        if (failure) {
            failure(nil, requestSerializationError);
            
            return nil;
        }
    }
    
    NSString *downloadTargetPath;
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:downloadPath isDirectory:&isDirectory]) {
        isDirectory = NO;
    }
    
    if (isDirectory) {
        NSString *fileName = [urlRequest.URL lastPathComponent];
        downloadTargetPath = [NSString pathWithComponents:@[downloadPath, fileName]];
    } else {
        downloadTargetPath = downloadPath;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadTargetPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:downloadTargetPath error:nil];
    }
    
    BOOL resumeSucceeded = NO;
    __block NSURLSessionDownloadTask *downloadTask = nil;
    NSURL *localUrl = [self incompleteDownloadTempPathForDownloadPath:downloadPath];
    if (localUrl != nil) {
        BOOL resumeDataFileExists = [[NSFileManager defaultManager] fileExistsAtPath:localUrl.path];
        NSData *data = [NSData dataWithContentsOfURL:localUrl];
        BOOL resumeDataIsValid = [QBNetworkUtils validateResumeData:data];

        BOOL canBeResumed = resumeDataFileExists && resumeDataIsValid;\
        if (canBeResumed) {
            @try {
                downloadTask = [self.manager downloadTaskWithResumeData:data progress:downloadProgress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                    return [NSURL fileURLWithPath:downloadTargetPath isDirectory:NO];
                } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                    if (!error) {
                        !success ?: success(downloadTask, filePath);
                    } else {
                        !failure ?: failure(downloadTask, error);
                    }
                }];
                resumeSucceeded = YES;
            } @catch (NSException *exception) {
                QBNetworkLog(@"Resume download failed, reason = %@", exception.reason);
                resumeSucceeded = NO;
            }
        }
    }
    
    if (!resumeSucceeded) {
        downloadTask = [self.manager downloadTaskWithRequest:urlRequest progress:downloadProgress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:downloadTargetPath isDirectory:NO];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            if (!error) {
                !success ?: success(downloadTask, filePath);
            } else {
                !failure ?: failure(downloadTask, error);
            }
        }];
    }
    
    return downloadTask;
}

#pragma mark - Resumable Download
- (NSString *)incompleteDownloadTempCacheFolder {
    NSFileManager *fileManager = [NSFileManager new];
    NSString *cacheFolder = [NSTemporaryDirectory() stringByAppendingPathComponent:QBNetworkIncompleteDownloadFolderName];

    BOOL isDirectory = NO;
    if ([fileManager fileExistsAtPath:cacheFolder isDirectory:&isDirectory] && isDirectory) {
        return cacheFolder;
    }
    NSError *error = nil;
    if ([fileManager createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error] && error == nil) {
        return cacheFolder;
    }
    QBNetworkLog(@"Failed to create cache directory at %@ with error: %@", cacheFolder, error != nil ? error.localizedDescription : @"unkown");
    return nil;
}

- (NSURL *)incompleteDownloadTempPathForDownloadPath:(NSString *)downloadPath {
    if (downloadPath == nil || downloadPath.length == 0) {
        return nil;
    }
    NSString *tempPath = nil;
    NSString *md5URLString = [QBNetworkUtils md5StringFromString:downloadPath];
    tempPath = [[self incompleteDownloadTempCacheFolder] stringByAppendingPathComponent:md5URLString];
    return tempPath == nil ? nil : [NSURL fileURLWithPath:tempPath];
}

@end
