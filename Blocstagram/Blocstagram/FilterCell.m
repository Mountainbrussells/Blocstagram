//
//  FilterCell.m
//  Blocstagram
//
//  Created by Ben Russell on 10/26/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import "FilterCell.h"

@implementation FilterCell



- (void)layoutFilterCell
{
    static NSInteger imageViewTag = 1000;
    static NSInteger labelTag = 1001;
    
    
    self.thumbnail = (UIImageView *)[self.contentView viewWithTag:imageViewTag];
    self.label = (UILabel *)[self.contentView viewWithTag:labelTag];
    
    CGFloat thumbnailEdgeSize = self.layout.itemSize.width;
    
    if (!self.thumbnail) {
        self.thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbnailEdgeSize, thumbnailEdgeSize)];
        self.thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        self.thumbnail.tag = imageViewTag;
        self.thumbnail.clipsToBounds = YES;
        
        [self.contentView addSubview:self.thumbnail];
    }
    
    if (!self.label) {
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, thumbnailEdgeSize, thumbnailEdgeSize, 20)];
        self.label.tag = labelTag;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
        [self.contentView addSubview:self.label];
    }
    
}



@end
