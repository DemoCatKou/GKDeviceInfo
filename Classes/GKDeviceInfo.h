//
//  KGDeviceInfo.h
//  DeviceInfo
//
//  Created by HongXing Guo on 2019/11/22.
//  Copyright © 2019 HongXing Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, GKNetWorkStatus) {
    GKNetWorkStatusNotReachable = 0,
    GKNetWorkStatusUnknown = 1,
    GKNetWorkStatusWWAN2G = 2,
    GKNetWorkStatusWWAN3G = 3,
    GKNetWorkStatusWWAN4G = 4,
    
    GKNetWorkStatusWiFi = 9,
};

@interface GKDeviceInfo : NSObject

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
