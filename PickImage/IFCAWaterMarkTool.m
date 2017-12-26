//
//  IFCAWaterMarkTool.m
//  PickImage
//
//  Created by vito7zhang on 2017/12/23.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import "IFCAWaterMarkTool.h"

@implementation IFCAWaterMarkTool
+(UIImage *)addText:(NSString *)text inImage:(UIImage *)image{
    UIGraphicsBeginImageContext(image.size);
    CGFloat w = image.size.width;
    CGFloat h = image.size.height;
    //    在画布中绘制内容
    [image drawInRect:CGRectMake(0, 0, w, h)];
    
    // 文字输入的区域
    CGRect rect = CGRectMake(0, h*0.75, w*0.9, h*0.2);
    // 计算文字大小
    NSInteger maxValue = w>h?w:h;
    NSUInteger fontSize = maxValue/10/text.length;
    //限制字体最大最小
    if (fontSize < 10) {
        fontSize = 10;
    }else if (fontSize > 28){
        fontSize = 28;
    }
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    NSLog(@"font = %@",font);
    // 设置文字右对齐，下对齐
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc]init] ;
    paragraph.alignment = NSTextAlignmentRight;
    paragraph.minimumLineHeight = h * 0.2;
    NSDictionary *dic = @{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraph,NSForegroundColorAttributeName:[UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:0.7]};
    [text drawInRect:rect withAttributes:dic];
    //    从画布中得到image
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return returnImage;
}
@end
