//
//  CCCryptoTool.h
//  ccAsset
//
//  Created by SealWallet on 2018/8/29.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCCryptoTool : NSObject

///加密
+(NSString *)encrypt:(NSString *)decryptCode password:(NSString *)password saltString:(NSString *)saltString;
///解密
+(NSString *)decrypt:(NSString *)encryptedCode password:(NSString *)password saltString:(NSString *)saltString;

@end
