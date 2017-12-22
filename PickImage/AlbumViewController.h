//
//  AlbumViewController.h
//  PickImage
//
//  Created by vito7zhang on 2017/11/22.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@protocol AlbumProtocol<NSObject>
-(void)selectedImageWithAssetArray:(NSArray<PHAsset *> *)assets;
@end

@interface AlbumViewController : UIViewController
// 最大选择图片张数，默认9。为0时候可以选择无限。
@property (nonatomic,assign)NSUInteger maxCount;

@property (nonatomic,weak)id <AlbumProtocol> delegate;
@end
