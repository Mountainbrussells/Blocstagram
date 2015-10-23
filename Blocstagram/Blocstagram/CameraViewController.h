//
//  CameraViewController.h
//  Blocstagram
//
//  Created by Ben Russell on 10/22/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  CameraViewController;

@protocol CameraViewControllerDelegate <NSObject>

- (void)cameraViewController:(CameraViewController *)cameraViewController didCompleteWithImage:(UIImage *)image;


@end

@interface CameraViewController : UIViewController

@property (nonatomic, weak)NSObject <CameraViewControllerDelegate>*delegate;

@end
