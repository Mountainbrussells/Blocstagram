//
//  CropImageViewController.h
//  Blocstagram
//
//  Created by Ben Russell on 10/23/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import "MediaFullScreenViewController.h"

@class CropImageViewController;

@protocol CropImageViewControllerDelegate <NSObject>

- (void)cropControllerFinishedWithImage:(UIImage *)croppedImage;

@end

@interface CropImageViewController : MediaFullScreenViewController

- (instancetype)initWithImage:(UIImage *)sourceImage;

@property (nonatomic, weak)NSObject <CropImageViewControllerDelegate> *delegate;

@end
