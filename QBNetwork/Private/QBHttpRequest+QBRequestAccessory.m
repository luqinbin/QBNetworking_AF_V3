//
//  QBHttpRequest+QBRequestAccessory.m
//  QBNetwork
//
//  Created by 覃斌 卢    on 2020/9/21.
//  Copyright © 2020 覃斌 卢   . All rights reserved.
//

#import "QBHttpRequest+QBRequestAccessory.h"

@implementation QBHttpRequest (QBRequestAccessory)

- (void)toggleAccessoriesWillStartCallBack {
    for (id<QBRequestAccessory> accessory in self.requestAccessories) {
        if ([accessory respondsToSelector:@selector(requestWillStart:)]) {
            [accessory requestWillStart:self];
        }
    }
}

- (void)toggleAccessoriesWillStopCallBack {
    for (id<QBRequestAccessory> accessory in self.requestAccessories) {
        if ([accessory respondsToSelector:@selector(requestWillStop:)]) {
            [accessory requestWillStop:self];
        }
    }
}

- (void)toggleAccessoriesDidStopCallBack {
    for (id<QBRequestAccessory> accessory in self.requestAccessories) {
        if ([accessory respondsToSelector:@selector(requestDidStop:)]) {
            [accessory requestDidStop:self];
        }
    }
}

@end
