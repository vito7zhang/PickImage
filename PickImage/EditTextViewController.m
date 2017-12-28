//
//  EditTextViewController.m
//  PickImage
//
//  Created by vito7zhang on 2017/11/29.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import "EditTextViewController.h"

#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height
#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavBarHeight 44.0
#define kTabBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?83:49)
#define kTopHeight (kStatusBarHeight + kNavBarHeight)
#define ScrollViewHeight Screen_Height-kTopHeight

@interface EditTextViewController ()<UITextViewDelegate>
@property (nonatomic,strong)UIButton *cancelButton;
@property (nonatomic,strong)UIButton *finishButton;
@end


@implementation EditTextViewController
//@synthesize mainTextView = _mainTextView;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.finishButton];
    [self.view addSubview:self.mainTextView];
    [self.view addSubview:self.colorView];
    [self.mainTextView becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeColorAction:) name:@"ChangeColor" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];//在这里注册通知

}
-(UIButton *)cancelButton{
    if (_cancelButton == nil) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelButton setTitle:@"取消" forState:0];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:0];
        _cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
        _cancelButton.frame = CGRectMake(20, 20, 50, 30);
        _cancelButton.backgroundColor = [UIColor clearColor];
        [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

-(UIButton *)finishButton{
    if (_finishButton == nil) {
        _finishButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_finishButton setTitle:@"完成" forState:0];
        [_finishButton setTitleColor:[UIColor blueColor] forState:0];
        _finishButton.frame = CGRectMake(Screen_Width-70, 20, 50, 30);
        _finishButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
        _finishButton.backgroundColor = [UIColor clearColor];
        [_finishButton addTarget:self action:@selector(finishButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishButton;
}
-(UITextView *)mainTextView{
    if (_mainTextView == nil) {
        _mainTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, 70, Screen_Width, Screen_Height-44-70)];
        _mainTextView.backgroundColor = [UIColor clearColor];
        _mainTextView.textColor = [UIColor redColor];
        _mainTextView.tintColor = [UIColor redColor];
        _mainTextView.font = [UIFont systemFontOfSize:24.0];
    }
    return _mainTextView;
}

-(ColorView *)colorView{
    if (_colorView == nil) {
        _colorView = [[ColorView alloc]initWithFrame:CGRectMake(0, Screen_Height-([[UIApplication sharedApplication] statusBarFrame].size.height>20?34:0)-44, Screen_Width, 44)];
        _colorView.backgroundColor = [UIColor clearColor];
    }
    return _colorView;
}

-(void)changeColorAction:(NSNotification *)noti{
    UIColor *color = noti.object[@"color"];
    self.mainTextView.textColor = color;
    self.mainTextView.tintColor = color;
}
-(void)keyboardWillChangeFrame:(NSNotification *)noti{
    NSDictionary *userInfo = noti.userInfo;
    // 动画的持续时间
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // 键盘的frame
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 执行动画
    [UIView animateWithDuration:duration animations:^{
        if (keyboardF.size.height == 0) {
            self.colorView.frame = CGRectMake(0, Screen_Height-([[UIApplication sharedApplication] statusBarFrame].size.height>20?34:0)-44, Screen_Width, 44);
        }else{
            self.colorView.frame = CGRectMake(0, Screen_Height-([[UIApplication sharedApplication] statusBarFrame].size.height>20?34:0)-44-keyboardF.size.height, Screen_Width, 44);
        }
    }];
    if (keyboardF.size.height == 0) {
        self.mainTextView.frame = CGRectMake(0, 70, Screen_Width, Screen_Height-44-70);
    }else{
        self.mainTextView.frame = CGRectMake(0, 70, Screen_Width, Screen_Height-44-70-keyboardF.size.height);
    }

}

-(void)cancelButtonAction:(UIButton *)sender{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

-(void)finishButtonAction:(UIButton *)sender{
    NSString *text = self.mainTextView.text;
    UIColor *color = self.mainTextView.textColor?self.mainTextView.textColor:[UIColor redColor];
    self.editInfo(text, color);
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (BOOL)shouldAutorotate{
    return NO;
}

@end
