//
//  SZcollectionViewDelegate.h
//  智能拼图
//
//  Created by Yjt on 2017/12/27.
//  Copyright © 2017年 shizhi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class PiecesStatus;
typedef void (^selectCell) (NSIndexPath *indexPath);
@interface SZcollectionViewDelegate : NSObject<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) PiecesStatus *status;
@property (nonatomic, assign) BOOL showNo;
/**
 *  创建代理对象实例，并将数据列表传进去
 *  代理对象将消息传递出去，是通过block的方式向外传递消息的
 *  @return 返回实例对象
 */
+ (instancetype)createCollectionViewDelegateWithDataSource:(NSArray *)dataSource
                                        selectBlock:(selectCell)selectBlock;



@end
