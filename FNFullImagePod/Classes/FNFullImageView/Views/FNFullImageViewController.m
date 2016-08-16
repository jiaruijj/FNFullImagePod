//
//  FNFullImageViewController.m
//  FNMerchant
//
//  Created by medita on 16/7/1.
//  Copyright © 2016年 FeiNiu. All rights reserved.
//

#import "FNFullImageViewController.h"
#import "FNFullScreenImageView.h"
#import "FNFullImageAnimation.h"
#import "NSBundle+MyLibrary.h"


@interface FNFullImageViewController ()<UIScrollViewDelegate>

@property (nonatomic,strong)   UIScrollView *scrollView;
@property (nonatomic,strong)   UIPageControl *pageControl;
@property (nonatomic,strong)   NSArray *imageUrlArray;
@property (nonatomic,strong)   UILabel *titleLabel;
@property (nonatomic,strong)   UILabel *pageLabel;
@property (nonatomic,strong)   UIButton *saveButton;
@property (nonatomic,strong)   UIImageView *currentImageView;
@property (nonatomic,assign)   NSInteger currentIndex;
@property (nonatomic,strong)   UIImage *currentImage;
@property (nonatomic,strong)   NSMutableArray *reuseImageArray;
@property (nonatomic,assign)   FNFullImageType type;
@property (nonatomic,strong)   NSMutableArray <FNFullScreenImage *>*images;
@property (nonatomic,strong)   NSArray <FNFullScreenImage *> *fullScreenImageArray;
@property (nonatomic,assign)   BOOL isHiddenStatueBar;
@property (nonatomic,assign)   BOOL isEndAnimation;
@property (nonatomic,assign)   BOOL isViewAppear;
@property (nonatomic,assign)   BOOL hiddenNavigationBar;//是否隐藏导航栏  push为NO  present YES
@property (nonatomic,strong)   UIButton *rightButton;

@end

@implementation FNFullImageViewController

#pragma mark - life cycle

// @"images.bundle/images/folder"


//兼容UIImage,NSString,FNFullScreenImage数组
- (instancetype)initWithImageArray:(NSArray *)imageArray
                            currentIndex:(NSInteger)currentIndex

{
    if (self = [super init]) {
        self.currentIndex = currentIndex;
        [self imageTypeFromArray:imageArray];
        [self translateFullImageArray:imageArray];
        
        [self initializationParams];
        [self initializationAnimation];
        
    }
    return self;
}

//针对 FNFullScreenImage数组 提供原图和目标位移图  缩放动画
- (instancetype)initWithFullScreenImageArray:(NSArray<FNFullScreenImage *> *)fullScreenImageArray currentIndex:(NSInteger)currentIndex tapType:(FNTapType)tapType
                                    pageType:(FNPageType)pageType
{
    if (self = [super init]) {
        
        self.type = FNFullImageTypeFullImage;
        self.fullScreenImageArray = fullScreenImageArray;
        self.currentIndex = currentIndex;
        self.hiddenNavigationBar = NO;
        self.pageType = pageType;
        self.tapType = tapType;
        
        [self initializationAnimation];
        
    }
    return self;
}

//默认值
- (void)initializationParams
{
    self.pageType = FNPageTypeLabel;
    self.hiddenNavigationBar = NO;
    self.tapType = FNTapTypeHide;
    
}

//从数组中得到成员类型
- (void)imageTypeFromArray :(NSArray *)imageArray{
    id obj = [self safeObjectAtIndex:0 ofArray:imageArray];
    
    if ([obj isKindOfClass:[UIImage class]]){
      self.type = FNFullImageTypeNormalImage;
    } else if ([obj isKindOfClass:[FNFullScreenImage class]]){
      self.type = FNFullImageTypeFullImage;
    } else {
      self.type = FNFullImageTypeUrl;
    }

}

//默认值
- (void)initializationAnimation
{
    self.modalPresentationStyle = UIModalPresentationCustom;
    
    if (self.type != FNFullImageTypeFullImage) return;
   FNFullImageAnimation *fullAnimation = [[FNFullImageAnimation alloc] init];
        FNFullScreenImage *image = [self safeObjectAtIndex:self.currentIndex ofArray:self.fullScreenImageArray];
        fullAnimation.image = [self screenshotfromImageView:image.originalImageView];
        CGRect rect = [image.originalImageView convertRect:image.originalImageView.bounds toView:nil];//这个image.originalImageView.bounds 转为window的frame
        fullAnimation.originalFrame = rect;
        self.animation = fullAnimation;
}


