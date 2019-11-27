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

#pragma mark - IDFV
+(NSString *)deviceIDFV;

#pragma mark - IDFA
+(BOOL)idfaIsOpen;
+(NSString *)deviceIDFA;

#pragma makr - SIM
+(BOOL)isSIMInstalled;
/**
 *@result @{"carrier_name":"", @"mcc":@"", @"mnc",@"country_code":ISO 3166-1}
 */
+(NSDictionary *)mobileNetworkInfo;



-(NSDictionary *)allDeviceInfo;

-(NSString *)allDeviceInfoJson;
@end

NS_ASSUME_NONNULL_END
