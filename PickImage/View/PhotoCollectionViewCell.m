//
//  PhotoCollectionViewCell.m
//  PickImage
//
//  Created by vito7zhang on 2017/11/22.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import "PhotoCollectionViewCell.h"
@interface PhotoCollectionViewCell()
@property (nonatomic,strong)CALayer *maskLayer;
@end

@implementation PhotoCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.selectedButton setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
    [self.selectedButton setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
    [self.selectedButton addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
    _maskLayer = [CALayer new];
    _maskLayer.bounds = self.frame;
    _maskLayer.hidden = YES;
    _maskLayer.backgroundColor = [UIColor colorWithRed:0.667 green:0.667 blue:0.667 alpha:0.5].CGColor;
    [self.layer addSublayer:_maskLayer];
}
/*2.实现回调方法*/
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"selected"]) {
        NSLog(@"Name is changed! new = %@",[change valueForKey:NSKeyValueChangeNewKey]);
        BOOL selected = [[change valueForKey:NSKeyValueChangeNewKey] boolValue];
        _maskLayer.hidden = !selected;
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
-(void)setBounds:(CGRect)bounds{
    [super setBounds:bounds];
    _maskLayer.frame = bounds;
}
-(void)dealloc{
    [self.selectedButton removeObserver:self forKeyPath:@"selected" context:nil];
}
@end
