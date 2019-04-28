
//
//  CCBlueTooth.m
//  karathen
//
//  Created by MengLiMing on 2018/11/23.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCBlueTooth.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "CCHardwareWallet.h"

static CCBlueTooth *blueTooth =nil;

@interface CCBlueTooth () <CBCentralManagerDelegate>

@property (nonatomic,strong) CBCentralManager *centralManager;
@property (nonatomic,strong) CBPeripheral *peripheral;
@property (nonatomic, assign) BOOL blueToothOpen;

@end

@implementation CCBlueTooth

+ (CCBlueTooth *)blueTooth {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        blueTooth = [[CCBlueTooth alloc] init];
    });
    return blueTooth;
}

#pragma mark - 监控蓝牙状态
- (void)startMonitor {
    if (!blueTooth.centralManager) {
        blueTooth.centralManager = [[CBCentralManager alloc] initWithDelegate:blueTooth queue:nil options:nil];
    }
}



#pragma mark - CBCentralManagerDelegate
-(void)centralManagerDidUpdateState:(CBCentralManager *)central {
    //第一次打开或者每次蓝牙状态改变都会调用这个函数
    if(central.state == CBCentralManagerStatePoweredOn) {
        self.blueToothOpen = YES;
    } else {
        self.blueToothOpen = NO;
        [[CCHardwareWallet hardwareWallet] disconnectDeviceCompletion:nil];
        [[CCHardwareWallet hardwareWallet] resetDevice];
    }
}


@end
