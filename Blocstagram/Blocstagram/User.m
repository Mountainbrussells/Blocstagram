//
//  User.m
//  Blocstagram
//
//  Created by Ben Russell on 10/14/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithDictionary:(NSDictionary *)userDictionary
{
    self = [super init];
    
    if (self) {
        self.idNumber = userDictionary[@"id"];
        self.userName = userDictionary[@"username"];
        self.fullName = userDictionary[@"full_name"];
        
        NSString *profileString = userDictionary[@"profile_picture"];
        NSURL *profileURL = [NSURL URLWithString:profileString];
        
        if (profileURL) {
            self.profilePictureURL = profileURL;
        }
    }
    
    return self;
}

@end
