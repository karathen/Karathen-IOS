//
//  CCWalletListCell.h
//  Karathen
//
//  Created by Karathen on 2018/7/19.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCBottomLineTableViewCell.h"

@interface CCWalletListCell : CCBottomLineTableViewCell

- (void)bindCellWithWallet:(CCWalletData *)wallet;

@end
