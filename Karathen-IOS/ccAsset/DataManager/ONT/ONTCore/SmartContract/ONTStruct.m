//
//  ONTStruct.m
//  ONTWallet
//
//  Created by Yuzhiyou on 2018/7/25.
//  Copyright © 2018年 Yuzhiyou. All rights reserved.
//

#import "ONTStruct.h"

@implementation ONTStruct
-(instancetype)init{
    self = [super init];
    if (self) {
        _array = [NSMutableArray new];
    }
    return self;
}


-(void)add:(NSObject *)o{
    if (o) {
        [_array addObject:o];
    }
}
@end
@implementation ONTStructs
-(instancetype)init{
    self = [super init];
    if (self) {
        _structs = [NSMutableArray new];
    }
    return self;
}

-(void)add:(NSObject *)o{
    if (o) {
        [_structs addObject:o];
    }
}
@end
