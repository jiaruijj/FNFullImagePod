//
//  FNSnapshot.h
//  TestFullImageView
//
//  Created by JR on 16/8/1.
//  Copyright © 2016年 JR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FNSnapshot : NSObject
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, strong) UIView *snapshotView;
@end
