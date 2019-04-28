//
//  Utils.m
//  TestCompileDemo
//
//  Created by 周权威 on 2018/8/22.
//  Copyright © 2018年 extropies. All rights reserved.
//

#import "Utils.h"
#import <iOS_EWalletDynamic/PA_EWallet.h>

@implementation Utils

+ (NSString *)errorCodeToString:(int)retValue
{
    NSString *strResult = Localized(@"PAEW_RET_UNKNOWN_FAIL");
    switch (retValue) {
            
        case PAEW_RET_SUCCESS:
            strResult = Localized(@"PAEW_RET_SUCCESS");
            break;
        case PAEW_RET_UNKNOWN_FAIL:
            strResult = Localized(@"PAEW_RET_UNKNOWN_FAIL");
            break;
        case PAEW_RET_ARGUMENTBAD:
            strResult= Localized(@"PAEW_RET_ARGUMENTBAD");
            break;
        case PAEW_RET_HOST_MEMORY:
            strResult=Localized(@"PAEW_RET_HOST_MEMORY");
            break;
        case PAEW_RET_DEV_ENUM_FAIL:
            strResult=Localized(@"PAEW_RET_DEV_ENUM_FAIL");
            break;
        case PAEW_RET_DEV_OPEN_FAIL:
            strResult=Localized(@"PAEW_RET_DEV_OPEN_FAIL");
            break;
        case PAEW_RET_DEV_COMMUNICATE_FAIL:
            strResult=Localized(@"PAEW_RET_DEV_COMMUNICATE_FAIL");
            break;
        case PAEW_RET_DEV_NEED_PIN:
            strResult=Localized(@"PAEW_RET_DEV_NEED_PIN");
            break;
        case PAEW_RET_DEV_OP_CANCEL:
            strResult=Localized(@"PAEW_RET_DEV_OP_CANCEL");
            break;
        case PAEW_RET_DEV_KEY_NOT_RESTORED:
            strResult=Localized(@"PAEW_RET_DEV_KEY_NOT_RESTORED");
            break;
        case PAEW_RET_DEV_KEY_ALREADY_RESTORED:
            strResult=Localized(@"PAEW_RET_DEV_KEY_ALREADY_RESTORED");
            break;
        case PAEW_RET_DEV_COUNT_BAD:
            strResult=Localized(@"PAEW_RET_DEV_COUNT_BAD");
            break;
        case PAEW_RET_DEV_RETDATA_INVALID:
            strResult=Localized(@"PAEW_RET_DEV_RETDATA_INVALID");
            break;
        case PAEW_RET_DEV_AUTH_FAIL:
            strResult=Localized(@"PAEW_RET_DEV_AUTH_FAIL");
            break;
        case PAEW_RET_DEV_STATE_INVALID:
            strResult=Localized(@"PAEW_RET_DEV_STATE_INVALID");
            break;
        case PAEW_RET_DEV_WAITING:
            strResult=Localized(@"PAEW_RET_DEV_WAITING");
            break;
        case PAEW_RET_DEV_COMMAND_INVALID:
            strResult=Localized(@"PAEW_RET_DEV_COMMAND_INVALID");
            break;
        case PAEW_RET_DEV_RUN_COMMAND_FAIL:
            strResult=Localized(@"PAEW_RET_DEV_RUN_COMMAND_FAIL");
            break;
        case PAEW_RET_DEV_HANDLE_INVALID:
            strResult=Localized(@"PAEW_RET_DEV_HANDLE_INVALID");
            break;
        case PAEW_RET_INTERNAL_ERROR:
            strResult=Localized(@"PAEW_RET_INTERNAL_ERROR");
            break;
        case PAEW_RET_TARGET_DEV_INVALID:
            strResult=Localized(@"PAEW_RET_TARGET_DEV_INVALID");
            break;
        case PAEW_RET_CRYPTO_ERROR:
            strResult=Localized(@"PAEW_RET_CRYPTO_ERROR");
            break;
        case PAEW_RET_DEV_TIMEOUT:
            strResult=Localized(@"PAEW_RET_DEV_TIMEOUT");
            break;
        case PAEW_RET_DEV_PIN_LOCKED:
            strResult=Localized(@"PAEW_RET_DEV_PIN_LOCKED");
            break;
        case PAEW_RET_DEV_PIN_CONFIRM_FAIL:
            strResult=Localized(@"PAEW_RET_DEV_PIN_CONFIRM_FAIL");
            break;
        case PAEW_RET_DEV_PIN_VERIFY_FAIL:
            strResult=Localized(@"PAEW_RET_DEV_PIN_VERIFY_FAIL");
            break;
        case PAEW_RET_DEV_CHECKDATA_FAIL:
            strResult=Localized(@"PAEW_RET_DEV_CHECKDATA_FAIL");
            break;
        case PAEW_RET_DEV_DEV_OPERATING:
            strResult=Localized(@"PAEW_RET_DEV_DEV_OPERATING");
            break;
        case PAEW_RET_DEV_PIN_UNINIT:
            strResult=Localized(@"PAEW_RET_DEV_PIN_UNINIT");
            break;
        case PAEW_RET_DEV_BUSY:
            strResult=Localized(@"PAEW_RET_DEV_BUSY");
            break;
        case PAEW_RET_DEV_ALREADY_AVAILABLE:
            strResult=Localized(@"PAEW_RET_DEV_ALREADY_AVAILABLE");
            break;
        case PAEW_RET_DEV_DATA_NOT_FOUND:
            strResult=Localized(@"PAEW_RET_DEV_DATA_NOT_FOUND");
            break;
        case PAEW_RET_DEV_SENSOR_ERROR:
            strResult=Localized(@"PAEW_RET_DEV_SENSOR_ERROR");
            break;
        case PAEW_RET_DEV_STORAGE_ERROR:
            strResult=Localized(@"PAEW_RET_DEV_STORAGE_ERROR");
            break;
        case PAEW_RET_DEV_STORAGE_FULL:
            strResult=Localized(@"PAEW_RET_DEV_STORAGE_FULL");
            break;
        case PAEW_RET_DEV_LOW_POWER:
            strResult=Localized(@"PAEW_RET_DEV_LOW_POWER");
            break;
        case PAEW_RET_DEV_TYPE_INVALID:
            strResult=Localized(@"PAEW_RET_DEV_TYPE_INVALID");
            break;
        case PAEW_RET_NO_VERIFY_COUNT:
            strResult=Localized(@"PAEW_RET_NO_VERIFY_COUNT");
            break;
        case PAEW_RET_AUTH_CANCEL:
            strResult=Localized(@"PAEW_RET_NO_VERIFY_COUNT");
            break;
        case PAEW_RET_PIN_LEN_ERROR:
            strResult=Localized(@"PAEW_RET_PIN_LEN_ERROR");
            break;
        case PAEW_RET_AUTH_TYPE_INVALID:
            strResult=Localized(@"PAEW_RET_AUTH_TYPE_INVALID");
            break;
        default:
            strResult = Localized(@"PAEW_RET_UNKNOWN_FAIL");
            break;
    }
    return strResult;
}


+(NSString *)bytesToHexString:(NSData *)data
{
    size_t length = data.length;
    void *bytes = (void *)[data bytes];
    return [Utils bytesToHexString:bytes length:length];
}

+ (NSString *)bytesToHexString:(void *)data length:(size_t)length
{
    NSMutableString *str = [NSMutableString new];
    for (int i = 0; i < length; i++) {
        [str appendFormat:@"%02X", ((Byte *)data)[i]];
    }
    return str;
}

+ (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:20];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
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

+(NSData *)hexStringToBytes:(NSString *)hexString
{
    size_t length = hexString.length;
    if (length % 2 != 0) {
        return nil;
    }
    NSMutableData *data = [NSMutableData new];
    
    for (int i = 0; i < length; i += 2) {
        NSRange range = NSMakeRange(i, i+2);
        unsigned int anInt;
        unsigned char b = 0;
        NSString *hexCharStr = [hexString substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        b = anInt;
        [data appendBytes:&b length:1];
    }
    return data;
}

@end
