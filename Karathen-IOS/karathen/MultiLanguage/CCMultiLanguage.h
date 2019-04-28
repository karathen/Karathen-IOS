//
//  CCMultiLanguage.h
//  Karathen
//
//  Created by Karathen on 2018/7/10.
//  Copyright © 2018年 raistone. All rights reserved.
//

//语言切换
#define Localized(key)  [[CCMultiLanguage manager] localizedWithKey:(key)]

#import <Foundation/Foundation.h>

/** 可选择的语言 */
static NSString *const CCLanguageOfChinese = @"zh-Hans";     // 简体中文
static NSString *const CCLanguageOfEnglish = @"en";          // 英文


/** 语言文件 */
static NSString *const CCLanguageFileName = @"Language";
/** 切换语言通知 */
static NSString *const CCAppLanguageDidChangeNotification = @"CCLanguageDidChange";

@interface CCMultiLanguage : NSObject

+ (CCMultiLanguage *)manager;

/** 本地语言 */
@property (nonatomic, strong, readonly) NSString *localeLanguage;
/** 当前选择语言 */
@property (nonatomic, strong, readonly) NSString *currentLanguage;


/** 根据key获取文字*/
- (NSString *)localizedWithKey:(NSString *)key;

/** 切换语言之后的block回调 */
+ (void)languageChanged:(void(^)(NSString *language))languageDidChange;

/** 设置当前语言 */
- (void)setCurrentLanguage:(NSString *)currentLanguage;

/** 可以切换的语言数组 */
- (NSArray *)allLanguages;


@end


