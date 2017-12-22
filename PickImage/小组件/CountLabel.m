//
//  CountLabel.m
//  PickImage
//
//  Created by vito7zhang on 2017/11/23.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import "CountLabel.h"

@interface CountLabel()
@property (nonatomic,assign)NSUInteger maxCount;
@property (nonatomic,assign)NSUInteger count;
@end

@implementation CountLabel

+(instancetype)labelWithMaxCount:(NSUInteger)maxCount{
    CountLabel *label = [[CountLabel alloc] init];
    label.text = [NSString stringWithFormat:@"0/%ld",maxCount];
    label.maxCount = maxCount;
    label.count = 0;
    label.font = [UIFont systemFontOfSize:18.0];
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment = NSTextAlignmentCenter;
    [label setTextColor:[UIColor blackColor]];
    return label;
}

-(BOOL)decrease{
    if (self.maxCount == 0) {
        return YES;
    }
    if (self.count > 0) {
        self.count -= 1;
        self.text = [NSString stringWithFormat:@"%ld/%ld",self.count,self.maxCount];
        return YES;
    }
    return NO;
}

-(BOOL)increase{
    if (self.maxCount == 0) {
        return YES;
    }
    if (self.count < self.maxCount) {
        self.count += 1;
        self.text = [NSString stringWithFormat:@"%ld/%ld",self.count,self.maxCount];
        return YES;
    }
    return NO;
}
-(void)setCount:(NSUInteger)count{
    if (count > _maxCount) {
        return;
    }
    _count = count;
    self.text = [NSString stringWithFormat:@"%ld/%ld",_count,self.maxCount];
}
@end
