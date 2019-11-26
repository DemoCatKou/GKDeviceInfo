//
//  KGDeviceInfo.h
//  DeviceInfo
//
//  Created by HongXing Guo on 2019/11/22.
//  Copyright © 2019 HongXing Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, KGNetWorkStatus) {
    KGNetWorkStatusNotReachable = 0,
    KGNetWorkStatusUnknown = 1,
    KGNetWorkStatusWWAN2G = 2,
    KGNetWorkStatusWWAN3G = 3,
    KGNetWorkStatusWWAN4G = 4,
    
    KGNetWorkStatusWiFi = 9,
};

@interface KGDeviceInfo : NSObject

+(NSString *)currentApplicationVersion;
+(NSString *)currentBundleIdentifier;
+(NSString *)deviceName;
+(NSString *)deviceModel;
+(NSString *)systemVersion;
+(NSString *)language; //first of preferred Languages
+(NSString *)currentCountry;
+(NSString *)screenSize;


-(BOOL)locationAuthorize;
-(void)requestLocation;
//网络 location

@end

NS_ASSUME_NONNULL_END
