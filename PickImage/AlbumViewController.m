//
//  AlbumViewController.m
//  PickImage
//
//  Created by vito7zhang on 2017/11/22.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import "AlbumViewController.h"
#import "CountLabel.h"
#import "PreviewViewController.h"
#import "PhotoCollectionViewCell.h"
#import "PHCachingImageManager+shareManager.h"

#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height

@interface AlbumViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,PreviewViewControlleProtocol>
@property (nonatomic,strong)NSMutableArray *selectedArray;
@property (nonatomic,strong)PHFetchResult *result;
@property (nonatomic,strong)UICollectionView *photoCollectionView;
@property (nonatomic,strong)UIAlertController *alertController;
@property (nonatomic,strong)UICollectionViewFlowLayout *layout;

// 计数视图
@property (nonatomic,strong)CountLabel *countLabel;

@end

@implementation AlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11.0, *)){
        self.photoCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    }
    
    [self setTitleView];
//    [self authorization];
    [self cachingImage];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStyleDone target:self action:@selector(confirmBarButtonItemAction:)];
    [self.view addSubview:self.photoCollectionView];

    // 初始化选择数组
    self.selectedArray = [NSMutableArray arrayWithCapacity:self.result.count];
    [self.result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.selectedArray addObject:@0];
    }];
}

-(void)setTitleView{
    if (self.maxCount <= 1) {
        self.title = @"相册";
    }else{
        self.navigationItem.titleView = self.countLabel;
    }
}

// 对图片做缓存
-(void)cachingImage{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    PHCachingImageManager *cache = [PHCachingImageManager defaultManager];
    cache.allowsCachingHighQualityImages = YES;
    [cache startCachingImagesForAssets:[self.result objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.result.count)]] targetSize:CGSizeMake(200, 200) contentMode:PHImageContentModeAspectFit options:options];
}


-(PHFetchResult *)result{
    if (_result == nil) {
        PHFetchOptions*options = [[PHFetchOptions alloc]init];
        options.sortDescriptors=@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate"ascending:NO]];
        self.result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
        
    }
    return _result;
}

-(UICollectionViewFlowLayout *)layout{
    if (_layout == nil) {
        _layout = [UICollectionViewFlowLayout new];
        //同一行相邻两个cell的最小间距
        _layout.minimumInteritemSpacing = 2;
        //最小两行之间的间距
        _layout.minimumLineSpacing = 2;
        _layout.itemSize = CGSizeMake((Screen_Width-9)/4, (Screen_Width-9)/4);
    }
    return _layout;
}
-(UICollectionView *)photoCollectionView{
    if (_photoCollectionView == nil) {
        _photoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height) collectionViewLayout:self.layout];
        _photoCollectionView.backgroundColor = [UIColor whiteColor];
        _photoCollectionView.delegate = self;
        _photoCollectionView.dataSource = self;
        UINib *cellNib=[UINib nibWithNibName:@"PhotoCollectionViewCell" bundle:nil];
        [_photoCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"PhotoCollectionViewCell"];
    }
    return _photoCollectionView;
}

-(UIAlertController *)alertController{
    if (_alertController == nil) {
        _alertController = [UIAlertController alertControllerWithTitle:@"提醒" message:@"请重新进入页面，授权应用请求图片，否则无法选择图片" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (self.navigationController != nil) {
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        [_alertController addAction:cancelAction];
    }
    return _alertController;
}

-(CountLabel *)countLabel{
    if (_countLabel == nil) {
        _countLabel = [CountLabel labelWithMaxCount:self.maxCount];
        _countLabel.frame = CGRectMake(0, 0, 100, 30);
    }
    return _countLabel;
}

#pragma mark UICollectionDelegate
//一共有多少个组
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
//每一组有多少个cell
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.result.count;
}
//每一个cell是什么
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCollectionViewCell" forIndexPath:indexPath];
    
    PHAsset *set = [self.result objectAtIndex:indexPath.row];
    PHImageManager *imageManager = [PHImageManager defaultManager];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    [imageManager requestImageForAsset:set targetSize:CGSizeMake(200, 200) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        cell.imageView.image = result;
    }];
    
    [cell.selectedButton addTarget:self action:@selector(selectedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectedButton.tag = 1000+indexPath.row;
    cell.backgroundColor=[UIColor groupTableViewBackgroundColor];
    return cell;
}
//cell的点击事件
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //cell被后移动的动画
    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
    
    PreviewViewController *previewVC = [PreviewViewController new];
    previewVC.delegate = self;
    previewVC.albumDelegate = self.delegate;
    previewVC.selectedArray = self.selectedArray;
    previewVC.page = indexPath.row;
    previewVC.maxCount = self.maxCount;
    previewVC.dataSource = [self.result objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.result.count)]];
    [self.navigationController pushViewController:previewVC animated:YES];
}

-(void)selectedImage{
    __block NSUInteger count = 0;
    [self.selectedArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[_photoCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
        NSLog(@"obj boolvalue = %d",[obj boolValue]);
        cell.selectedButton.selected = [obj boolValue];
        if ([obj boolValue]) {
            count += 1;
        }
    }];
    [self.countLabel setCount:count];
}

#pragma mark 绑定事件
-(void)selectedButtonAction:(UIButton *)sender{
    if (sender.selected && [self.countLabel decrease]) {
        sender.selected = NO;
        self.selectedArray[sender.tag-1000] = @0;
    }else if (!sender.selected && [self.countLabel increase]){
        sender.selected = YES;
        self.selectedArray[sender.tag-1000] = @1;
    }
}
-(void)confirmBarButtonItemAction:(UIBarButtonItem *)sender{
    if ([self.delegate respondsToSelector:@selector(selectedImageWithAssetArray:)]) {
        NSMutableArray *result = [NSMutableArray array];
        [self.selectedArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj boolValue]) {
                [result addObject:[self.result objectAtIndex:idx]];
            }
        }];
        [self.delegate selectedImageWithAssetArray:result];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

// 获取权限
-(void)authorization{
    PHAuthorizationStatus photoAuthStatus = [PHPhotoLibrary authorizationStatus];
    // 授权查询
    if (photoAuthStatus == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status != PHAuthorizationStatusAuthorized) {
                [self presentViewController:self.alertController animated:YES completion:nil];
            }
        }];
    }else if(photoAuthStatus == PHAuthorizationStatusRestricted || photoAuthStatus == PHAuthorizationStatusDenied) {
        // 未授权
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status != PHAuthorizationStatusAuthorized) {
                [self presentViewController:self.alertController animated:YES completion:nil];
            }
        }];
    }else{
        // 已授权
        [self.photoCollectionView reloadData];
    }
}

@end
