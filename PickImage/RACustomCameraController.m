//
//  RACustomCameraController.m
//  RACustomCamera
//
//  Created by Rocky on 15/9/22.
//  Copyright © 2015年 Rocky. All rights reserved.
//

#import "RACustomCameraController.h"
#import <AVFoundation/AVFoundation.h>
#import "IFCAPickImageTool.h"
#import "EditViewController.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight  [UIScreen mainScreen].bounds.size.height


@interface RACustomCameraController ()<UIGestureRecognizerDelegate>
{
    BOOL navigationHidden;
}
//界面控件
@property (nonatomic,strong) UIView *backView;
@property (nonatomic,strong) UIButton *flashButton;
@property (nonatomic,strong) UIView *lightView;
@property (nonatomic,strong) UIButton *cancelButton;
@property (nonatomic,strong) UIButton *cameraButton;
@property (nonatomic,strong) UIButton *reversalButton;
//AVFoundation

@property (nonatomic) dispatch_queue_t sessionQueue;
/**
 *  AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
 */
@property (nonatomic, strong) AVCaptureSession* session;
/**
 *  输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
/**
 *  照片输出流
 */
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;
/**
 *  预览图层
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;

/**
 *  记录开始的缩放比例
 */
@property(nonatomic,assign)CGFloat beginGestureScale;
/**
 *  最后的缩放比例
 */
@property(nonatomic,assign)CGFloat effectiveScale;
@end

@implementation RACustomCameraController

#pragma mark life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.effectiveScale = self.beginGestureScale = 1.0f;
    [self.view addSubview:self.flashButton];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.cameraButton];
    [self.view addSubview:self.reversalButton];
    [self initAVCaptureSession];
    [self setUpGesture];
}

