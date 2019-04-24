//
//  ONTStruct.h
//  ONTWallet
//
//  Created by Yuzhiyou on 2018/7/25.
//  Copyright © 2018年 Yuzhiyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ONTStruct : NSObject
@property (nonatomic,strong) NSMutableArray *array;

-(void)add:(NSObject *)o;
@end


@interface ONTStructs : NSObject
@property (nonatomic,strong) NSMutableArray<ONTStruct *> *structs;

-(void)add:(ONTStruct *)o;
@end
