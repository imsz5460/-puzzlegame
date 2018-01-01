//
//  SZSquareCell.h
//  智能拼图
//
//  Created by shizhi on 2017/12/6.
//  Copyright © 2017年 shizhi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SZSquareModel;
@interface SZSquareCell : UICollectionViewCell


@property (nonatomic ,strong)SZSquareModel *model;
@property (nonatomic ,assign)BOOL showNo;

@end
