//
//  PreviewViewController.m
//  PickImage
//
//  Created by vito7zhang on 2017/11/23.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import "PreviewViewController.h"
#import <Photos/Photos.h>
#import "IFCAImageTextButton.h"
#import "CountLabel.h"
#import "PreviewCollectionViewCell.h"
#import "EditViewController.h"

#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height
#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavBarHeight 44.0
#define kTabBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?83:49)
#define kTopHeight (kStatusBarHeight + kNavBarHeight)
#define ScrollViewHeight Screen_Height

@interface PreviewViewController ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
// 预览滚动视图，加上两个imageview实现预览功能，nowimage代表当前图片
@property (nonatomic,strong)UIScrollView *mainScrollView;
@property (nonatomic,strong)UIImageView *nowImageView;
@property (nonatomic,strong)UIImageView *nextImageView;
@property (nonatomic,strong)UIImage *nowImage;
// 下面的预览小图
@property (nonatomic,strong)UICollectionView *previewCollectionView;
@property (nonatomic,strong)NSMutableArray *previewDataSource;;
// 头部显示
@property (nonatomic,strong)CountLabel *countLabel;
// 直接选中图片按钮，直接退出选取图片
@property (nonatomic,strong)UIButton *sendButton;
// 下面toolbar的按钮
@property (nonatomic,strong)IFCAImageTextButton *selectButton;
@property (nonatomic,strong)UIButton *editButton;
// 当前查看图片的资源
@property (nonatomic,strong)PHAsset *set;
@property (nonatomic,strong)PHImageRequestOptions *options;
@end

@implementation PreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.toolbarHidden = NO;
    self.set = self.dataSource[self.page];
    
    [self.view addSubview:self.mainScrollView];
    [self.view addSubview:self.previewCollectionView];
    
    [self setNavigationTabbarAndToolBar];
    
    self.previewDataSource = [NSMutableArray array];
    __block NSUInteger count = 0;
    [self.selectedArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj boolValue]) {
            [self.previewDataSource addObject:@(idx)];
            count++;
        }
    }];
    [self.countLabel setCount:count];
    _previewCollectionView.hidden = !self.previewDataSource.count;
}

-(void)setNavigationTabbarAndToolBar{
    // 返回上一层
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonAction:)];
    
    // 设置右上角选取按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选取" style:UIBarButtonItemStyleDone target:self action:@selector(pickBarButtonItemAction:)];
    
    // 设置ToolBar按钮
    UIBarButtonItem *editBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(editButtonAction:)];
    UIView *vesselView = [UIView new];
    vesselView.frame = CGRectMake(0, 0, 80, 30);
    [vesselView addSubview:self.selectButton];
    UIBarButtonItem *selectBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:vesselView];
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self setToolbarItems:@[editBarButtonItem,flexItem,selectBarButtonItem]];
    
    self.navigationItem.titleView = self.countLabel;
    
    //点击显示隐藏导航栏
    [self.mainScrollView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(scrollViewTapAction:)]];

}

-(UIScrollView *)mainScrollView{
    if (_mainScrollView == nil) {
        _mainScrollView = [UIScrollView new];
        _mainScrollView.frame = CGRectMake(0, 0, Screen_Width, ScrollViewHeight);
        _mainScrollView.delegate = self;
        _mainScrollView.contentSize = CGSizeMake(3*Screen_Width, 0);
        _mainScrollView.contentOffset = CGPointMake(Screen_Width, 0);
        _mainScrollView.backgroundColor = [UIColor blackColor];
        _mainScrollView.pagingEnabled = YES;
        _mainScrollView.showsVerticalScrollIndicator = NO;
        _mainScrollView.showsHorizontalScrollIndicator = NO;
        _mainScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        [self.view addSubview:_mainScrollView];
        [_mainScrollView addSubview:self.nowImageView];
        [_mainScrollView addSubview:self.nextImageView];
    }
    return _mainScrollView;
}

