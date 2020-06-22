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

@interface GKDeviceInfo()<CLLocationManagerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
@property (strong, nonatomic) AVCaptureSession *session;
@end
typedef void(^voidBlock)(void);
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
    NSNumber *sensorBrightness;
    voidBlock lightnessHandler;
    
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
    if ([[notification.userInfo objectForKey:@"AVSystemController_AudioCategoryNotificationParameter"] isEqualToString:@"Audio/Video"]) {
        if ([[notification.userInfo objectForKey:@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"] isEqualToString:@"ExplicitVolumeChange"]) {
            currentVolume = [[notification.userInfo objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
//            根据音量处理相关的设置
            if (_delegate &&[_delegate conformsToProtocol:@protocol(GKDeviceInfoDelegate)] && [_delegate respondsToSelector:@selector(deviceInfoDidChange:)]) {
                [_delegate deviceInfoDidChange:self];
            }
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
        lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
        lon = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
        [self reverseGeocoder:location];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
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
            netWorkStatusName = @"NotReachable";
        break;
      case HLNetWorkStatusUnknown:
            netWorkStatusName = @"Unknow";
        break;
      case HLNetWorkStatusWWAN2G:
            netWorkStatusName = @"2G";
        break;
      case HLNetWorkStatusWWAN3G:
            netWorkStatusName = @"3G";
        break;
      case HLNetWorkStatusWWAN4G:
            netWorkStatusName = @"4G";
        break;
      case HLNetWorkStatusWiFi:
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

-(void)allDeviceInfo:(complateDictionary)complate {
    [self lightSensitive:^{
        CGFloat screenBrightness = [UIScreen mainScreen].brightness;
        NSDictionary *dic = @{@"bundle_id":[GKDeviceInfo currentBundleIdentifier],
                              @"version":[GKDeviceInfo currentApplicationVersion],
                              @"device_name":[GKDeviceInfo deviceName],
                              @"device_model":[GKDeviceInfo deviceModel],
                              @"system":[GKDeviceInfo systemVersion],
                              @"screen_width":[NSNumber numberWithFloat:[GKDeviceInfo screenSize].width],
                              @"screen_height":[NSNumber numberWithFloat:[GKDeviceInfo screenSize].height],
                              @"country":[GKDeviceInfo currentCountry],
                              @"language":[GKDeviceInfo language],
                              @"network":self->netWorkStatusName,
                              @"wifi":[GKDeviceInfo wifiInfo],
                              @"mobile_network":[GKDeviceInfo mobileNetworkInfo],
                              @"vpn":[GKDeviceInfo getProxyStatus],
                              @"latitude":[NSDecimalNumber decimalNumberWithString:self->lat],
                              @"longitude":[NSDecimalNumber decimalNumberWithString:self->lon],
                              @"idfa":[GKDeviceInfo deviceIDFA],
                              @"idfv":[GKDeviceInfo deviceIDFV],
                              @"media":@{
                                      @"volume":[NSNumber numberWithFloat:self->currentVolume],
                                      @"screen_brightness":[NSNumber numberWithFloat:screenBrightness],
                                      @"sensor_brightness":self->sensorBrightness==nil ? [NSNull null] : self->sensorBrightness
                              },
                              @"location":@{@"street":self->street,
                                            @"province":self->province,
                                            @"city":self->city,
                                            @"county":self->county,
                                            @"location_iso_country_code":self->locationISOcontryCode}
        };
        complate(dic);
    }];
}

-(void)allDeviceInfoJson:(complateString)complate {
    [self allDeviceInfo:^(NSDictionary * _Nonnull dic) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        if (jsonData == nil) {
            complate(@"");
        } else {
            NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
            str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            complate(str);
        }
    }];
    
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
//
//    NSMutableDictionary* options = [[NSMutableDictionary alloc] init];
//    [options setObject:@"com.kent.deviceinfo.DeviceInfo" forKey: kNEHotspotHelperOptionDisplayName];
//    dispatch_queue_t queue = dispatch_queue_create("com.kent.deviceinfo.DeviceInfo", NULL);
//
//    BOOL returnType = [NEHotspotHelper registerWithOptions: options queue: queue handler: ^(NEHotspotHelperCommand * cmd) {
//
//        NEHotspotNetwork* network;
//        if (cmd.commandType == kNEHotspotHelperCommandTypeEvaluate || cmd.commandType == kNEHotspotHelperCommandTypeFilterScanList) {
//            // 遍历 WiFi 列表，打印基本信息
//            for (network in cmd.networkList) {
//                NSString* wifiInfoString = [[NSString alloc] initWithFormat: @"---------------------------\nSSID: %@\nMac地址: %@\n信号强度: %f\nCommandType:%ld\n---------------------------\n\n", network.SSID, network.BSSID, network.signalStrength, (long)cmd.commandType];
//
//                // 检测到指定 WiFi 可设定密码直接连接
//                if ([network.SSID isEqualToString: @"测试 WiFi"]) {
//                    [network setConfidence: kNEHotspotHelperConfidenceHigh];
//                    [network setPassword: @"123456789"];
//                    NEHotspotHelperResponse *response = [cmd createResponse: kNEHotspotHelperResultSuccess];
//                    [response setNetworkList: @[network]];
//                    [response setNetwork: network];
//                    [response deliver];
//                }
//            }
//        }
//    }];
//
//    // 注册成功 returnType 会返回一个 Yes 值，否则 No
//}

#pragma mark- 光感
- (void)lightSensitive:(void(^)(void))complate {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        sensorBrightness = nil;
        complate();
        return;
    }
    // 1.获取硬件设备
    AVCaptureDevice *deviceF = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDevicePosition posion;
//    posion = AVCaptureDevicePositionBack;
    posion = AVCaptureDevicePositionFront;
    if (@available(iOS 13.0, *)) {
            NSArray *devices = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInDualCamera, AVCaptureDeviceTypeBuiltInTripleCamera, AVCaptureDeviceTypeBuiltInDualWideCamera, AVCaptureDeviceTypeBuiltInTelephotoCamera, AVCaptureDeviceTypeBuiltInTrueDepthCamera, AVCaptureDeviceTypeBuiltInUltraWideCamera, AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified].devices;//[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
            //position
            //AVCaptureDevicePositionFront
            //AVCaptureDevicePositionUnspecified
            //AVCaptureDevicePositionBack
            for (AVCaptureDevice *device in devices )
            {
                if ( device.position == posion )
                {
                    deviceF = device;
                    break;
                }
            }
        } else {
            NSArray *devices = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInDualCamera, AVCaptureDeviceTypeBuiltInTelephotoCamera, AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified].devices;
                    for (AVCaptureDevice *device in devices )
                    {
                        if ( device.position == posion )
                        {
                            deviceF = device;
                            break;
                        }
                    }
        }
    
    // 2.创建输入流
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc]initWithDevice:deviceF error:nil];
    
    // 3.创建设备输出流
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    

    // AVCaptureSession属性
    self.session = [[AVCaptureSession alloc]init];
    // 设置为高质量采集率
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    // 添加会话输入和输出
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }
    if ([self.session canAddOutput:output]) {
        [self.session addOutput:output];
    }
    
    lightnessHandler = complate;
    // 9.启动会话
    [self.session startRunning];
    
}

#pragma mark- AVCaptureVideoDataOutputSampleBufferDelegate的方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    
    sensorBrightness = [NSNumber numberWithFloat:brightnessValue];
    lightnessHandler();
    [self.session stopRunning];
}

@end
