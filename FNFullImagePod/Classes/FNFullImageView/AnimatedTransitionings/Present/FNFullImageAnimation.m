//
//  FNFullImageAnimation.m
//  FNMarket
//
//  Created by fuyong on 15/5/7.
//  Copyright (c) 2015年 cn.com.feiniu. All rights reserved.
//

#import "FNFullImageAnimation.h"
#import "FNFullImageViewController.h"

@implementation FNFullImageAnimation


- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3f;
}

- (CGRect)scaleFrameForImage:(UIImage *)initialImage
{
    CGSize imageSize = initialImage.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    
    // 设置伸缩比例
    CGFloat minScale = kScreenWidth / imageWidth;
    if (minScale > 1) {
        minScale = 1.0;
    }
    CGFloat maxScale = 2.0;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        maxScale = maxScale / [[UIScreen mainScreen] scale];
    }
    
    CGRect imageFrame = CGRectMake(0, 0, kScreenWidth, imageHeight * kScreenWidth / imageWidth);
    // 内容尺寸
    // y值
    if (imageFrame.size.height < kScreenHeight) {
        imageFrame.origin.y = floorf((kScreenHeight - imageFrame.size.height) / 2.0);
    } else {
        imageFrame.origin.y = 0;
    }
    return imageFrame;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    fromVC.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    toVC.view.frame = fromVC.view.frame;
    UIView *containerView= [transitionContext containerView];
    [containerView addSubview:fromVC.view];
    [containerView addSubview:toVC.view];
    
    
    
    if (self.presented) {
        UIView *view = [[UIView alloc] initWithFrame:toVC.view.frame];
        view.alpha = 1;
        view.backgroundColor = [UIColor blackColor];
        [containerView addSubview:view];
        UIImageView *imageView = [[UIImageView alloc] init];
        if (self.image) {
            imageView = [[UIImageView alloc] initWithFrame:[self scaleFrameForImage:self.image]];
            imageView.image = _image;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [containerView addSubview:imageView];
        }
        NSTimeInterval duration = [self transitionDuration:transitionContext];
        fromVC.view.hidden = YES;
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             imageView.frame = self.originalFrame;
                             view.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [imageView removeFromSuperview];
                             [view removeFromSuperview];
                             self.presented = NO;
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                             if ([[[UIDevice currentDevice] systemVersion] integerValue]>= 8) {
                                 [[[UIApplication sharedApplication]keyWindow]addSubview:toVC.view];
                             }
                         }];

    } else {
        toVC.view.hidden = YES;
        UIView *view = [[UIView alloc] initWithFrame:toVC.view.frame];
        view.alpha = 0;
        view.backgroundColor = [UIColor blackColor];
        [containerView addSubview:view];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.originalFrame];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [containerView addSubview:imageView];
        imageView.image = self.image;
        NSTimeInterval duration = [self transitionDuration:transitionContext];
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             view.alpha = 1;
                             if (weakSelf.image) {
                                 
                                 imageView.frame = [weakSelf scaleFrameForImage:weakSelf.image];
                             }else{
                                 imageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
                             }
                             
                         }
                         completion:^(BOOL finished) {
                             [imageView removeFromSuperview];
                             [view removeFromSuperview];
                             toVC.view.hidden = NO;
                             self.presented = YES;
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }];
    }
}


@end