-(UICollectionView *)previewCollectionView{
    if (_previewCollectionView == nil) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout = [UICollectionViewFlowLayout new];
        layout.sectionInset = UIEdgeInsetsMake(15, 10, 15, 10);
        //同一行相邻两个cell的最小间距
        layout.minimumInteritemSpacing = 10;
        //最小两行之间的间距
        layout.minimumLineSpacing = 10;
        layout.itemSize = CGSizeMake(70, 70);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _previewCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, Screen_Height-kNavBarHeight-100, Screen_Width, 100) collectionViewLayout:layout];
        _previewCollectionView.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
        _previewCollectionView.delegate = self;
        _previewCollectionView.dataSource = self;
        [_previewCollectionView registerNib:[UINib nibWithNibName:@"PreviewCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"PreviewViewControllerCollectionCell"];
    }
    return _previewCollectionView;
}
-(CountLabel *)countLabel{
    if (_countLabel == nil) {
        _countLabel = [CountLabel labelWithMaxCount:self.maxCount];
    }
    return _countLabel;
}
-(UIImageView *)nowImageView{
    if (_nowImageView == nil) {
        _nowImageView = [UIImageView new];
        _nowImageView.frame = CGRectMake(Screen_Width, 0, Screen_Width, ScrollViewHeight);
        _nowImageView.backgroundColor = [UIColor blackColor];
        _nowImageView.userInteractionEnabled = YES;
        _nowImageView.contentMode = UIViewContentModeScaleAspectFit;
        // 先对当前第一张imageview设置一下
        PHImageManager *imageManager = [PHImageManager defaultManager];
        [imageManager requestImageForAsset:self.set targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:self.options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            _nowImageView.image = result;
            _nowImage = result;
        }];
    }
    return _nowImageView;
}

-(UIImageView *)nextImageView{
    if (_nextImageView == nil) {
        _nextImageView = [UIImageView new];
        _nextImageView.frame = CGRectMake(-CGFLOAT_MAX, 0, Screen_Width, ScrollViewHeight);
        _nextImageView.backgroundColor = [UIColor blackColor];
        _nextImageView.userInteractionEnabled = YES;
        _nextImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _nextImageView;
}

-(PHImageRequestOptions *)options{
    if (_options == nil) {
        _options = [[PHImageRequestOptions alloc] init];
        _options.synchronous = YES;
        _options.resizeMode = PHImageRequestOptionsResizeModeFast;
        _options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    }
    return _options;
}

-(IFCAImageTextButton *)selectButton{
    if (_selectButton == nil) {
        _selectButton = [IFCAImageTextButton new];
        [_selectButton setTitle:@"选择" forState:0];
        [_selectButton setTitleColor:[UIColor blueColor] forState:0];
        [_selectButton setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
        _selectButton.frame = CGRectMake(0, 2, 80, 26);
        [_selectButton setImageLocation:IFCAImageLocationLeft spacing:5];
        [_selectButton addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        // 当前图片是否为选中状态
        _selectButton.selected = [self.selectedArray[self.page] boolValue];
    }
    return _selectButton;
}

#pragma mark 按钮绑定事件
-(void)scrollViewTapAction:(UITapGestureRecognizer *)tap{
    [UIView animateWithDuration:0.25 animations:^{
        self.navigationController.navigationBarHidden = !self.navigationController.navigationBarHidden;
        self.navigationController.toolbarHidden = self.navigationController.navigationBarHidden;
        if ([self.selectedArray containsObject:@(1)]) {
            self.previewCollectionView.hidden = self.navigationController.navigationBarHidden;
        }
    }];
}

-(void)editButtonAction:(UIBarButtonItem *)sender{
    EditViewController *editVC = [EditViewController new];
    editVC.editImage = self.nowImage;
    editVC.backImage = ^(UIImage *image) {
        [self saveImage:image];
        self.nowImageView.image = image;
    };
    [self.navigationController pushViewController:editVC animated:YES];
}
-(void)selectButtonAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    NSInteger selected = sender.selected;
    self.selectedArray[self.page] = @(selected);
    if ([self.previewDataSource containsObject:@(self.page)]) {
        [self.previewDataSource removeObject:@(self.page)];
    }else{
        [self.previewDataSource addObject:@(self.page)];
    }
    _previewCollectionView.hidden = !self.previewDataSource.count;
    [self.previewCollectionView reloadData];
    if (sender.selected) {
        [_countLabel increase];
    }else{
        [_countLabel decrease];
    }
}
-(void)pickBarButtonItemAction:(UIBarButtonItem *)sender{
    UIViewController *vc = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-3];
//    if ([self.albumDelegate respondsToSelector:@selector(selectedImageWithAssetArray:)]) {
//        NSMutableArray *result = [NSMutableArray array];
//        [self.selectedArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([obj boolValue]) {
//                [result addObject:[self.dataSource objectAtIndex:idx]];
//            }
//        }];
//        [self.delegate performSelector:@selector(selectedImageWithAssetArray:) withObject:result];
//    }
    [self.navigationController popToViewController:vc animated:YES];
}
-(void)backButtonAction:(UIBarButtonItem *)sender{
    if ([self.delegate respondsToSelector:@selector(selectedImage)]) {
        [self.delegate selectedImage];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView != _mainScrollView) {
        return;
    }
    // 当滑动到第一(或最后)屏，且当前为第一(或最后)张图片的时候，将nextImageView暂时隐藏防止用户手贱一直滑看到
    if((self.page == 0 && scrollView.contentOffset.x < Screen_Width/2) || (self.page == self.dataSource.count-1 && scrollView.contentOffset.x > Screen_Width*1.5)){
        if (!(_nextImageView.frame.origin.x != CGFLOAT_MAX)) {
            _nextImageView.frame = CGRectMake(CGFLOAT_MAX, 0, Screen_Width, ScrollViewHeight);
        }
        return;
    }
    // 当用户往左滑或往右滑的时候呈现下一张图片
    if (scrollView.contentOffset.x > Screen_Width) {  // 往左滑
        if (self.page >= self.dataSource.count-1) {
        }else{
            if (self.nextImageView.frame.origin.x != Screen_Width*2) {
                self.nextImageView.frame = CGRectMake(Screen_Width*2, 0, Screen_Width, ScrollViewHeight);
                self.set = self.dataSource[self.page+1];
                PHImageManager *imageManager = [PHImageManager defaultManager];
                [imageManager requestImageForAsset:self.set targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:self.options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    self.nextImageView.image = result;
                }];
            }
        }
    }else if (scrollView.contentOffset.x < Screen_Width) {  // 往右滑
        if (self.page <= 0) {
        }else{
            if (self.nextImageView.frame.origin.x != 0) {
                self.nextImageView.frame = CGRectMake(0, 0, Screen_Width, ScrollViewHeight);
                self.set = self.dataSource[self.page-1];
                PHImageManager *imageManager = [PHImageManager defaultManager];
                [imageManager requestImageForAsset:self.set targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:self.options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    self.nextImageView.image = result;
                }];
            }
        }
    }
    
    if (scrollView.contentOffset.x == Screen_Width && _nextImageView.frame.origin.x != CGFLOAT_MAX) {
        _nextImageView.frame = CGRectMake(CGFLOAT_MAX, 0, Screen_Width, ScrollViewHeight);
        return;
    }
    // 滑动结束
    if (scrollView.contentOffset.x <= 0) {
        if (_nextImageView.frame.origin.x != CGFLOAT_MAX) {
            self.page--;
            _nextImageView.frame = CGRectMake(CGFLOAT_MAX, 0, Screen_Width, ScrollViewHeight);
            scrollView.contentOffset = CGPointMake(Screen_Width, 0);
            _nowImageView.image = _nextImageView.image;
            self.nowImage = _nextImageView.image;
            return;
        }
    }
    if (scrollView.contentOffset.x >= Screen_Width*2) {
        if (_nextImageView.frame.origin.x != CGFLOAT_MAX) {
            self.page++;
            _nextImageView.frame = CGRectMake(CGFLOAT_MAX, 0, Screen_Width, ScrollViewHeight);
            scrollView.contentOffset = CGPointMake(Screen_Width, 0);
            _nowImageView.image = _nextImageView.image;
            self.nowImage = _nextImageView.image;
            return;
        }
    }
}

