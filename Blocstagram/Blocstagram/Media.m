//
//  Media.m
//  Blocstagram
//
//  Created by Ben Russell on 10/14/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import "Media.h"
#import "User.h"
#import "Comment.h"

@implementation Media

- (instancetype)initWithDictionary:(NSDictionary *)mediaDictionary
{
    self = [super init];
    
    if (self) {
        self.idNumber = mediaDictionary[@"id"];
        self.user = [[User alloc] initWithDictionary:mediaDictionary[@"user"]];
        NSString *standardResolutionImageURLString = mediaDictionary[@"images"][@"standard_resolution"][@"url"];
        NSURL *standardResolutionImageURL = [NSURL URLWithString:standardResolutionImageURLString];
        
        if (standardResolutionImageURL) {
            self.mediaImage = standardResolutionImageURL;
        }
        
        NSDictionary *captionDictionary = mediaDictionary[@"caption"];
        
        // Caption might be null (if there is no caption)
        if ([captionDictionary isKindOfClass:[NSDictionary class]]) {
            self.caption = captionDictionary[@"text"];
        } else {
            self.caption = @"";
        }
        
        NSMutableArray *commentsArray = [NSMutableArray array];
        
        for (NSDictionary *commentsDictionary in mediaDictionary[@"comments"][@"data"]) {
            Comment *comment = [[Comment alloc] initWithDictionary:commentsDictionary];
            [commentsArray addObject:comment];
        }
        
        self.comments = commentsArray;
    }
    
    return self;
   
}

@end
