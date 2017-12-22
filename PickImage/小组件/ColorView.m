//
//  ColorView.m
//  PickImage
//
//  Created by vito7zhang on 2017/11/28.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import "ColorView.h"

@implementation ColorView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUIInFrame:frame];
    }
    return self;
}
-(instancetype)init{
    if (self == [super init]) {
        [self setUIInFrame:CGRectZero];
    }
    return self;
}

-(void)setUIInFrame:(CGRect)frame{
    if (self.subviews.count != 0) {
        return;
    }
    NSArray *colors = @[[UIColor blackColor],[UIColor whiteColor],[UIColor redColor],[UIColor orangeColor],[UIColor greenColor],[UIColor blueColor],[UIColor purpleColor],[UIColor cyanColor]];
    CGFloat width = 26.0;
    CGFloat space = (frame.size.width-26*8)/9;
    for (int i = 0; i < colors.count; i++) {
        UIColor *color = colors[i];
        UIButton *colorButton = [UIButton buttonWithType:UIButtonTypeSystem];
        colorButton.backgroundColor = color;
        colorButton.layer.masksToBounds = YES;
        colorButton.layer.cornerRadius = 13.0;
        colorButton.layer.borderColor = [UIColor whiteColor].CGColor;
        colorButton.layer.borderWidth = 3.0;
        colorButton.frame = CGRectMake(space*(i+1)+width*i, frame.size.height/2.0-width/2, width, width);
        [colorButton addTarget:self action:@selector(colorChangeAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:colorButton];
    }
    UIView *view = self.subviews.firstObject;
    view.frame = CGRectMake(view.frame.origin.x-2, view.frame.origin.y-2, 30.0, 30.0);
    view.layer.cornerRadius = 15.0;
}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self resizeButton];
    UIView *view = self.subviews.firstObject;
    view.frame = CGRectMake(view.frame.origin.x-2, view.frame.origin.y-2, 30.0, 30.0);
    view.layer.cornerRadius = 15.0;
}

-(void)colorChangeAction:(UIButton *)sender{
    [self resizeButton];
    sender.layer.cornerRadius = 15.0;
    CGRect rect = sender.frame;
    sender.frame = CGRectMake(rect.origin.x-2, rect.origin.y-2, 30.0, 30.0);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeColor" object:@{@"color":sender.backgroundColor}];
}

-(void)resizeButton{
    CGFloat width = 26.0;
    CGFloat space = (self.frame.size.width-width*8)/9;
    for (int i = 0; i < self.subviews.count; i++) {
        UIView *view = self.subviews[i];
        view.frame = CGRectMake(space*(i+1)+width*i, self.frame.size.height/2.0-width/2, width, width);
    }
}
@end
