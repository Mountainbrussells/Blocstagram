//
//  DataSource.h
//  Blocstagram
//
//  Created by Ben Russell on 10/14/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Media;

@interface DataSource : NSObject

+(instancetype) sharedInstance;

@property (nonatomic, strong, readonly) NSArray *mediaItems;

- (void)deleteMediaItem:(Media *)item;
- (void)insertObject:(Media *)object inMediaItemsAtIndex:(NSUInteger)index;

@end




