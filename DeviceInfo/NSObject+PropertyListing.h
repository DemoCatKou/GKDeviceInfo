//
//  NSObject+PropertyListing.h
//  DeviceInfo
//
//  Created by HongXing Guo on 2019/12/5.
//  Copyright © 2019 HongXing Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (PropertyListing)
- (NSArray *)getAllProperties;
- (NSDictionary *)properties_aps;
-(void)printMothList;
@end

NS_ASSUME_NONNULL_END
