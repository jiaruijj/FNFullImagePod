//
//  FNImageAnimatedTransitioning.m
//  TestFullImageView
//
//  Created by JR on 16/8/1.
//  Copyright © 2016年 JR. All rights reserved.
//

#import "FNImageAnimatedTransitioning.h"

@implementation FNImageAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.35;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *containerView = [transitionContext containerView];
    
    CGRect finalFrameForToVC = [transitionContext finalFrameForViewController:toVC];
    toView.frame = finalFrameForToVC;
    [toView layoutIfNeeded];
    
    UIImageView *fromImageView = nil;
    if ([fromVC conformsToProtocol:@protocol(FNTransitioningDelegate)] && [fromVC respondsToSelector:@selector(transitioningInfoAsFrom:context:)]) {
        fromImageView = [[(id<FNTransitioningDelegate>)fromVC transitioningInfoAsFrom:self context:transitionContext] valueForKey:FNImageAnimatedTransitioningInfoImageViewKey];
    }
    UIImageView *toImageView = nil;
    NSValue *endFrameForIV = nil;
    if ([toVC conformsToProtocol:@protocol(FNTransitioningDelegate)] && [toVC respondsToSelector:@selector(transitioningInfoAsTo:context:)]) {
        toImageView = [[(id<FNTransitioningDelegate>)toVC transitioningInfoAsTo:self context:transitionContext] valueForKey:FNImageAnimatedTransitioningInfoImageViewKey];
        endFrameForIV = [[(id<FNTransitioningDelegate>)toVC transitioningInfoAsTo:self context:transitionContext] valueForKey:FNImageAnimatedTransitioningInfoEndFrameForImageViewKey];
    }
    
    if (fromImageView && toImageView && fromImageView.superview && toImageView.superview && endFrameForIV) {
        if (self.operation == UINavigationControllerOperationPush || self.operation == UINavigationControllerOperationPop) {
            CGFloat maskViewAlpha = 0.2;
            UIView *maskViewForFromView = [[UIView alloc] init];
            maskViewForFromView.backgroundColor = [UIColor blackColor];
            maskViewForFromView.frame = fromView.bounds;
            [fromView addSubview:maskViewForFromView];
            maskViewForFromView.alpha = 0.0;
            
            UIView *maskViewForToView = [[UIView alloc] init];
            maskViewForToView.backgroundColor = [UIColor blackColor];
            maskViewForToView.frame = toView.bounds;
            [toView addSubview:maskViewForToView];
            maskViewForToView.alpha = maskViewAlpha;
            
            if (self.operation == UINavigationControllerOperationPush) {
                CGRect frame = toView.frame;
                frame.origin.x = fromView.frame.origin.x + fromView.frame.size.width;
                toView.frame = frame;
                [containerView addSubview:toView];
            } else if (self.operation == UINavigationControllerOperationPop) {
                CGRect frame = toView.frame;
                frame.origin.x = fromView.frame.origin.x - frame.size.width / 3.0;
                toView.frame = frame;
                [containerView insertSubview:toView belowSubview:fromView];
            }
            
            UIImageView *imageView = [self copyOfImageView:toImageView];
            if (toImageView.layer.cornerRadius == fromImageView.layer.cornerRadius) {
                imageView.layer.cornerRadius = toImageView.layer.cornerRadius;
                imageView.layer.borderColor = toImageView.layer.borderColor;
                imageView.layer.borderWidth = toImageView.layer.borderWidth;
            }
            imageView.frame = [containerView convertRect:fromImageView.frame fromView:fromImageView.superview] ;
            [containerView addSubview:imageView];
            
            fromImageView.hidden = YES;
            toImageView.hidden = YES;
            
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations: ^{
                maskViewForFromView.alpha = maskViewAlpha;
                maskViewForToView.alpha = 0.0;
                
                toView.frame = finalFrameForToVC;
                
                if (self.operation == UINavigationControllerOperationPush) {
                    CGRect frame = fromView.frame;
                    frame.origin.x = frame.origin.x - frame.size.width / 3.0;
                    fromView.frame = frame;
                } else if (self.operation == UINavigationControllerOperationPop) {
                    CGRect frame = fromView.frame;
                    frame.origin.x = frame.origin.x + frame.size.width;
                    fromView.frame = frame;
                }
                
                imageView.frame = [endFrameForIV CGRectValue];
            } completion:^(BOOL finished) {
                [maskViewForFromView removeFromSuperview];
                [maskViewForToView removeFromSuperview];
                
                fromImageView.hidden = NO;
                toImageView.hidden = NO;
                [imageView removeFromSuperview];
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            }];
        } else {
            [super animateTransition:transitionContext];
        }
    } else {
        [super animateTransition:transitionContext];
    }
}

- (UIImageView *)copyOfImageView:(UIImageView *)imageView {
    UIImageView *dummyImageView = [[UIImageView alloc] init];
    dummyImageView.contentMode = imageView.contentMode;
    dummyImageView.image = imageView.image;
    dummyImageView.clipsToBounds = imageView.clipsToBounds;
    return dummyImageView;
}
@end
