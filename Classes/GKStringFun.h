//
//  GKStringFun.h
//  DeviceInfo
//
//  Created by HongXing Guo on 2019/11/28.
//  Copyright © 2019 HongXing Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKStringFun : NSObject
+(NSString *)simpleStringEncryptInput:(NSString *)input uid:(int)uid isEncode:(BOOL)isencode;
@end

NS_ASSUME_NONNULL_END
