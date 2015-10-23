//
//  UIImage+ImageUtilities.h
//  Blocstagram
//
//  Created by Ben Russell on 10/22/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageUtilities)

- (UIImage *)imageWithFixedOtientation;
- (UIImage *)imageResizedToMatchAspectRatioOfSize:(CGSize)size;
- (UIImage *)imageCroppedToRect:(CGRect)cropRect;
- (UIImage *)imageByScalingToSize:(CGSize)size andCroppingWithRect:(CGRect)rect;

@end


