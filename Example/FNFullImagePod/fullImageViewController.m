//
//  fullImageViewController.m
//  FNFullImagePod
//
//  Created by JR on 08/16/2016.
//  Copyright (c) 2016 JR. All rights reserved.
//

#import "fullImageViewController.h"
#import "UIImageView+WebCache.h"
#import "UINavigationController+FNTransitioning.h"
#import "FNFullImageViewController.h"
#import "FNPresentPageAnimation.h"
#import "FNFullImageAnimation.h"
#import "NSBundle+MyLibrary.h"


@interface fullImageViewController () <FNTransitioningDelegate>
@property (nonatomic,copy) NSArray *dataArray;
@property (nonatomic,copy) NSArray *photoArray;
@property (nonatomic,copy) NSMutableArray *imageArray;
@property (nonatomic,copy) NSMutableArray *imageUrlArray;
@property (nonatomic,strong) UIImageView *imageView;
@end

@implementation fullImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"FullImage切换动画演示";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.dataArray[section] count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *resuseID = @"resuseID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:resuseID];
    if (indexPath.row == 6) {
        FNFullScreenImage *fullImage = self.photoArray[0];
        NSURL *url = [NSURL URLWithString:fullImage.imageURLString];
        [cell.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:[self imageBundleUrlString:@"icon_imaging"] inBundle:[NSBundle myLibraryBundle] compatibleWithTraitCollection:nil]];
        _imageView = cell.imageView;
    }
    cell.textLabel.text = self.dataArray[indexPath.section][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FNFullScreenImage *fullImage = self.photoArray[0];
    fullImage.originalImageView = _imageView;
    //    [self.photoArray replaceObjectAtIndex:0 withObject:fullImage];
    
    
    //FNFullImage类型数组
    FNFullImageViewController *fullVc = [[FNFullImageViewController alloc]initWithImageArray:self.photoArray currentIndex:0];
    
    //UIImage类型数组
    //    FNFullImageViewController *fullVc = [[FNFullImageViewController alloc]initWithImageArray:self.imageArray currentIndex:0];
    
    //NSString类型数组
    //    FNFullImageViewController *fullVc = [[FNFullImageViewController alloc]initWithImageArray:self.imageUrlArray currentIndex:0];
    
    fullVc.tapType = FNTapTypeShow;
    
    FNPresentPageAnimation * animation = [[FNPresentPageAnimation alloc] init];
    
    if (indexPath.section == 0) {
        self.navigationController.transitioningStyle = FNNavigationTransitioningStyleNone;
        switch (indexPath.row) {
            case 0:
                self.navigationController.transitioningStyle = FNNavigationTransitioningStyleSystem;
                [fullVc push];
                break;
            case 1:
                self.navigationController.transitioningStyle = FNNavigationTransitioningStyleFade;
                [fullVc push];
                break;
            case 2:
                self.navigationController.transitioningStyle = FNNavigationTransitioningStyleDivide;
                [fullVc push];
                break;
            case 3:
                self.navigationController.transitioningStyle = FNNavigationTransitioningStyleResignTop;
                [fullVc push];
                break;
            case 4:
                self.navigationController.transitioningStyle = FNNavigationTransitioningStyleResignLeft;
                [fullVc push];
                break;
            case 5:
                self.navigationController.transitioningStyle = FNNavigationTransitioningStyleFlipOver;
                [fullVc push];
                break;
            case 6:
                /**present出来**/
                //不设置animation 默认为放大缩小,设置之后用设置的动画
                //                fullVc.animation = animation;
                [fullVc show];
                /**push出来**/
                //                self.navigationTransitioningStyle = FNNavigationTransitioningStyleDivide;
                //                [fullVc push];
                
                break;
            case 7:
                self.navigationController.transitioningStyle = FNNavigationTransitioningStyleCoverVertical;
                self.navigationController.coverDirection = FNCoverDirectionFromTop;
                [fullVc push];
                break;
            case 8:
                self.navigationController.transitioningStyle = FNNavigationTransitioningStyleCoverVertical;
                self.navigationController.coverDirection = FNCoverDirectionFromBottom;
                [fullVc push];
                break;
            default:
                break;
        }
    }
    else {
        NSString *aniType = (NSString *)self.dataArray[indexPath.section][indexPath.row];
        [self animationWithType:aniType subType:@"kCATransitionFromLeft" duration:1.0];
        [self.navigationController pushViewController:fullVc animated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 100, 30)];
    lable.textColor = [UIColor redColor];
    lable.font = [UIFont systemFontOfSize:16];
    lable.text = section == 0 ? @"自定义动画" : @"系统转场动画";
    return lable;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0 ? 50 : 55;
}


#pragma mark - getter

- (NSArray *)photoArray
{
    
    if (!_photoArray) {
        FNFullScreenImage *fullImage = [[FNFullScreenImage alloc] init];
        fullImage.imageURLString = @"http://cdn.duitang.com/uploads/item/201209/27/20120927174050_HjNYf.jpeg";
        
        
        FNFullScreenImage *fullImage2 = [[FNFullScreenImage alloc] init];
        fullImage2.imageURLString = @"http://imgsrc.baidu.com/forum/w%3D580/sign=fcae01763b87e9504217f3642039531b/2f2eb9389b504fc29fccbeb0e4dde71191ef6df7.jpg";
        _photoArray = [NSArray arrayWithObjects:fullImage, fullImage2, nil];
        
    }
    return _photoArray;
}

- (NSMutableArray *)imageArray
{
    if (!_imageArray) {
        UIImage *image1 = [UIImage imageNamed:[self imageBundleUrlString:@"icon_imaging"] inBundle:[NSBundle myLibraryBundle] compatibleWithTraitCollection:nil];
        UIImage *image2 = [UIImage imageNamed:[self imageBundleUrlString:@"icon_return"] inBundle:[NSBundle myLibraryBundle] compatibleWithTraitCollection:nil];
        UIImage *image3 = [UIImage imageNamed:[self imageBundleUrlString:@"icon_setting"] inBundle:[NSBundle myLibraryBundle] compatibleWithTraitCollection:nil];
        _imageArray = [NSMutableArray arrayWithObjects:image1, image2,image3, nil];
    }
    return _imageArray;
}

//得到bundle资源
- (NSString *)imageBundleUrlString :(NSString *)imageName{
    NSString *path = @"images.bundle/images/";
    return [path stringByAppendingString:imageName];
}

- (NSMutableArray *)imageUrlArray
{
    if (!_imageArray) {
        _imageArray = [NSMutableArray arrayWithObjects:@"http://cdn.duitang.com/uploads/item/201209/27/20120927174050_HjNYf.jpeg", @"http://imgsrc.baidu.com/forum/w%3D580/sign=fcae01763b87e9504217f3642039531b/2f2eb9389b504fc29fccbeb0e4dde71191ef6df7.jpg", nil];
    }
    return _imageArray;
}

- (NSArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = @[
                       @[@"默认Push",@"淡入淡出",@"抽屉",@"从上切换",@"从左切换",@"翻页",@"图片移动动画",@"垂直覆盖"],
                       @[@"fade",@"moveIn",@"reveal",@"pageCurl",@"pageUnCurl"]
                       ];
    }
    return _dataArray;
}

@end

