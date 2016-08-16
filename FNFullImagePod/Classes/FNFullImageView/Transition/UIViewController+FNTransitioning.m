//
//  UIViewController+FNTransitioning.m
//  TestFullImageView
//
//  Created by JR on 16/8/1.
//  Copyright © 2016年 JR. All rights reserved.
//

#import "UIViewController+FNTransitioning.h"
#import <objc/runtime.h>

@implementation UIViewController (FNTransitioning)

//getter
- (FNNavigationTransitioningStyle)navigationTransitioningStyle {
    NSNumber *style = objc_getAssociatedObject(self, @selector(navigationTransitioningStyle));
    if (!style) {
        style = @(FNNavigationTransitioningStyleNone);
        self.navigationTransitioningStyle = [style unsignedIntegerValue];
    }
    return [style unsignedIntegerValue];
}

//setter
- (void)setNavigationTransitioningStyle:(FNNavigationTransitioningStyle)navigationTransitioningStyle {
    objc_setAssociatedObject(self, @selector(navigationTransitioningStyle), @(navigationTransitioningStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//设置系统转场动画
- (void)animationWithType:(NSString *)type subType:(NSString *)subType duration:(CFTimeInterval) duration{
    UIView * view = self.navigationController.view;
    CATransition * tran=[CATransition animation];
    tran.type = type;
    [self.view.layer addAnimation:tran forKey:@"type"];
    tran.subtype = subType;
    tran.duration = duration;
    tran.delegate = self;
    [view.layer addAnimation:tran forKey:@"aniKey"];
}
@end
