//
//  MediaTableViewTest.m
//  Blocstagram
//
//  Created by Ben Russell on 10/27/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MediaTableViewCell.h"
#import "Media.h"

@interface MediaTableViewTest : XCTestCase

@property (nonatomic, strong)NSDictionary *mediaDictionary;

@end

@implementation MediaTableViewTest

- (void)testImageHeight
{
    MediaTableViewCell *cell = [[MediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"layoutCell"];
    
    Media *mediaItem = [[Media alloc] initWithDictionary:self.mediaDictionary];
    mediaItem.image = [UIImage imageNamed:@"Steelhead"];
    
    [cell setMediaItem:mediaItem];
    
    
    
    CGFloat width = 640.0;
    
    CGFloat imageHeight = [MediaTableViewCell heightForMediaItem:mediaItem width:width traitCollection:cell.traitCollection];
    
    
    
    XCTAssertEqual(imageHeight, 225, @"Image View height should be 225");
    
    
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
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
