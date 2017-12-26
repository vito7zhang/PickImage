//
//  EditTextViewController.h
//  PickImage
//
//  Created by vito7zhang on 2017/11/29.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorView.h"

@interface EditTextViewController : UIViewController
@property (nonatomic,strong)UITextView *mainTextView;
@property (nonatomic,strong)ColorView *colorView;
@property (nonatomic,copy)void (^editInfo)(NSString *,UIColor *);
@end
