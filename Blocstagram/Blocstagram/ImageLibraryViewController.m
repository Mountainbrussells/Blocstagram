//
//  ImageLibraryViewController.m
//  Blocstagram
//
//  Created by Ben Russell on 10/23/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import "ImageLibraryViewController.h"
#import "CropImageViewController.h"

#import <Photos/Photos.h>

@interface ImageLibraryViewController () <CropImageViewControllerDelegate>

@property (nonatomic, strong) PHFetchResult *result;

@end


@implementation ImageLibraryViewController

- (instancetype)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100, 100);
    
    return [super initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    UIImage *cancelImage = [UIImage imageNamed:@"x"];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:cancelImage style:UIBarButtonItemStyleDone target:self action:@selector(cancelPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void)cancelPressed:(UIBarButtonItem *)sender
{
    [self.delegate imageLibraryViewController:self didCompleteWithImage:nil];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat minWidth = 100;
    NSInteger divisor = width / minWidth;
    CGFloat cellSize = width / divisor;
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    flowLayout.itemSize = CGSizeMake(cellSize, cellSize);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
}

- (void)loadAssets
{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    self.result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadAssets];
                    [self.collectionView reloadData];
                });
            }
        }];
    } else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        [self loadAssets];
    }
}

#pragma mark - CollectionViewDelegates

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.result.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSInteger imageViewtag = 54321;
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:imageViewtag];
    
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        
        imageView.tag = imageViewtag;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        imageView.contentMode = YES;
        [cell.contentView addSubview:imageView];
    }
    
    if (cell.tag != 0) {
        [[PHImageManager defaultManager] cancelImageRequest:(PHImageRequestID)cell.tag];
    }
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    PHAsset *asset = self.result[indexPath.row];
    
    cell.tag = [[PHImageManager defaultManager] requestImageForAsset:asset
                                                          targetSize:flowLayout.itemSize
                                                         contentMode:PHImageContentModeAspectFill
                                                             options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                                 UICollectionViewCell *cellToUpdate = [collectionView cellForItemAtIndexPath:indexPath];
                                                                 if (cellToUpdate){
                                                                     UIImageView *imageView = (UIImageView *)[cellToUpdate.contentView viewWithTag:imageViewtag];
                                                                     imageView.image = result;
                                                                 }
                                                             }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = self.result[indexPath.row];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = YES;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:PHImageManagerMaximumSize
                                              contentMode:PHImageContentModeDefault
                                                  options:options
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                CropImageViewController *cropVC = [[CropImageViewController alloc] initWithImage:result];
                                                cropVC.delegate = self;
                                                [self.navigationController pushViewController:cropVC animated:YES];
                                            }];
}

#pragma mark - CropImageViewControllerDelegate

- (void)cropControllerFinishedWithImage:(UIImage *)croppedImage
{
    [self.delegate imageLibraryViewController:self didCompleteWithImage:croppedImage];
}


@end
