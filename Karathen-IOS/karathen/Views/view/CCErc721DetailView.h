//
//  CCErc721DetailView.h
//  Karathen
//
//  Created by Karathen on 2018/9/14.
//  Copyright © 2018年 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCErc721TokenInfoModel;

@interface CCErc721DetailView : UIView

- (void)bindTokenModel:(CCErc721TokenInfoModel *)tokenModel withAsset:(CCAsset *)asset;


- (void)bindUrl:(NSString *)url withTokenId:(NSString *)tokenId;

@end
