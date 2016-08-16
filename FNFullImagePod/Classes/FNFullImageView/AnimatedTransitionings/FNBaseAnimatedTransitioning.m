//
//  FNBaseAnimatedTransitioning.m
//  TestFullImageView
//
//  Created by JR on 16/8/1.
//  Copyright © 2016年 JR. All rights reserved.
//

#import "FNBaseAnimatedTransitioning.h"

@implementation FNBaseAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.26;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *containerView = [transitionContext containerView];
    
    CGRect finalFrameForToVC = [transitionContext finalFrameForViewController:toVC];
    toView.frame = finalFrameForToVC;
    [toView layoutIfNeeded];
    
    if (self.operation == UINavigationControllerOperationPush) {
        CGRect frame = toView.frame;
        frame.origin.x = fromView.frame.origin.x + fromView.frame.size.width;
        toView.frame = frame;
        [containerView addSubview:toView];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            toView.frame = finalFrameForToVC;
            
            CGRect frame = fromView.frame;
            frame.origin.x = frame.origin.x - frame.size.width / 3.0;
            fromView.frame = frame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    } else if (self.operation == UINavigationControllerOperationPop) {
        CGRect frame = toView.frame;
        frame.origin.x = fromView.frame.origin.x - toView.frame.size.width / 3.0;
        toView.frame = frame;
        [containerView insertSubview:toView belowSubview:fromView];
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            toView.frame = finalFrameForToVC;
            
            CGRect frame = fromView.frame;
            frame.origin.x = frame.origin.x + frame.size.width;
            fromView.frame = frame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    } else {
        [containerView addSubview:toView];
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }
}

#pragma mark - UIViewControllerTransitioningDelegate methods
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}

@end
