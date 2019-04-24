//
//  CCWalletTextFieldEditView.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/12.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWalletEditView.h"
#import "NumberTF.h"

@interface CCWalletTextFieldEditView : CCWalletEditView

@property (nonatomic, strong, readonly) NumberTF *textField;

- (NSString *)text;
- (void)setText:(NSString *)text;


/**
 清空文字
 */
- (void)clearText;

@end
