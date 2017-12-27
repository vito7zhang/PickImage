//
//  EditViewController.m
//  PickImage
//
//  Created by vito7zhang on 2017/11/28.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import "EditViewController.h"
#import "ColorView.h"
#import "EditTextViewController.h"
#import "UIView+Extension.h"
#import "EditedLabel.h"

#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height
#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavBarHeight 44.0
#define kTabBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?83:49)
#define kTopHeight (kStatusBarHeight + kNavBarHeight)
#define ScrollViewHeight Screen_Height-kTopHeight


@interface EditViewController ()
{
    //当前缩放倍数，最小为1
    CGFloat scale;
    //单击手势，会失效，所以做成全局
    UIPanGestureRecognizer *onePan;
}
// 容器，装在imageview，负责缩放
@property (nonatomic,strong)UIView *containView;
// 负责显示图片
@property (nonatomic,strong)UIImageView *backgroundImageView;
@property (nonatomic,strong)UIButton *cancelButton;
@property (nonatomic,strong)UIButton *finishButton;
// 取色视图
@property (nonatomic,strong)ColorView *colorView;
@property (nonatomic,strong)UIButton *penButton;
@property (nonatomic,strong)UIButton *penRepealButton;
@property (nonatomic,strong)UIButton *textButton;
@property (nonatomic,strong)UIToolbar *toolBar;
// 编辑后的图片
@property (nonatomic,strong)UIImage *editedImage;
// 绘制线条用到的
@property (nonatomic,strong)UIBezierPath *path;
@property (nonatomic,strong)CAShapeLayer *shapeLayer;
@property (nonatomic,strong)NSMutableArray *lines;
@property (nonatomic,strong)UIColor *strokeColor;

@property (nonatomic,strong)NSMutableArray *texts;
@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    scale = 1.0;
    self.strokeColor = [UIColor redColor];
    self.lines = [NSMutableArray array];
    self.texts = [NSMutableArray array];
    NSLog(@"editview = %p",self);

    [self.view addSubview:self.containView];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.colorView];
    [self.view addSubview:self.penRepealButton];
    [self.view addSubview:self.finishButton];
    [self.view addSubview:self.toolBar];
    [self addGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeColor:) name:@"ChangeColor" object:nil];
}

// 为图片增加缩放，位移手势
-(void)addGestureRecognizer{
    self.backgroundImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    onePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(oneTouchPanAction:)];
    UIPanGestureRecognizer *doublePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTouchPanAction:)];
    doublePan.minimumNumberOfTouches = 2;
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [self.containView addGestureRecognizer:tap];
    [self.containView addGestureRecognizer:onePan];
    [self.containView addGestureRecognizer:doublePan];
    [self.containView addGestureRecognizer:pinch];
}
-(UIView *)containView{
    if (_containView == nil) {
        _containView = [[UIView alloc] initWithFrame:self.view.frame];
        _containView.backgroundColor = [UIColor blackColor];
        [_containView addSubview:self.backgroundImageView];
    }
    return _containView;
}
-(UIImageView *)backgroundImageView{
    if (_backgroundImageView == nil) {
        _backgroundImageView = [[UIImageView alloc] init];
        // 设置图片
        _backgroundImageView.image = self.editImage;
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
        // 防止画线过界
        _backgroundImageView.layer.masksToBounds = YES;
        // 计算大小，根据图片比例来算
        if (self.editImage.size.width/self.editImage.size.height > Screen_Width/Screen_Height) {
            _backgroundImageView.frame = CGRectMake(0, (Screen_Height-self.editImage.size.height*Screen_Width/self.editImage.size.width)/2, Screen_Width, self.editImage.size.height*Screen_Width/self.editImage.size.width);
        }else if(self.editImage.size.width/self.editImage.size.height == Screen_Width/Screen_Height) {
            _backgroundImageView.frame = self.view.frame;
        }else{
            _backgroundImageView.frame = CGRectMake((Screen_Width-self.editImage.size.width*Screen_Height/self.editImage.size.height)/2, 0, Screen_Width, self.editImage.size.width*Screen_Height/self.editImage.size.height);
        }
    }
    return _backgroundImageView;
}


