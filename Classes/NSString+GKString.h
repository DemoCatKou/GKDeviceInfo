//
//  NSString+GKString.h
//  DeviceInfo
//
//  Created by HongXing Guo on 2019/11/28.
//  Copyright © 2019 HongXing Guo. All rights reserved.
//

#import <UIKit/UIKit.h>


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (GKString)

- (NSString *)urlEncode;
- (NSString *)urlDecode;
@end

NS_ASSUME_NONNULL_END
