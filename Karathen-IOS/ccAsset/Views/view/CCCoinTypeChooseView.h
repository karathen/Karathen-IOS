//
//  CCCoinTypeChooseView.h
//  ccAsset
//
//  Created by SealWallet on 2018/11/27.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "MLMOptionSelectView.h"
#import "CCTableViewCell.h"

@class CCCoinTypeChooseView;
@protocol CCCoinTypeChooseViewDelegate <NSObject>

@optional
- (void)chooseView:(CCCoinTypeChooseView *)chooseView coinType:(CCCoinType)coinType;

@end

@interface CCCoinTypeChooseView : MLMOptionSelectView

@property (nonatomic, assign) CCImportType importType;
@property (nonatomic, assign) CCCoinType chooseType;

@property (nonatomic, weak) id <CCCoinTypeChooseViewDelegate> chooseDelegate;

- (NSArray *)coins;
- (instancetype)initWithImportType:(CCImportType)importType chooseType:(CCCoinType)chooseType;
- (void)showTargetView:(UIView *)view space:(CGFloat)space;

@end


@interface CCCoinTypeChooseCell : CCTableViewCell

- (void)bindCellWithCoinType:(CCCoinType)coinType selected:(BOOL)selected;

@end
