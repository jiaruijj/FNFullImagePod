//
//  UINavigationController+FNTransitioning.m
//  TestFullImageView
//
//  Created by JR on 16/8/1.
//  Copyright © 2016年 JR. All rights reserved.
//

#import <objc/runtime.h>
#import "UINavigationController+FNTransitioning.h"
#import "FNTransitioningCache.h"

typedef enum : NSUInteger {
    TransitioningSourceDefault,
    TransitioningSourceViewController,
    TransitioningSourceDelegate,
} TransitioningSource;

@interface TransitioningProxy : NSProxy <UINavigationControllerDelegate>
@property (nonatomic, weak) id<UINavigationControllerDelegate> delegate;
@property (nonatomic, assign) BOOL symmetrical;
@property (nonatomic, assign) TransitioningSource source;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, strong) NSMutableArray *transitioningCaches;

@property (nonatomic, assign) FNNavigationTransitioningStyle transitioningStyle;
@property (nonatomic, weak) FNBaseAnimatedTransitioning *animatedTransitioning;
@property (nonatomic, strong) FNFadeAnimatedTransitioning *fadeAnimatedTransitioning;
@property (nonatomic, strong) FNDivideAnimatedTransitioning *divideAnimatedTransitioning;
@property (nonatomic, strong) FNResignTopAnimatedTransitioning *resignTopAnimatedTransitioning;
@property (nonatomic, strong) FNResignLeftAnimatedTransitioning *resignLeftAnimatedTransitioning;
@property (nonatomic, strong) FNFlipOverAnimatedTransitioning *flipOverAnimatedTransitioning;
@property (nonatomic, strong) FNImageAnimatedTransitioning *imageAnimatedTransitioning;
@property (nonatomic, strong) FNCoverVerticalAnimatedTransitioning *coverVerticalAnimatedTransitioning;

@end

@implementation TransitioningProxy
- (instancetype)init
{
    _delegate = nil;
    _symmetrical = YES;
    _source = TransitioningSourceDefault;
    _viewController = nil;
    _transitioningCaches = [NSMutableArray array];
    _transitioningStyle = FNNavigationTransitioningStyleSystem;
    _animatedTransitioning = nil;
    return self;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation setTarget:self.delegate];
    [invocation invoke];
    return;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [(id)self.delegate methodSignatureForSelector:sel];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (sel_isEqual(aSelector, @selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)) || sel_isEqual(aSelector, @selector(navigationController:interactionControllerForAnimationController:))) {
        return YES;
    }
    return [self.delegate respondsToSelector:aSelector];
}

#pragma mark - Property
- (void)setTransitioningStyle:(FNNavigationTransitioningStyle)transitioningStyle {
    _transitioningStyle = transitioningStyle;
    self.animatedTransitioning = [self p_animatedTransitioningForStyle:self.transitioningStyle];
}

- (FNFadeAnimatedTransitioning *)fadeAnimatedTransitioning {
    if (!_fadeAnimatedTransitioning) {
        _fadeAnimatedTransitioning = [[FNFadeAnimatedTransitioning alloc] init];
    }
    return _fadeAnimatedTransitioning;
}

- (FNDivideAnimatedTransitioning *)divideAnimatedTransitioning {
    if (!_divideAnimatedTransitioning) {
        _divideAnimatedTransitioning = [[FNDivideAnimatedTransitioning alloc] init];
    }
    return _divideAnimatedTransitioning;
}

- (FNResignTopAnimatedTransitioning *)resignTopAnimatedTransitioning {
    if (!_resignTopAnimatedTransitioning) {
        _resignTopAnimatedTransitioning = [[FNResignTopAnimatedTransitioning alloc] init];
    }
    return _resignTopAnimatedTransitioning;
}

- (FNResignLeftAnimatedTransitioning *)resignLeftAnimatedTransitioning {
    if (!_resignLeftAnimatedTransitioning) {
        _resignLeftAnimatedTransitioning = [[FNResignLeftAnimatedTransitioning alloc] init];
    }
    return _resignLeftAnimatedTransitioning;
}

- (FNFlipOverAnimatedTransitioning *)flipOverAnimatedTransitioning {
    if (!_flipOverAnimatedTransitioning) {
        _flipOverAnimatedTransitioning = [[FNFlipOverAnimatedTransitioning alloc] init];
    }
    return _flipOverAnimatedTransitioning;
}

- (FNImageAnimatedTransitioning *)imageAnimatedTransitioning {
    if (!_imageAnimatedTransitioning) {
        _imageAnimatedTransitioning = [[FNImageAnimatedTransitioning alloc] init];
    }
    return _imageAnimatedTransitioning;
}

