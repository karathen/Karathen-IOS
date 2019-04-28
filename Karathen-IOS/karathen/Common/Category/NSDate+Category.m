//
//  NSDate+Category.m
//  Karathen
//
//  Created by Karathen on 2018/7/25.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "NSDate+Category.h"

@implementation NSDate (Category)

+ (NSString *)timeWithTimeStamp:(NSTimeInterval)timeStamp dateFormatter:(NSString *)dateFormatter {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = dateFormatter;
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    return [dateFormat stringFromDate:date];
}

@end
