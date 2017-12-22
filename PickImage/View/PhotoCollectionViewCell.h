//
//  PhotoCollectionViewCell.h
//  PickImage
//
//  Created by vito7zhang on 2017/11/22.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *selectedButton;

@end
