//
//  FNImageDetailCollectionViewCell.h
//  ShowImageDetail
//
//  Created by fuyong on 15/2/11.
//  Copyright (c) 2015年 fuyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FNFullScreenImage;
@interface FNFullScreenImageView : UIView

@property (strong, nonatomic) UIImageView *imageView;
@property (nonatomic, copy) void(^hideDetailView)();

- (void)updateWithImage:(FNFullScreenImage *)image completion:(void(^)(NSError *error))completion;
- (void)resetScrollView;

@end
