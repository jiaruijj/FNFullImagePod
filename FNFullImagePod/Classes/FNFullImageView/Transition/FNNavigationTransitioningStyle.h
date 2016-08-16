//
//  FNNavigationTransitioningStyle.h
//  TestFullImageView
//
//  Created by JR on 16/8/1.
//  Copyright © 2016年 JR. All rights reserved.
//

#ifndef FNNavigationTransitioningStyle_h
#define FNNavigationTransitioningStyle_h

// 导航切换样式
typedef enum : NSUInteger {
    //系统
    FNNavigationTransitioningStyleSystem = 0,
    //淡入淡出
    FNNavigationTransitioningStyleFade,
    //抽屉
    FNNavigationTransitioningStyleDivide,
    //从上切换
    FNNavigationTransitioningStyleResignTop,
    //从左切换
    FNNavigationTransitioningStyleResignLeft,
    //翻页
    FNNavigationTransitioningStyleFlipOver,
    //图片位移,需要设置代理设置fromView和toView以及position
    FNNavigationTransitioningStyleImage,
    //垂直覆盖
    FNNavigationTransitioningStyleCoverVertical,
    // 如果为UIViewcontroller时候设置为NONE
    FNNavigationTransitioningStyleNone = NSUIntegerMax
}
FNNavigationTransitioningStyle;

#endif /* FNNavigationTransitioningStyle_h */
