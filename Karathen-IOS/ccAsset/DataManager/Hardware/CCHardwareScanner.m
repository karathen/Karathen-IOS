//
//  CCHardwareScanner.m
//  ccAsset
//
//  Created by SealWallet on 2018/11/22.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCHardwareScanner.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <iOS_EWalletDynamic/PA_EWallet.h>
#import "StructHeaderFile.h"

static const NSString *deviceName = @"WOOKONG BIO";

@interface CCHardwareScanner ()

@property (nonatomic, strong) NSMutableArray *devices;
@property (nonatomic, assign) BOOL scanning;

@end

@implementation CCHardwareScanner

- (instancetype)init {
    if (self = [super init]) {
        scanner = self;
    }
    return self;
}

#pragma mark - 扫描设备
- (void)scanHardwareDevices {
    if (self.scanning) {
        return;
    }
    self.scanning = YES;
    [self clearDevice];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(scanDeviceStartWithScanner:)]) {
        [self.delegate scanDeviceStartWithScanner:self];
    }
    __block unsigned char nDeviceType = PAEW_DEV_TYPE_BT;
    __block char *szDeviceNames = (char *)malloc(512*16);
    __block size_t nDeviceNameLen = 512*16;
    __block size_t nDevCount = 0;
    __block EnumContext DevContext = {0};
    DevContext.timeout = 10;
    DevContext.enumCallBack = EnumCallback;
    strcpy(DevContext.searchName, [[deviceName stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet] UTF8String]);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int devInfoState = PAEW_GetDeviceListWithDevContext(nDeviceType, szDeviceNames, &nDeviceNameLen, &nDevCount, &DevContext, sizeof(DevContext));
        dispatch_async(dispatch_get_main_queue(), ^{
            self.scanning = NO;
            if (devInfoState == 0) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(scanDeviceEndWithScanner:)]) {
                    [self.delegate scanDeviceEndWithScanner:self];
                }
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(scanDeviceFailWithScanner:)]) {
                    [self.delegate scanDeviceFailWithScanner:self];
                }
            }
            free(szDeviceNames);
        });
    });
}

- (void)clearDevice {
    [self.devices removeAllObjects];
    if (self.delegate && [self.delegate respondsToSelector:@selector(hardwareDevicesChangeWithScanner:)]) {
        [self.delegate hardwareDevicesChangeWithScanner:self];
    }
}

- (void)addDevice:(CCHardwareDevice *)device {
    [self.devices addObject:device];
    if (self.delegate && [self.delegate respondsToSelector:@selector(hardwareDevicesChangeWithScanner:)]) {
        [self.delegate hardwareDevicesChangeWithScanner:self];
    }
}

static CCHardwareScanner *scanner =nil;

//扫描设备的回调方法
int EnumCallback(const char *szDevName, int nRSSI, int nState)
{
    CCHardwareDevice *device = [[CCHardwareDevice alloc] init];
    device.peripheralName = [NSString stringWithUTF8String:szDevName];
    device.RSSI = nRSSI;
    device.state = nState;
    [scanner addDevice:device];
    return PAEW_RET_SUCCESS;
}

#pragma mark - get
- (NSMutableArray *)devices {
    if (!_devices) {
        _devices = [NSMutableArray array];
    }
    return _devices;
}

@end

@implementation CCHardwareDevice

- (BOOL)isConnected {
    return self.state == CBPeripheralStateConnected;
}

@end
