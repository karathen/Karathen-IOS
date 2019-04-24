//
//  CCSubLBXScanViewController+ScanQR.h
//  ccAsset
//
//  Created by SealWallet on 2018/8/1.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCSubLBXScanViewController.h"

@interface CCSubLBXScanViewController (ScanQR)

+ (CCSubLBXScanViewController *)customScanVC;


/**
 根据style获取提示中心位置的frame

 @param style LBXScanViewStyle
 @param scanView LBXScanView
 @return rect
 */
- (CGRect)centerViewRectWithStyle:(LBXScanViewStyle *)style withViewFrame:(LBXScanView *)scanView;

@end
