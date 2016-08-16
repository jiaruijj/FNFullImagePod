//
//  FNPresentPageAnimation.m
//  FNFullImageDemo
//
//  Created by JR on 16/8/10.
//  Copyright © 2016年 JR. All rights reserved.
//

#import "FNPresentPageAnimation.h"

@implementation FNPresentPageAnimation


// 返回动画的时间
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.8;
}
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *containerView = [transitionContext containerView];
    
    toView.frame = [transitionContext finalFrameForViewController:toVC];
    [toView layoutIfNeeded];
    
    if (!self.presented) {
        [containerView addSubview:toView];
        toView.alpha = 0.0;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toView.alpha = 1.0;
        } completion:^(BOOL finished) {
            self.presented = YES;
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    } else if (self.presented) {
        [containerView insertSubview:toView belowSubview:fromView];
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.presented = NO;
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    } else {
        [super animateTransition:transitionContext];
    }
}

@end
