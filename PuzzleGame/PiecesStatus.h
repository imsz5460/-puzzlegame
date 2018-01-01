//
//  PiecesStatus.h
//  智能拼图
//
//  Created by shizhi on 2017/12/6.
//  Copyright © 2017年 shizhi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JXPathSearcher.h"
#import "JXAStarSearcher.h"
#import "SZSquareModel.h"

/// 表示游戏过程中，某一个时刻，所有方块的排列状态
@interface PiecesStatus : NSObject <JXPathSearcherStatus, JXAStarSearcherStatus>
/// 矩阵行数
@property (nonatomic, assign) NSInteger totalRows;
/// 矩阵列数
@property (nonatomic, assign) NSInteger totalCols;

/// 方块数组，按从上到下，从左到右，顺序排列
@property (nonatomic, strong) NSMutableArray<SZSquareModel *> *pieceArrayModel;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *pieceArray;
/// 空格位置，无空格时为-1
@property (nonatomic, assign) NSInteger indexOfWhite;

/// 创建实例
+ (instancetype)statusWithCols:(NSInteger)cols Rows:(NSInteger)rows image:(UIImage *)image;

/// 复制本实例
- (instancetype)copyStatus;

/// 判断是否与另一个状态相同
- (BOOL)equalWithStatus:(PiecesStatus *)status;

/// 空格是否能移动到某个位置
- (BOOL)canMoveToIndex:(NSInteger)index;

/// 把空格移动到某个位置
- (void)moveToIndex:(NSInteger)index;
//计算当前可移动的方块
- (NSInteger)calculateIndexOfMoveable_left;

- (NSInteger)calculateIndexOfMoveable_right;

- (NSInteger)calculateIndexOfMoveable_up;

- (NSInteger)calculateIndexOfMoveable_down;

- (NSInteger)rowOfIndex:(NSInteger)index;

- (NSInteger)colOfIndex:(NSInteger)index;

//打乱图序,返回pieceArrayModel
- (NSMutableArray *) disorganize;
- (NSMutableArray *)currentIndexs;
//校验是否成功闯关
- (BOOL) isSuccess:(NSMutableArray *)currentPieceArr;
@end

