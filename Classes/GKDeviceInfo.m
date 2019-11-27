//
//  KGDeviceInfo.m
//  DeviceInfo
//
//  Created by HongXing Guo on 2019/11/22.
//  Copyright © 2019 HongXing Guo. All rights reserved.
//

#import "GKDeviceInfo.h"

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AdSupport/AdSupport.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import "UIDevice+Hardware.h"
#import "HLNetWorkReachability.h"

@interface GKDeviceInfo()<CLLocationManagerDelegate>

@end

@implementation GKDeviceInfo
{
    HLNetWorkReachability *reachability;
    GKNetWorkStatus netWorkStatus;
    NSString *netWorkStatusName;
    CLLocationManager *locationManager;
    NSString *lat;
    NSString *lon;
}
-(instancetype)init {
    self = [super init];
    if (self) {
        netWorkStatusName = @"";
        lat = @"";
        lon = @"";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kNetWorkReachabilityChangedNotification object:nil];
        reachability = [HLNetWorkReachability reachabilityWithHostName:@"www.baidu.com"];
        [reachability startNotifier];
    }
    return self;
}

+(NSString *)currentApplicationVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+(NSString *)currentBundleIdentifier {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

+(NSString *)deviceName {
    return [[UIDevice currentDevice] name];
}

+(NSString *)deviceModel {
    NSString *model = [[UIDevice currentDevice] model];
    NSString *platformString = [UIDevice currentDevice].platformString;
    if (platformString == nil) {
        return model;
    } else {
        return platformString;
    }
}

+(NSString *)systemVersion {
    NSString *name = [[UIDevice currentDevice] systemName];
    NSString *version = [[UIDevice currentDevice] systemVersion];
    return [NSString stringWithFormat:@"%@%@", name, version];
}

+(NSString *)language {
    NSArray *languages = [NSLocale preferredLanguages];
//    CLog(@"preferredLanguages %@", languages.description); //首选语言顺序
//
//    NSArray *arrayLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
//    CLog(@"AppleLanguages %@", arrayLanguages.description);
//
//    NSString *nsLang_1 = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"]  objectAtIndex:0];
//    CLog(@"AppleLanguages %@", nsLang_1); //语言地区？zh-Hans-CN
//
//    NSString *nsLang  = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
//    CLog(@"NSLocaleLanguageCode %@", nsLang); //语言？？？？？？？ //en
//
//    NSString *country = [[NSLocale currentLocale] localeIdentifier];
//    CLog(@"country %@", country); //en_CN
//
//    NSString *nsCountry  = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
//    CLog(@"country %@", nsCountry); // CN
    if (languages.count > 0) {
        return languages.firstObject;
    } else {
        return @"";
    }
}

+(NSString *)currentCountry {
    NSString *nsCountry  = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    return nsCountry;
}

+(NSString *)screenSize {
    CGSize size = [[UIScreen mainScreen] currentMode].size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    return [NSString stringWithFormat:@"%.0f×%.0f", width, height];
}

+(NSString *) otherInfo {
    UIDevice *device = [UIDevice currentDevice];
    NSUInteger cpuFrequency = [device cpuFrequency];
    NSUInteger busFrequency = [device busFrequency];
    NSUInteger cpuCount = [device cpuCount];
    NSUInteger totalMemory = [device totalMemory]; //18446744073350529024
    NSUInteger userMemory = [device userMemory];   //18446744072416428032
    NSNumber *totalDiskSpace = [device totalDiskSpace]; //63921311744
    NSNumber *freeDiskSpace = [device freeDiskSpace];   //9439830016
    NSString *mac = [device macAddress];
    NSString *ip = [device ipAddresses];
    
    NSString *str = [NSString stringWithFormat:@"cupFrequency:%lu busFrequency:%lu count:%lu \nmemory:%lu/%lu, disk:%lu/%lu\nmac:%@ ip:%@", (unsigned long)cpuFrequency, busFrequency, cpuCount, userMemory, totalMemory, freeDiskSpace.unsignedIntegerValue, totalDiskSpace.unsignedIntegerValue, mac, ip];
    return str;
}

#pragma mark - location
-(void)requestLocation {
    if ([self locationAuthorize]) {
        [self managerStartLocation];
    } else {
        [self locationPermissionCheck];
    }
}
-(BOOL)locationAuthorize {
    if (![CLLocationManager locationServicesEnabled]) {
        return NO;
    }
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted) {
        lat = @"0";
        lon = @"0";
        return NO;
    }
    return YES;
}

