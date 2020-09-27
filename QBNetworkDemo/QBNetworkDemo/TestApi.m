//
//  TestApi.m
//  QBNetwork
//
//  Created by 覃斌 卢    on 2020/9/16.
//  Copyright © 2020 覃斌 卢   . All rights reserved.
//

#import "TestApi.h"

@implementation TestApi

- (NSString *)requestUrl {
    return @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1600432572663&di=04bf645b2501a83a0ec905acc06d562f&imgtype=0&src=http%3A%2F%2Fyouimg1.c-ctrip.com%2Ftarget%2Ftg%2F096%2F755%2F666%2F49611e232c4646bcbfdca563a39b15ab.jpg";
}

//- (id)requestArgument {
//    return @{
//        @"id": @"9099898",
//    };
//}

- (QBRequestMethodType)requestMethodType {
    return QBRequestMethodTypeGet;
}

- (QBResponseSerializerType)responseSerializerType {
    return QBResponseSerializerTypeHTTP;
}

- (NSString *)resumableDownloadPath {
    NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cachePath = [libPath stringByAppendingPathComponent:@"Caches"];
    NSString *filePath = [cachePath stringByAppendingPathComponent:@"tempImage"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filePath]) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return filePath;
}

@end
