//
//  CCTableView.h
//  ccAsset
//
//  Created by SealWallet on 2018/8/31.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCTableView : UITableView

/**
 批量注册cell

 @param cells cell Class 数组
 */
- (void)registerClassCells:(NSArray <Class> *)cells;



@end
