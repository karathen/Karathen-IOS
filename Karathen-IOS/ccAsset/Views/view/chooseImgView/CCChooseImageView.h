//
//  CCChooseImageView.h
//  ccAsset
//
//  Created by SealWallet on 2018/10/26.
//  Copyright © 2018 raistone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCChooseImageView;
@protocol CCChooseImageViewDelegate <NSObject>

@optional
- (void)chooseImageWithView:(CCChooseImageView *)chooseView imageIndex:(NSInteger)index;
- (void)deleteImageWithView:(CCChooseImageView *)chooseView imageIndex:(NSInteger)index;

@end


@interface CCChooseImageView : UIView

@property (nonatomic, weak) id<CCChooseImageViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray <UIImage *> *imageArray;

- (instancetype)initWithTitle:(NSString *)title
                    maxChoose:(NSInteger)maxChoose
                    viewWidth:(CGFloat)viewWidth
                    columnNum:(NSInteger)columnNum;

- (void)reloadData;

@end

@interface CCChooseImageSingle : UIView

@property (nonatomic, strong) UIImageView *closeView;

- (void)bindWithImage:(UIImage *)image;

@end
