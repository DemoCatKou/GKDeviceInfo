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
#import <SystemConfiguration/CaptiveNetwork.h>
#import <NetworkExtension/NetworkExtension.h>
#include <sys/sysctl.h>
#import <AVFoundation/AVFoundation.h>

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
    CLGeocoder *geocoder;
    NSString *lat;
    NSString *lon;
    CGFloat currentVolume;
    
    NSString *street;
    NSString *province;
    NSString *city;
    NSString *county;
    NSString *locationISOcontryCode;
    
}
-(instancetype)init {
    self = [super init];
    if (self) {
        netWorkStatusName = @"";
        lat = @"0";
        lon = @"0";
        street = @"";
        province = @"";
        city = @"";
        county = @"";
        locationISOcontryCode = @"";
        AVAudioSession *session = [AVAudioSession sharedInstance];
        currentVolume = session.outputVolume;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kNetWorkReachabilityChangedNotification object:nil];
        reachability = [HLNetWorkReachability reachabilityWithHostName:@"www.baidu.com"];
        [reachability startNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVolumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//        [self requestLocation];
    }
    return self;
}

-(void)onVolumeChanged:(NSNotification *)notification{
    NSLog(@"----notification---%@",notification);
    if ([[notification.userInfo objectForKey:@"AVSystemController_AudioCategoryNotificationParameter"] isEqualToString:@"Audio/Video"]) {
        if ([[notification.userInfo objectForKey:@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"] isEqualToString:@"ExplicitVolumeChange"]) {
//            CGFloat volume = [[notification.userInfo objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
            //根据音量处理相关的设置
//            CLog(@"%f", volume);
        }
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNetWorkReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
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

+(CGSize)screenSize {
    CGSize size = [[UIScreen mainScreen] currentMode].size;
    return size;
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

+ (CGFloat)systemBrightness {
    return [UIScreen mainScreen].brightness;
}

- (CGFloat)systemVolume {
        return currentVolume;
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
    locationManager.distanceFilter = 10;
}

-(void)managerStartLocation {
    [locationManager requestLocation];
//    [locationManager startUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
//        CLog(@"定位权限未开启");
        lat = @"0";
        lon = @"0";
        if (_delegate &&[_delegate conformsToProtocol:@protocol(GKDeviceInfoDelegate)] && [_delegate respondsToSelector:@selector(deviceInfoDidChange:)]) {
            [_delegate deviceInfoDidChange:self];
        }
    } else {
        [self managerStartLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    for (CLLocation *location in locations) {
//        CLog(@"lat,lon : %f,%f", location.coordinate.latitude, location.coordinate.longitude);
        lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
        lon = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
        [self reverseGeocoder:location];
    }
    
//    if (_delegate &&[_delegate conformsToProtocol:@protocol(GKDeviceInfoDelegate)] && [_delegate respondsToSelector:@selector(deviceInfoDidChange:)]) {
//        [_delegate deviceInfoDidChange:self];
//    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//    CLog(@"location error:%@", error.description);
    lon = @"1";
    lat = @"1";
    if (_delegate &&[_delegate conformsToProtocol:@protocol(GKDeviceInfoDelegate)] && [_delegate respondsToSelector:@selector(deviceInfoDidChange:)]) {
        [_delegate deviceInfoDidChange:self];
    }
}

- (void)reverseGeocoder:(CLLocation *)currentLocation {
    if (geocoder == nil) {
        geocoder = [[CLGeocoder alloc] init];
    }
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error || placemarks.count == 0) {
            //
        } else {
            CLPlacemark *placemark = placemarks.firstObject;
//            NSString *address = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@ %@ %@", placemark.thoroughfare, placemark.subThoroughfare, placemark.locality, placemark.subLocality, placemark.administrativeArea, placemark.subAdministrativeArea, placemark.ISOcountryCode, placemark.country, placemark.inlandWater, placemark.areasOfInterest];
//            NSLog(@"~~~~~~~address: %@", address);
            self->street = placemark.thoroughfare==nil ? @"" : placemark.thoroughfare;
            self->province = placemark.administrativeArea==nil ? @"" : placemark.administrativeArea;
            self->city = placemark.locality==nil ? @"" : placemark.locality;
            self->county = placemark.subLocality==nil ? @"" : placemark.subLocality;
            self->locationISOcontryCode = placemark.ISOcountryCode==nil ? @"" : placemark.ISOcountryCode;
            
            if (self->_delegate &&[self->_delegate conformsToProtocol:@protocol(GKDeviceInfoDelegate)] && [self->_delegate respondsToSelector:@selector(deviceInfoDidChange:)]) {
                [self->_delegate deviceInfoDidChange:self];
            }
        }
    }];
}

#pragma mark - reachability
// 通知处理
- (void)reachabilityChanged:(NSNotification *)notification
{
    HLNetWorkReachability *curReach = [notification object];
    HLNetWorkStatus netStatus = [curReach currentReachabilityStatus];
    
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
    if (![netWorkStatusName isEqualToString:@""] && (NSUInteger)netStatus != netWorkStatus) {
        netWorkStatus = (NSUInteger)netStatus;
        if (_delegate &&[_delegate conformsToProtocol:@protocol(GKDeviceInfoDelegate)] && [_delegate respondsToSelector:@selector(deviceInfoDidChange:)]) {
            [_delegate deviceInfoDidChange:self];
        }
    }
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
                          @"screen_width":[NSNumber numberWithFloat:[GKDeviceInfo screenSize].width],
                          @"screen_height":[NSNumber numberWithFloat:[GKDeviceInfo screenSize].height],
                          @"country":[GKDeviceInfo currentCountry],
                          @"language":[GKDeviceInfo language],
                          @"network":netWorkStatusName,
                          @"wifi":[GKDeviceInfo wifiInfo],
                          @"mobile_network":[GKDeviceInfo mobileNetworkInfo],
                          @"vpn":[GKDeviceInfo getProxyStatus],
                          @"latitude":[NSDecimalNumber decimalNumberWithString:lat],
                          @"longitude":[NSDecimalNumber decimalNumberWithString:lon],
                          @"idfa":[GKDeviceInfo deviceIDFA],
                          @"idfv":[GKDeviceInfo deviceIDFV],
                          @"street":street,
                          @"province":province,
                          @"city":city,
                          @"county":county,
                          @"location_iso_contry_code":locationISOcontryCode
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
        return @"";
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
                          @"mcc":[NSNumber numberWithInteger:carrier.mobileCountryCode.integerValue],
                          @"mnc":[NSNumber numberWithInteger:carrier.mobileNetworkCode.integerValue],
                          @"country_code":carrier.isoCountryCode
                        };
    return dic;
}

#pragma mark - VPN Check
+ (NSDictionary *)getProxyStatus {
    NSDictionary *proxySettings =  (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
    NSArray *proxies = (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef _Nonnull)([NSURL URLWithString:@"https://www.baidu.com"]), (__bridge CFDictionaryRef _Nonnull)(proxySettings)));
    NSDictionary *settings = [proxies objectAtIndex:0];
    
    NSString *host = [settings objectForKey:(NSString *)kCFProxyHostNameKey];
    host = host==nil ? @"" : host;
    NSString *port = [settings objectForKey:(NSString *)kCFProxyPortNumberKey];
    port = port==nil ? @"0" : port;
    NSString *type = [settings objectForKey:(NSString *)kCFProxyTypeKey];
    BOOL ivpn = NO;
    
    if ([[settings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"]){
        ivpn = NO;
    }else{
        //设置代理了
        ivpn = YES;
    }
    return @{@"status":[NSNumber numberWithBool:ivpn], @"host":host, @"port":[NSNumber numberWithInt:port.intValue], @"type":type};
}

#pragma mark - WIFI Info
+ (NSDictionary *)wifiInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSDictionary *info = nil;
    for (NSString *ifname in ifs) {
        info = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname);
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (info != nil) {
        [info enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSString class]]) {
                [dic setObject:obj forKey:key];
            }
        }];
    }
    return dic;
}

