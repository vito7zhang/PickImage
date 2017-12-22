//
//  CountLabel.h
//  PickImage
//
//  Created by vito7zhang on 2017/11/23.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountLabel : UILabel
+(instancetype)labelWithMaxCount:(NSUInteger)maxCount;
-(void)setCount:(NSUInteger)count;
// 增加
-(BOOL)increase;
// 减少
-(BOOL)decrease;
@end
