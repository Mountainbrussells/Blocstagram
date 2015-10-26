//
//  FilterCell.h
//  Blocstagram
//
//  Created by Ben Russell on 10/26/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *thumbnail;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

- (void)layoutFilterCell;

@end
