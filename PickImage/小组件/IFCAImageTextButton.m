//
//  IFCAImageTextButton.m
//  PickImage
//
//  Created by vito7zhang on 2017/11/27.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import "IFCAImageTextButton.h"

@implementation IFCAImageTextButton

- (void)setImageLocation:(IFCAImageLocation)location spacing:(CGFloat)spacing {
    CGFloat imageWith = self.imageView.image.size.width;
    CGFloat imageHeight = self.imageView.image.size.height;
    
    CGSize texth_wXQ = CGSizeMake(MAXFLOAT,MAXFLOAT);
    NSDictionary *dicText = @{NSFontAttributeName :self.titleLabel.font};
    CGFloat titleWidth = [self.titleLabel.text boundingRectWithSize:texth_wXQ options:NSStringDrawingUsesLineFragmentOrigin attributes:dicText context:nil].size.width;
    
    CGFloat titleHeight = [self.titleLabel.text boundingRectWithSize:texth_wXQ options:NSStringDrawingUsesLineFragmentOrigin attributes:dicText context:nil].size.height;
    //image中心移动的x距离
    CGFloat imageOffsetX = (imageWith + titleWidth) / 2 - imageWith / 2;
    //image中心移动的y距离
    CGFloat imageOffsetY = imageHeight / 2 + spacing / 2;
    //title中心移动的x距离
    CGFloat titleOffsetX = (imageWith + titleWidth / 2) - (imageWith + titleWidth) / 2;
    //title中心移动的y距离
    CGFloat labelOffsetY = titleHeight / 2 + spacing / 2;
    
    switch (location) {
        case IFCAImageLocationLeft:
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -spacing/2, 0, spacing/2);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, spacing/2, 0, -spacing/2);
            break;
            
        case IFCAImageLocationRight:
            self.imageEdgeInsets = UIEdgeInsetsMake(0, titleWidth + spacing/2, 0, -(titleWidth + spacing/2));
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -(imageHeight + spacing/2), 0, imageHeight + spacing/2);
            break;
            
        case IFCAImageLocationTop:
            
            self.imageEdgeInsets = UIEdgeInsetsMake(-imageOffsetY, imageOffsetX, imageOffsetY, -imageOffsetX);
            self.titleEdgeInsets = UIEdgeInsetsMake(labelOffsetY, -titleOffsetX, -labelOffsetY, titleOffsetX);
            break;
            
        case IFCAImageLocationBottom:
            
            self.imageEdgeInsets = UIEdgeInsetsMake(imageOffsetY, imageOffsetX, -imageOffsetY, -imageOffsetX);
            self.titleEdgeInsets = UIEdgeInsetsMake(-labelOffsetY, -titleOffsetX, labelOffsetY, titleOffsetX);
            
            break;
            
        default:
            break;
    }
    
}

- (void)setImageLocation:(IFCAImageLocation)location spacing:(CGFloat)spacing offSet:(IFCAOffSetDirection)offSetDirection offSetVar:(CGFloat)offSetVar{
    CGFloat imageWith = self.imageView.image.size.width;
    CGFloat imageHeight = self.imageView.image.size.height;
    CGSize texth_wXQ = CGSizeMake(MAXFLOAT,MAXFLOAT);
    NSDictionary *dicText = @{NSFontAttributeName :self.titleLabel.font};
    CGFloat titleWidth = [self.titleLabel.text boundingRectWithSize:texth_wXQ options:NSStringDrawingUsesLineFragmentOrigin attributes:dicText context:nil].size.width;
    
    CGFloat titleHeight = [self.titleLabel.text boundingRectWithSize:texth_wXQ options:NSStringDrawingUsesLineFragmentOrigin attributes:dicText context:nil].size.height;
    
    //image中心移动的x距离
    CGFloat imageOffsetX = (imageWith + titleWidth) / 2 - imageWith / 2;
    //image中心移动的y距离
    CGFloat imageOffsetY = imageHeight / 2 + spacing / 2;
    //title中心移动的x距离
    CGFloat titleOffsetX = (imageWith + titleWidth / 2) - (imageWith + titleWidth) / 2;
    //title中心移动的y距离
    CGFloat labelOffsetY = titleHeight / 2 + spacing / 2;
    
    switch (location) {
        case IFCAImageLocationLeft:
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -spacing/2, 0, spacing/2);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, spacing/2, 0, -spacing/2);
            break;
            
        case IFCAImageLocationRight:
            self.imageEdgeInsets = UIEdgeInsetsMake(0, titleWidth + spacing/2, 0, -(titleWidth + spacing/2));
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -(imageHeight + spacing/2), 0, imageHeight + spacing/2);
            break;
            
        case IFCAImageLocationTop:
            
            self.imageEdgeInsets = UIEdgeInsetsMake(-imageOffsetY, imageOffsetX, imageOffsetY, -imageOffsetX);
            self.titleEdgeInsets = UIEdgeInsetsMake(labelOffsetY, -titleOffsetX, -labelOffsetY, titleOffsetX);
            break;
            
        case IFCAImageLocationBottom:
            
            self.imageEdgeInsets = UIEdgeInsetsMake(imageOffsetY, imageOffsetX, -imageOffsetY, -imageOffsetX);
            self.titleEdgeInsets = UIEdgeInsetsMake(-labelOffsetY, -titleOffsetX, labelOffsetY, titleOffsetX);
            
            break;
            
        default:
            break;
    }
    
    CGFloat imageTop = self.imageEdgeInsets.top;
    CGFloat imageLeft = self.imageEdgeInsets.left;
    CGFloat imageBottom = self.imageEdgeInsets.bottom;
    CGFloat imageRight = self.imageEdgeInsets.right;
    
    CGFloat titleTop = self.titleEdgeInsets.top;
    CGFloat titleLeft = self.titleEdgeInsets.left;
    CGFloat titleBottom = self.titleEdgeInsets.bottom;
    CGFloat titleRight = self.titleEdgeInsets.right;
    switch (offSetDirection){
        case IFCAOffSetDirectionLeft:
            self.imageEdgeInsets = UIEdgeInsetsMake(imageTop, imageLeft - offSetVar, imageBottom, imageRight + offSetVar);
            self.titleEdgeInsets = UIEdgeInsetsMake(titleTop, titleLeft - offSetVar, titleBottom, titleRight + offSetVar);
            
            break;
        case IFCAOffSetDirectionRight:
            self.imageEdgeInsets = UIEdgeInsetsMake(imageTop, imageLeft + offSetVar, imageBottom, imageRight - offSetVar);
            self.titleEdgeInsets = UIEdgeInsetsMake(titleTop, titleLeft + offSetVar, titleBottom, titleRight - offSetVar);
            break;
        case IFCAOffSetDirectionTop:
            self.imageEdgeInsets = UIEdgeInsetsMake(imageTop - offSetVar , imageLeft, imageBottom + offSetVar, imageRight);
            self.titleEdgeInsets = UIEdgeInsetsMake(titleTop - offSetVar , titleLeft, titleBottom + offSetVar, titleRight);
            break;
        case IFCAOffSetDirectionBottom:
            self.imageEdgeInsets = UIEdgeInsetsMake(imageTop + offSetVar, imageLeft, imageBottom - offSetVar, imageRight);
            self.titleEdgeInsets = UIEdgeInsetsMake(titleTop + offSetVar, titleLeft, titleBottom - offSetVar, titleRight);
            break;
        default:
            break;
    }
    
}

@end