#pragma mark 按钮绑定事件
-(void)cancelButtonAction:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
    UIViewController *vc = [self.navigationController popViewControllerAnimated:YES];
    if (vc == nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
-(void)finishButtonAction:(UIButton *)sender{
    self.backImage(self.editedImage);
    UIViewController *vc = [self.navigationController popViewControllerAnimated:YES];
//    if (vc == nil) {
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
}
-(void)penButtonAction:(UIButton *)sender{
    onePan.enabled = NO;
    sender.selected = !sender.selected;
    [UIView animateWithDuration:0.25 animations:^{
        if (sender.selected) {
            self.colorView.alpha = 1.0;
            self.penRepealButton.alpha = 1.0;
        }else{
            self.colorView.alpha = 0.0;
            self.penRepealButton.alpha = 0.0;
        }
    }];
}
-(void)penRepealButtonAction:(UIButton *)sender{
    if (self.lines.count > 0) {
        CALayer *layer = self.lines.lastObject;
        [layer removeFromSuperlayer];
        [self.lines removeLastObject];
    }
}
-(void)textButtonAction:(UIButton *)sender{
    self.colorView.alpha = 0.0;
    self.penRepealButton.alpha = 0.0;
    EditTextViewController *editTextVC = [EditTextViewController new];
    editTextVC.view.backgroundColor = [UIColor clearColor];
    editTextVC.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    editTextVC.editInfo = ^(NSString *text, UIColor *color) {
        EditedLabel *editedLabel = [EditedLabel new];
        editedLabel.fixationRect = self.backgroundImageView.frame;
        editedLabel.text = text;
        editedLabel.font = [UIFont systemFontOfSize:24.0];
        editedLabel.textColor = color;
        [self.texts addObject:editedLabel];
        [self.backgroundImageView addSubview:editedLabel];
    };
    [self.view addSubview:editTextVC.view];
    [self addChildViewController:editTextVC];
}

#pragma mark 手势事件
-(void)tapAction:(UITapGestureRecognizer *)tap{
    BOOL toolbarHidden = !self.toolBar.alpha;
    [UIView animateWithDuration:0.25 animations:^{
        if (toolbarHidden) {
            [self showAnything];
        }else{
            [self hiddenAnythingWithoutBackimage];
        }
    }];
}
-(void)oneTouchPanAction:(UIPanGestureRecognizer *)pan{
    CGPoint point = [pan translationInView:pan.view];
    pan.view.transform = CGAffineTransformTranslate(pan.view.transform, point.x, point.y);
    //每次移动完，将移动量置为0，否则下次移动会加上这次移动量
    [pan setTranslation:CGPointMake(0, 0) inView:pan.view];
    // 检测移动上下左右越界
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (-pan.view.transform.tx>(pan.view.width-Screen_Width)/2) {
            CGAffineTransform transform = pan.view.transform;
            transform.tx = -(pan.view.width-Screen_Width)/2;
            pan.view.transform = transform;
        }else if(pan.view.transform.tx > (pan.view.width-Screen_Width)/2) {
            CGAffineTransform transform = pan.view.transform;
            transform.tx = (pan.view.width-Screen_Width)/2;
            pan.view.transform = transform;
        }
        if (-pan.view.transform.ty>(pan.view.height-Screen_Height)/2) {
            CGAffineTransform transform = pan.view.transform;
            transform.ty = -(pan.view.height-Screen_Height)/2;
            pan.view.transform = transform;
        }else if(pan.view.transform.ty > (pan.view.height-Screen_Height)/2) {
            CGAffineTransform transform = pan.view.transform;
            transform.ty = (pan.view.height-Screen_Height)/2;
            pan.view.transform = transform;
        }
    }
}
-(void)doubleTouchPanAction:(UIPanGestureRecognizer *)pan{
    CGPoint point = [pan translationInView:pan.view];
    pan.view.transform = CGAffineTransformTranslate(pan.view.transform, point.x, point.y);
    //每次移动完，将移动量置为0，否则下次移动会加上这次移动量
    [pan setTranslation:CGPointMake(0, 0) inView:pan.view];
    // 检测移动上下左右越界
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (-pan.view.transform.tx>(pan.view.width-Screen_Width)/2) {
            CGAffineTransform transform = pan.view.transform;
            transform.tx = -(pan.view.width-Screen_Width)/2;
            pan.view.transform = transform;
        }else if(pan.view.transform.tx > (pan.view.width-Screen_Width)/2) {
            CGAffineTransform transform = pan.view.transform;
            transform.tx = (pan.view.width-Screen_Width)/2;
            pan.view.transform = transform;
        }
        if (-pan.view.transform.ty>(pan.view.height-Screen_Height)/2) {
            CGAffineTransform transform = pan.view.transform;
            transform.ty = -(pan.view.height-Screen_Height)/2;
            pan.view.transform = transform;
        }else if(pan.view.transform.ty > (pan.view.height-Screen_Height)/2) {
            CGAffineTransform transform = pan.view.transform;
            transform.ty = (pan.view.height-Screen_Height)/2;
            pan.view.transform = transform;
        }
    }
}
// 捏合手势
-(void)pinchAction:(UIPinchGestureRecognizer *)pinch{
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
        [self hiddenAnythingWithoutBackimage];
        NSLog(@"pinch.view.width = %f",pinch.view.width);
    }
}
//改变颜色通知
-(void)changeColor:(NSNotification *)noti{
    if (self.childViewControllers.count == 0) {
        _strokeColor = noti.object[@"color"];
    }
}
// 隐藏导航栏
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
    self.navigationController.navigationBarHidden = YES;
}
// 取消隐藏导航栏
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.toolbarHidden = NO;
    self.navigationController.navigationBarHidden = NO;
}
// 将所有视图显示
-(void)showAnything{
    self.toolBar.alpha = 1.0;
    self.cancelButton.alpha = 1.0;
    self.finishButton.alpha = 1.0;
    if (self.penButton.selected) {
        self.colorView.alpha = 1.0;
        self.penRepealButton.alpha = 1.0;
    }
}
// 将所有视图隐藏
-(void)hiddenAnythingWithoutBackimage{
    self.toolBar.alpha = 0.0;
    self.cancelButton.alpha = 0.0;
    self.finishButton.alpha = 0.0;
    self.colorView.alpha = 0.0;
    self.penRepealButton.alpha = 0.0;
}
// 移动绘制线条
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    onePan.enabled = !self.penButton.selected;
    if (self.penButton.selected) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self.backgroundImageView];
        _path = [UIBezierPath bezierPath];
        _path.lineWidth = 5.0;
        [_path moveToPoint:point];
        
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.path = _path.CGPath;
        _shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
        _shapeLayer.fillColor = [UIColor clearColor].CGColor;
        _shapeLayer.lineCap = kCALineCapRound;
        _shapeLayer.lineJoin = kCALineJoinRound;
        _shapeLayer.strokeColor = _strokeColor.CGColor;
        _shapeLayer.lineWidth = _path.lineWidth;
        [self.backgroundImageView.layer addSublayer:_shapeLayer];
        [self.lines addObject:_shapeLayer];
    }
}
// 为线条增加点
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.penButton.selected) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self.backgroundImageView];
        [_path addLineToPoint:point];
        _shapeLayer.path = _path.CGPath;
    }
}

