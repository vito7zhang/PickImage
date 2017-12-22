//
//  EditedLabel.m
//  PickImage
//
//  Created by vito7zhang on 2017/12/22.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import "EditedLabel.h"
#import "UIView+Extension.h"

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
    self.frame = rect;
    self.center = CGPointMake(Screen_Width/2, Screen_Height/2);
}
-(void)setFont:(UIFont *)font{
    [super setFont:font];
    CGRect rect = [self.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : font} context:nil];
    self.frame = rect;
    self.center = CGPointMake(Screen_Width/2, Screen_Height/2);
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
    [self showBorder];
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
    CGFloat tx = point.x;
    CGFloat ty = point.y;
    // 检测越界
    CGFloat transformx = pan.view.transform.tx + self.centerX + tx;
    CGFloat transformy = pan.view.transform.ty + self.centerY + ty;
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (transformx > (_fixationRect.origin.x +_fixationRect.size.width)) {
            //        tx = _fixationRect.size.width + _fixationRect.origin.x - pan.view.transform.tx;
            tx = 0;
            pan.view.transform = CGAffineTransformTranslate(pan.view.transform, _fixationRect.origin.x +_fixationRect.size.width-pan.view.transform.tx-self.centerX, 0);
        }else if(transformx < _fixationRect.origin.x){
            //        tx = pan.view.transform.tx - _fixationRect.origin.x;
            tx = 0;
            pan.view.transform = CGAffineTransformTranslate(pan.view.transform, _fixationRect.origin.x -pan.view.transform.tx-self.centerX, 0);
        }else{
            pan.view.transform = CGAffineTransformTranslate(pan.view.transform, tx, 0);
        }
        if (transformy > (_fixationRect.origin.y + _fixationRect.size.height)) {
            //        ty = _fixationRect.size.height + _fixationRect.origin.y - pan.view.transform.ty;
            ty = 0;
            pan.view.transform = CGAffineTransformTranslate(pan.view.transform, 0, _fixationRect.origin.y +_fixationRect.size.height-pan.view.transform.ty-self.centerY);
        }else if(transformy < _fixationRect.origin.y){
            //        ty = pan.view.transform.ty - _fixationRect.origin.y;
            ty = 0;
            pan.view.transform = CGAffineTransformTranslate(pan.view.transform, 0, _fixationRect.origin.y -pan.view.transform.ty-self.centerY);
        }else{
            pan.view.transform = CGAffineTransformTranslate(pan.view.transform, 0, ty);
        }
    }else{
        pan.view.transform = CGAffineTransformTranslate(pan.view.transform, tx, ty);
    }
    //每次移动完，将移动量置为0，否则下次移动会加上这次移动量
    [pan setTranslation:CGPointMake(0, 0) inView:pan.view];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

@end
