//
//  NSString+GKString.m
//  DeviceInfo
//
//  Created by HongXing Guo on 2019/11/28.
//  Copyright © 2019 HongXing Guo. All rights reserved.
//

#import "NSString+GKString.h"

#import <UIKit/UIKit.h>


@implementation NSString (GKString)


- (NSString *)urlEncode{
    // !*'();:@&=+$,/?%#[]{}" 表示URL里遇到这些字符 将使用字母数字加%的形式代替
    NSCharacterSet *characterSet = [[NSCharacterSet characterSetWithCharactersInString:
@"!*'();:@&=+$,/?%#[]{}\""] invertedSet];
    return [self stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
}
 
- (NSString *)urlDecode{
    return [self stringByRemovingPercentEncoding];
}
@end
