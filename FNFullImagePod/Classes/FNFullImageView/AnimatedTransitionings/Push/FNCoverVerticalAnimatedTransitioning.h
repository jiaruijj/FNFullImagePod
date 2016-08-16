//
//  FNCoverVerticalAnimatedTransitioning.h
//  TestFullImageView
//
//  Created by JR on 16/8/1.
//  Copyright © 2016年 JR. All rights reserved.
//

#import "FNBaseAnimatedTransitioning.h"


static NSString *const FNCoverVerticalAnimatedTransitioningInfoBackgroundColorKey = @"FNCoverVerticalAnimatedTransitioningInfoBackgroundColorKey";

typedef enum : NSUInteger {
    FNCoverDirectionFromTop,
    FNCoverDirectionFromBottom
} FNCoverDirection;
@interface FNCoverVerticalAnimatedTransitioning : FNBaseAnimatedTransitioning
@property (nonatomic, assign) FNCoverDirection direction;
@end
