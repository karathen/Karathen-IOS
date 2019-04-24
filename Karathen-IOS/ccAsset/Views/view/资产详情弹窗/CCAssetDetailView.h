//
//  CCAssetDetailView.h
//  ccAsset
//
//  Created by SealWallet on 2018/9/4.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "MLMOptionSelectView.h"

@interface CCAssetDetailView : MLMOptionSelectView

@property (nonatomic, weak) CCAsset *asset;

- (void)showTargetView:(UIView *)view;

@end

@interface CCAssetDetailTypeCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLab;

@end

@interface CCAssetDetailBottomCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *tokenLab;
@property (nonatomic, strong) UILabel *descLab;

@end
