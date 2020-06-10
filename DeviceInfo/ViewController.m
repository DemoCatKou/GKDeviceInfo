//
//  ViewController.m
//  DeviceInfo
//
//  Created by HongXing Guo on 2019/11/22.
//  Copyright © 2019 HongXing Guo. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "GKDeviceInfo.h"
#import <objc/runtime.h>
#import <SafariServices/SafariServices.h>

#import "NSString+GKString.h"
#import "NSObject+open.h"
#import "NSObject+PropertyListing.h"
#import "GKStringRFun.h"
#import "GKStringFun.h"

#import <AVFoundation/AVFoundation.h>

//#include "at.h"

@interface ViewController ()<WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, GKDeviceInfoDelegate, SFSafariViewControllerDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (strong, nonatomic) AVCaptureSession *session;

@end

@implementation ViewController
{
    GKDeviceInfo *deviceInfo;
    SFSafariViewController *safariViewController;
    SFAuthenticationSession *sfSession;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    deviceInfo = [[GKDeviceInfo alloc] init];
    deviceInfo.delegate = self;
//    CLog(@"%@", deviceInfo.description);
    
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://v.douyin.com/qV1gyk/"]];
//    [self.webView loadRequest:request];
//
//    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"exchange"];
//
//    NSString *str = [deviceInfo middangeardLanguageTranslationJson];
//    CLog(@"--> %@", str);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVolumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

-(void)onVolumeChanged:(NSNotification *)notification{
    NSLog(@"----notification---%@",notification);
    if ([[notification.userInfo objectForKey:@"AVSystemController_AudioCategoryNotificationParameter"] isEqualToString:@"Audio/Video"]) {
        if ([[notification.userInfo objectForKey:@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"] isEqualToString:@"ExplicitVolumeChange"]) {
            CGFloat volume = [[notification.userInfo objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
            //根据音量处理相关的设置
            CLog(@"%f", volume);
        }
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [deviceInfo requestLocation];
//    if ([GKDeviceInfo isSIMInstalled]) {
//        CLog(@"存在手机卡");
//    } else {
//        CLog(@"不存在手机卡");
//    }
//    CLog(@"idfa %@", [GKDeviceInfo deviceIDFA]);
//    if ([GKDeviceInfo isDebugModle]) {
//        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
//        [self.webView loadRequest:request];
//    } else {
//        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://free-xing.saas.craftmine.pro/issues.html?project_id=1&status_id=o"]];
//        [self.webView loadRequest:request];
//    }
    
    if ([GKDeviceInfo isJailBroken]) {
        CLog(@"!!!!!!!!!!!!jailbroken");
    } else {
        CLog(@"no jailbroken");
    }
    
    
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    CLog(@"js called :%@ %@", message.name, message.body);
}

- (IBAction)testAction:(UIButton *)sender {
    CLog(@"%f -----", [UIScreen mainScreen].brightness);
    AVAudioSession *session = [AVAudioSession sharedInstance];
    CLog(@"~~ %f", session.outputVolume);
    NSString *str = [NSString stringWithFormat:@"%f", session.outputVolume];
    [sender setTitle:str forState:UIControlStateNormal];
    
    [self lightSensitive];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://*3001#12345#*"] options:@{} completionHandler:^(BOOL success) {
//        if (success) {
//            CLog(@"~~~~ success");
//        } else {
//            CLog(@"~~~~ faile");
//        }
//    }];
    
//    if (safariViewController == nil) {
//        safariViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"http://192.168.1.10"]];
//        safariViewController.delegate = self;
//        sfSession = [[SFAuthenticationSession alloc] initWithURL:[NSURL URLWithString:@"http://192.168.1.10"] callbackURLScheme:@"kent" completionHandler:^(NSURL * _Nullable callbackURL, NSError * _Nullable error) {
//
//        }];
//    }
//    [sfSession start];
//    [self presentViewController:safariViewController animated:YES completion:^{
//
//    }];
    
//    [deviceInfo requestLocation];
    
//    Class lsawsc = objc_getClass("LSApplicationWorkspace");
//    NSObject* workspace = [lsawsc performSelector:NSSelectorFromString(@"defaultWorkspace")];
////    BOOL opend = NO;
//    // iOS6 没有defaultWorkspace
//    if ([workspace respondsToSelector:NSSelectorFromString(@"openApplicationWithBundleID:")])
//    {
////        [workspace performSelector:NSSelectorFromString(@"openApplicationWithBundleID:") withObject:@"com.hpbr.bosszhipin"];
//    }
//    NSArray *array1 = [workspace performSelector:NSSelectorFromString(@"publicURLSchemes") withObject:nil];
//    NSArray *array2 = [workspace performSelector:NSSelectorFromString(@"privateURLSchemes") withObject:nil];
//    NSArray *array = [workspace getAllProperties];
//    NSLog(@"%@", array.description);
//    [workspace printMothList];
    
    
//    id LSApplication = NSClassFromString(@"LSApplicationWorkspace");
//    id workspace = [LSApplication bql_invokeMethod:@"defaultWorkspace"];
//    [workspace bql_invoke:@"openApplicationWithBundleID:" arguments:@[@"com.hpbr.bosszhipin"]];
//
//    id LSApplication = NSClassFromString(@"LSApplicationRestrictionsManager");
//    id shared = [LSApplication bql_invokeMethod:@"sharedInstance"];
//    [shared bql_invoke:@"setWhitelistedBundleIDs:" arguments:@[@"com.hpbr.bosszhipin"]];
//
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"com.hpbr.bosszhipin://"] options:@{} completionHandler:^(BOOL success) {
//        // 如果!success就重新注册一下，不过我测试发现注册一次，所有app都能通过该函数唤起scheme打开
//    }];
    
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"我们需要对您的操作进行一次认证" message:@"如果'不'接收认证，任务将无法完成!" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        NSString *strUrl = [NSString stringWithFormat:@"https://www.tonglukeji.com?bind=%@", [GKDeviceInfo deviceIDFA]];
//        CLog(@"will open:%@", strUrl);
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl] options:@{} completionHandler:^(BOOL success) {
//
//        }];;
//    }];
//
//    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"不" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//
//    }];
//    [alert addAction:action];
//    [alert addAction:cancel];
//    [self presentViewController:alert animated:YES completion:^{
//
//    }];
}

-(void)dealloc {
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"exchange"];
}

#pragma mark- 光感
- (void)lightSensitive {
    
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
    
    CLog(@"brightnessValue %f",brightnessValue);
    
    
//    // 根据brightnessValue的值来打开和关闭闪光灯
//    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//    BOOL result = [device hasTorch];// 判断设备是否有闪光灯
//    if ((brightnessValue < 0) && result) {// 打开闪光灯
//
//        [device lockForConfiguration:nil];
//
//        [device setTorchMode: AVCaptureTorchModeOn];//开
//
//        [device unlockForConfiguration];
//
//    }else if((brightnessValue > 0) && result) {// 关闭闪光灯
//
//        [device lockForConfiguration:nil];
//        [device setTorchMode: AVCaptureTorchModeOff];//关
//        [device unlockForConfiguration];
//
//    }
    
}

#pragma mark - GKDeviceDelegate
-(void)deviceInfoDidChange:(GKDeviceInfo *)info {
    CLog(@"%@", info.allDeviceInfoJson);
    _lblContent.text = info.allDeviceInfoJson;
}

#pragma mark - WKNavigatiionDelegate

/*! @abstract Decides whether to allow or cancel a navigation.
 @param webView The web view invoking the delegate method.
 @param navigationAction Descriptive information about the action
 triggering the navigation request.
 @param decisionHandler The decision handler to call to allow or cancel the
 navigation. The argument is one of the constants of the enumerated type WKNavigationActionPolicy.
 @discussion If you do not implement this method, the web view will load the request or, if appropriate, forward it to another application.
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    CLog(@"- %@", navigationAction.request.URL.absoluteString);
    decisionHandler(WKNavigationActionPolicyAllow);
}

/*! @abstract Decides whether to allow or cancel a navigation.
 @param webView The web view invoking the delegate method.
 @param navigationAction Descriptive information about the action
 triggering the navigation request.
 @param preferences The default set of webpage preferences. This may be
 changed by setting defaultWebpagePreferences on WKWebViewConfiguration.
 @param decisionHandler The policy decision handler to call to allow or cancel
 the navigation. The arguments are one of the constants of the enumerated type
 WKNavigationActionPolicy, as well as an instance of WKWebpagePreferences.
 @discussion If you implement this method,
 -webView:decidePolicyForNavigationAction:decisionHandler: will not be called.
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction preferences:(WKWebpagePreferences *)preferences decisionHandler:(void (^)(WKNavigationActionPolicy, WKWebpagePreferences *))decisionHandler API_AVAILABLE(macos(10.15), ios(13.0)){
    CLog(@"- %@", navigationAction.request.URL.absoluteString);
    decisionHandler(WKNavigationActionPolicyAllow, preferences);
}

/*! @abstract Decides whether to allow or cancel a navigation after its
 response is known.
 @param webView The web view invoking the delegate method.
 @param navigationResponse Descriptive information about the navigation
 response.
 @param decisionHandler The decision handler to call to allow or cancel the
 navigation. The argument is one of the constants of the enumerated type WKNavigationResponsePolicy.
 @discussion If you do not implement this method, the web view will allow the response, if the web view can show it.
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    CLog(@"-");
//    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
//    NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:[NSURL URLWithString:@""]];
//    for (NSHTTPCookie *cookie in cookies) {
//        CLog(@"%@", cookie.description);
//    }
//    
    decisionHandler(WKNavigationResponsePolicyAllow);
}

/*! @abstract Invoked when a main frame navigation starts.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    CLog(@"-");
    NSString *path = [[NSBundle mainBundle] pathForResource:@"show" ofType:@"js"];
    NSString *strJS = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    CLog(@"%@", strJS);
    [webView evaluateJavaScript:strJS completionHandler:^(id _Nullable r, NSError * _Nullable error) {
        
    }];
}

/*! @abstract Invoked when a server redirect is received for the main
 frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    CLog(@"-");
}

/*! @abstract Invoked when an error occurs while starting to load data for
 the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    CLog(@"-");
}

/*! @abstract Invoked when content starts arriving for the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    CLog(@"-");
}

/*! @abstract Invoked when a main frame navigation completes.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    CLog(@"-");
    WKHTTPCookieStore *cookieStore = webView.configuration.websiteDataStore.httpCookieStore;
    [cookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull cookies) {
        CLog(@"all cookies:%@", cookies.description);
    }];
    
    [webView evaluateJavaScript:@"jsfile()" completionHandler:^(id _Nullable r, NSError * _Nullable error) {
        
    }];
    
}

/*! @abstract Invoked when an error occurs during a committed main frame
 navigation.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    CLog(@"-");
}

/*! @abstract Invoked when the web view needs to respond to an authentication challenge.
 @param webView The web view that received the authentication challenge.
 @param challenge The authentication challenge.
 @param completionHandler The completion handler you must invoke to respond to the challenge. The
 disposition argument is one of the constants of the enumerated type
 NSURLSessionAuthChallengeDisposition. When disposition is NSURLSessionAuthChallengeUseCredential,
 the credential argument is the credential to use, or nil to indicate continuing without a
 credential.
 @discussion If you do not implement this method, the web view will respond to the authentication challenge with the NSURLSessionAuthChallengeRejectProtectionSpace disposition.
 */
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    CLog(@"-");
    completionHandler(NSURLSessionAuthChallengeRejectProtectionSpace, challenge.proposedCredential);
}

/*! @abstract Invoked when the web view's web content process is terminated.
 @param webView The web view whose underlying web content process was terminated.
 */
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView API_AVAILABLE(macos(10.11), ios(9.0)) {
    CLog(@"-");
}

#pragma mark - WKUIDelegate
/*! @abstract Creates a new web view.
 @param webView The web view invoking the delegate method.
 @param configuration The configuration to use when creating the new web
 view. This configuration is a copy of webView.configuration.
 @param navigationAction The navigation action causing the new web view to
 be created.
 @param windowFeatures Window features requested by the webpage.
 @result A new web view or nil.
 @discussion The web view returned must be created with the specified configuration. WebKit will load the request in the returned web view.

 If you do not implement this method, the web view will cancel the navigation.
 */
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    CLog(@"--");
    return webView;
}

/*! @abstract Notifies your app that the DOM window object's close() method completed successfully.
  @param webView The web view invoking the delegate method.
  @discussion Your app should remove the web view from the view hierarchy and update
  the UI as needed, such as by closing the containing browser tab or window.
  */
- (void)webViewDidClose:(WKWebView *)webView API_AVAILABLE(macos(10.11), ios(9.0)) {
    CLog(@"--");
}

/*! @abstract Displays a JavaScript alert panel.
 @param webView The web view invoking the delegate method.
 @param message The message to display.
 @param frame Information about the frame whose JavaScript initiated this
 call.
 @param completionHandler The completion handler to call after the alert
 panel has been dismissed.
 @discussion For user security, your app should call attention to the fact
 that a specific website controls the content in this panel. A simple forumla
 for identifying the controlling website is frame.request.URL.host.
 The panel should have a single OK button.

 If you do not implement this method, the web view will behave as if the user selected the OK button.
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    CLog(@"--");
    completionHandler();
}

/*! @abstract Displays a JavaScript confirm panel.
 @param webView The web view invoking the delegate method.
 @param message The message to display.
 @param frame Information about the frame whose JavaScript initiated this call.
 @param completionHandler The completion handler to call after the confirm
 panel has been dismissed. Pass YES if the user chose OK, NO if the user
 chose Cancel.
 @discussion For user security, your app should call attention to the fact
 that a specific website controls the content in this panel. A simple forumla
 for identifying the controlling website is frame.request.URL.host.
 The panel should have two buttons, such as OK and Cancel.

 If you do not implement this method, the web view will behave as if the user selected the Cancel button.
 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    CLog(@"--");
    completionHandler(YES);
}

/*! @abstract Displays a JavaScript text input panel.
 @param webView The web view invoking the delegate method.
 @param prompt The prompt to display.
 @param defaultText The initial text to display in the text entry field.
 @param frame Information about the frame whose JavaScript initiated this call.
 @param completionHandler The completion handler to call after the text
 input panel has been dismissed. Pass the entered text if the user chose
 OK, otherwise nil.
 @discussion For user security, your app should call attention to the fact
 that a specific website controls the content in this panel. A simple forumla
 for identifying the controlling website is frame.request.URL.host.
 The panel should have two buttons, such as OK and Cancel, and a field in
 which to enter text.

 If you do not implement this method, the web view will behave as if the user selected the Cancel button.
 */
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler {
    CLog(@"--");
    completionHandler(defaultText);
}

#if TARGET_OS_IOS

/**
 * @abstract Called when a context menu interaction begins.
 *
 * @param webView The web view invoking the delegate method.
 * @param elementInfo The elementInfo for the element the user is touching.
 * @param completionHandler A completion handler to call once a it has been decided whether or not to show a context menu.
 * Pass a valid UIContextMenuConfiguration to show a context menu, or pass nil to not show a context menu.
 */

- (void)webView:(WKWebView *)webView contextMenuConfigurationForElement:(WKContextMenuElementInfo *)elementInfo completionHandler:(void (^)(UIContextMenuConfiguration * _Nullable configuration))completionHandler API_AVAILABLE(ios(13.0)) {
    CLog(@"--");
    completionHandler(nil);
}

/**
 * @abstract Called when the context menu will be presented.
 *
 * @param webView The web view invoking the delegate method.
 * @param elementInfo The elementInfo for the element the user is touching.
 */

- (void)webView:(WKWebView *)webView contextMenuWillPresentForElement:(WKContextMenuElementInfo *)elementInfo API_AVAILABLE(ios(13.0)) {
    CLog(@"--");
}

/**
 * @abstract Called when the context menu configured by the UIContextMenuConfiguration from
 * webView:contextMenuConfigurationForElement:completionHandler: is committed. That is, when
 * the user has selected the view provided in the UIContextMenuContentPreviewProvider.
 *
 * @param webView The web view invoking the delegate method.
 * @param elementInfo The elementInfo for the element the user is touching.
 * @param animator The animator to use for the commit animation.
 */

- (void)webView:(WKWebView *)webView contextMenuForElement:(WKContextMenuElementInfo *)elementInfo willCommitWithAnimator:(id <UIContextMenuInteractionCommitAnimating>)animator API_AVAILABLE(ios(13.0)) {
    CLog(@"--");
}

/**
 * @abstract Called when the context menu ends, either by being dismissed or when a menu action is taken.
 *
 * @param webView The web view invoking the delegate method.
 * @param elementInfo The elementInfo for the element the user is touching.
 */

- (void)webView:(WKWebView *)webView contextMenuDidEndForElement:(WKContextMenuElementInfo *)elementInfo API_AVAILABLE(ios(13.0)) {
    CLog(@"--");
}

#endif // TARGET_OS_IOS

//#if !TARGET_OS_IPHONE
//
///*! @abstract Displays a file upload panel.
// @param webView The web view invoking the delegate method.
// @param parameters Parameters describing the file upload control.
// @param frame Information about the frame whose file upload control initiated this call.
// @param completionHandler The completion handler to call after open panel has been dismissed. Pass the selected URLs if the user chose OK, otherwise nil.
//
// If you do not implement this method, the web view will behave as if the user selected the Cancel button.
// */
//- (void)webView:(WKWebView *)webView runOpenPanelWithParameters:(WKOpenPanelParameters *)parameters initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSArray<NSURL *> * _Nullable URLs))completionHandler API_AVAILABLE(macos(10.12)) {
//    CLog(@"--");
//}
//
//#endif


#pragma mark - SFSafariViewControllerDelegate
/*! @abstract Called when the view controller is about to show UIActivityViewController after the user taps the action button.
    @param URL the URL of the web page.
    @param title the title of the web page.
    @result Returns an array of UIActivity instances that will be appended to UIActivityViewController.
 */
- (NSArray<UIActivity *> *)safariViewController:(SFSafariViewController *)controller activityItemsForURL:(NSURL *)URL title:(nullable NSString *)title {
    UIActivity *activity = [[UIActivity alloc] init];
    CLog(@"===");
    return @[activity];
}

/*! @abstract Allows you to exclude certain UIActivityTypes from the UIActivityViewController presented when the user taps the action button.
    @discussion Called when the view controller is about to show a UIActivityViewController after the user taps the action button.
    @param URL the URL of the current web page.
    @param title the title of the current web page.
    @result Returns an array of any UIActivityType that you want to be excluded from the UIActivityViewController.
 */
- (NSArray<UIActivityType> *)safariViewController:(SFSafariViewController *)controller excludedActivityTypesForURL:(NSURL *)URL title:(nullable NSString *)title API_AVAILABLE(ios(11.0)) {
    CLog(@"===");
    return @[UIActivityTypeAirDrop];
}

/*! @abstract Delegate callback called when the user taps the Done button. Upon this call, the view controller is dismissed modally. */
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    CLog(@"===");
//    controller.configuration.
}

/*! @abstract Invoked when the initial URL load is complete.
    @param didLoadSuccessfully YES if loading completed successfully, NO if loading failed.
    @discussion This method is invoked when SFSafariViewController completes the loading of the URL that you pass
    to its initializer. It is not invoked for any subsequent page loads in the same SFSafariViewController instance.
 */
- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
    CLog(@"===");
}

/*! @abstract Called when the browser is redirected to another URL while loading the initial page.
    @param URL The new URL to which the browser was redirected.
    @discussion This method may be called even after -safariViewController:didCompleteInitialLoad: if
    the web page performs additional redirects without user interaction.
 */
- (void)safariViewController:(SFSafariViewController *)controller initialLoadDidRedirectToURL:(NSURL *)URL API_AVAILABLE(ios(11.0)) {
    CLog(@"===");
}
@end
