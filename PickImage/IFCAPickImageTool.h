//
//  IFCAPickImageTool.h
//  PickImage
//
//  Created by vito7zhang on 2017/11/22.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumViewController.h"

@protocol PickImageDelegate
-(void)selectedImageWithResult:(NSArray <PHAsset *>*)result;
@end

@interface IFCAPickImageTool : NSObject

+(instancetype)sharePickImageTool;
// 选择最大图片数目
@property (nonatomic,assign) NSUInteger maxCount;
// 是否允许编辑
@property (nonatomic, assign) BOOL imageEdit;

@property (nonatomic,weak) id <PickImageDelegate>delegate;

-(void)showInViewController:(UIViewController *)showVC;


@end
