//
//  DataSource.m
//  Blocstagram
//
//  Created by Ben Russell on 10/14/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import "DataSource.h"
#import "User.h"
#import "Media.h"
#import "Comment.h"
#import "LoginViewController.h"

#import <UICKeyChainStore.h>
#import <AFNetworking.h>


@interface DataSource() {
    NSMutableArray *_mediaItems;
}

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSArray *mediaItems;

@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingOlderItems;
@property (nonatomic, assign) BOOL thereAreNoMoreOlderMEssages;

@property (nonatomic, strong) AFHTTPRequestOperationManager *instagramOperationsManager;

@end

@implementation DataSource

+ (instancetype) sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (NSString *) instagramClientID
{
    return @"efb2b4d2f24241c2926f96adc3661b87";
}

- (instancetype) init
{
    self = [super init];
    
    if (self) {
        [self createOperationsManager];
        
        self.accessToken = [UICKeyChainStore stringForKey:@"access token"];
        
        if (!self.accessToken) {
            [self registerForAccessNotification];
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
                NSArray *storedMediaItems = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (storedMediaItems.count > 0) {
                        NSMutableArray *mutableMediaItems = [storedMediaItems mutableCopy];
                        
                        [self willChangeValueForKey:@"mediaItems"];
                        self.mediaItems = mutableMediaItems;
                        [self didChangeValueForKey:@"mediaItems"];
                        // #1
                        
                    } else {
                        [self populateDataWithParameters:nil completionHandler:nil];
                    }
                });
            });
        }
    }
    
    
    return  self;
}

- (void)registerForAccessNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      self.accessToken = note.object;
                                                      [UICKeyChainStore setString:self.accessToken forKey:@"access token"];
                                                      
                                                      // Got a token; populate the data
                                                      [self populateDataWithParameters:nil completionHandler:nil];
                                                  }];
    
}

- (void)requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler
{
    self.thereAreNoMoreOlderMEssages = NO;
    
    if (self.isRefreshing == NO) {
        self.isRefreshing = YES;
        
        NSString *minID = [[self.mediaItems firstObject] idNumber];
        NSDictionary *parameters;
        
        if (minID) {
            parameters = @{@"min_id":minID};
        }
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isRefreshing = NO;
            
            if (completionHandler) {
                completionHandler(error);
            }
        }];
        
    }
}

- (void)requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler
{
    if (self.isLoadingOlderItems == NO  && self.thereAreNoMoreOlderMEssages == NO){
        self.isLoadingOlderItems = YES;
       
        NSString *maxID = [[self.mediaItems lastObject] idNumber];
        NSDictionary *parameters;
        
        if (maxID) {
            parameters = @{@"max_id":maxID};
        }
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isLoadingOlderItems = NO;
            if (completionHandler){
                completionHandler(error);
            }
        }];
    }
}

- (void)populateDataWithParameters:(NSDictionary *)parameters completionHandler:(NewItemCompletionBlock)completionHandler
{
    if (self.accessToken) {
        // only try to get thedata if there is an access token
        
        NSMutableDictionary *mutableParameters = [@{@"access_token": self.accessToken} mutableCopy];
        
        [mutableParameters addEntriesFromDictionary:parameters];
        
        [self.instagramOperationsManager GET:@"users/self/feed"
                                  parameters:mutableParameters
                                     success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                         if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                             [self parseDataFromFeedDictionary:responseObject
                                                     fromRequestWithParameters:parameters];
                                         }
                                         
                                         if (completionHandler) {
                                             completionHandler(nil);
                                         }
                                     }
                                     failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                         if (completionHandler) {
                                             completionHandler(error);
                                         }
                                     }];

    }
}

- (void) parseDataFromFeedDictionary:(NSDictionary *)feedDictionary fromRequestWithParameters:(NSDictionary *)parameters
{
    NSArray *mediaArray = feedDictionary[@"data"];
    
    NSMutableArray *tmpMediaItems = [NSMutableArray array];
    
    for (NSDictionary *mediaDictionary in mediaArray) {
        Media *mediaItem = [[Media alloc] initWithDictionary:mediaDictionary];
        
        if (mediaItem) {
            [tmpMediaItems addObject:mediaItem];
            
        }
    }
    
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    
    if (parameters[@"min_id"]) {
        // This was a pull to refresh request
        NSLog(@"This was a pull to refresh");
        
        NSRange rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count);
        NSIndexSet *indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
        
        [mutableArrayWithKVO insertObjects:tmpMediaItems atIndexes:indexSetOfNewObjects];
    } else if (parameters[@"max_id"]) {
        // This was an infinite scroll request
        
        if (tmpMediaItems.count == 0) {
            // disable infinitescroll, since there are no more older items
            self.thereAreNoMoreOlderMEssages = YES;
        } else {
            [mutableArrayWithKVO addObjectsFromArray:tmpMediaItems];
        }
    } else {
        
        [self willChangeValueForKey:@"mediaItems"];
        self.mediaItems = tmpMediaItems;
        [self didChangeValueForKey:@"mediaItems"];
    }
    
    [self saveImages];
    
}

