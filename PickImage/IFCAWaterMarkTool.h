//
//  IFCAWaterMarkTool.h
//  PickImage
//
//  Created by vito7zhang on 2017/12/23.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IFCAWaterMarkTool : NSObject
+(UIImage*)addText:(NSString *)text inImage:(UIImage *)image;
@end
