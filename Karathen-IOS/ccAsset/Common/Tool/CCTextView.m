//
//  CCTextView.m
//  ccAsset
//
//  Created by SealWallet on 2018/7/17.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCTextView.h"

@implementation CCTextView

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    CGRect originalRect = [super caretRectForPosition:position];
    originalRect.size.height = self.font.lineHeight;
    
    return originalRect;
}

@end
