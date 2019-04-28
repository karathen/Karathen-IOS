//
//  CCTableViewCell.m
//  Karathen
//
//  Created by Karathen on 2018/7/10.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCTableViewCell.h"

@implementation CCTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = 0;
    }
    return self;
}

@end
