//
//  FNTransitioningCache.h
//  TestFullImageView
//
//  Created by JR on 16/8/1.
//  Copyright © 2016年 JR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNNavigationTransitioningStyle.h"

@interface FNTransitioningCache : NSObject
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, assign) FNNavigationTransitioningStyle transitioningStyle;
@end
