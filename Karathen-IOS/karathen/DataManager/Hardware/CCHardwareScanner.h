//
//  CCHardwareScanner.h
//  karathen
//
//  Created by MengLiMing on 2018/11/22.
//  Copyright © 2018 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCHardwareDevice,CCHardwareScanner;

@protocol CCHardwareScannerDelegate <NSObject>

@optional
//扫描设备变动
- (void)hardwareDevicesChangeWithScanner:(CCHardwareScanner *)scanner;
//扫描设备失败
- (void)scanDeviceFailWithScanner:(CCHardwareScanner *)scanner;
//扫描设备开始
- (void)scanDeviceStartWithScanner:(CCHardwareScanner *)scanner;
//扫描结束
- (void)scanDeviceEndWithScanner:(CCHardwareScanner *)scanner;

@end


@interface CCHardwareScanner : NSObject

@property (nonatomic, assign, readonly) BOOL scanning;
@property (nonatomic, strong, readonly) NSMutableArray *devices;
@property (nonatomic, weak) id <CCHardwareScannerDelegate> delegate;

/**
 扫描硬件设备
 */
- (void)scanHardwareDevices;



@end


@interface CCHardwareDevice : NSObject

@property (nonatomic, strong) NSString *peripheralName;
@property (nonatomic, assign) NSInteger RSSI;
@property (nonatomic, assign) NSInteger state;


/**
 是否已连接

 @return 是否已连接
 */
- (BOOL)isConnected;

@end
