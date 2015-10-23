//
//  UIImage+ImageUtilities.m
//  Blocstagram
//
//  Created by Ben Russell on 10/22/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import "UIImage+ImageUtilities.h"



@implementation UIImage (ImageUtilities)

- (UIImage *)imageWithFixedOtientation
{
    // Do nothing if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return [self copy];
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in two steps: Rotate if left/right/down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
         
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGimage into a new context, applying the transform
    // calculated above
    
    CGFloat scaleFactor = self.scale;
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width * scaleFactor, self.size.height * scaleFactor, CGImageGetBitsPerComponent(self.CGImage), 0, CGImageGetColorSpace(self.CGImage), CGImageGetBitmapInfo(self.CGImage));
    CGContextScaleCTM(ctx, scaleFactor, scaleFactor);
    CGContextConcatCTM(ctx, transform);
    
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);

            break;
    }
    
    // Create a new UIImage from the drawing contex
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg scale:scaleFactor orientation:UIImageOrientationUp];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage *) imageResizedToMatchAspectRatioOfSize:(CGSize)size
{
    CGFloat horizonalRatio = size.width / self.size.width;
    CGFloat verticalRatio = size.height / self.size.height;
    CGFloat ratio = MAX(horizonalRatio, verticalRatio);
    CGSize newSize = CGSizeMake(self.size.width * ratio * self.scale, self.size.height * ratio * self.scale);
    
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = self.CGImage;
    
    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             newRect.size.width,
                                             newRect.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage),
                                             0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    
    // Draw into the context
    CGContextDrawImage(ctx, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(ctx);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:self.scale orientation:UIImageOrientationUp];
    
    // Clean Up
    CGContextRelease(ctx);
    CGImageRelease(newImageRef);
    
    return newImage;
}

- (UIImage *)imageCroppedToRect:(CGRect)cropRect
{
    cropRect.size.width *= self.scale;
    cropRect.size.height *= self.scale;
    cropRect.origin.x *= self.scale;
    cropRect.origin.y *= self.scale;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return image;
}

- (UIImage *)imageByScalingToSize:(CGSize)size andCroppingWithRect:(CGRect)rect
{
    
    // Do nothing if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return [self copy];
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in two steps: Rotate if left/right/down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGimage into a new context, applying the transform
    // calculated above
    
    CGFloat scaleFactor = self.scale;
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width * scaleFactor, self.size.height * scaleFactor, CGImageGetBitsPerComponent(self.CGImage), 0, CGImageGetColorSpace(self.CGImage), CGImageGetBitmapInfo(self.CGImage));
    CGContextScaleCTM(ctx, scaleFactor, scaleFactor);
    CGContextConcatCTM(ctx, transform);
    
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
            
            break;
    }
    
    // Create a new UIImage from the drawing contex
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg scale:scaleFactor orientation:UIImageOrientationUp];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    // END OF ORIENTATION
    
    CGFloat horizonalRatio = size.width / img.size.width;
    CGFloat verticalRatio = size.height / img.size.height;
    CGFloat ratio = MAX(horizonalRatio, verticalRatio);
    CGSize newSize = CGSizeMake(img.size.width * ratio * img.scale, img.size.height * ratio * img.scale);
    
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = img.CGImage;
    
    CGContextRef ctx1 = CGBitmapContextCreate(NULL,
                                             newRect.size.width,
                                             newRect.size.height,
                                             CGImageGetBitsPerComponent(img.CGImage),
                                             0,
                                             CGImageGetColorSpace(img.CGImage),
                                             CGImageGetBitmapInfo(img.CGImage));
    
    // Draw into the context
    CGContextDrawImage(ctx1, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(ctx1);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:img.scale orientation:UIImageOrientationUp];
    
    // Clean Up
    CGContextRelease(ctx1);
    CGImageRelease(newImageRef);
    
    // END OF RESIZE: HAVE newImage now
    
    rect.size.width *= newImage.scale;
    rect.size.height *= newImage.scale;
    rect.origin.x *= newImage.scale;
    rect.origin.y *= newImage.scale;
    
    CGImageRef imageRef1 = CGImageCreateWithImageInRect(newImage.CGImage, rect);
    UIImage *image = [UIImage imageWithCGImage:imageRef1 scale:newImage.scale orientation:newImage.imageOrientation];
    CGImageRelease(imageRef1);
    return image;
    
    
}

@end
