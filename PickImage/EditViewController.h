//
//  EditViewController.h
//  PickImage
//
//  Created by vito7zhang on 2017/11/28.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditViewController : UIViewController
@property (nonatomic,strong)UIImage *editImage;
@property (nonatomic,weak)void (^backImage)(UIImage *);
@end
