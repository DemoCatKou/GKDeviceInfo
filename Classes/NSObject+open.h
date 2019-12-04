//
//  NSObject+open.h
//  DeviceInfo
//
//  Created by HongXing Guo on 2019/12/3.
//  Copyright © 2019 HongXing Guo. All rights reserved.
//
//
//#import <AppKit/AppKit.h>


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (open)

- (id )bql_invoke:(NSString *)selector;
- (id )bql_invoke:(NSString *)selector arguments:(NSArray *)arguments;
- (id )bql_invokeMethod:(NSString *)selector;
- (id )bql_invokeMethod:(NSString *)selector arguments:(NSArray *)arguments;

@end

NS_ASSUME_NONNULL_END
