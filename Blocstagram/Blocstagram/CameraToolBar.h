//
//  CameraToolBar.h
//  Blocstagram
//
//  Created by Ben Russell on 10/22/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraToolBar;


@protocol CameraToolbarDelegate <NSObject>

- (void) leftButtonPressedOnToolbar:(CameraToolBar *)toolbar;
- (void) rightButtonPressedOnToolbar:(CameraToolBar *)toolbar;
- (void) cameraButtonPressedOnToolbar:(CameraToolBar *)toolbar;

@end

@interface CameraToolBar : UIView

- (instancetype)initWithImageNames:(NSArray *)imageNames;

@property (nonatomic, weak) NSObject <CameraToolbarDelegate> *delegate;

@end
