//
//  EditedLabel.m
//  PickImage
//
//  Created by vito7zhang on 2017/12/22.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import "EditedLabel.h"
#import "UIView+Extension.h"
#import "EditTextViewController.h"

#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height


@interface EditedLabel()<UIGestureRecognizerDelegate>
{
    float scale;
}
@property (nonatomic,strong)NSTimer *timer;
@end

@implementation EditedLabel

-(instancetype)init{
    if (self = [super init]) {
        // 自动换行
        self.numberOfLines = 0;
        // 自动加边框
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.masksToBounds = YES;
        self.userInteractionEnabled = YES;
        [self setTimerToHideBorder];
        // 如果没操作则启动定时器，2.5秒后隐藏边框
        [self addGesture];
    }
    return self;
}

-(void)addGesture{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchAction:)];
    pinch.delegate = self;
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotationAction:)];
    rotation.delegate = self;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
//    [pinch requireGestureRecognizerToFail:rotation];
    [self addGestureRecognizer:tap];
    [self addGestureRecognizer:pinch];
    [self addGestureRecognizer:rotation];
    [self addGestureRecognizer:pan];
}

-(void)setText:(NSString *)text{
    [super setText:text];
    CGRect rect = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : self.font} context:nil];
    self.frame = CGRectMake((self.fixationRect.size.width-rect.size.width)/2, (self.fixationRect.size.height-rect.size.height)/2, rect.size.width, rect.size.height);
}
-(void)setFont:(UIFont *)font{
    [super setFont:font];
    CGRect rect = [self.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : font} context:nil];
    self.frame = CGRectMake((self.fixationRect.size.width-rect.size.width)/2, (self.fixationRect.size.height-rect.size.height)/2, rect.size.width, rect.size.height);
}
//显示边框
-(void)showBorder{
    self.layer.borderWidth = 1.0f;
    [self setTimerToHideBorder];
}

-(void)setTimerToHideBorder{
    [self.timer invalidate];
    self.timer = nil;
    self.timer = [[NSTimer alloc] initWithFireDate:[self setHideBorderTime] interval:0 repeats:NO block:^(NSTimer * _Nonnull timer) {
        self.layer.borderWidth = 0.0f;
    }];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

-(NSDate *)setHideBorderTime{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:2.5];
    return date;
}

-(void)tapAction:(UITapGestureRecognizer *)tap{
    if (self.layer.borderWidth > 0) {
        self.transform = CGAffineTransformIdentity;
        EditTextViewController *editTextVC = [EditTextViewController new];
        editTextVC.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        editTextVC.mainTextView.textColor = self.textColor;
        editTextVC.mainTextView.tintColor = self.textColor;
        editTextVC.mainTextView.text = self.text;
        editTextVC.colorView.selectedColor = self.textColor;
        editTextVC.editInfo = ^(NSString *text, UIColor *color) {
            if ([text isEqualToString:@""] || text == nil) {
                [self removeFromSuperview];
            }else{
                self.text = text;
                self.textColor = color;
                self.font = [UIFont systemFontOfSize:24.0];
            }
        };
        NSLog(@"self.getCurrentVC = %p,",self.getCurrentVC);
        [self.getCurrentVC.view addSubview:editTextVC.view];
        [self.getCurrentVC addChildViewController:editTextVC];
    }else{
        [self showBorder];
    }
}

-(void)pinchAction:(UIPinchGestureRecognizer *)pinch{
    [self showBorder];
    if (pinch.state==UIGestureRecognizerStateBegan || pinch.state==UIGestureRecognizerStateChanged){
        UIView *view=[pinch view];
        //扩大、缩小倍数
        view.transform=CGAffineTransformScale(view.transform, pinch.scale, pinch.scale);
        scale *= pinch.scale;
        pinch.scale=1;
    }
    // 结束的时候如果缩小倍数如果小于1，则回到原图的样子
    if (pinch.state == UIGestureRecognizerStateEnded) {
        if (scale < 1.0) {
            scale = 1;
            pinch.view.transform = CGAffineTransformIdentity;
        }
        NSLog(@"pinch.view.width = %f",pinch.view.width);
    }
}

-(void)rotationAction:(UIRotationGestureRecognizer *)rotation{
    [self showBorder];
    rotation.view.transform = CGAffineTransformRotate(rotation.view.transform, rotation.rotation);
    //将上次的弧度重置
    rotation.rotation = 0;
}

// 拖拽移动label
-(void)panAction:(UIPanGestureRecognizer *)pan{
    [self showBorder];
    CGPoint point = [pan translationInView:pan.view];
    
    // 越界检测
    // 这次移动到的x坐标点
    CGFloat transformx = pan.view.transform.tx + self.centerX + point.x;
    CGFloat transformy = pan.view.transform.ty + self.centerY + point.y;
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (transformx > (_fixationRect.size.width)) {
            pan.view.transform = CGAffineTransformTranslate(pan.view.transform, _fixationRect.size.width-pan.view.transform.tx-self.centerX, 0);
        }else if(transformx < 0){
            pan.view.transform = CGAffineTransformTranslate(pan.view.transform, -pan.view.transform.tx-self.centerX, 0);
        }else{
            pan.view.transform = CGAffineTransformTranslate(pan.view.transform, point.x, 0);
        }
        if (transformy > (_fixationRect.size.height)) {
            pan.view.transform = CGAffineTransformTranslate(pan.view.transform, 0,  +_fixationRect.size.height-pan.view.transform.ty-self.centerY);
        }else if(transformy < 0){
            pan.view.transform = CGAffineTransformTranslate(pan.view.transform, 0, -pan.view.transform.ty-self.centerY);
        }else{
            pan.view.transform = CGAffineTransformTranslate(pan.view.transform, 0, point.y);
        }
    }else{
        pan.view.transform = CGAffineTransformTranslate(pan.view.transform, point.x, point.y);
    }
    //每次移动完，将移动量置为0，否则下次移动会加上这次移动量
    [pan setTranslation:CGPointMake(0, 0) inView:pan.view];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if (gestureRecognizer.view == otherGestureRecognizer.view) {
        return YES;
    }
    return NO;
}


@end
