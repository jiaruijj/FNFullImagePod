//
//  FNCoverVerticalAnimatedTransitioning.m
//  TestFullImageView
//
//  Created by JR on 16/8/1.
//  Copyright © 2016年 JR. All rights reserved.
//

#import "FNCoverVerticalAnimatedTransitioning.h"
#import "FNSnapshot.h"

@interface FNCoverVerticalAnimatedTransitioning ()
@property (nonatomic, strong) NSMutableArray *snapshots;
@end

@implementation FNCoverVerticalAnimatedTransitioning
- (NSMutableArray *)snapshots {
    if (!_snapshots) {
        _snapshots = [NSMutableArray array];
    }
    return _snapshots;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.4;
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
    
    UIColor *originalColor = keyWindow.backgroundColor;
    UIColor *newColor = toView.backgroundColor;
    if ([toVC conformsToProtocol:@protocol(FNTransitioningDelegate)] && [(id<FNTransitioningDelegate>)toVC respondsToSelector:@selector(transitioningInfoAsTo:context:)]) {
        newColor = [[(id<FNTransitioningDelegate>)toVC transitioningInfoAsTo:self context:transitionContext] valueForKey:FNCoverVerticalAnimatedTransitioningInfoBackgroundColorKey];
    }
    
    CGFloat ratio = 0.50;
    CGFloat offset = 4;
    if (self.operation == UINavigationControllerOperationPush) {
        keyWindow.backgroundColor = newColor;
        
        UIView *snapshotView = [baseView snapshotViewAfterScreenUpdates:NO];
        snapshotView.frame = baseView.frame;
        [keyWindow addSubview:snapshotView];
        [containerView addSubview:toView];
        
        CGRect originalFrame = baseView.frame;
        CGRect newFrame = baseView.frame;
        if (self.direction == FNCoverDirectionFromTop) {
            newFrame.origin.y -= newFrame.size.height;
        } else if (self.direction == FNCoverDirectionFromBottom) {
            newFrame.origin.y += newFrame.size.height;
        }
        baseView.frame = newFrame;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] * ratio delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            CGRect frame = snapshotView.frame;
            if (self.direction == FNCoverDirectionFromTop) {
                frame.origin.y += frame.size.height;
            } else if (self.direction == FNCoverDirectionFromBottom) {
                frame.origin.y -= frame.size.height;
            }
            snapshotView.frame = frame;
            
            frame = originalFrame;
            if (self.direction == FNCoverDirectionFromTop) {
                frame.origin.y += offset;
            } else if (self.direction == FNCoverDirectionFromBottom) {
                frame.origin.y -= offset;
            }
            baseView.frame = frame;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:[self transitionDuration:transitionContext] * (1 - ratio) delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                baseView.frame = originalFrame;
            } completion:^(BOOL finished) {
                keyWindow.backgroundColor = originalColor;
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
            keyWindow.backgroundColor = newColor;
            
            UIView *snapshotView = result.snapshotView;
            [keyWindow addSubview:snapshotView];
            
            CGRect originalFrame = baseView.frame;
            CGRect newFrame = originalFrame;
            if (self.direction == FNCoverDirectionFromTop) {
                newFrame.origin.y += newFrame.size.height;
            } else if (self.direction == FNCoverDirectionFromBottom) {
                newFrame.origin.y -= newFrame.size.height;
            }
            snapshotView.frame = newFrame;
            
            [UIView animateWithDuration:[self transitionDuration:transitionContext] * ratio delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                CGRect frame = baseView.frame;
                if (self.direction == FNCoverDirectionFromTop) {
                    frame.origin.y -= newFrame.size.height;
                } else if (self.direction == FNCoverDirectionFromBottom) {
                    frame.origin.y += newFrame.size.height;
                }
                baseView.frame = frame;
                
                frame = originalFrame;
                if (self.direction == FNCoverDirectionFromTop) {
                    frame.origin.y -= offset;
                } else if (self.direction == FNCoverDirectionFromBottom) {
                    frame.origin.y += offset;
                }
                snapshotView.frame = frame;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:[self transitionDuration:transitionContext] * (1 - ratio) delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    snapshotView.frame = originalFrame;
                } completion:^(BOOL finished) {
                    keyWindow.backgroundColor = originalColor;
                    
                    baseView.frame = originalFrame;
                    [containerView addSubview:toView];
                    [snapshotView removeFromSuperview];
                    [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                }];
            }];
        } else {
            [super animateTransition:transitionContext];
        }
    } else {
        [super animateTransition:transitionContext];
    }
}

@end
