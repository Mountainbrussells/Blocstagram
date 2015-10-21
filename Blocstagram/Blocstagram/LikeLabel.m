//
//  LikeLabel.m
//  Blocstagram
//
//  Created by Ben Russell on 10/21/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import "LikeLabel.h"

@implementation LikeLabel

- (instancetype) init {
    self = [super init];
    
    if (self) {
        self.text = @"64";
        
        [self sizeToFit];
        
        
        
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
