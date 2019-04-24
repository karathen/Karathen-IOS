//
//  CCBackUpMnemonicView.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/16.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,CCBackUpMnemonicType) {
    CCBackUpMnemonicTypeCustom,//默认样式
    CCBackUpMnemonicTypeCancle,//单击取消的样式
    CCBackUpMnemonicTypeVerify,//验证的样式
};

@class CCBackUpMnemonicView,CCBackUpMnemonicModel;
@protocol CCBackUpMnemonicViewDelegate <NSObject>

- (void)backupView:(CCBackUpMnemonicView *)backupView selectModel:(CCBackUpMnemonicModel *)model;

@end

@interface CCBackUpMnemonicView : UICollectionView

+ (CCBackUpMnemonicView *)backupViewWithMnemonic:(NSString *)mnemonic viewWidth:(CGFloat)viewWidth viewType:(CCBackUpMnemonicType)viewtype;

@property (nonatomic, assign) CGSize viewSize;

@property (nonatomic, weak) id<CCBackUpMnemonicViewDelegate> backupDelegate;
@property (nonatomic, assign, readonly) CCBackUpMnemonicType type;

///CCBackUpMnemonicTypeCancle调用
- (void)addOrCancelModel:(CCBackUpMnemonicModel *)model;
- (BOOL)verifyMnemonic;

///CCBackUpMnemonicTypeVerify调用
- (void)selectedChangeModel:(CCBackUpMnemonicModel *)model;

@end


@interface CCBackUpMnemonicModel : NSObject

@property (nonatomic, strong) NSString *mnemonic;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL selected;

@end


@interface CCBackUpMnemonicCell : UICollectionViewCell

- (void)bindCellWithModel:(CCBackUpMnemonicModel *)model withType:(CCBackUpMnemonicType)type;

@end