- (void)viewWillAppear:(BOOL)animated{
    navigationHidden = self.navigationController.navigationBarHidden;
    self.navigationController.navigationBarHidden = YES;
    if (self.session) {
        [self.session startRunning];
    }
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}
- (void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBarHidden = navigationHidden;
    if (self.session) {
        [self.session stopRunning];
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark private method
- (void)initAVCaptureSession{
    self.session = [[AVCaptureSession alloc] init];
    NSError *error;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
    [device lockForConfiguration:nil];
    //设置闪光灯为自动
    [device setFlashMode:AVCaptureFlashModeAuto];
    [device unlockForConfiguration];
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    //输出设置。AVVideoCodecJPEG   输出jpeg格式图片
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    
    //初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    NSLog(@"%f",ScreenWidth);
    self.previewLayer.frame = self.backView.bounds;
    self.backView.layer.masksToBounds = YES;
    [self.backView.layer addSublayer:self.previewLayer];
    
}

- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}

#pragma 创建手势
- (void)setUpGesture{
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinch.delegate = self;
    [self.backView addGestureRecognizer:pinch];
}

#pragma mark gestureRecognizer delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        self.beginGestureScale = self.effectiveScale;
    }
    return YES;
}
//缩放手势 用于调整焦距
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer{
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.backView];
        CGPoint convertedLocation = [self.previewLayer convertPoint:location fromLayer:self.previewLayer.superlayer];
        if (![self.previewLayer containsPoint:convertedLocation]) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if (allTouchesAreOnThePreviewLayer ) {
        self.effectiveScale = self.beginGestureScale * recognizer.scale;
        if (self.effectiveScale < 1.0){
            self.effectiveScale = 1.0;
        }
        NSLog(@"%f-------------->%f------------recognizerScale%f",self.effectiveScale,self.beginGestureScale,recognizer.scale);
        
        CGFloat maxScaleAndCropFactor = [[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
        
        NSLog(@"%f",maxScaleAndCropFactor);
        if (self.effectiveScale > maxScaleAndCropFactor)
            self.effectiveScale = maxScaleAndCropFactor;
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
        [CATransaction commit];
        
    }
    
}
#pragma 按钮响应事件
- (void)takePhotoButtonClick:(UIButton *)sender {
    NSLog(@"takephotoClick...");
    AVCaptureConnection *stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
    [stillImageConnection setVideoOrientation:avcaptureOrientation];
    [stillImageConnection setVideoScaleAndCropFactor:self.effectiveScale];
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:jpegData];
        IFCAPickImageTool *tool = [IFCAPickImageTool sharePickImageTool];
        id delegate = tool.delegate;
        if (tool.imageEdit) {
            EditViewController *editVC = [EditViewController new];
            editVC.editImage = image;
            editVC.backImage = ^(UIImage *image) {
                PHAsset *asset = [self saveImage:image];
                if ([delegate respondsToSelector:@selector(selectedImageWithResult:)]) {
                    [delegate selectedImageWithResult:@[asset]];
                }
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            };
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editVC];
            [self presentViewController:nav animated:YES completion:nil];
        }else{
            PHAsset *asset = [self saveImage:image];
            if ([delegate respondsToSelector:@selector(selectedImageWithResult:)]) {
                [delegate selectedImageWithResult:@[asset]];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}
- (void)flashButtonClick:(UIButton *)sender {
    [UIView animateWithDuration:0.25 animations:^{
        self.lightView.alpha = self.lightView.alpha ? 0 : 1;
    }];
}
-(void)changeFlashlightModeAction:(UIButton *)sender{
    [UIView animateWithDuration:0.25 animations:^{
        self.lightView.alpha = 0;
    }];
    NSInteger tag = sender.tag-10000;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //修改前必须先锁定
    [device lockForConfiguration:nil];
    //必须判定是否有闪光灯，否则如果没有闪光灯会崩溃
    if ([device hasFlash]) {
        NSArray *imageName = @[@"flashlight_off",@"flashlight_on",@"flashlight_auto"];
        device.flashMode = tag;
        [self.flashButton setImage:[UIImage imageNamed:imageName[tag]] forState:0];
    } else {
        NSLog(@"设备不支持闪光灯");
    }
    [device unlockForConfiguration];
}
-(void)cancelButtonAction:(UIButton *)sender{
    UIViewController *vc = [self.navigationController popViewControllerAnimated:YES];
    if (vc == nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
-(void)reversalButtonAction:(UIButton *)sender{
    AVCaptureDevicePosition desiredPosition;
    if (sender.selected){
        desiredPosition = AVCaptureDevicePositionBack;
    }else{
        desiredPosition = AVCaptureDevicePositionFront;
    }
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([d position] == desiredPosition) {
            [self.previewLayer.session beginConfiguration];
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
            for (AVCaptureInput *oldInput in self.previewLayer.session.inputs) {
                [[self.previewLayer session] removeInput:oldInput];
            }
            [self.previewLayer.session addInput:input];
            [self.previewLayer.session commitConfiguration];
            break;
        }
    }
    sender.selected = !sender.selected;
}

#pragma mark 懒加载视图
-(UIView *)backView{
    if (_backView == nil) {
        _backView = [UIView new];
        _backView.frame = CGRectMake(0, 44,ScreenWidth, ScreenHeight-44-84);
        [self.view addSubview:_backView];
    }
    return _backView;
}

-(UIButton *)flashButton{
    if (_flashButton == nil) {
        _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _flashButton.frame = CGRectMake(20, 12, 20, 20);
        [_flashButton setImage:[UIImage imageNamed:@"flashlight_auto"] forState:0];
        [_flashButton addTarget:self action:@selector(flashButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashButton;
}
-(UIView *)lightView{
    if (_lightView == nil) {
        _lightView = [UIView new];
        _lightView.frame = CGRectMake(80, 8, ScreenWidth-80, 30);
        NSArray *names = @[@"关闭",@"打开",@"自动"];
        for (int i = 0; i < names.count; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(30*(i+1)+60*i, 0, 60, 30);
            [button setTitleColor:[UIColor whiteColor] forState:0];
            [button setTitle:names[i] forState:0];
            button.titleLabel.font = [UIFont systemFontOfSize:16.0];
            [button addTarget:self action:@selector(changeFlashlightModeAction:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = i+10000;
            [_lightView addSubview:button];
        }
        _lightView.alpha = 0;
        [self.view addSubview:_lightView];
    }
    return _lightView;
}
-(UIButton *)cancelButton{
    if (_cancelButton == nil) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelButton setTitle:@"取消" forState:0];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:0];
        _cancelButton.frame = CGRectMake(20, ScreenHeight-57, 60, 30);
        [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}
-(UIButton *)cameraButton{
    if (_cameraButton == nil) {
        _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cameraButton.frame = CGRectMake(ScreenWidth/2-32, ScreenHeight-74, 64, 64);
        [_cameraButton setImage:[UIImage imageNamed:@"round"] forState:0];
        [self.cameraButton addTarget:self action:@selector(takePhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraButton;
}
-(UIButton *)reversalButton{
    if (_reversalButton == nil) {
        _reversalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _reversalButton.frame = CGRectMake(ScreenWidth-44-20, ScreenHeight-57, 36, 30);
        [_reversalButton setImage:[UIImage imageNamed:@"reversal"] forState:0];
        [_reversalButton addTarget:self action:@selector(reversalButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reversalButton;
}

- (PHAsset *)saveImage:(UIImage *)image{
    NSError *error;
    __block NSString *localIdentifier;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //        PHAsset *asset = self.dataSource[self.page];
        // 插件一个新的相册请求
        PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        request.creationDate = [NSDate date];
        localIdentifier = request.placeholderForCreatedAsset.localIdentifier;
        // 从请求中获取PHAsset
    } error:&error];
    if (error != nil) {
        NSLog(@"图片存储发生了错误 error = %@",error);
        return nil;
    }
    PHAsset *newAsset = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil].firstObject;
    return newAsset;
}

@end

