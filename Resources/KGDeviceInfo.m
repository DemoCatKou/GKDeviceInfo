//
//  KGDeviceInfo.m
//  DeviceInfo
//
//  Created by HongXing Guo on 2019/11/22.
//  Copyright © 2019 HongXing Guo. All rights reserved.
//

#import "KGDeviceInfo.h"

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "UIDevice+Hardware.h"
#import "HLNetWorkReachability.h"

@interface KGDeviceInfo()<CLLocationManagerDelegate>

@end

@implementation KGDeviceInfo
{
    HLNetWorkReachability *reachability;
    KGNetWorkStatus newWorkStatus;
    CLLocationManager *locationManager;
}
-(instancetype)init {
    self = [super init];
    if (self) {
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
//    NSString *localizedModel = [[UIDevice currentDevice] localizedModel];
    NSString *platformString = [UIDevice currentDevice].platformString;
    
    return [NSString stringWithFormat:@"%@ %@", model, platformString];
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
    } else {
        [self managerStartLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
//    CLog(@"\n");
    for (CLLocation *location in locations) {
//        CLog(@"lat,lon : %f,%f", location.coordinate.latitude, location.coordinate.longitude);
    }
//    CLog(@"\n");
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
    newWorkStatus = (NSUInteger)netStatus;
    [self logInfo];
    switch (netStatus) {
      case HLNetWorkStatusNotReachable:
//        CLog(@"网络不可用");
        break;
      case HLNetWorkStatusUnknown:
//        CLog(@"未知网络");
        break;
      case HLNetWorkStatusWWAN2G:
//        CLog(@"2G网络");
        break;
      case HLNetWorkStatusWWAN3G:
//        CLog(@"3G网络");
        break;
      case HLNetWorkStatusWWAN4G:
//        CLog(@"4G网络");
        break;
      case HLNetWorkStatusWiFi:
//        CLog(@"WiFi");
        break;
         
      default:
        break;
    }
}

-(void)logInfo {
    NSLog(@"%@", [self description]);
}

-(NSString *)description {
    NSMutableString *str = [NSMutableString string];
    [str appendFormat:@"\n"];
    [str appendFormat:@"BundleIdentifier:%@", [KGDeviceInfo currentBundleIdentifier]];
    [str appendFormat:@"\n"];
    [str appendFormat:@"version:%@;", [KGDeviceInfo currentApplicationVersion]];
    [str appendFormat:@"\n"];
    [str appendFormat:@"device:%@ %@; ", [KGDeviceInfo deviceName], [KGDeviceInfo deviceModel]];
    [str appendFormat:@"\n"];
    [str appendFormat:@"system:%@ %@", [KGDeviceInfo systemVersion], [KGDeviceInfo screenSize]];
    [str appendFormat:@"\n"];
    [str appendFormat:@"country:%@ language:%@", [KGDeviceInfo language], [KGDeviceInfo currentCountry]];
    [str appendFormat:@"\n"];
    [str appendFormat:@"network:%lu", (unsigned long)newWorkStatus];
    [str appendFormat:@"\n"];
    [str appendFormat:@"%@", [KGDeviceInfo otherInfo]];
    [str appendFormat:@"\n"];
    [KGDeviceInfo language];
//    [str appendFormat:@"%@", [KGDeviceInfo networktype]];
    return str;
}


@end
