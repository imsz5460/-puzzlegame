//
//  SZSquareModel.m
//  智能拼图
//
//  Created by Yjt on 2017/12/27.
//  Copyright © 2017年 shizhi. All rights reserved.
//

#import "SZSquareModel.h"

@implementation SZSquareModel
+ (instancetype)squuareWithID:(NSInteger)ID image:(UIImage *)image {
    SZSquareModel *squuare = [[SZSquareModel alloc] init];
    squuare.originalIndex = ID;
    squuare.image = image;
    
    return squuare;
}
@end
