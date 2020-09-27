//
//  QBNetworkUtils.h
//  QBNetwork
//
//  Created by 覃斌 卢    on 2020/9/16.
//  Copyright © 2020 覃斌 卢   . All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT void QBNetworkLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

@interface QBNetworkUtils : NSObject

+ (NSString *)md5StringFromString:(NSString *)string;

+ (BOOL)validateJSON:(id)json withValidator:(id)jsonValidator;

+ (BOOL)validateResumeData:(NSData *)data;

+ (BOOL)isErrorFatal:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