-(void)locationPermissionCheck {
    locationManager = [[CLLocationManager alloc] init];
//    [locationManager requestAlwaysAuthorization];
    [locationManager requestWhenInUseAuthorization];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 20;
}

-(void)managerStartLocation {
    [locationManager requestLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
//        CLog(@"定位权限未开启");
        lat = @"0";
        lon = @"0";
    } else {
        [self managerStartLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    for (CLLocation *location in locations) {
//        CLog(@"lat,lon : %f,%f", location.coordinate.latitude, location.coordinate.longitude);
        lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
        lon = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    }
    [self logInfo];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//    CLog(@"location error:%@", error.description);
}

#pragma mark - reachability
// 通知处理
- (void)reachabilityChanged:(NSNotification *)notification
{
    HLNetWorkReachability *curReach = [notification object];
    HLNetWorkStatus netStatus = [curReach currentReachabilityStatus];
    netWorkStatus = (NSUInteger)netStatus;
    switch (netStatus) {
      case HLNetWorkStatusNotReachable:
//        CLog(@"网络不可用");
            netWorkStatusName = @"NotReachable";
        break;
      case HLNetWorkStatusUnknown:
//        CLog(@"未知网络");
            netWorkStatusName = @"Unknow";
        break;
      case HLNetWorkStatusWWAN2G:
//        CLog(@"2G网络");
            netWorkStatusName = @"2G";
        break;
      case HLNetWorkStatusWWAN3G:
//        CLog(@"3G网络");
            netWorkStatusName = @"3G";
        break;
      case HLNetWorkStatusWWAN4G:
//        CLog(@"4G网络");
            netWorkStatusName = @"4G";
        break;
      case HLNetWorkStatusWiFi:
//        CLog(@"WiFi");
            netWorkStatusName = @"WiFi";
        break;
         
      default:
        break;
    }
    [self logInfo];
}

-(void)logInfo {
    NSLog(@"%@", [self description]);
}

-(NSString *)description {
    NSString *str = [self allDeviceInfoJson];
    return str;
}

-(NSDictionary *)allDeviceInfo {
    NSDictionary *dic = @{@"bundle_id":[GKDeviceInfo currentBundleIdentifier],
                          @"version":[GKDeviceInfo currentApplicationVersion],
                          @"device_name":[GKDeviceInfo deviceName],
                          @"device_model":[GKDeviceInfo deviceModel],
                          @"system":[GKDeviceInfo systemVersion],
                          @"screen":[GKDeviceInfo screenSize],
                          @"country":[GKDeviceInfo currentCountry],
                          @"language":[GKDeviceInfo language],
                          @"network":netWorkStatusName,
                          @"mobile_network":[GKDeviceInfo mobileNetworkInfo],
                          @"latitude":lat,
                          @"longitude":lon,
                          @"idfa":[GKDeviceInfo deviceIDFA],
                          @"idfv":[GKDeviceInfo deviceIDFV]
    };
    
    return dic;
}

-(NSString *)allDeviceInfoJson {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self allDeviceInfo] options:NSJSONWritingPrettyPrinted error:&error];
    if (jsonData == nil) {
        return @"";
    }
    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return str;
}

#pragma mark - IDFV
+(NSString *)deviceIDFV {
    NSUUID *uuid = [[UIDevice currentDevice] identifierForVendor];
    return [uuid UUIDString];
}

#pragma mark - IDFA
+(BOOL)idfaIsOpen {
    return [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
}

+(NSString *)deviceIDFA {
    if (![GKDeviceInfo idfaIsOpen]) {
        return @"0";
    }
    NSUUID *uuid = [[ASIdentifierManager sharedManager] advertisingIdentifier];
    return [uuid UUIDString];
}
#pragma makr - SIM
+(BOOL)isSIMInstalled {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    if (!carrier.isoCountryCode) {
        return NO;
    } else {
        return YES;
    }
}

+(NSDictionary *)mobileNetworkInfo {
    if (![GKDeviceInfo isSIMInstalled]) {
        return @{};
    }
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    NSDictionary *dic = @{@"carrier_name":carrier.carrierName,
                          @"mcc":carrier.mobileCountryCode,
                          @"mnc":carrier.mobileNetworkCode,
                          @"country_code":carrier.isoCountryCode
                        };
    return dic;
}

@end
