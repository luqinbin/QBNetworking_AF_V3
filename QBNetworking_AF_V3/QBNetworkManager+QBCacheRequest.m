//
//  QBNetworkManager+QBCacheRequest.m
//  QBNetwork
//
//  Created by 覃斌 卢    on 2020/9/17.
//  Copyright © 2020 覃斌 卢   . All rights reserved.
//

#import "QBNetworkManager+QBCacheRequest.h"
#import "QBHttpRequest.h"

static char cacheRequestsKey;

typedef NSMapTable<NSString *, QBHttpRequest *> QBCacheExecutingRequests;

@implementation QBNetworkManager (QBCacheRequest)

- (QBCacheExecutingRequests *)executingRequests {
    @synchronized(self) {
        QBCacheExecutingRequests *requests = objc_getAssociatedObject(self, &cacheRequestsKey);
        if (requests) {
            return requests;
        }
        
        requests = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory capacity:1];
        objc_setAssociatedObject(self, &cacheRequestsKey, requests, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        return requests;
    }
}

- (NSArray<QBHttpRequest *> *)allExecutingRequests {
    QBCacheExecutingRequests *requests = [self executingRequests];
    NSArray *array = nil;
    @synchronized(self) {
        NSEnumerator *enumerator = [requests keyEnumerator];
        array = enumerator.allObjects;
    }
    
    return array;
}

- (QBHttpRequest *)executingRequestWithKey:(NSString *)key {
    QBHttpRequest *request = nil;
    
    if (key) {
        QBCacheExecutingRequests *requests = [self executingRequests];
        @synchronized(self) {
            request = [requests objectForKey:key];
        }
    }
    
    return request;
}

- (void)addExecutingRequest:(QBHttpRequest *)request forKey:(NSString *)key repeatCancel:(BOOL)repeatCancel {
    if (key) {
        if (repeatCancel) {
            /// cancel上一次NSURLSessionDataTask
            [self cancelExecutingRequestWithKey:key];
        }
        
        if (request) {
            QBCacheExecutingRequests *requests = [self executingRequests];
            @synchronized(self) {
                [requests setObject:request forKey:key];
            }
        }
    }
}

- (void)cancelExecutingRequestWithKey:(NSString *)key {
    QBCacheExecutingRequests *requests = [self executingRequests];
    QBHttpRequest *request;
    
    @synchronized(self) {
        request = [requests objectForKey:key];
    }
    
    if (request) {
        [request.requestTask cancel];
    }
}

- (void)removeExecutingRequestWithKey:(NSString *)key {
    if (key) {
        QBCacheExecutingRequests *requests = [self executingRequests];
        @synchronized(self) {
            [requests removeObjectForKey:key];
        }
    }
}

@end
