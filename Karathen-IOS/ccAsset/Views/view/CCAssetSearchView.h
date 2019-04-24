//
//  CCAssetSearchView.h
//  ccAsset
//
//  Created by SealWallet on 2018/9/3.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCAssetSearchView;
@protocol CCAssetSearchViewDelegate <NSObject>

@optional
- (void)textFieldBeginEdit:(CCAssetSearchView *)searchView;
- (void)textFieldEndEdit:(CCAssetSearchView *)searchView;
- (void)textFieldSearch:(CCAssetSearchView *)searchView keyword:(NSString *)keyword;

@end

@interface CCAssetSearchView : UIView

@property (nonatomic, strong, readonly) UITextField *textField;

@property (nonatomic, weak) id<CCAssetSearchViewDelegate> delegate;

@end
