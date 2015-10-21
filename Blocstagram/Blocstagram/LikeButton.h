//
//  LikeButton.h
//  Blocstagram
//
//  Created by Ben Russell on 10/21/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LikeState) {
    LikeStateNotLiked             = 0,
    LikeStateLiking               = 1,
    LikeStateliked                = 2,
    LikeStateUnliking             = 3
};

@interface LikeButton : UIButton

/**
 The current state of the like button. Setting to LikeButtonNotLiked or LikeButtonLiked will display and empty heart or a heart respectively
 */
@property (nonatomic, assign) LikeState likeButtonState;

@end
