//
//  CCUploadDeviceRequest.h
//  Karathen
//
//  Created by Karathen on 2018/10/26.
//  Copyright © 2018 raistone. All rights reserved.
//

#import "CCRequest.h"

@interface CCUploadDeviceRequest : CCRequest

@property (nonatomic, strong) NSDictionary *addressDic;

- (void)uploadRequet:(void(^)(void))completion;

@end