#pragma mark - DEVICE STATUS
+ (BOOL)isJailBroken {
    NSArray *jailbreak_tool_paths = @[
        @"/Applications/Cydia.app",
        @"/Library/MobileSubstrate/MobileSubstrate.dylib",
        @"/bin/bash",
        @"/usr/sbin/sshd",
        @"/etc/apt"
    ];

    for (int i=0; i<jailbreak_tool_paths.count; i++) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:jailbreak_tool_paths[i]]) {
            return YES;
        }
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
        return YES;
    }
    //unusefull
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"User/Applications/"]) {
        NSArray *appList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"User/Applications/" error:nil];
        NSLog(@"appList = %@", appList);
        return YES;
    }
    //unusefull
    if (printEnv()) {
        NSLog(@"The device is jail broken!");
        return YES;
    }
    return NO;
}
char* printEnv(void) {
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    NSLog(@"%s", env);
    return env;
}


+ (BOOL)isDebugModle {
#if !TARGET_OS_IPHONE
    return false;
#endif
    struct kinfo_proc info;
    size_t info_size = sizeof(info);
    int name[4];
    
    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID;
    name[3] = getpid();
    
    if (sysctl(name, 4, &info, &info_size, NULL, 0) == -1) {
        NSLog(@"sysctl() failed: %s", strerror(errno));
        return false;
    }
    if ((info.kp_proc.p_flag & P_TRACED) != 0){
        return true;
    }
    return false;
}

