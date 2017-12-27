//
//  testCollectionViewCell.m
//  PickImage
//
//  Created by vito7zhang on 2017/12/27.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import "testCollectionViewCell.h"

@implementation testCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backImageView.contentMode = UIViewContentModeScaleAspectFill;
}

@end