- (void)downLoadImageForMediaItem:(Media *)mediaItem
{
    if (mediaItem.mediaImage && !mediaItem.image) {
        mediaItem.downloadState = MediaDownloadStateDownloadInProgress;
        
        [self.instagramOperationsManager GET:mediaItem.mediaImage.absoluteString
                                  parameters:nil
                                     success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                         if ([responseObject isKindOfClass:[UIImage class]]) {
                                             mediaItem.image = responseObject;
                                             mediaItem.downloadState = MediaDownloadStateHasImage;
                                             NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                                             NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                                             [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
                                             [self saveImages];
                                         } else {
                                             mediaItem.downloadState = MediaDownloadStateNonRecoverableError;
                                         }
                                         
                                         
                                     }
                                     failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                         NSLog(@"Error downloading image: %@", error);
                                         
                                         mediaItem.downloadState = MediaDownloadStateNonRecoverableError;
                                         
                                         if ([error.domain isEqualToString:NSURLErrorDomain]) {
                                             // A networking problem
                                             if (error.code == NSURLErrorTimedOut ||
                                                 error.code == NSURLErrorCancelled ||
                                                 error.code == NSURLErrorCannotConnectToHost ||
                                                 error.code == NSURLErrorNetworkConnectionLost ||
                                                 error.code == NSURLErrorNotConnectedToInternet ||
                                                 error.code == kCFURLErrorInternationalRoamingOff ||
                                                 error.code == kCFURLErrorCallIsActive ||
                                                 error.code == kCFURLErrorDataNotAllowed ||
                                                 error.code == kCFURLErrorTimedOut ||
                                                 error.code == kCFURLErrorRequestBodyStreamExhausted) {
                                                 
                                                 // It might work if we try again
                                                 mediaItem.downloadState = MediaDownloadStateNeedsImage;
                                             }
                                         }
                                     }];
    }
}


#pragma mark - Key/Value Observing

- (NSUInteger)countOfMediaItems
{
    return self.mediaItems.count;
}

- (id)objectInMediaItemsAtIndex:(NSUInteger)index
{
    return [self.mediaItems objectAtIndex:index];
}

- (NSArray *)mediaItemsAtIndexes:(NSIndexSet *)indexes
{
    return [self.mediaItems objectsAtIndexes:indexes];
}

- (void)insertObject:(Media *)object inMediaItemsAtIndex:(NSUInteger)index
{
    [_mediaItems insertObject:object atIndex:index];
}

- (void)removeObjectFromMediaItemsAtIndex:(NSUInteger)index
{
    [_mediaItems removeObjectAtIndex:index];
}

- (void)replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object
{
    [_mediaItems replaceObjectAtIndex:index withObject:object];
}

- (void)deleteMediaItem:(Media *)item
{
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    [mutableArrayWithKVO removeObject:item];
}

#pragma - mark NSCoding

- (NSString *)pathForFilename:(NSString *)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    
    return dataPath;
}

- (void)saveImages
{
    if (self.mediaItems.count > 0){
        // Write the changes to disk
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSUInteger numberOfItemsToSave = MIN(self.mediaItems.count, 50);
            NSArray *mediaItemsToSave = [self.mediaItems subarrayWithRange:NSMakeRange(0, numberOfItemsToSave)];
            
            NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
            NSData *mediaItemData = [NSKeyedArchiver archivedDataWithRootObject:mediaItemsToSave];
            
            NSError *dataError;
            BOOL wroteSuccessfully = [mediaItemData writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
            
            if (!wroteSuccessfully) {
                NSLog(@"Couldn't write file: %@", dataError);
            }
            
        });
    }
}

#pragma - mark AFN operations manager
- (void)createOperationsManager
{
    NSURL *baseURL = [NSURL URLWithString:@"https://api.instagram.com/v1/"];
    self.instagramOperationsManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    
    AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
    
    AFImageResponseSerializer *imageSerializer = [AFImageResponseSerializer serializer];
    imageSerializer.imageScale = 1.0;
    
    AFCompoundResponseSerializer *serializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonSerializer, imageSerializer]];
    self.instagramOperationsManager.responseSerializer = serializer;
}

#pragma mark - Liking Media Items

- (void)toggleLikeOnMediaItem:(Media *)mediaItem withCompletionHandler:(void (^)(void))completionHandler
{
    NSString *urlString = [NSString stringWithFormat:@"meedia/%@/likes", mediaItem.idNumber];
    NSDictionary *parameters = @{@"access_token": self.accessToken};
    
    if (mediaItem.likeState == LikeStateNotLiked) {
        mediaItem.likeState = LikeStateLiking;
        
        // For testing
        mediaItem.likeState = LikeStateliked;
        mediaItem.numberOfLikes += 1;
        [self reloadMediaItem:mediaItem];
        
//        [self.instagramOperationsManager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//            mediaItem.likeState = LikeStateliked;
//            
//            if (completionHandler) {
//                completionHandler();
//            }
//        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
//            mediaItem.likeState = LikeStateNotLiked;
//            
//            if (completionHandler) {
//                completionHandler();
//            }
//        }];
    } else if (mediaItem.likeState == LikeStateliked) {
        
        mediaItem.likeState = LikeStateUnliking;
        
//        // for testing
//        mediaItem.likeState = LikeStateNotLiked;
        [self.instagramOperationsManager DELETE:urlString parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            mediaItem.likeState = LikeStateNotLiked;
            
            if (completionHandler) {
                completionHandler();
            }
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            mediaItem.likeState = LikeStateliked;
            
            if (completionHandler) {
                completionHandler();
            }
        }];
    }
    
}

- (void)reloadMediaItem:(Media *)mediaItem {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    
    NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
    [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
}
@end
