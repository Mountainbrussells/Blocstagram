//
//  CameraViewController.m
//  Blocstagram
//
//  Created by Ben Russell on 10/22/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import "CameraViewController.h"
#import "CameraToolBar.h"
#import "UIImage+ImageUtilities.h"
#import "CropBox.h"
#import "ImageLibraryViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface CameraViewController () <CameraToolbarDelegate, ImageLibraryViewControllerDelegate>

@property (nonatomic, strong)UIView *imagePreview;

@property (nonatomic, strong)AVCaptureSession *session;
@property (nonatomic, strong)AVCaptureVideoPreviewLayer *captureVideoPreviewlayer;
@property (nonatomic, strong)AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, strong)UIToolbar *topView;
@property (nonatomic, strong)UIToolbar *bottomView;

@property (nonatomic, strong)CropBox *cropBox;
@property (nonatomic, strong)CameraToolBar *cameraToolbar;

@end

@implementation CameraViewController

#pragma mark - Build View Hierarchy

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createViews];
    [self addViewsToViewHierarchy];
    [self setUpImageCapture];
    [self createCancelButton];
    
}

- (void)createCancelButton
{
    UIImage *cancelImage = [UIImage imageNamed:@"x"];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:cancelImage
                                                                     style:UIBarButtonItemStyleDone
                                                                    target:self
                                                                    action:@selector(cancelPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void)setUpImageCapture
{
    // #1
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    
    // #2
    self.captureVideoPreviewlayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.captureVideoPreviewlayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.captureVideoPreviewlayer.masksToBounds = YES;
    [self.imagePreview.layer addSublayer:self.captureVideoPreviewlayer];
    
    // #3
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // #4
            if (granted) {
                // #5
                AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                
                // #6
                NSError *error = nil;
                AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
                if (!input) {
                    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:error.localizedDescription
                                                                                     message:error.localizedRecoverySuggestion
                                                                              preferredStyle:UIAlertControllerStyleAlert];
                    [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK button")
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  [self.delegate cameraViewController:self
                                                                                 didCompleteWithImage:nil];
                                                              }]];
                    
                    [self presentViewController:alertVC animated:YES completion:nil];
                } else {
                    // #7
                    
                    [self.session addInput:input];
                    
                    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
                    self.stillImageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
                    
                    [self.session addOutput:self.stillImageOutput];
                    
                    [self.session startRunning];
                }
            } else {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Camera Permission Denied", @"camera permission denied title")
                                                                                 message:NSLocalizedString(@"This app doesn't have permission to use the camera; please update your privacy settings.", @"camera permission denied recovery suggestion")
                                                                          preferredStyle:UIAlertControllerStyleAlert];
                [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"ok button")
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              [self.delegate cameraViewController:self didCompleteWithImage:nil];
                                                          }]];
                
                [self presentViewController:alertVC animated:YES completion:nil];
            }
        });
    }];
}

- (void)createViews
{
    self.imagePreview = [UIView new];
    self.topView = [UIToolbar new];
    self.bottomView = [UIToolbar new];
    self.cropBox = [CropBox new];
    self.cameraToolbar = [[CameraToolBar alloc] initWithImageNames:@[@"rotate", @"road"]];
    self.cameraToolbar.delegate = self;
    UIColor *whiteBG = [UIColor colorWithWhite:1.0 alpha:.15];
    self.topView.barTintColor = whiteBG;
    self.bottomView.barTintColor = whiteBG;
    self.topView.alpha = 0.5;
    self.bottomView.alpha = 0.5;
    
    
}

- (void)addViewsToViewHierarchy
{
    NSMutableArray *views = [@[self.imagePreview, self.cropBox, self.topView, self.bottomView] mutableCopy];
    [views addObject:self.cameraToolbar];
    
    for (UIView *view in views) {
        [self.view addSubview:view];
    }
}



