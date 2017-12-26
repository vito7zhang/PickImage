//
//  IFCAPickImageTool.m
//  PickImage
//
//  Created by vito7zhang on 2017/11/22.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import "IFCAPickImageTool.h"
#import "AlbumViewController.h"
#import "RACustomCameraController.h"
#import <Photos/Photos.h>

@interface IFCAPickImageTool ()
@property (nonatomic,strong)UIAlertController *alertController;
@property (nonatomic,weak)UIViewController *vc;
@end

static IFCAPickImageTool *_tool = nil;

@implementation IFCAPickImageTool
+(instancetype)sharePickImageTool{
    return [[self alloc] init];
}
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tool = [super allocWithZone:zone];
        [_tool defaultConfiguration];
    });
    return _tool;
}
- (instancetype)init{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tool = [super init];
        [_tool defaultConfiguration];
    });
    return _tool;
}

-(void)defaultConfiguration{
    _tool.imageEdit = YES;
    _tool.maxCount = 9;
    _tool.waterMark = YES;
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    _tool.waterMarkText = [formatter stringFromDate:[NSDate date]];
}
-(void)showInViewController:(UIViewController *)vc{
    _vc = vc;
    [vc presentViewController:self.alertController animated:YES completion:nil];
}

-(UIAlertController *)alertController{
    if (_alertController == nil) {
        _alertController = [UIAlertController alertControllerWithTitle:@"提醒" message:@"请选择照片位置" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            RACustomCameraController *cVC = [RACustomCameraController new];
            [_vc presentViewController:cVC animated:YES completion:nil];
        }];
        UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (status == PHAuthorizationStatusAuthorized) {
                            AlbumViewController *albumVC = [AlbumViewController new];
                            albumVC.maxCount = 9;
    //                        albumVC.delegate = self;
                            [_vc.navigationController pushViewController:albumVC animated:YES];
                        }else if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized){
                            [self showAlertToOpenauthorizationStatus];
                        }
                    });
                }];
            }else if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized){
                [self showAlertToOpenauthorizationStatus];
            }else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized){
                AlbumViewController *albumVC = [AlbumViewController new];
                albumVC.maxCount = 9;
//                albumVC.delegate = self;
                [_vc.navigationController pushViewController:albumVC animated:YES];
            }
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [_alertController addAction:cameraAction];
        [_alertController addAction:albumAction];
        [_alertController addAction:cancelAction];
    }
    return _alertController;
}

-(void)showAlertToOpenauthorizationStatus{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提醒" message:@"请在iPhone的'设置-隐私-照片'选项中,允许访问你的相册" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:cancel];
    [_vc presentViewController:controller animated:YES completion:nil];
    return ;

}

@end
