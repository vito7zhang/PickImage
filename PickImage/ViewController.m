//
//  ViewController.m
//  PickImage
//
//  Created by vito7zhang on 2017/11/21.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import "ViewController.h"
#import "IFCAPickImageTool.h"
#import "testCollectionViewCell.h"

@interface ViewController ()<PickImageDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,strong)NSArray *dataSource;
@property (nonatomic,strong)UICollectionView *collection;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"vc = %p",self);

    UIButton *showActionSheetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [showActionSheetButton setTitle:@"选择照片" forState:0];
    showActionSheetButton.frame = CGRectMake(40, 88, 80, 30);
    [showActionSheetButton addTarget:self action:@selector(showActionSheetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showActionSheetButton];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(100, 100);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    _collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 118, self.view.frame.size.width, self.view.frame.size.height-118) collectionViewLayout:layout];
    _collection.delegate = self;
    _collection.dataSource = self;
    _collection.backgroundColor = [UIColor whiteColor];
    [_collection registerNib:[UINib nibWithNibName:@"testCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"reuse"];
    [self.view addSubview:_collection];
    
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    testCollectionViewCell *cell = (testCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"reuse" forIndexPath:indexPath];
    [[PHImageManager defaultManager] requestImageForAsset:self.dataSource[indexPath.row] targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage *resultImage, NSDictionary *info) {
        cell.backImageView.image = resultImage;
    }];
    return cell;
}
-(void)showActionSheetButtonAction:(UIButton *)sender{
    IFCAPickImageTool *tool = [IFCAPickImageTool new];
    tool.delegate = self;
//    tool.imageEdit = NO;
    [tool showInViewController:self];
}
-(void)selectedImageWithResult:(NSArray<PHAsset *> *)result{
    NSLog(@"result = %@",result);
    NSLog(@"result = %@",result);
    self.dataSource = result;
    [self.collection reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
