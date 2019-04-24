//
//  CCTransferView.h
//  ccAsset
//
//  Created by SealWallet on 2018/9/14.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCTransferView, CCErc721TokenInfoModel;
@protocol CCTransferViewDelegate <NSObject>

@optional
- (void)transferView:(CCTransferView *)transferView
              remark:(NSString *)remark
           toAddress:(NSString *)toAddress
              number:(NSString *)number;

@end

@interface CCTransferView : UIScrollView

@property (nonatomic, weak) id<CCTransferViewDelegate> transferDelegate;

- (instancetype)initWithAsset:(CCAsset *)asset
                   walletData:(CCWalletData *)walletData
                    toAddress:(NSString *)toAddress;

- (void)changeToAddress:(NSString *)toAddress;

- (void)bindTokenModel:(CCErc721TokenInfoModel *)tokenModel;

@end
