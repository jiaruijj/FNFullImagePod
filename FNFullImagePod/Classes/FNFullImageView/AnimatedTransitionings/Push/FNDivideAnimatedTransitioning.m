//
//  FNDivideAnimatedTransitioning.m
//  TestFullImageView
//
//  Created by JR on 16/8/1.
//  Copyright © 2016年 JR. All rights reserved.
//

#import "FNDivideAnimatedTransitioning.h"
#import "FNDivideSnapshot.h"

@interface FNDivideAnimatedTransitioning ()
@property (nonatomic, strong) NSMutableArray *snapshots;
@end

@implementation FNDivideAnimatedTransitioning
- (NSMutableArray *)snapshots {
    if (!_snapshots) {
        _snapshots = [NSMutableArray array];
    }
    return _snapshots;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.30;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *containerView = [transitionContext containerView];
    
    toView.frame = [transitionContext finalFrameForViewController:toVC];
    [toView layoutIfNeeded];
    
    UIView *baseView = [[fromView.window subviews] firstObject];
    CGFloat width = baseView.bounds.size.width;
    CGFloat height = baseView.bounds.size.height;
    
    if (self.operation == UINavigationControllerOperationPush) {
        CGFloat position = height / 2.0;
        if ([fromVC conformsToProtocol:@protocol(FNTransitioningDelegate)] && [fromVC respondsToSelector:@selector(transitioningInfoAsFrom:context:)]) {
            position = [[[(id<FNTransitioningDelegate>)fromVC transitioningInfoAsFrom:self context:transitionContext] valueForKey:FNDivideAnimatedTransitioningInfoPositionKey] floatValue];
        }
        
        CGRect topFrame = CGRectMake(0, 0, width, position);
        CGRect bottomFrame = CGRectMake(0, position, width, height - position);
        
        UIView *snapshotTop = [baseView resizableSnapshotViewFromRect:topFrame afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
        UIView *snapshotBottom = [baseView resizableSnapshotViewFromRect:bottomFrame afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
        snapshotTop.frame = topFrame;
        snapshotBottom.frame = bottomFrame;
        
        [containerView addSubview:toView];
        [baseView addSubview:snapshotTop];
        [baseView addSubview:snapshotBottom];
        
        topFrame.origin.y = -topFrame.size.height;
        bottomFrame.origin.y = baseView.bounds.size.height;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            snapshotTop.frame = topFrame;
            snapshotTop.alpha = 0;
            
            snapshotBottom.frame = bottomFrame;
            snapshotBottom.alpha = 0;
        } completion:^(BOOL finished) {
            [snapshotTop removeFromSuperview];
            [snapshotBottom removeFromSuperview];
            
            FNDivideSnapshot *snapshot = nil;
            for (FNDivideSnapshot *sp in self.snapshots) {
                if (sp.viewController == fromVC) {
                    snapshot = sp;
                    break;
                }
            }
            if (snapshot) {
                snapshot.snapshotTop = snapshotTop;
                snapshot.snapshotBottom = snapshotBottom;
            } else {
                snapshot = [[FNDivideSnapshot alloc] init];
                snapshot.viewController = fromVC;
                snapshot.snapshotTop = snapshotTop;
                snapshot.snapshotBottom = snapshotBottom;
                [self.snapshots addObject:snapshot];
            }
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    } else if (self.operation == UINavigationControllerOperationPop) {
        FNDivideSnapshot *result = nil;
        for (int i = (int)self.snapshots.count - 1; i >= 0; i--) {
            FNDivideSnapshot *snapshot = [self.snapshots objectAtIndex:i];
            if (snapshot.viewController == toVC) {
                result = snapshot;
                break;
            }
        }
        
        if (result) {
            NSUInteger index = [self.snapshots indexOfObject:result];
            [self.snapshots removeObjectsInRange:NSMakeRange(index, self.snapshots.count - index)];
            if (result.snapshotTop.frame.size.width == baseView.frame.size.height
                || result.snapshotTop.frame.size.height == baseView.frame.size.width) {
                result = nil;
            }
        }
        
        if (result) {
            UIView *snapshotTop = result.snapshotTop;
            UIView *snapshotBottom = result.snapshotBottom;
            
            CGRect topFrame = snapshotTop.frame;
            topFrame.origin.y = - topFrame.size.height;
            snapshotTop.frame = topFrame;
            
            CGRect bottomFrame = snapshotBottom.frame;
            bottomFrame.origin.y = height;
            snapshotBottom.frame = bottomFrame;
            
            snapshotTop.alpha = 0;
            snapshotBottom.alpha = 0;
            [baseView addSubview:snapshotTop];
            [baseView addSubview:snapshotBottom];
            
            topFrame.origin.y = 0;
            bottomFrame.origin.y = height - bottomFrame.size.height;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                snapshotTop.frame = topFrame;
                snapshotTop.alpha = 1.0;
                
                snapshotBottom.frame = bottomFrame;
                snapshotBottom.alpha = 1.0;
            } completion:^(BOOL finished) {
                [containerView addSubview:toView];
                [snapshotTop removeFromSuperview];
                [snapshotBottom removeFromSuperview];
                
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
