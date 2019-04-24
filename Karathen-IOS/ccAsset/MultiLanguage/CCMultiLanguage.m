//
//  CCMultiLanguage.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/10.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCMultiLanguage.h"
#import "TZImagePickerController.h"

static CCMultiLanguage *manager = nil;
@implementation CCMultiLanguage

+ (CCMultiLanguage *)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CCMultiLanguage alloc] init];
        
        TZImagePickerConfig *config = [TZImagePickerConfig sharedInstance];
        config.preferredLanguage = manager.currentLanguage;
    });
    return manager;
}

+ (void)languageChanged:(void (^)(NSString *))languageDidChange {
    [[NSNotificationCenter.defaultCenter rac_addObserverForName:CCAppLanguageDidChangeNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSString *language = x.object;
        if (language && languageDidChange) {
            languageDidChange(language);
        }
    }];
}

#pragma mark - 根据key获取文字
- (NSString *)localizedWithKey:(NSString *)key {
    NSString *path = [[NSBundle mainBundle] pathForResource:self.currentLanguage ofType:@"lproj"];
    NSString *result = [[NSBundle bundleWithPath:path] localizedStringForKey:key value:nil table:CCLanguageFileName];
    return result ?: key;
}


#pragma mark - 设置当前语言
- (void)setCurrentLanguage:(NSString *)currentLanguage {
    if ([currentLanguage isEqualToString:self.currentLanguage]) {
        return;
    }
    
    TZImagePickerConfig *config = [TZImagePickerConfig sharedInstance];
    config.preferredLanguage = currentLanguage;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:currentLanguage forKey:CCKeyForCurrentLanguage];
    [userDefaults synchronize];
    
    [NSNotificationCenter.defaultCenter postNotificationName:CCAppLanguageDidChangeNotification object:currentLanguage];
}


/**
 获取当前本地语言

 @return 当前语言
 */
- (NSString *)localeLanguage {
    return (NSString *)[[NSLocale preferredLanguages] objectAtIndex:0];
}


/**
 当前的APP语言

 @return 当前的app语言
 */
- (NSString *)currentLanguage {
    NSString *currentLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:CCKeyForCurrentLanguage];
    if (!currentLanguage) {
        if ([self.localeLanguage hasPrefix:CCLanguageOfChinese]) {
            currentLanguage = CCLanguageOfChinese;
        } else {
            currentLanguage = CCLanguageOfEnglish;
        }
    }
    return currentLanguage;
}


/**
 当前所有可用语言

 @return 可用语言
 */
- (NSArray *)allLanguages {
    return @[
             CCLanguageOfChinese,
             CCLanguageOfEnglish
             ];
}


@end
