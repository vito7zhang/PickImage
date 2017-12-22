//
//  CameraViewController.m
//  PickImage
//
//  Created by vito7zhang on 2017/11/21.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface CameraViewController ()
// 设置设备的参数
@property (nonatomic,strong)AVCaptureDevice *device;
// 提供设备的数据
@property (nonatomic,strong)AVCaptureDeviceInput *deviceInput;
// 输出，抽象类
@property (nonatomic,strong)AVCaptureOutput *output;
// 管理输入输出的流，以及出现问题时生成的运行时错误
@property (nonatomic,strong)AVCaptureSession *session;
// 相机生成出来的实时图像
@property (nonatomic,strong)AVCaptureVideoPreviewLayer *layer;
@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSArray *devices = [AVCaptureDeviceDiscoverySession devicesWithMediaType:<#(nonnull AVMediaType)#>]
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
