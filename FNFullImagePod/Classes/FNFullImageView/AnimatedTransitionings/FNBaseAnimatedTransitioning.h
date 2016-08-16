//
//  FNBaseAnimatedTransitioning.h
//  TestFullImageView
//
//  Created by JR on 16/8/1.
//  Copyright © 2016年 JR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FNTransitioningDelegate.h"

@interface FNBaseAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning,UIViewControllerTransitioningDelegate>
@property (nonatomic, assign) UINavigationControllerOperation operation;
@property (nonatomic, assign) BOOL presented;
@end
