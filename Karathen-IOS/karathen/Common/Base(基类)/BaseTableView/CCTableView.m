//
//  CCTableView.m
//  Karathen
//
//  Created by Karathen on 2018/8/31.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCTableView.h"

@implementation CCTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        self.separatorStyle = 0;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


- (void)registerClassCells:(NSArray<Class> *)cells {
    for (Class class in cells) {
        [self registerClass:class forCellReuseIdentifier:NSStringFromClass(class)];
    }
}


@end
