//
//  SZcollectionViewDelegate.m
//  智能拼图
//
//  Created by Yjt on 2017/12/27.
//  Copyright © 2017年 shizhi. All rights reserved.
//

#import "SZcollectionViewDelegate.h"
#import "SZSquareCell.h"
#import "PiecesStatus.h"

@interface SZcollectionViewDelegate ()
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, copy)   selectCell selectBlock;
@end


@implementation SZcollectionViewDelegate
static NSString * const reuseIdentifier = @"Cell";

+ (instancetype)createCollectionViewDelegateWithDataSource:(NSArray *)dataSource
                                               selectBlock:(selectCell)selectBlock {
    
    return [[[self class] alloc] initTableViewDelegateWithDataSource:dataSource
                                                       selectBlock:selectBlock];
    
}


- (instancetype)initTableViewDelegateWithDataSource:(NSArray *)dataSource selectBlock:(selectCell)selectBlock {
    self = [super init];
    if (self) {
        
        self.dataSource = dataSource;
        self.selectBlock = selectBlock;
    }
    return self;
}


#pragma mark - <UICollectionViewDataSource>

//共有多少组
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

//每一组当中有多少个格子.
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _status.totalRows*_status.totalCols;
}

//每一个格子展示什么内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SZSquareCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    //想要在cell内容展示东西,必须得要自定义Cell.
    //内部没有自带的控件.
    cell.showNo = _showNo;
    cell.model = self.dataSource[indexPath.item];
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {


    //    与左右上下对比，如果是其中之一，就与白色方块交换；
    if ( [_status calculateIndexOfMoveable_left] == indexPath.item) {
        //    数据源交换
        [self nextStep:indexPath];

    } else if ( [_status calculateIndexOfMoveable_right] == indexPath.item) {

        [self nextStep:indexPath];

    } else if ( [_status calculateIndexOfMoveable_up] == indexPath.item) {

        [self nextStep:indexPath];

    } else if ( [_status calculateIndexOfMoveable_down] == indexPath.item) {

        [self nextStep:indexPath];

    }

}


- (void)nextStep:(NSIndexPath *)indexPath {

    [self.dataSource exchangeObjectAtIndex:indexPath.item withObjectAtIndex:_status.indexOfWhite];

    _status.indexOfWhite = indexPath.item;
    
    if (self.selectBlock) {
        self.selectBlock(indexPath);
    }
    
}


#pragma mark - <UICollectionViewDelegateFlowLayout>
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
     return CGSizeMake(collectionView.frame.size.width/_status.totalCols-0.01, collectionView.frame.size.height/_status.totalRows-0.01);
    
}

//定义每个UICollectionView 的边距

- ( UIEdgeInsets )collectionView:( UICollectionView *)collectionView layout:( UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:( NSInteger )section {
    
    return UIEdgeInsetsMake ( 0 , 0 , 0 , 0 );
    
}

//设置水平间距 (同一行的cell的左右间距）

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0;
    
}

//垂直间距 (同一列cell上下间距)

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0;
    
}


@end
