//
//  CCTradeConfirmView.h
//  ccAsset
//
//  Created by SealWallet on 2018/10/17.
//  Copyright © 2018 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCTradeConfirmView, CCErc721TokenInfoModel;
@protocol CCTradeConfirmViewDelegate <NSObject>

@optional
- (void)confrimView:(CCTradeConfirmView *)transferView
            gasPrice:(NSString *)gasPrice
            gasLimit:(NSString *)gasLimit;

@end

@interface CCTradeConfirmView : UIScrollView

@property (nonatomic, weak) id<CCTradeConfirmViewDelegate> confirmDelegate;

- (instancetype)initWithWalletData:(CCWalletData *)walletData
                             asset:(CCAsset *)asset
                         toAddress:(NSString *)toAddress
                             value:(NSString *)value
                        tokenModel:(CCErc721TokenInfoModel *)tokenModel
                            remark:(NSString *)remark;

- (instancetype)initWithWalletData:(CCWalletData *)walletData
                         toAddress:(NSString *)toAddress
                          gasPrice:(NSString *)gasprice
                          gasLimit:(NSString *)gasLimit
                            toDapp:(NSString *)toDapp
                             value:(NSString *)value
                            remark:(NSString *)remark;

@end