#pragma mark configUI
-(ColorView *)colorView{
    if (_colorView == nil) {
        _colorView = [[ColorView alloc] initWithFrame:CGRectMake(0, Screen_Height-([[UIApplication sharedApplication] statusBarFrame].size.height>20?78:44)-44, Screen_Width/9*8, 44)];
        _colorView.alpha = 0.0;
    }
    return _colorView;
}
-(UIButton *)penRepealButton{
    if (_penRepealButton == nil) {
        _penRepealButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_penRepealButton setImage:[UIImage imageNamed:@"repeal"] forState:0];
        _penRepealButton.frame = CGRectMake(Screen_Width/9*8,Screen_Height-([[UIApplication sharedApplication] statusBarFrame].size.height>20?78:44)-44+(44-26)/2, 26, 26);
        [_penRepealButton addTarget:self action:@selector(penRepealButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _penRepealButton.alpha = 0.0;
    }
    return _penRepealButton;
}
-(UIButton *)cancelButton{
    if (_cancelButton == nil) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelButton setTitle:@"取消" forState:0];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:0];
        _cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
        [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.frame = CGRectMake(20, 20, 50, 30);
    }
    return _cancelButton;
}
-(UIButton *)finishButton{
    if (_finishButton == nil) {
        _finishButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_finishButton setTitle:@"完成" forState:0];
        [_finishButton setTitleColor:[UIColor blueColor] forState:0];
        _finishButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
        [_finishButton addTarget:self action:@selector(finishButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _finishButton.frame = CGRectMake(Screen_Width-70, 20, 50, 30);
    }
    return _finishButton;
}
-(UIToolbar *)toolBar{
    if (_toolBar == nil) {
        _toolBar = [UIToolbar new];
        _toolBar.frame = CGRectMake(0, Screen_Height-([[UIApplication sharedApplication] statusBarFrame].size.height>20?78:44), Screen_Width, 44);
        UIView *penVesselView = [[UIView alloc]initWithFrame:CGRectMake(7, 7, 30, 30)];
        [penVesselView addSubview:self.penButton];
        UIView *textVesselView = [[UIView alloc]initWithFrame:CGRectMake(7, 7, 30, 30)];
        [textVesselView addSubview:self.textButton];
        UIBarButtonItem *penBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:penVesselView];
        UIBarButtonItem *textBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:textVesselView];
        UIBarButtonItem *flexBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [_toolBar setItems:@[penBarButtonItem,flexBarButtonItem,textBarButtonItem]];
    }
    return _toolBar;
}
-(UIButton *)penButton{
    if (_penButton == nil) {
        _penButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _penButton.frame = CGRectMake(0, 0, 30, 30);
        [_penButton setImage:[UIImage imageNamed:@"pen"] forState:0];
        [_penButton addTarget:self action:@selector(penButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _penButton;
}
-(UIButton *)textButton{
    if (_textButton == nil) {
        _textButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _textButton.frame = CGRectMake(0, 0, 30, 30);
        [_textButton setImage:[UIImage imageNamed:@"T"] forState:0];
        [_textButton addTarget:self action:@selector(textButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _textButton;
}
-(UIImage *)editedImage{
    if (_editedImage == nil) {
        CGFloat imageScale = self.editImage.size.width/self.backgroundImageView.width;
        UIGraphicsBeginImageContextWithOptions(self.backgroundImageView.frame.size, 1, imageScale);
        [self.backgroundImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
        _editedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return _editedImage;
}
@end
