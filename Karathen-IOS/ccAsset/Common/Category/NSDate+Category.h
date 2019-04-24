//
//  NSDate+Category.h
//  ccAsset
//
//  Created by SealWallet on 2018/7/25.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Category)

+ (NSString *)timeWithTimeStamp:(NSTimeInterval)timeStamp dateFormatter:(NSString *)dateFormatter;

@end