- (FNCoverVerticalAnimatedTransitioning *)coverVerticalAnimatedTransitioning {
    if (!_coverVerticalAnimatedTransitioning) {
        _coverVerticalAnimatedTransitioning = [[FNCoverVerticalAnimatedTransitioning alloc] init];
        _coverVerticalAnimatedTransitioning.direction = FNCoverDirectionFromTop;
    }
    return _coverVerticalAnimatedTransitioning;
}

#pragma mark - Private
- (FNBaseAnimatedTransitioning *)p_animatedTransitioningForStyle:(FNNavigationTransitioningStyle)style {
    FNBaseAnimatedTransitioning *animatedTransitioning = nil;
    switch (style) {
        case FNNavigationTransitioningStyleSystem:
            animatedTransitioning = nil;
            break;
        case FNNavigationTransitioningStyleFade:
            animatedTransitioning = self.fadeAnimatedTransitioning;
            break;
        case FNNavigationTransitioningStyleDivide:
            animatedTransitioning = self.divideAnimatedTransitioning;
            break;
        case FNNavigationTransitioningStyleResignTop:
            animatedTransitioning = self.resignTopAnimatedTransitioning;
            break;
        case FNNavigationTransitioningStyleResignLeft:
            animatedTransitioning = self.resignLeftAnimatedTransitioning;
            break;
        case FNNavigationTransitioningStyleFlipOver:
            animatedTransitioning = self.flipOverAnimatedTransitioning;
            break;
        case FNNavigationTransitioningStyleImage:
            animatedTransitioning = self.imageAnimatedTransitioning;
            break;
        case FNNavigationTransitioningStyleCoverVertical:
            animatedTransitioning = self.coverVerticalAnimatedTransitioning;
            break;
            
        default:
            break;
    }
    return animatedTransitioning;
}

#pragma mark <UINavigationControllerDelegate>
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    FNTransitioningCache *lastPushCache = nil;
    if (operation == UINavigationControllerOperationPop) {
        for (FNTransitioningCache *cache in self.transitioningCaches) {
            if (cache.viewController == toVC) {
                lastPushCache = cache;
                break;
            }
        }
        if (lastPushCache) {
            NSInteger index = [self.transitioningCaches indexOfObject:lastPushCache];
            [self.transitioningCaches removeObjectsInRange:NSMakeRange(index, self.transitioningCaches.count - index)];
        }
    }
    
    id<UIViewControllerAnimatedTransitioning> transitioning = nil;
    // Source: Delegate
    if ([self.delegate respondsToSelector:_cmd]) {
        transitioning = [self.delegate navigationController:navigationController animationControllerForOperation:operation fromViewController:fromVC toViewController:toVC];
        if (transitioning) {
            self.source = TransitioningSourceDelegate;
            return transitioning;
        }
    }
    
    // Source: View Controller
    if (self.symmetrical && operation == UINavigationControllerOperationPop) {
        if ([toVC conformsToProtocol:@protocol(UINavigationControllerDelegate)] && [toVC respondsToSelector:_cmd]) {
            transitioning = [(id<UINavigationControllerDelegate>)toVC navigationController:navigationController animationControllerForOperation:operation fromViewController:fromVC toViewController:toVC];
            if (transitioning) {
                self.source = TransitioningSourceViewController;
                self.viewController = toVC;
                return transitioning;
            }
        }
    } else {
        if ([fromVC conformsToProtocol:@protocol(UINavigationControllerDelegate)] && [fromVC respondsToSelector:_cmd]) {
            transitioning = [(id<UINavigationControllerDelegate>)fromVC navigationController:navigationController animationControllerForOperation:operation fromViewController:fromVC toViewController:toVC];
            if (transitioning) {
                self.source = TransitioningSourceViewController;
                self.viewController = fromVC;
                return transitioning;
            }
        }
    }
    
    self.source = TransitioningSourceDefault;
    switch (operation) {
        case UINavigationControllerOperationNone: {
            transitioning = nil;
            return transitioning;
        }
        case UINavigationControllerOperationPush: {
            FNTransitioningCache *cache = [[FNTransitioningCache alloc] init];
            cache.viewController = fromVC;
            
            FNNavigationTransitioningStyle style = fromVC.navigationTransitioningStyle;
            if (style != FNNavigationTransitioningStyleNone) {
                FNBaseAnimatedTransitioning *animatedTransitioning = [self p_animatedTransitioningForStyle:style];
                animatedTransitioning.operation = operation;
                transitioning = animatedTransitioning;
                cache.transitioningStyle = style;
            } else {
                self.animatedTransitioning.operation = operation;
                transitioning = self.animatedTransitioning;
                cache.transitioningStyle = self.transitioningStyle;
            }
            [self.transitioningCaches addObject:cache];
            return transitioning;
        }
        case UINavigationControllerOperationPop: {
            if (self.symmetrical) {
                if (lastPushCache) {
                    FNNavigationTransitioningStyle style = lastPushCache.transitioningStyle;
                    FNBaseAnimatedTransitioning *animatedTransitioning = [self p_animatedTransitioningForStyle:style];
                    animatedTransitioning.operation = operation;
                    transitioning = animatedTransitioning;
                } else {
                    FNNavigationTransitioningStyle style = toVC.navigationTransitioningStyle;
                    if (style != FNNavigationTransitioningStyleNone) {
                        FNBaseAnimatedTransitioning *animatedTransitioning = [self p_animatedTransitioningForStyle:style];
                        animatedTransitioning.operation = operation;
                        transitioning = animatedTransitioning;
                    } else {
                        self.animatedTransitioning.operation = operation;
                        transitioning = self.animatedTransitioning;
                    }
                }
            } else {
                FNNavigationTransitioningStyle style = fromVC.navigationTransitioningStyle;
                if (style != FNNavigationTransitioningStyleNone) {
                    FNBaseAnimatedTransitioning *animatedTransitioning = [self p_animatedTransitioningForStyle:style];
                    animatedTransitioning.operation = operation;
                    transitioning = animatedTransitioning;
                } else {
                    self.animatedTransitioning.operation = operation;
                    transitioning = self.animatedTransitioning;
                }
            }
            return transitioning;
        }
    }
    return transitioning;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    switch (self.source) {
        case TransitioningSourceDelegate:
            if ([self.delegate respondsToSelector:_cmd]) {
                return [self.delegate navigationController:navigationController interactionControllerForAnimationController:animationController];
            } else {
                return nil;
            }
        case TransitioningSourceViewController:
            if ([self.viewController conformsToProtocol:@protocol(UINavigationControllerDelegate)] && [self.viewController respondsToSelector:_cmd]) {
                return [(id)self.viewController navigationController:navigationController interactionControllerForAnimationController:animationController];
            } else {
                return nil;
            }
        case TransitioningSourceDefault:
            return nil;
        default:
            break;
    }
    return nil;
}
@end

