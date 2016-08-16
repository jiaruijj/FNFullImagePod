//
//  FNResignLeftAnimatedTransitioning.m
//  TestFullImageView
//
//  Created by JR on 16/8/1.
//  Copyright © 2016年 JR. All rights reserved.
//

#import "FNResignLeftAnimatedTransitioning.h"
#import "FNSnapshot.h"

@interface FNResignLeftAnimatedTransitioning ()
@property (nonatomic, strong) NSMutableArray *snapshots;
@end

@implementation FNResignLeftAnimatedTransitioning
- (NSMutableArray *)snapshots {
    if (!_snapshots) {
        _snapshots = [NSMutableArray array];
    }
    return _snapshots;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.35;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *containerView = [transitionContext containerView];
    
    toView.frame = [transitionContext finalFrameForViewController:toVC];
    [toView layoutIfNeeded];
    
    UIWindow *keyWindow = fromView.window;
    UIView *baseView = [[keyWindow subviews] firstObject];
    NSInteger tag = 1203;
    
    if (self.operation == UINavigationControllerOperationPush) {
        UIView *snapshotView = [baseView snapshotViewAfterScreenUpdates:NO];
        snapshotView.frame = baseView.frame;
        UIView *maskView = [[UIView alloc] initWithFrame:snapshotView.bounds];
        maskView.backgroundColor = [UIColor blackColor];
        maskView.alpha = 0.0;
        maskView.tag = tag;
        [snapshotView addSubview:maskView];
        
        [containerView addSubview:toView];
        [keyWindow addSubview:snapshotView];
        [keyWindow bringSubviewToFront:baseView];
        
        CGRect originalFrame = baseView.frame;
        CGRect newFrame = baseView.frame;
        newFrame.origin.x = newFrame.origin.x + newFrame.size.width;
        baseView.frame = newFrame;
        
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1.0/750;
        transform = CATransform3DTranslate(transform, 0, 0, -50);
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            baseView.frame = originalFrame;
            snapshotView.layer.transform = transform;
            maskView.alpha = 0.35;
        } completion:^(BOOL finished) {
            [snapshotView removeFromSuperview];
            
            FNSnapshot *snapshot = nil;
            for (FNSnapshot *sp in self.snapshots) {
                if (sp.viewController == fromVC) {
                    snapshot = sp;
                    break;
                }
            }
            if (snapshot) {
                snapshot.snapshotView = snapshotView;
            } else {
                snapshot = [[FNSnapshot alloc] init];
                snapshot.snapshotView = snapshotView;
                snapshot.viewController = fromVC;
                [self.snapshots addObject:snapshot];
            }
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    } else if (self.operation == UINavigationControllerOperationPop) {
        FNSnapshot *result = nil;
        for (int i = (int)self.snapshots.count - 1; i >= 0; i--) {
            FNSnapshot *snapshot = [self.snapshots objectAtIndex:i];
            if (snapshot.viewController == toVC) {
                result = snapshot;
                break;
            }
        }
        
        if (result) {
            NSUInteger index = [self.snapshots indexOfObject:result];
            [self.snapshots removeObjectsInRange:NSMakeRange(index, self.snapshots.count - index)];
            if (result.snapshotView.frame.size.width == baseView.frame.size.height || result.snapshotView.frame.size.height == baseView.frame.size.width) {
                result = nil;
            }
        }
        
        if (result) {
            UIView *snapshotView = result.snapshotView;
            UIView *maskView = [snapshotView viewWithTag:tag];
            
            [keyWindow addSubview:snapshotView];
            [keyWindow bringSubviewToFront:baseView];
            
            CGRect originalFrame = baseView.frame;
            CGRect newFrame = baseView.frame;
            newFrame.origin.x = newFrame.origin.x + newFrame.size.width;
            
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                maskView.alpha = 0.0;
                snapshotView.layer.transform = CATransform3DIdentity;
                baseView.frame = newFrame;
            } completion:^(BOOL finished) {
                baseView.frame = originalFrame;
                [containerView addSubview:toView];
                [snapshotView removeFromSuperview];
                
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            }];
        } else {
            [super animateTransition:transitionContext];
        }
    } else {
        [super animateTransition:transitionContext];
    }
}
@end
