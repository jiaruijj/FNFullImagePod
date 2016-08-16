//
//  FNFadeAnimatedTransitioning.m
//  TestFullImageView
//
//  Created by JR on 16/8/1.
//  Copyright © 2016年 JR. All rights reserved.
//

#import "FNFadeAnimatedTransitioning.h"

@implementation FNFadeAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.30;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *containerView = [transitionContext containerView];
    
    toView.frame = [transitionContext finalFrameForViewController:toVC];
    [toView layoutIfNeeded];
    
    if (self.operation == UINavigationControllerOperationPush) {
        [containerView addSubview:toView];
        toView.alpha = 0.0;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toView.alpha = 1.0;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    } else if (self.operation == UINavigationControllerOperationPop) {
        [containerView insertSubview:toView belowSubview:fromView];
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    } else {
        [super animateTransition:transitionContext];
    }
}

@end
