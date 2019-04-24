//
//  CCLanguageSetCell.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/11.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCBottomLineTableViewCell.h"

@interface CCLanguageSetCell : CCBottomLineTableViewCell

//语言
- (void)bindCellWithLanguage:(NSString *)language;

//货币
- (void)bindCellWithUnit:(NSString *)unit;

@end
