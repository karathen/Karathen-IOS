//
//  MLMSegmentManager.m
//  MLMSegmentPage
//
//  Created by my on 2017/2/5.
//  Copyright © 2017年 my. All rights reserved.
//

#import "MLMSegmentManager.h"


@implementation MLMSegmentManager




+ (void)associateHead:(MLMSegmentHead *)head
           withScroll:(MLMSegmentScroll *)scroll
           completion:(void(^)())completion {
    [MLMSegmentManager associateHead:head withScroll:scroll contentChangeAni:YES completion:completion selectEnd:nil];
}


+ (void)associateHead:(MLMSegmentHead *)head
           withScroll:(MLMSegmentScroll *)scroll
     contentChangeAni:(BOOL)ani
           completion:(void(^)())completion
            selectEnd:(void(^)(NSInteger index))selectEnd {

    NSInteger showIndex;
    showIndex = head.showIndex?head.showIndex:scroll.showIndex;
    
    head.showIndex = showIndex;
    [head defaultAndCreateView];
    
    @weakify(scroll)
    head.selectedIndex = ^(NSInteger index) {
        @strongify(scroll)
        dispatch_async(dispatch_get_main_queue(), ^{
            [scroll setContentOffset:CGPointMake(index*scroll.width, 0) animated:ani];
        });
    };
    
    if (completion) {
        completion();
    }
    
    @weakify(head)
    scroll.scrollEnd = ^(NSInteger index) {
        @strongify(head)
        [head setSelectIndex:index];
        [head animationEnd];
        if (selectEnd) {
            selectEnd(index);
        }
    };
    scroll.animationEnd = ^(NSInteger index) {
        @strongify(head)
        [head setSelectIndex:index];
        [head animationEnd];
        if (selectEnd) {
            selectEnd(index);
        }
    };
    scroll.offsetScale = ^(CGFloat scale) {
        @strongify(head)
        [head changePointScale:scale];
    };
    
    
    scroll.showIndex = showIndex;
    [scroll createView];
    
    UIView *view = head.nextResponder?head:scroll;
    UIViewController *currentVC = [view viewController];
    currentVC.automaticallyAdjustsScrollViewInsets = NO;
}


@end