@interface UINavigationController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) TransitioningProxy *proxy;
@end

@implementation UINavigationController (FNTransitioning)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        NSArray *originalSelectors = @[@"viewDidLoad", @"setDelegate:", @"delegate"];
        NSArray *swizzledSelectors = @[@"ms_viewDidLoad", @"ms_setDelegate:", @"ms_delegate"];
        
        for (int i = 0; i < originalSelectors.count; i++) {
            SEL originalSelector = NSSelectorFromString([originalSelectors objectAtIndex:i]);
            SEL swizzledSelector = NSSelectorFromString([swizzledSelectors objectAtIndex:i]);
            
            Method originalMethod = class_getInstanceMethod(class, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
            
            BOOL result = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
            if (result) {
                class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
    });
}

#pragma mark - Method Swizzling
- (void)ms_viewDidLoad {
    [self ms_viewDidLoad];
    self.interactivePopGestureRecognizer.delegate = self;
    self.delegate = self.delegate;
}

- (void)ms_setDelegate:(id<UINavigationControllerDelegate>)delegate {
    self.proxy.delegate = delegate;
    [self ms_setDelegate:self.proxy];
}

- (id<UINavigationControllerDelegate>)ms_delegate {
    return self.proxy.delegate;
}

#pragma mark - Property
- (TransitioningProxy *)proxy {
    TransitioningProxy *proxy = objc_getAssociatedObject(self, @selector(proxy));
    if (!proxy) {
        proxy = [[TransitioningProxy alloc] init];
        self.proxy = proxy;
    }
    return proxy;
}

- (void)setProxy:(TransitioningProxy *)proxy {
    objc_setAssociatedObject(self, @selector(proxy), proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)symmetrical {
    return self.proxy.symmetrical;
}

- (void)setSymmetrical:(BOOL)symmetrical {
    self.proxy.symmetrical = symmetrical;
}

- (FNNavigationTransitioningStyle)transitioningStyle {
    return self.proxy.transitioningStyle;
}

- (void)setTransitioningStyle:(FNNavigationTransitioningStyle)transitioningStyle {
    if (transitioningStyle == FNNavigationTransitioningStyleNone) {
        transitioningStyle = FNNavigationTransitioningStyleSystem;
    }
    self.proxy.transitioningStyle = transitioningStyle;
}

- (FNCoverDirection)coverDirection {
    return self.proxy.coverVerticalAnimatedTransitioning.direction;
}

- (void)setCoverDirection:(FNCoverDirection)coverDirection {
    self.proxy.coverVerticalAnimatedTransitioning.direction = coverDirection;
}
@end
