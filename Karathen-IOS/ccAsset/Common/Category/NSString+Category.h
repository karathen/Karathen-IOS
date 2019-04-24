//
//  NSString+Category.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/23.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Category)

/**
 保留小数后几位

 @param number number
 @param roundMode 四舍五入规则，  四舍五入NSRoundPlain 舍NSRoundDown 进1 NSRoundUp
 @param position 位数
 @return 返回值
 */
+ (NSString *)formatDecimalNum:(NSDecimalNumber *)number roundMode:(NSRoundingMode)roundMode afterPoint:(int)position;


/**
 转换精度

 @param value 原值
 @param decimal 小数位
 @return 返回值
 */
+ (NSString *)valueString:(NSString *)value decimal:(NSString *)decimal;
+ (NSDecimalNumber *)numberValueString:(NSString *)value decimal:(NSString *)decimal;

/**
 不区分大小写的不交

 @param string string
 @return BOOL
 */
- (BOOL)compareWithString:(NSString *)string;


/**
 包含字母数字

 @param pass 密码
 @return YES/NO
 */
+ (BOOL)judgePassWordLegal:(NSString *)pass;


/**
 删除首位空格
 */
- (NSString *)deleteSpace;


/**
 验证邮箱

 @param email 邮箱
 @return BOOL
 */
+ (BOOL)validateEmail:(NSString *)email;


/**
 检验网址

 @param urlStr 网址
 @return 网址
 */
+ (NSString *)getCompleteWebsite:(NSString *)urlStr;

+ (NSString *)hexStringFromString:(NSString *)string;


///32位小写
- (NSString *)md5ForLower32Bate;

///32位大写
- (NSString *)md5ForUpper32Bate;

///16位小写
- (NSString *)md5ForLower16Bate;

///16位大写
- (NSString *)md5ForUpper16Bate;


@end
