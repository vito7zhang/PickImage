//
//  ColorView.h
//  PickImage
//
//  Created by vito7zhang on 2017/11/28.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SelectedColor) {
    blackColor = 0,
    whiteColor,
    redColor,
    orangeColor,
    greenColor,
    blueColor,
    purpleColor,
    cyanColor
};

@interface ColorView : UIView
@property (nonatomic,assign)UIColor *selectedColor;

@end