- (void)translateFullImageArray:(NSArray *)imageArray
{
    NSMutableArray *fullImageArray = [NSMutableArray array];
    [imageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImage *image = obj;
        FNFullScreenImage *fullImage = [[FNFullScreenImage alloc] init];
        fullImage.image = image;
        [fullImageArray addObject:fullImage];
    }];

    switch (_type) {
        case FNFullImageTypeUrl:
            self.imageUrlArray = imageArray;
            break;
        case FNFullImageTypeFullImage:
            self.fullScreenImageArray = imageArray;
            break;
        case FNFullImageTypeNormalImage:
            self.fullScreenImageArray = fullImageArray;
            break;
        default:
            break;
    }
}

- (void)setAnimation:(FNBaseAnimatedTransitioning *)animation
{
    _animation = animation;
    self.transitioningDelegate = animation;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureUI];
    [self prepareReuseImageViews];
    [self configureNavigation];
    [self showImages];
    [self updateCurrentImageView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isViewAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UI

//初始化重用imageview数组
- (void)prepareReuseImageViews
{
    self.reuseImageArray = [NSMutableArray array];
    NSInteger reuseViewCount = self.images.count > 3 ? 3: self.images.count;
    for (NSInteger i =0; i<reuseViewCount;i++ ) {
    
        FNFullScreenImageView *fullscreenImageView = [[FNFullScreenImageView alloc] initWithFrame:self.scrollView.frame];
        [self.reuseImageArray addObject:fullscreenImageView];
        
    }
    
}

//初始化images
- (void)prepareImages
{
    switch (self.type) {
        case FNFullImageTypeUrl:
            [self prepareUrlReuseImageViews];
            break;
        case FNFullImageTypeFullImage:
            [self prepareImageReuseImageViews];
            break;
        case FNFullImageTypeNormalImage:
            [self prepareImageReuseImageViews];
        default:
            break;
    }
}

- (void)prepareUrlReuseImageViews
{
    self.images = [NSMutableArray array];
    for (NSString *imageUrl in self.imageUrlArray) {
        FNFullScreenImage *fullscreenImage = [[FNFullScreenImage alloc] init];
        fullscreenImage.imageURLString = imageUrl;
        [self.images addObject:fullscreenImage];
    }
}

#pragma  mark - 调用显示和消失
- (void)show
{
    self.tapType = FNTapTypeHide;
    self.hiddenNavigationBar = YES;
    UIViewController *vc = [FNFullImageViewController topViewController];
    [vc presentViewController:self animated:YES completion:nil];
}

- (void)push
{
    UIViewController *vc = [FNFullImageViewController topViewController];
    if (vc.navigationController) {
       [vc.navigationController pushViewController:self animated:YES];
    }

}

- (void)disappear
{
    NSArray *viewcontrollers = self.navigationController.viewControllers;
    if (viewcontrollers.count>1) {
        if ([viewcontrollers objectAtIndex:viewcontrollers.count-1] ==self) {
            //push方式
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else{
        //present方式
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}

#pragma  mark - UI

- (void)prepareImageReuseImageViews
{
    self.images = [NSMutableArray arrayWithArray:self.fullScreenImageArray];
}

- (void)configureUI
{
    
    [self prepareImages];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor blackColor];
    
    self.scrollView = scrollView;
    self.scrollView.contentSize = CGSizeMake(self.images.count * kScreenWidth, 0);
    [self.scrollView setContentOffset:CGPointMake(self.currentIndex * kScreenWidth, 0) animated:NO];
    
    if (self.hiddenNavigationBar) {
    [self configPageType];
    [self configSaveBtn];
    }
}

//设置导航栏
- (void)configureNavigation
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 21)];
    titleLabel.text = [NSString stringWithFormat:@"%ld/%lu",self.currentIndex+1,self.images.count];
    self.navigationItem.titleView = titleLabel;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel = titleLabel;
    
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftImage = [UIImage imageNamed:[self imageBundleUrlString:@"icon_return"] inBundle:[NSBundle myLibraryBundle] compatibleWithTraitCollection:nil];
    [leftButton addTarget:self action:@selector(leftButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setImage:leftImage forState:UIControlStateNormal];
    [leftButton setFrame:CGRectMake(0, 0, leftImage.size.width, leftImage.size.height)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];

    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:[self imageBundleUrlString:@"icon_setting"] inBundle:[NSBundle myLibraryBundle] compatibleWithTraitCollection:nil];
    [rightButton addTarget:self action:@selector(rightButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setImage:image forState:UIControlStateNormal];
    [rightButton setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    self.rightButton = rightButton;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
}

//得到bundle资源
- (NSString *)imageBundleUrlString :(NSString *)imageName{
    NSString *path = @"images.bundle/images/";
    return [path stringByAppendingString:imageName];
}

- (void)configSaveBtn
{
    UIButton *saveButton = [[UIButton alloc] init];
    [self.view addSubview:saveButton];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveButton.titleLabel.font = [UIFont systemFontOfSize: 14];
    saveButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    saveButton.layer.cornerRadius = 5;
    saveButton.clipsToBounds = YES;
    [saveButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    saveButton.frame = CGRectMake(kScreenWidth-50, kScreenHeight-50, 50, 20);
    _saveButton = saveButton;

}


#pragma  mark - 常用方法
- (id _Nullable)safeObjectAtIndex:(NSUInteger)index ofArray:(NSArray *)array{
    if ([array count] > 0 && [array count] > index) {
        return [array objectAtIndex:index];
    } else {
        return nil;
    }
}

- (UIImage * _Nonnull)screenshotfromImageView:(UIImageView *)fromImageView{
    UIGraphicsBeginImageContextWithOptions(fromImageView.bounds.size, NO, [UIScreen mainScreen].scale);
    
    [fromImageView drawViewHierarchyInRect:fromImageView.bounds afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(image);
    image = [UIImage imageWithData:imageData];
    
    return image;
}

+ (UIViewController *)topViewController {
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController *)topViewController:(UIViewController *)rootViewController {
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        return [self topViewController:[navigationController.viewControllers lastObject]];
    }
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabController = (UITabBarController *)rootViewController;
        return [self topViewController:tabController.selectedViewController];
    }
    if (rootViewController.presentedViewController) {
        return [self topViewController:rootViewController.presentedViewController];
    }
    return rootViewController;
}


- (void)leftButtonTouch:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonTouch:(UIButton *)btn
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    WS(weakSelf);
    [alertController addAction:[UIAlertAction actionWithTitle:@"保存到相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf saveImage];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma  mark - 保存图片
- (void)saveImage
{
    [self updateCurrentImageView];
    UIImageWriteToSavedPhotosAlbum(_currentImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    NSString *showMessage = error ? @"保存失败" : @"保存成功";
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.90f];
    label.layer.cornerRadius = 5;
    label.clipsToBounds = YES;
    label.bounds = CGRectMake(0, 0, 150, 30);
    label.center = self.view.center;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:17];
    [[UIApplication sharedApplication].keyWindow addSubview:label];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:label];
    label.text = showMessage;
    [label performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];

}

- (void)updateCurrentImageView {
    
    FNFullScreenImage *currentImage = [self safeObjectAtIndex:self.currentIndex ofArray:self.images];
    FNFullScreenImageView *currentImageView = [[FNFullScreenImageView alloc]init];
    [currentImageView updateWithImage:currentImage completion:^(NSError *error) {
        _currentImageView = currentImageView.imageView;
    }];
}


//设置页数类型,默认为label
- (void)configPageType
{
    
    if (self.pageType == FNPageTypeLabel){
        UILabel *pageLabel = [[UILabel alloc] init];
        pageLabel.text = [NSString stringWithFormat:@"%ld/%lu",self.currentIndex+1,self.images.count];
        pageLabel.textColor = [UIColor whiteColor];
        pageLabel.font = [UIFont systemFontOfSize:14];
        self.pageLabel = pageLabel;
        [self.view addSubview:pageLabel];
        pageLabel.textAlignment = NSTextAlignmentLeft;
        pageLabel.frame = CGRectMake(10, kScreenHeight-50, 100, 20);
        
    } else {
        UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
        
        [self.view addSubview:pageControl];
        self.pageControl = pageControl;
        
        pageControl.frame = CGRectMake(kScreenWidth/2.0-50, kScreenHeight-50, 100, 20);
        pageControl.numberOfPages = self.imageUrlArray ? self.imageUrlArray.count : self.images.count;
        pageControl.pageIndicatorTintColor = [UIColor cyanColor];
        pageControl.currentPageIndicatorTintColor = [UIColor redColor];
        pageControl.currentPage = _currentIndex;
    }

}


- (void)showImages
{

 if (!self.rightButton.enabled) {
        
        self.rightButton.enabled = YES;
    }
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (self.images.count <= 3) {
        for (NSInteger i = 0; i < self.images.count; i++) {
            FNFullScreenImageView *imageView = [self safeObjectAtIndex:i ofArray:self.reuseImageArray];
            [self updateImageView:imageView atIndex:i];
        }
        return;
    }
    
    FNFullScreenImageView *imageView = [self safeObjectAtIndex:1 ofArray:self.reuseImageArray];
    [self updateImageView:imageView atIndex:self.currentIndex];
    
    if (self.currentIndex - 1 >= 0) {
        FNFullScreenImageView *previousImageView = [self safeObjectAtIndex:0 ofArray:self.reuseImageArray];
        [self updateImageView:previousImageView atIndex:self.currentIndex - 1];
    }
    if (self.currentIndex + 1 <= self.images.count - 1) {
        FNFullScreenImageView *nextImageView = [self safeObjectAtIndex:2 ofArray:self.reuseImageArray];
        [self updateImageView:nextImageView atIndex:self.currentIndex + 1];
    }

}

- (void)updateImageView:(FNFullScreenImageView *)imageView atIndex:(NSInteger)index
{
    CGRect rect = imageView.frame;
    rect.origin.x = self.scrollView.frame.size.width * index;
    imageView.frame = rect;
    imageView.tag = index;
    WS(weakSelf);
    imageView.hideDetailView = ^
    {
        //隐藏导航栏
        weakSelf.tapType == FNTapTypeHide ?  [weakSelf disappear] : [weakSelf hideNavgationBar:!weakSelf.navigationController.navigationBarHidden];
    };
    FNFullScreenImage *image = [self safeObjectAtIndex:index ofArray:self.images];
    [imageView updateWithImage:image completion:^(NSError *error) {
        //当加载图片url失败时，默认是不能点击保存图片按钮的
        if (error && weakSelf.currentIndex == index) {
            weakSelf.rightButton.enabled = NO;
        }
    }];
    
    [self.scrollView addSubview:imageView];

}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    隐藏导航栏
    if (self.isViewAppear) {
        [self hideNavgationBar:YES];
    }
    
    CGRect visibleBounds = scrollView.bounds;
    NSInteger index = (NSInteger)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
    if (index > self.images.count - 1) index = self.images.count - 1;
    if (index != self.currentIndex) {
        self.currentIndex = index;
        self.pageControl.currentPage = self.currentIndex;
        self.titleLabel.text = [NSString stringWithFormat:@"%ld/%ld",self.currentIndex+1,self.images.count];
        self.pageLabel.text = [NSString stringWithFormat:@"%ld/%ld",self.currentIndex+1,self.images.count];
        if (self.images.count > 3) {
            [self showImages];
        } else {
            [self.reuseImageArray makeObjectsPerformSelector:@selector(resetScrollView)];
        }
    }
}

#pragma mark - hidden status bar

- (void)hideNavgationBar:(BOOL )hidden
{
    if (self.navigationController.navigationBarHidden == hidden) {
        return;
    }
    
    WS(weakSelf);
    CGFloat alpha = hidden ? 0.0f : 1.0f;
    [UIView animateKeyframesWithDuration:0.5 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        weakSelf.navigationController.navigationBar.alpha = alpha;
        //状态栏的是否隐藏
        [weakSelf setStatueBarHidden:hidden];
    } completion:^(BOOL finished) {
        weakSelf.navigationController.navigationBarHidden = hidden;
        
    }];
}

/**
 *  是否隐藏状态栏
 */
- (void)setStatueBarHidden:(BOOL)hidden
{
    _isHiddenStatueBar = hidden;
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}


- (BOOL)prefersStatusBarHidden{
    if (_isHiddenStatueBar) {
        return YES;
    }else{
        return NO;
    }
}




@end


@implementation FNFullScreenImage



@end
