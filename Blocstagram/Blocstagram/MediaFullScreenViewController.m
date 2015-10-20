//
//  MediaFullScreenViewController.m
//  Blocstagram
//
//  Created by Ben Russell on 10/19/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import "MediaFullScreenViewController.h"
#import "Media.h"

@interface MediaFullScreenViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) Media *media;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) NSLayoutConstraint *shareButtonVerticleConstraint;
@property (nonatomic, strong) NSLayoutConstraint *shareButtonHorizontalConstraint;

@end

@implementation MediaFullScreenViewController

- (instancetype)initWithMedia:(Media *)media
{
    self = [super init];
    
    if (self) {
        self.media = media;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // #1
    self.scrollView = [UIScrollView new];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.scrollView];
    
    // #2
    self.imageView = [UIImageView new];
    self.imageView.image = self.media.image;
    
    [self.scrollView addSubview:self.imageView];
    
    // #3
    self.scrollView.contentSize = self.media.image.size;
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapFired:)];
    self.doubleTap.numberOfTapsRequired = 2;
    
    [self.tap requireGestureRecognizerToFail:self.doubleTap];
    
    [self.scrollView addGestureRecognizer:self.tap];
    [self.scrollView addGestureRecognizer:self.doubleTap];
    
    // Add share button
    self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.shareButton.backgroundColor = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1];
    self.shareButton.layer.cornerRadius = 10;
    self.shareButton.clipsToBounds = YES;
    [self.shareButton addTarget:self action:@selector(shareButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton setTitle:@"Share" forState:UIControlStateNormal];
    self.shareButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.shareButton setTitleColor:[UIColor colorWithRed:0.345 green:0.314 blue:0.550 alpha:1] forState:UIControlStateNormal];
    

    
    [self.scrollView addSubview:self.shareButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self centerScrollView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    //#4
    self.scrollView.frame = self.view.bounds;
    
    // #5
    CGSize scrollViewFrameSize = self.scrollView.frame.size;
    CGSize scrollViewContentSize = self.scrollView.contentSize;
    
    CGFloat scaleWidth = scrollViewFrameSize.width / scrollViewContentSize.width;
    CGFloat scaleHeight = scrollViewFrameSize.height / scrollViewContentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 1;
    
   // TODO: not understanding trailing
//    self.shareButtonHorizontalConstraint = [NSLayoutConstraint constraintWithItem:_shareButton
//                                                                        attribute:NSLayoutAttributeTrailing
//                                                                        relatedBy:NSLayoutRelationEqual
//                                                                           toItem:self.scrollView
//                                                                        attribute:NSLayoutAttributeTrailing
//                                                                       multiplier:1
//                                                                         constant:8];
    
    self.shareButtonHorizontalConstraint = [NSLayoutConstraint constraintWithItem:_shareButton
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.scrollView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1
                                                                         constant:0];

    self.shareButtonVerticleConstraint = [NSLayoutConstraint constraintWithItem:_shareButton
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.scrollView
                                                                      attribute:NSLayoutAttributeTopMargin
                                                                     multiplier:1
                                                                       constant:20];
    [self.scrollView addConstraints:@[self.shareButtonHorizontalConstraint, self.shareButtonVerticleConstraint]];
    
    [self.scrollView setNeedsLayout];
    [self.scrollView layoutIfNeeded];
    
}



- (void)centerScrollView
{
    [self.imageView sizeToFit];
    
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - CGRectGetWidth(contentsFrame)) / 2;
        
    } else {
        contentsFrame.origin.x = 0;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - CGRectGetHeight(contentsFrame)) / 2;
        
    } else {
        contentsFrame.origin.y = 0;
    }
    
    self.imageView.frame = contentsFrame;
}

#pragma mark - Gesture Recognizers

- (void)tapFired:(UIGestureRecognizer *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doubleTapFired:(UIGestureRecognizer *)sender
{
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        CGPoint locationPoint = [sender locationInView:self.imageView];
        
        CGSize scrollViewSize = self.scrollView.bounds.size;
        
        CGFloat width = scrollViewSize.width / self.scrollView.maximumZoomScale;
        CGFloat height = scrollViewSize.height / self.scrollView.maximumZoomScale;
        CGFloat x = locationPoint.x - (width / 2);
        CGFloat y = locationPoint.y - (height / 2);
        
        [self.scrollView zoomToRect:CGRectMake(x, y, width, height) animated:YES];
        
        [self.scrollView setNeedsLayout];
        [self.scrollView layoutIfNeeded];
        
    } else {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
        
        [self.scrollView setNeedsLayout];
        [self.scrollView layoutIfNeeded];
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerScrollView];
}

#pragma mark - Share Button
- (void)shareButtonTapped:(UIButton *)sender
{
    NSLog(@"Share button was tapped");
    
    NSMutableArray *itemsToShare = [NSMutableArray array];
    
    
    if (self.imageView.image) {
        [itemsToShare addObject:self.imageView.image];
    }
    
    if (itemsToShare.count > 0) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
