//
//  PreviewCollectionViewCell.m
//  PickImage
//
//  Created by vito7zhang on 2017/11/27.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import "PreviewCollectionViewCell.h"

@implementation PreviewCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.layer.borderColor = [UIColor blueColor].CGColor;
}

@end