#pragma mark - Layout

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    self.topView.frame = CGRectMake(0, self.topLayoutGuide.length, width, 44);
    
    CGFloat yOriginOfBottomView = CGRectGetMaxY(self.topView.frame) + width;
    CGFloat heightOfBottomView = CGRectGetHeight(self.view.frame) - yOriginOfBottomView;
    self.bottomView.frame = CGRectMake(0 , yOriginOfBottomView, width, heightOfBottomView);
   
    self.cropBox.frame = CGRectMake(0, CGRectGetMaxY(self.topView.frame), width, width);
    
    self.imagePreview.frame = self.view.bounds;
    self.captureVideoPreviewlayer.frame = self.imagePreview.bounds;
    
    CGFloat cameraToolBarHeight = 100;
    
    self.cameraToolbar.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - cameraToolBarHeight, width, cameraToolBarHeight);
}

#pragma mark - Event Handling

- (void)cancelPressed:(UIBarButtonItem *)sender
{
    [self.delegate cameraViewController:self
                   didCompleteWithImage:nil];
}

- (void)cameraButtonPressedOnToolbar:(CameraToolBar *)toolbar
{
    AVCaptureConnection *videoConnection;
    
    // #8
    // Find the right connection object
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in connection.inputPorts) {
            if ([port.mediaType isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    
    // #9
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer) {
            // #10
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
            
            // #11
            image = [image imageWithFixedOtientation];
            image = [image imageResizedToMatchAspectRatioOfSize:self.captureVideoPreviewlayer.bounds.size];
            
           
            CGRect gridRect = self.cropBox.frame;
            
            CGRect cropRect = gridRect;
            cropRect.origin.x = (CGRectGetMinX(gridRect) + (image.size.width - CGRectGetWidth(gridRect)) / 2);
            
            image = [image imageCroppedToRect:cropRect];
            
            // #13
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate cameraViewController:self didCompleteWithImage:image];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:error.localizedDescription
                                                                                 message:error.localizedRecoverySuggestion
                                                                          preferredStyle:UIAlertControllerStyleAlert];
                [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK button")
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              [self.delegate cameraViewController:self
                                                                             didCompleteWithImage:nil];
                                                          }]];
                [self presentViewController:alertVC
                                   animated:YES
                                 completion:nil];
            });
        }
    }];
}

#pragma mark - CameraToolBarDelegate

- (void)leftButtonPressedOnToolbar:(CameraToolBar *)toolbar
{
    AVCaptureDeviceInput *currentCameraInput = self.session.inputs.firstObject;
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    if (devices.count > 1) {
        NSUInteger currentIndex = [devices indexOfObject:currentCameraInput.device];
        NSUInteger newIndex = 0;
        
        if (currentIndex < devices.count - 1) {
            newIndex = currentIndex +1;
        }
        
        AVCaptureDevice *newCamera = devices[newIndex];
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:nil];
        
        if (newVideoInput) {
            UIView *fakeView = [self.imagePreview snapshotViewAfterScreenUpdates:YES];
            fakeView.frame = self.imagePreview.frame;
            [self.view insertSubview:fakeView aboveSubview:self.imagePreview];
            
            [self.session beginConfiguration];
            [self.session removeInput:currentCameraInput];
            [self.session addInput:newVideoInput];
            [self.session commitConfiguration];
            
            [UIView animateWithDuration:0.2
                                           delay:0
                                         options:UIViewAnimationOptionCurveEaseInOut
                                      animations:^{
                                          fakeView.alpha = 0;
                                      } completion:^(BOOL finished) {
                                          [fakeView removeFromSuperview];
                                      }];
        }
    }
}

- (void)rightButtonPressedOnToolbar:(CameraToolBar *)toolbar
{
    ImageLibraryViewController *imageLibraryVC = [[ImageLibraryViewController alloc] init];
    imageLibraryVC.delegate = self;
    [self.navigationController pushViewController:imageLibraryVC animated:YES];
}

#pragma mark - ImageLibraryViewControllerDelegate

- (void)imageLibraryViewController:(ImageLibraryViewController *)imageLibraryViewController didCompleteWithImage:(UIImage *)image
{
    [self.delegate cameraViewController:self didCompleteWithImage:image];
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
