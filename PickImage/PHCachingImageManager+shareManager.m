//
//  PHCachingImageManager+shareManager.m
//  PickImage
//
//  Created by vito7zhang on 2017/11/23.
//  Copyright © 2017年 vito7zhang. All rights reserved.
//

#import "PHCachingImageManager+shareManager.h"

@implementation PHCachingImageManager (shareManager)
+(instancetype)defaultManager{
    static PHCachingImageManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PHCachingImageManager alloc]init];
    });
    return manager;
}
@end