//+ (void)scanWifiInfos{
//    NSLog(@"1.Start");
//
//    NSMutableDictionary* options = [[NSMutableDictionary alloc] init];
//    [options setObject:@"com.kent.deviceinfo.DeviceInfo" forKey: kNEHotspotHelperOptionDisplayName];
//    dispatch_queue_t queue = dispatch_queue_create("com.kent.deviceinfo.DeviceInfo", NULL);
//
//    NSLog(@"2.Try");
//    BOOL returnType = [NEHotspotHelper registerWithOptions: options queue: queue handler: ^(NEHotspotHelperCommand * cmd) {
//
//        NSLog(@"4.Finish");
//        NEHotspotNetwork* network;
//        if (cmd.commandType == kNEHotspotHelperCommandTypeEvaluate || cmd.commandType == kNEHotspotHelperCommandTypeFilterScanList) {
//            // 遍历 WiFi 列表，打印基本信息
//            for (network in cmd.networkList) {
//                NSString* wifiInfoString = [[NSString alloc] initWithFormat: @"---------------------------\nSSID: %@\nMac地址: %@\n信号强度: %f\nCommandType:%ld\n---------------------------\n\n", network.SSID, network.BSSID, network.signalStrength, (long)cmd.commandType];
//                NSLog(@"%@", wifiInfoString);
//
//                // 检测到指定 WiFi 可设定密码直接连接
//                if ([network.SSID isEqualToString: @"测试 WiFi"]) {
//                    [network setConfidence: kNEHotspotHelperConfidenceHigh];
//                    [network setPassword: @"123456789"];
//                    NEHotspotHelperResponse *response = [cmd createResponse: kNEHotspotHelperResultSuccess];
//                    NSLog(@"Response CMD: %@", response);
//                    [response setNetworkList: @[network]];
//                    [response setNetwork: network];
//                    [response deliver];
//                }
//            }
//        }
//    }];
//
//    // 注册成功 returnType 会返回一个 Yes 值，否则 No
//    NSLog(@"3.Result: %@", returnType == YES ? @"Yes" : @"No");
//}
@end
