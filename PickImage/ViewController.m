//
//  ViewController.m
//  PickImage
//
//  Created by vito7zhang on 2017/11/21.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import "ViewController.h"
#import "IFCAPickImageTool.h"

@interface ViewController ()<AlbumProtocol>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *showActionSheetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [showActionSheetButton setTitle:@"选择照片" forState:0];
    showActionSheetButton.frame = CGRectMake(40, 88, 80, 30);
    [showActionSheetButton addTarget:self action:@selector(showActionSheetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showActionSheetButton];
    
}

-(void)showActionSheetButtonAction:(UIButton *)sender{
    IFCAPickImageTool *tool = [IFCAPickImageTool new];
    [tool showInViewController:self];
}

-(void)selectedImageWithAssetArray:(NSArray<PHAsset *> *)assets{
    NSLog(@"我选取了这些照片：%@",assets);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
