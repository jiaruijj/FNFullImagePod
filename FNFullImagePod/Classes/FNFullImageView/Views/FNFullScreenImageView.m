//
//  FNImageDetailCollectionViewCell.m
//  ShowImageDetail
//
//  Created by fuyong on 15/2/11.
//  Copyright (c) 2015年 fuyong. All rights reserved.
//

#import "FNFullScreenImageView.h"
#import "UIImageView+WebCache.h"
#import "FNFullImageViewController.h"
#import "NSBundle+MyLibrary.h"

@interface FNFullScreenImageView () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;


@end

@implementation FNFullScreenImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    _imageView = [[UIImageView alloc] initWithFrame:self.frame];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.userInteractionEnabled = YES;
    [_scrollView addSubview:_imageView];
    [self addSubview:_scrollView];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.minimumZoomScale = 1.0;
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.imageView addGestureRecognizer:doubleTapGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesuture:)];
    [self.imageView addGestureRecognizer:tapGesture];
    
    [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
}

#pragma mark - Public methods

- (void)updateWithImage:(FNFullScreenImage *)fullImage completion:(void (^)(NSError *))completion
{
    if (fullImage.image) {
        self.imageView.image = fullImage.image;
        completion(nil);
    } else if (fullImage.imageURLString) {
        
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:fullImage.imageURLString] placeholderImage:[UIImage imageNamed:@"images.bundle/images/icon_imaging" inBundle:[NSBundle myLibraryBundle] compatibleWithTraitCollection:nil] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            fullImage.image = image;
            completion(error);
        }];
    }
    [self resetScrollView];
}

- (void)resetScrollView
{
    [self.scrollView setZoomScale:1 animated:NO];
}

#pragma mark - Event handle

/**/
- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)sender
{
    if (self.scrollView.zoomScale == 1) {
        [self.scrollView setZoomScale:2 animated:YES];
    } else if (self.scrollView.zoomScale == 2) {
        [self.scrollView setZoomScale:1 animated:YES];
    } else if (self.scrollView.zoomScale >= 1.5) {
        [self.scrollView setZoomScale:2 animated:YES];
    } else if (self.scrollView.zoomScale < 1) {
        [self.scrollView setZoomScale:1 animated:YES];
    }
    [self layoutIfNeeded];
}


- (void)handleTapGesuture:(UITapGestureRecognizer *)sender
{
    if (self.hideDetailView) {
        self.hideDetailView();
    }
}

#pragma mark - UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


@end
