//
//  QBProtobufRequestSerializer.m
//  QBNetwork
//
//  Created by 覃斌 卢    on 2020/9/15.
//  Copyright © 2020 覃斌 卢   . All rights reserved.
//

#import "QBProtobufRequestSerializer.h"

@implementation QBProtobufRequestSerializer

+ (instancetype)serializer {
    QBProtobufRequestSerializer *serializer = [[self alloc] init];
    return serializer;
}

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               withParameters:(id)parameters
                                        error:(NSError *__autoreleasing *)error {
    NSParameterAssert(request);
    
    if ([self.HTTPMethodsEncodingParametersInURI containsObject:[[request HTTPMethod] uppercaseString]]) {
        return [super requestBySerializingRequest:request withParameters:parameters error:error];
    }
    
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    
    [self.HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
        if (![request valueForHTTPHeaderField:field]) {
            [mutableRequest setValue:value forHTTPHeaderField:field];
        }
    }];
    
    if (parameters) {
        if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
            [mutableRequest setValue:@"application/x-protobuf" forHTTPHeaderField:@"Content-Type"];
        }
        
        if (!parameters) {
            return nil;
        }
        
        [mutableRequest setHTTPBody:((NSData *)parameters)];
    }
    
    return mutableRequest;
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    QBProtobufRequestSerializer *serializer = [super copyWithZone:zone];
    return serializer;
}

@end
