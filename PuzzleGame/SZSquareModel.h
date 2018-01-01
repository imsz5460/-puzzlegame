//
//  SZSquareModel.h
//  智能拼图
//
//  Created by Yjt on 2017/12/27.
//  Copyright © 2017年 shizhi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SZSquareModel : NSObject

@property (nonatomic ,strong)UIImage *image;
@property (nonatomic ,assign)NSInteger originalIndex;

+ (instancetype)squuareWithID:(NSInteger)ID image:(UIImage *)image;
@end
