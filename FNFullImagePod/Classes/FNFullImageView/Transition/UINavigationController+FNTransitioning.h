//
//  UINavigationController+FNTransitioning.h
//  TestFullImageView
//
//  Created by JR on 16/8/1.
//  Copyright © 2016年 JR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+FNTransitioning.h"
#import "FNFadeAnimatedTransitioning.h"
#import "FNDivideAnimatedTransitioning.h"
#import "FNResignTopAnimatedTransitioning.h"
#import "FNResignLeftAnimatedTransitioning.h"
#import "FNFlipOverAnimatedTransitioning.h"
#import "FNImageAnimatedTransitioning.h"
#import "FNCoverVerticalAnimatedTransitioning.h"

@interface UINavigationController (FNTransitioning)
/**
 *  导航栏切换样式
 */
@property (nonatomic, assign) FNNavigationTransitioningStyle transitioningStyle;
/**
 *  对称
 */
@property (nonatomic, assign) BOOL symmetrical;
/**
 *  控制fnnavigationtransitioningstylecoververtical方向
 */
@property (nonatomic, assign) FNCoverDirection coverDirection;
@end
