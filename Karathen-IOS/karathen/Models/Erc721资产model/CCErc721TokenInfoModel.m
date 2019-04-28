//
//  CCErc721TokenInfoModel.m
//  Karathen
//
//  Created by Karathen on 2018/9/15.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCErc721TokenInfoModel.h"

@implementation CCErc721TokenInfoModel

#pragma mark - 图片地址
- (NSString *)tokenIconWithAsset:(CCAsset *)asset {
    if ([CCWalletData checkIsCryptoKittiesAsset:asset]) {
        return [NSString stringWithFormat:@"https://storage.googleapis.com/ck-kitty-image/0x06012c8cf97bead5deae237070f9587f8e7a266d/%@.png",self.tokenId];
    }
    return nil;
}

+ (NSString *)tokenIconWithAsset:(CCAsset *)asset tokenId:(NSString *)tokeId {
    if ([CCWalletData checkIsCryptoKittiesAsset:asset]) {
        return [NSString stringWithFormat:@"https://storage.googleapis.com/ck-kitty-image/0x06012c8cf97bead5deae237070f9587f8e7a266d/%@.png",tokeId];
    }
    return nil;
}

#pragma mark - ck猫的繁衍速度
- (NSString *)ckSpeed {
    NSString *cooldown = self.data[@"cooldownIndex"];
    NSInteger cooldownindex = [cooldown integerValue];
    NSArray *speedArray = @[
                            Localized(@"CK Speed1"),
                            Localized(@"CK Speed2"),
                            Localized(@"CK Speed3"),
                            Localized(@"CK Speed4"),
                            Localized(@"CK Speed5"),
                            Localized(@"CK Speed6"),
                            Localized(@"CK Speed7"),
                            Localized(@"CK Speed8")];

    NSInteger speedIndex;
    if (cooldownindex == 0) {
        speedIndex = 0;
    } else if (cooldownindex == 13) {
        speedIndex = 7;
    } else {
        speedIndex = (cooldownindex/2) + (cooldownindex%2==0?0:1);
    }
    return speedArray[speedIndex];
}

- (NSString *)ckGeneration {
    return [NSString stringWithFormat:@"%@",self.data[@"generation"]];
}

@end
