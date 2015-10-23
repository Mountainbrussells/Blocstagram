//
//  MediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Ben Russell on 10/19/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media;

@interface MediaFullScreenViewController : UIViewController

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) Media *media;

- (instancetype)initWithMedia:(Media *)media;

- (void)centerScrollView;

- (void)recalculateZoomScale;

@end
