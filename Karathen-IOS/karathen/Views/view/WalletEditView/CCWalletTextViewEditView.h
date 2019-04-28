//
//  CCWalletTextViewEditView.h
//  Karathen
//
//  Created by Karathen on 2018/7/17.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import "CCWalletEditView.h"
#import "CCTextView.h"

@interface CCWalletTextViewEditView : CCWalletEditView

@property (nonatomic, strong, readonly) CCTextView *textView;

- (NSString *)text;

@end
