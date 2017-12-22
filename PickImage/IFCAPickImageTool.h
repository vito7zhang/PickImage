//
//  IFCAPickImageTool.h
//  PickImage
//
//  Created by vito7zhang on 2017/11/22.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumViewController.h"

@interface IFCAPickImageTool : NSObject
// 选择最大图片数目
@property (nonatomic,assign)NSUInteger maxCount;
// 是否允许编辑
@property (nonatomic, assign) BOOL imageEdit;
// 是否有水印
@property (nonatomic, assign) BOOL waterMark;
// 自定义水印文字
@property (nonatomic, copy) NSString *waterMarkText;

-(void)showInViewController:(UIViewController *)vc;
@end
