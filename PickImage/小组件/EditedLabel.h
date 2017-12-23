//
//  EditedLabel.h
//  PickImage
//
//  Created by vito7zhang on 2017/12/22.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditedLabel : UILabel
// 这个值要先设置呀，约束这个控制的位置同时固定位置
@property (nonatomic,assign)CGRect fixationRect;
@end
