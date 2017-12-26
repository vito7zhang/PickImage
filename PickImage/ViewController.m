//
//  ViewController.m
//  PickImage
//
//  Created by vito7zhang on 2017/11/21.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import "ViewController.h"
#import "IFCAPickImageTool.h"

@interface ViewController ()<PickImageDelegate>

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
    tool.delegate = self;
//    tool.imageEdit = NO;
    [tool showInViewController:self];
}
-(void)selectedImageWithResult:(NSArray<PHAsset *> *)result{
    NSLog(@"result = %@",result);
    NSLog(@"result = %@",result);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
