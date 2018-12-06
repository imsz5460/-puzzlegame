//
//  PiecesStatus.m
//  智能拼图
//
//  Created by shizhi on 2017/12/6.
//  Copyright © 2017年 shizhi. All rights reserved.
//

#import "PiecesStatus.h"
#import "UIImage+tools.h"

@interface PiecesStatus ()
@property (strong, nonatomic) NSMutableArray *currentIndexs;//当前方块对应初始时索引
@property (strong, nonatomic) NSArray *targetIndexs;//目标索引数组

@end

@implementation PiecesStatus {
    id<JXPathSearcherStatus> _parentStatus;
    NSInteger _gValue;
    NSInteger _hValue;
    NSInteger _fValue;
}

+ (instancetype)statusWithCols:(NSInteger)cols Rows:(NSInteger)rows image:(UIImage *)image {
//    if (cols*rows < 9 || !image) {
//        
//        NSLog(@"请选择3阶以上的");
//        return nil;
//    }
    
    PiecesStatus *status = [[PiecesStatus alloc] init];
    status.totalRows = rows;
    status.totalCols = cols;
    status.pieceArray = [NSMutableArray array];
    status.pieceArrayModel = [NSMutableArray array];
    status.indexOfWhite = cols*rows-1;
    
    NSMutableArray * temp_targetIndexs = [NSMutableArray array];
    CGFloat x,y,w,h;
    w = (image.size.width/cols)/[UIScreen mainScreen].scale;
    h = (image.size.height/rows)/[UIScreen mainScreen].scale;
    
    for (int i=0; i<rows; i++) {
        for (int j=0; j<cols; j++) {
            x = j*w;
            y = i*h;
            CGRect rect = CGRectMake(x,y,w,h);
            SZSquareModel *model;
            if ((i==rows-1) && (j== cols-1)) {
                model = [SZSquareModel squuareWithID:i*cols+j image: nil];
            } else {
                model = [SZSquareModel squuareWithID:i*cols+j image: [image cutImageInRect: rect]];
            }
            [temp_targetIndexs  addObject: @(i*cols+j)];
            [status.pieceArrayModel addObject:model];
        }
    }
    status.targetIndexs = temp_targetIndexs;
    status.pieceArray = temp_targetIndexs;
    
    return status;
}

-(NSMutableArray *) disorganize {
   self.pieceArrayModel = [self changeArray:self.pieceArrayModel];
   self.pieceArray = [self currentIndexs];
   return self.pieceArrayModel;
}

- (instancetype)copyStatus {
    PiecesStatus *status = [[PiecesStatus alloc] init];
    status.totalRows = self.totalRows;
    status.totalCols = self.totalCols;
    status.pieceArray = [self.pieceArray mutableCopy];
    status.pieceArrayModel = [self.pieceArrayModel mutableCopy];
    status.indexOfWhite = self.indexOfWhite;
    return status;
}

- (BOOL)equalWithStatus:(PiecesStatus *)status {
    return [self.pieceArray  isEqualToArray:status.pieceArray];
}


/// 空格是否能移动到某个位置
- (BOOL)canMoveToIndex:(NSInteger)index {
    
    return  ( [self calculateIndexOfMoveable_left] == index)  ||
            ( [self calculateIndexOfMoveable_right] == index) ||
            ( [self calculateIndexOfMoveable_up] == index) ||
            ( [self calculateIndexOfMoveable_down] == index);
    
}

/// 把空格移动到某个位置
- (void)moveToIndex:(NSInteger)index {
    
    id temp = self.pieceArray[self.indexOfWhite];
    self.pieceArray[self.indexOfWhite] = self.pieceArray[index];
    self.pieceArray[index] = temp;
    //如果对搜索效率有更高要求，可以在搜索完成后再进行转换
    [self.pieceArrayModel exchangeObjectAtIndex:self.indexOfWhite withObjectAtIndex:index];
    
    self.indexOfWhite = index;
}


#pragma mark - 状态(结点)协议
- (NSString *)statusIdentifier {
    NSMutableString *str = [NSMutableString string];

//    [self.pieceArray enumerateObjectsUsingBlock:^(SZSquareModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [str appendFormat:@"%ld,",obj.originalIndex];
//
//    }];
 
    [self.pieceArray enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [str appendFormat:@"%ld,", [obj integerValue]];
        
    }];
    return str;
}

- (void)setParentStatus:(id<JXPathSearcherStatus>)parentStatus {
    _parentStatus = parentStatus;
}

- (id<JXPathSearcherStatus>)parentStatus {
    return _parentStatus;
}

- (NSMutableArray<id<JXPathSearcherStatus>> *)childStatus {
    NSMutableArray *array = [NSMutableArray array];
    NSInteger targetIndex = -1;
    if ((targetIndex = [self calculateIndexOfMoveable_up]) != -1) {
        [self addChildStatusIndex:targetIndex toArray:array];
    }
    if ((targetIndex = [self calculateIndexOfMoveable_down]) != -1) {
        [self addChildStatusIndex:targetIndex toArray:array];
    }
    if ((targetIndex = [self calculateIndexOfMoveable_left]) != -1) {
        [self addChildStatusIndex:targetIndex toArray:array];
    }
    if ((targetIndex = [self calculateIndexOfMoveable_right]) != -1) {
        [self addChildStatusIndex:targetIndex toArray:array];
    }
    return array;
}

#pragma mark -计算当前可移动的方块
- (NSInteger)calculateIndexOfMoveable_left {
    NSInteger left = _indexOfWhite - 1;
    return [self colOfIndex: left] > [self colOfIndex: _indexOfWhite] ? -1 : left;
}

