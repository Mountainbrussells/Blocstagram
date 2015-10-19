//
//  Comment.m
//  Blocstagram
//
//  Created by Ben Russell on 10/14/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import "Comment.h"
#import "User.h"

@implementation Comment

- (instancetype)initWithDictionary:(NSDictionary *)commentDictionary
{
    self= [super init];
    
    if (self) {
        self.idNumber = commentDictionary[@"id"];
        self.text = commentDictionary[@"text"];
        self.from = [[User alloc] initWithDictionary:commentDictionary[@"from"]];
    }
    
    return self;
}

@end
