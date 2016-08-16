//
//  FNTransitioningDelegate.h
//  TestFullImageView
//
//  Created by JR on 16/8/1.
//  Copyright © 2016年 JR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol FNTransitioningDelegate <NSObject>
@optional

/**
 *  代理指定fromView或者fromView的属性等
 *
 */
- (NSDictionary *)transitioningInfoAsFrom:(id <UIViewControllerAnimatedTransitioning>)transitioning context:(id <UIViewControllerContextTransitioning>)context;

/**
 *  代理指定toView或者toView的属性等
 *
 */
- (NSDictionary *)transitioningInfoAsTo:(id <UIViewControllerAnimatedTransitioning>)transitioning context:(id <UIViewControllerContextTransitioning>)context;

/**   
 *     exzample   需要得到具体原图或目标图以及位置则需要实现下列代理
 *
 *  - (NSDictionary *)transitioningInfoAsFrom:(id<UIViewControllerAnimatedTransitioning>)transitioning context:(id<UIViewControllerContextTransitioning>)context {
     if ([transitioning isKindOfClass:[FNDivideAnimatedTransitioning class]]) {
      CGRect rect = [self.view.window convertRect:self.cell.frame fromView:self.cell.superview];
       return @{FNDivideAnimatedTransitioningInfoPositionKey: @(rect.origin.y + rect.size.height / 2.0)};
     }
     if ([transitioning isKindOfClass:[FNImageAnimatedTransitioning class]]) {
        return @{FNImageAnimatedTransitioningInfoImageViewKey: self.imageView};
     }
     return nil;
 }
 
 - (NSDictionary *)transitioningInfoAsTo:(id<UIViewControllerAnimatedTransitioning>)transitioning context:(id<UIViewControllerContextTransitioning>)context {
      if ([transitioning isKindOfClass:[FNCoverVerticalAnimatedTransitioning class]]) \
        {
         return @{FNCoverVerticalAnimatedTransitioningInfoBackgroundColorKey: [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1.0]};
        }
      if ([transitioning isKindOfClass:[FNImageAnimatedTransitioning class]]) {
        CGRect rect = [self.view convertRect:self.imageView.frame fromCoordinateSpace:self.imageView.superview];
           rect.origin.y += 64;
             return @{FNImageAnimatedTransitioningInfoImageViewKey: self.imageView,
                 FNImageAnimatedTransitioningInfoEndFrameForImageViewKey: [NSValue valueWithCGRect:rect]};
       }
       return nil;
 }
 */
@end