- (NSInteger)calculateIndexOfMoveable_right {
    NSInteger right = _indexOfWhite + 1;
    return [self colOfIndex: right] < [self colOfIndex: _indexOfWhite] ? -1 : right;
}

- (NSInteger)calculateIndexOfMoveable_up {
    
    return (_indexOfWhite - _totalCols) < 0 ? -1 : _indexOfWhite - _totalCols;
}

- (NSInteger)calculateIndexOfMoveable_down {
    
    return (_indexOfWhite + _totalCols) > (_totalCols*_totalRows-1) ? -1 : _indexOfWhite + _totalCols;
}

- (NSInteger)rowOfIndex:(NSInteger)index {
    return index / _totalCols;
}

- (NSInteger)colOfIndex:(NSInteger)index {
    return index % _totalCols;
}


- (void)addChildStatusIndex:(NSInteger)index toArray:(NSMutableArray *)array {
    // 排除父状态
    if ([self parentStatus] && [(PiecesStatus *)[self parentStatus] indexOfWhite] == index) {
        return;
    }
    if (![self canMoveToIndex:index]) {
        return;
    }
    PiecesStatus *status = [self copyStatus];
    [status moveToIndex:index];
    [array addObject:status];
    status.parentStatus = self;
}

#pragma mark - A*搜索状态(结点)协议
- (NSInteger)gValue {
    return _gValue;
}

- (void)setGValue:(NSInteger)gValue {
    _gValue = gValue;
}

- (NSInteger)hValue {
    return _hValue;
}

- (void)setHValue:(NSInteger)hValue {
    _hValue = hValue;
}

- (NSInteger)fValue {
    return _fValue;
}

- (void)setFValue:(NSInteger)fValue {
    _fValue = fValue;
}

/// 估算从当前状态到目标状态的代价
- (NSInteger)estimateToTargetStatus:(id<JXPathSearcherStatus>)targetStatus {
    PiecesStatus *target = (PiecesStatus *)targetStatus;
    
    // 计算每一个方块距离它正确位置的距离
    // 曼哈顿距离
    NSInteger manhattanDistance = 0;
    for (NSInteger index = 0; index < self.pieceArray.count; ++ index) {
        // 略过空格
        if (index == self.indexOfWhite) {
            continue;
        }
        
//        SZSquareModel *currentPiece = self.pieceArray[index];
//        SZSquareModel *targetPiece = target.pieceArray[index];
        
//        manhattanDistance +=
//        ABS([self rowOfIndex:currentPiece.originalIndex- [target rowOfIndex:targetPiece.originalIndex]]) +
//        ABS([self colOfIndex:currentPiece.originalIndex  - [target colOfIndex:targetPiece.originalIndex]]);
        
        NSNumber *currentPiece = self.pieceArray[index];
        NSNumber *targetPiece = target.pieceArray[index];
        
        manhattanDistance +=
        ABS([self rowOfIndex:[currentPiece integerValue]] - [target rowOfIndex:[targetPiece integerValue]]) +
        ABS([self colOfIndex:[currentPiece integerValue]] - [target colOfIndex:[targetPiece integerValue]]);
    }
    
    // 增大权重
    return 5 * manhattanDistance;
}

#pragma mark -判断乱序数组是否可还原，基于对逆序数的计算
-(BOOL)canRecovery:(NSMutableArray *)randomArr {
    
    int inverCount = 0;
    for (int i = 0; i < randomArr.count-1; i++) {
        
        for (int j = i + 1; j < randomArr.count; j++) {
            SZSquareModel *modeli = randomArr[i];
            SZSquareModel *modelj = randomArr[j];
            if (modeli.originalIndex > modelj.originalIndex) {
                inverCount++;
            }
        }
    }
    if (!(inverCount % 2)) {//对2求余，余0，逆序数为偶数，即偶排列；否则，为奇排列
        return YES;
    }
    return NO;
}

#pragma mark -数组随机乱序
- (NSMutableArray *)randomArray:(NSMutableArray *)originalArr
{
    
    NSMutableArray *newDatasourceArr = [NSMutableArray array];
    NSMutableArray *tempArr = [originalArr mutableCopy];
    int m = (int)tempArr.count;
    for (int i=0; i<m; i++) {
        int t = arc4random() % (tempArr.count);
        newDatasourceArr[i] = tempArr[t];
        tempArr[t] = [tempArr lastObject];
        [tempArr removeLastObject];
        
    }
    return  newDatasourceArr;
}

#pragma mark -数组变换
- (NSMutableArray *)changeArray:(NSMutableArray *)originalArr {
    
    id last = originalArr.lastObject;
    NSMutableArray *temp = originalArr;
    [temp removeLastObject];
    
    // 数组乱序,还要校验随机后是否跟原来一样
    do {
        do {
            temp = [self randomArray: temp];
        } while (![self canRecovery: temp]);
    } while ([self isSuccessWithCurrent:temp  andTarget:self.pieceArrayModel]);
    
    [temp addObject: last];
    return temp;
}

- (NSArray *)addObject:(id)obj fromObj:(NSMutableArray *)fromObj {
    [fromObj addObject: obj];
    return fromObj;
}

#pragma mark -校验是否成功闯关
- (BOOL) isSuccessWithCurrent:(NSArray *)currentPieceArr andTarget:(NSArray *)targetArr {
    
    return [currentPieceArr isEqualToArray: targetArr];
}



#pragma mark -currentIndexs
- (NSMutableArray *)currentIndexs {
    _currentIndexs = [NSMutableArray array];
    
    [self.pieceArrayModel enumerateObjectsUsingBlock:^(SZSquareModel *  obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [_currentIndexs addObject: @(obj.originalIndex)];
    }];
    
    return _currentIndexs;
}


@end