// 减速完毕，可以认为是停止滑动的时候
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView != _mainScrollView) {
        return;
    }
    [scrollView setContentOffset:CGPointMake(Screen_Width, 0) animated:YES];
    self.selectButton.selected = [self.selectedArray[self.page] boolValue];
    [_previewCollectionView reloadData];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PreviewCollectionViewCell *cell = (PreviewCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PreviewViewControllerCollectionCell" forIndexPath:indexPath];
    self.set = self.dataSource[[self.previewDataSource[indexPath.row] integerValue]];
    PHImageManager *imageManager = [PHImageManager defaultManager];
    [imageManager requestImageForAsset:self.set targetSize:CGSizeMake(70, 70) contentMode:PHImageContentModeAspectFit options:self.options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        cell.backgroundImageView.image = result;
    }];
    if (self.page == [self.previewDataSource[indexPath.row] integerValue]) {
        cell.layer.borderWidth = 2.0;
    }else{
        cell.layer.borderWidth = 0;
    }
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.previewDataSource.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.page = [self.previewDataSource[indexPath.row] integerValue];
    self.set = self.dataSource[self.page];
    PHImageManager *imageManager = [PHImageManager defaultManager];
    [imageManager requestImageForAsset:self.set targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:self.options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        self.nowImage = result;
        self.nowImageView.image = result;
    }];
    [collectionView reloadData];
}

- (void)saveImage:(UIImage *)image{
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
        return;
    }
    PHAsset *newAsset = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil].firstObject;
    self.dataSource[self.page] = newAsset;
}

@end
