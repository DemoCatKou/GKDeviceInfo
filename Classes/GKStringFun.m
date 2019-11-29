//
//  GKStringFun.m
//  DeviceInfo
//
//  Created by HongXing Guo on 2019/11/28.
//  Copyright © 2019 HongXing Guo. All rights reserved.
//

#import "GKStringFun.h"

@implementation GKStringFun

+(NSString *)simpleStringEncryptInput:(NSString *)input uid:(int)uid isEncode:(BOOL)isencode {
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSData *data;// = [input dataUsingEncoding:encoding];
    if (isencode) {
        data = [input dataUsingEncoding:encoding];
    } else {
        data = [GKStringFun convertHexStrToData:input];
    }
    Byte *byte = (Byte *)[data bytes];
    
    Byte *byteArray = malloc(sizeof(byte) * data.length);
    
    for (int i=0; i<data.length; i++) {
        int t = byte[i];
        int f = i + uid%31;
        uint16_t t_16 = t;
        uint16_t f_16 = f;
        if (t <= 256) {
            uint16_t ti = (t_16&65504) | ((f_16^t_16)&31);
            
            Byte b = ti;
            byteArray[i] = b;
        } else {
            byteArray[i] = t;
        }
    }
    
    NSData *dataResult = [NSData dataWithBytes:byteArray length:data.length];
    NSString *result;
    if (isencode) {
        result = [GKStringFun convertDataToHexStr:dataResult];
    } else {
        result = [[NSString alloc] initWithData:dataResult encoding:encoding];
    }
    return result;
    
}



+ (NSData *)bytesFromUInt16:(uint16_t)val
{
    NSMutableData *valData = [[NSMutableData alloc] init];
    
    unsigned char valChar[2];
    valChar[0] = 0xff & val;
    valChar[1] = (0xff00 & val) >> 8;
    [valData appendBytes:valChar length:2];
    
    return [GKStringFun dataWithReverse:valData];
}

+ (NSData *)dataWithReverse:(NSData *)srcData
{
    NSUInteger byteCount = srcData.length;
    NSMutableData *dstData = [[NSMutableData alloc] initWithData:srcData];
    NSUInteger halfLength = byteCount / 2;
    for (NSUInteger i=0; i<halfLength; i++) {
        NSRange begin = NSMakeRange(i, 1);
        NSRange end = NSMakeRange(byteCount - i - 1, 1);
        NSData *beginData = [srcData subdataWithRange:begin];
        NSData *endData = [srcData subdataWithRange:end];
        [dstData replaceBytesInRange:begin withBytes:endData.bytes];
        [dstData replaceBytesInRange:end withBytes:beginData.bytes];
    }//for

    return dstData;}


+ (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange,BOOL *stop) {
    unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i =0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) &0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;

}

//将16进制的字符串转换成NSData

+ (NSMutableData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] %2 == 0) {
        range = NSMakeRange(0,2);
    } else {
        range = NSMakeRange(0,1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        range.location += range.length;
        range.length = 2;
    }
    return hexData;

}
/**
 //    const char *c_input = [input UTF8String];
     NSMutableString *result = [NSMutableString string];
     
     for (int i=0; i<input.length; i++) {
         NSString *str = [input substringWithRange:NSMakeRange(i, 1)];
 //        const char *c = [str cStringUsingEncoding:NSASCIIStringEncoding];
         int t = [str characterAtIndex:0];
         int f = i + uid%31;
         uint16_t t_16 = t;
         uint16_t f_16 = f;
         if (t <= 127) {
             uint16_t ti = (t_16&65504) | ((f_16^t_16)&31);
             [result appendFormat:@"%c", ti];
         } else {
             [result appendFormat:@"%c", t];
         }
     }
     return result;
*/
@end
