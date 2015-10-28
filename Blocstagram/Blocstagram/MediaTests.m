//
//  MediaTests.m
//  Blocstagram
//
//  Created by Ben Russell on 10/27/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Media.h"
#import "User.h"
#import "Comment.h"

@interface MediaTests : XCTestCase

@property (nonatomic, strong)NSDictionary *mediaDictionary;

@end

@implementation MediaTests

- (void)testThatInitializerWorksWithSourceDictionary
{
    NSDictionary *sourceDictionary = @{@"id": @"1234",
                                       @"user": @{@"id":@"4455", @"username":@"Bobbo", @"full_name":@"BobSmith"},
                                      @"images":@{@"standard_resolution":@{@"url": @"http://www.example.com/example.jpg"}},
                                       @"caption": @{@"text":@"What A pic!"},
                                       @"comments":@{@"data":@[@{@"id":@"4321", @"text":@"That rocks", @"from":@{@"full_name":@"John Smith", @"id":@"23456", @"profile_picture": @"http://www.example.com/example.jpg", @"username":@"JohnnyS"}}]},
                                                     @"user_has_liked":@YES};
   
    Media *testMedia = [[Media alloc] initWithDictionary:sourceDictionary];
    
    XCTAssertEqualObjects(testMedia.idNumber, sourceDictionary[@"id"], @"The id numbers should be equal");
    
                                       
                                       
                                       
}

- (void)testThatInitializerWorksWithDownloadDictionary
{
  
    
    Media *testMedia = [[Media alloc] initWithDictionary:self.mediaDictionary];
    
    XCTAssertEqualObjects(testMedia.idNumber, self.mediaDictionary[@"id"], @"The id numbers should be equal");
    XCTAssertEqualObjects(testMedia.user.userName, self.mediaDictionary[@"user"][@"username"], @"The usernames should be equal");
    
    NSString *standardResolutionImageURLString = self.mediaDictionary[@"images"][@"standard_resolution"][@"url"];
    NSURL *standardResolutionImageURL = [NSURL URLWithString:standardResolutionImageURLString];
    XCTAssertEqualObjects(testMedia.mediaImage, standardResolutionImageURL, @"The URL's should be equal");
    
    NSDictionary *captionDictionary = self.mediaDictionary[@"caption"];
    XCTAssertEqualObjects(testMedia.caption, captionDictionary[@"text"], @"Captions should be equal");
    
    
}

- (void)setUp {
    [super setUp];
    NSString *str=[[NSBundle mainBundle] pathForResource:@"instagramdownload" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:str];
    NSError *error;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    NSLog(@"%@", jsonDictionary);
    NSArray *mediaArray = jsonDictionary[@"data"];
    self.mediaDictionary = mediaArray[0];
    
        
    
    
   
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
