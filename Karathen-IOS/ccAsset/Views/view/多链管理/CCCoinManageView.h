//
//  CCCoinManageView.h
//  ccAsset
//
//  Created by SealWallet on 2018/10/19.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCTableView.h"
#import "CCBottomLineTableViewCell.h"

@class CCCoinManageView,CCCoinManageModel;
@protocol CCCoinManageViewDelegate <NSObject>

@optional
- (void)confirmManageView:(CCCoinManageView *)manageView;

@end

@interface CCCoinManageView : CCTableView

@property (nonatomic, weak) id<CCCoinManageViewDelegate> manageDelegate;

- (instancetype)initWithAccount:(CCAccountData *)account;

@end


@protocol CCCoinManageCellDelegate <NSObject>

@optional
- (void)moveCellAction:(UILongPressGestureRecognizer *)longPress;
- (void)changeHiddenWithModel:(CCCoinManageModel *)model;

@end

@interface CCCoinManageCell : CCBottomLineTableViewCell

@property (nonatomic, weak) id<CCCoinManageCellDelegate> delegate;

- (void)bindCellWithModel:(CCCoinManageModel *)model;

@end


@interface CCCoinManageHead : UIView

@end

@interface CCCoinManageModel : NSObject

@property (nonatomic, assign) CCCoinType coinType;
@property (nonatomic, assign) BOOL isHidden;

@end
