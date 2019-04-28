//
//  CCSubLBXScanViewController+ScanQR.m
//  Karathen
//
//  Created by Karathen on 2018/8/1.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCSubLBXScanViewController+ScanQR.h"
#import "LBXScanViewStyle.h"
#import "UIImageTool.h"

@implementation CCSubLBXScanViewController (ScanQR)


+ (CCSubLBXScanViewController *)customScanVC {
    CCSubLBXScanViewController *scanVC = [[CCSubLBXScanViewController alloc] init];
    
    //使用的扫码库
    scanVC.libraryType = SLT_Native;
    //识别码制
    if (scanVC.libraryType != SLT_ZXing) {
        scanVC.scanCodeType = SCT_QRCode;
    }
    //style
    scanVC.style = [scanVC customStyle];
    //
    scanVC.qRScanView = [[LBXScanView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_AND_NAVIGATION_HEIGHT) style:[scanVC customStyle]];
    [scanVC.view addSubview:scanVC.qRScanView];
    
    return scanVC;
}

#pragma mark - 根据style获取提示中心位置的frame
- (CGRect)centerViewRectWithStyle:(LBXScanViewStyle *)style withViewFrame:(LBXScanView *)scanView {
    CGFloat width = SCREEN_WIDTH-2*style.xScanRetangleOffset;
    CGFloat height = width/style.whRatio;
    CGFloat x = style.xScanRetangleOffset;
    CGFloat y =  scanView.cc_height/2.0 - height/2.0 - style.centerUpOffset;
    return CGRectMake(x, y, width, height);
}

#pragma mark - LBXScanViewStyle
//自定义style
- (LBXScanViewStyle *)customStyle {
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc] init];
    
    //向上偏移
    style.centerUpOffset = FitScale(14);
    //边缘距离
    style.xScanRetangleOffset = FitScale(85);
    //四个角的风格
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Outer;
    //四个角的颜色
    style.colorAngle = [UIColor whiteColor];
    //线的颜色
    style.colorRetangleLine = [UIColor clearColor];
    //四个角的线条宽度
    style.photoframeLineW = FitScale(2);
    //扫码框周围4个角的宽度
    style.photoframeAngleW = FitScale(16);
    //扫码框周围4个角的高度
    style.photoframeAngleH = FitScale(16);
    
    return style;
}



@end
