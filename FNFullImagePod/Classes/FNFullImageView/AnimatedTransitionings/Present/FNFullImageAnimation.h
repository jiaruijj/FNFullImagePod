//
//  FNFullImageAnimation.h
//  FNMarket
//
//  Created by fuyong on 15/5/7.
//  Copyright (c) 2015年 cn.com.feiniu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNBaseAnimatedTransitioning.h"

@interface FNFullImageAnimation : FNBaseAnimatedTransitioning

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CGRect originalFrame;


@end
