//
//  FNImageAnimatedTransitioning.h
//  TestFullImageView
//
//  Created by JR on 16/8/1.
//  Copyright © 2016年 JR. All rights reserved.
//

#import "FNBaseAnimatedTransitioning.h"

/*
动画过度位置
 */
static NSString *const FNImageAnimatedTransitioningInfoImageViewKey = @"FNImageAnimatedTransitioningInfoImageViewKey";

/*
窗口坐标值
 */
static NSString *const FNImageAnimatedTransitioningInfoEndFrameForImageViewKey = @"FNImageAnimatedTransitioningInfoEndFrameForImageViewKey";

@interface FNImageAnimatedTransitioning : FNBaseAnimatedTransitioning

@end
