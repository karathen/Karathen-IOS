//
//  CCWalletManager+ETH.m
//  Karathen
//
//  Created by Karathen on 2018/8/22.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWalletManager+ETH.h"

@implementation CCWalletManager (ETH)

#pragma mark - 助记词创建多地址
+ (NSString *)createETHAddressWithMnemonics:(NSString *)mnemonics
                                       slot:(int)slot {
    Account *account = [[Account alloc] initWithMnemonicPhrase:mnemonics coinType:60 account:0 external:0 slot:slot];
    return account.address.checksumAddress;
}

#pragma mark - 私钥创建地址
+ (NSString *)createETHAddressWithPrivateKey:(NSString *)privateKey {
    if (privateKey.length < 1) {
        return nil;
    }
    Account *account = [Account accountWithPrivateKey:[SecureData hexStringToData:[privateKey hasPrefix:@"0x"]?privateKey:[@"0x" stringByAppendingString:privateKey]]];
    return account.address.checksumAddress;
}

#pragma mark - keystore创建地址
+ (void)createETHAddressWithKeystore:(NSString *)keystore
                            password:(NSString *)password
                          completion:(void(^)(BOOL suc,CCWalletError error,NSString *privatekey,NSString *address))completion {
    if (keystore.length < 1) {
        completion(NO,CCWalletErrorKeyStoreLength,nil,nil);
        return;
    }
    
    [Account decryptSecretStorageJSON:keystore password:password callback:^(Account *account, NSError *NSError) {
        if (NSError) {
            completion(NO,CCWalletErrorKeyStoreValid,nil,nil);
        }else{
            NSString *privateKeyStr = [SecureData dataToHexString:account.privateKey];
            completion(YES,CCWalletImportKeyStoreSuc,privateKeyStr,account.address.checksumAddress);
        }
    }];
}


#pragma mark - 通过助记词导出私钥
+ (NSString *)exportETHPrivateKeyWithMnemonics:(NSString *)mnemonics
                                          slot:(int)slot {
    Account *account = [[Account alloc] initWithMnemonicPhrase:mnemonics coinType:60 account:0 external:0 slot:slot];
    NSString *privateKey = [SecureData dataToHexString:account.privateKey];
    return privateKey;
}


#pragma mark - 创建钱包
+ (void)createETHWalletWithPassword:(NSString *)passWord
                         completion:(void(^)(NSString *address,NSString *keyStore,NSString *mnemonicPhrase,NSString *privateKey))completion {
    Account *account = [Account randomMnemonicAccount];
    NSString *mnemonicPhrase = account.mnemonicPhrase;
    [account encryptSecretStorageJSON:passWord callback:^(NSString *json) {
        NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        //地址
        NSString *addressStr = [NSString stringWithFormat:@"0x%@",dic[@"address"]];
        //私钥
        NSString *privateKeyStr = [SecureData dataToHexString:account.privateKey];
        //助记词account.mnemonicPhrase
        //助记keyStore 就是json字符串
        completion(addressStr,json,mnemonicPhrase,privateKeyStr);
    }];
}

#pragma mark - 助记词导出keystore
+ (void)exportETHKeystoreWithMnemonics:(NSString *)mnemonics
                                  slot:(int)slot
                              password:(NSString *)password
                            completion:(void(^)(BOOL suc,CCWalletError error,NSString *keystore))completion {
    Account *account = [[Account alloc] initWithMnemonicPhrase:mnemonics coinType:60 account:0 external:0 slot:slot];
    if (account) {
        [account encryptSecretStorageJSON:password callback:^(NSString *json) {
            completion(YES,CCWalletExportKeystoreSuc,[self keyStore:json]);
        }];
    } else {
        completion(NO,CCWalletErrorMnemonicsValidPhrase,nil);
    }
}

#pragma mark - 私钥导出keystore
+ (void)exportETHKeystoreWithPrivatekey:(NSString *)privateKey
                              password:(NSString *)password
                            completion:(void(^)(BOOL suc,CCWalletError error,NSString *keystore))completion {
    if (privateKey.length < 1) {
        completion(NO,CCWalletImportPrivateKeyValidPhrase,nil);
    }
    Account *account = [Account accountWithPrivateKey:[SecureData hexStringToData:[privateKey hasPrefix:@"0x"]?privateKey:[@"0x" stringByAppendingString:privateKey]]];
    if (account) {
        [account encryptSecretStorageJSON:password callback:^(NSString *json) {
            completion(YES,CCWalletExportKeystoreSuc,[self keyStore:json]);
        }];
    } else {
        completion(NO,CCWalletImportPrivateKeyValidPhrase,nil);
    }
}



#pragma mark - 导出keystore的时候需要处理,含有x-ethers可以导出助记词，不包含则不能，通过私钥导入的钱包也不能得到助记词，通过助记词导入的钱包可以
+ (NSString *)keyStore:(NSString *)keyStore {
    NSMutableDictionary *keyStoreDic = [keyStore.mj_JSONObject mutableCopy];
    [keyStoreDic removeObjectForKey:@"x-ethers"];
    [keyStoreDic setObject:keyStoreDic[@"Crypto"] forKey:@"crypto"];
    [keyStoreDic removeObjectForKey:@"Crypto"];
    return keyStoreDic.mj_JSONString;
}

@end
