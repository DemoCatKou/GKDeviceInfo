//
//  KGDeviceInfo.h
//  DeviceInfo
//
//  Created by HongXing Guo on 2019/11/22.
//  Copyright © 2019 HongXing Guo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, GKNetWorkStatus) {
    GKNetWorkStatusNotReachable = 0,
    GKNetWorkStatusUnknown = 1,
    GKNetWorkStatusWWAN2G = 2,
    GKNetWorkStatusWWAN3G = 3,
    GKNetWorkStatusWWAN4G = 4,
    
    GKNetWorkStatusWiFi = 9,
};
typedef void(^complateDictionary)(NSDictionary *dic);
typedef void(^complateString)(NSString *str);
@class GKDeviceInfo;
@protocol GKDeviceInfoDelegate <NSObject>

@optional
-(void)deviceInfoDidChange:(GKDeviceInfo *)info;

@end

@interface GKDeviceInfo : NSObject

@property(weak, nonatomic) id<GKDeviceInfoDelegate> delegate;

+ (NSString *)currentApplicationVersion;
+ (NSString *)currentBundleIdentifier;
+ (NSString *)deviceName;
+ (NSString *)deviceModel;
+ (NSString *)systemVersion;
+ (NSString *)language; //first of preferred Languages
+ (NSString *)currentCountry;
+ (CGSize)screenSize;

#pragma mark - IDFV
+(NSString *)deviceIDFV;

#pragma mark - IDFA
+ (BOOL)idfaIsOpen;
+ (NSString *)deviceIDFA;

#pragma mark - SIM
+ (BOOL)isSIMInstalled;
/**
 *@result @{"carrier_name":"", @"mcc":@"", @"mnc",@"country_code":ISO 3166-1}
 */
+ (NSDictionary *)mobileNetworkInfo;

#pragma mark - VPN Check
+ (NSDictionary *)getProxyStatus;

#pragma mark - WIFI Info
// ....
+ (NSDictionary *)wifiInfo;

#pragma mark -
- (CGFloat)systemVolume;
+ (CGFloat)systemBrightness;
#pragma mark - LOCATION
// ....
- (BOOL)locationAuthorize;
- (void)requestLocation;

- (void)allDeviceInfo:(complateDictionary)complate;
- (void)allDeviceInfoJson:(complateString)complate;

#pragma mark - DEVICE STATUS
+ (BOOL)isJailBroken;
+ (BOOL)isDebugModle;

@end

NS_ASSUME_NONNULL_END
