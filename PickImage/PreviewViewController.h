//
//  PreviewViewController.h
//  PickImage
//
//  Created by vito7zhang on 2017/11/23.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumViewController.h"

@protocol PreviewViewControlleProtocol<NSObject>
-(void)selectedImage;
@end

@interface PreviewViewController : UIViewController
@property (nonatomic,strong)NSMutableArray *selectedArray;
// 当前是第几张
@property (nonatomic,assign)NSUInteger page;
// 最多选择几张
@property (nonatomic,assign)NSUInteger maxCount;
// 所有图片数据
@property (nonatomic,copy)NSArray *dataSource;

@property (nonatomic,weak)id <PreviewViewControlleProtocol> delegate;
@property (nonatomic,weak)id <AlbumProtocol> albumDelegate;

@end
