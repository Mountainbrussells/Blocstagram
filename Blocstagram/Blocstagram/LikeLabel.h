//
//  LikeLabel.h
//  Blocstagram
//
//  Created by Ben Russell on 10/21/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Media.h"

@interface LikeLabel : UILabel

- (NSInteger)numberOfLikes: (Media *)mediaItem;



@end
