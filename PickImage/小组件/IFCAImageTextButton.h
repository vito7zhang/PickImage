//
//  IFCAImageTextButton.h
//  PickImage
//
//  Created by vito7zhang on 2017/11/27.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, IFCAImageLocation) {
    IFCAImageLocationLeft = 0,          //图片在左，默认
    IFCAImageLocationRight,             //图片在右
    IFCAImageLocationTop,               //图片在上
    IFCAImageLocationBottom,            //图片在下
};

typedef NS_ENUM(NSInteger, IFCAOffSetDirection) {
    IFCAOffSetDirectionLeft = 0,   //左边偏移，默认
    IFCAOffSetDirectionRight,      //右边偏移
    IFCAOffSetDirectionTop,        //上边偏移
    IFCAOffSetDirectionBottom,     //下边偏移
};
@interface IFCAImageTextButton : UIButton

- (void)setImageLocation:(IFCAImageLocation)location spacing:(CGFloat)spacing;
- (void)setImageLocation:(IFCAImageLocation)location spacing:(CGFloat)spacing offSet:(IFCAOffSetDirection)offSetDirection offSetVar:(CGFloat)offSetVar;

@end
