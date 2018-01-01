//
//  ViewController.m
//  智能拼图
//
//  Created by shizhi on 2017/12/6.
//  Copyright © 2017年 shizhi. All rights reserved.
//

#import "ViewController.h"
#import "SZSquareCell.h"
#import "UIImage+tools.h"
#import "JXAStarSearcher.h"
#import "PiecesStatus.h"
#import "SZcollectionViewDelegate.h"
#import "SZSquareModel.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *originalImg;
@property (weak, nonatomic) IBOutlet UIView *whiteBlock;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *whiteBlock_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *whiteBlock_height;
@property (weak, nonatomic) IBOutlet UITextField *rowTF;
@property (weak, nonatomic) IBOutlet UITextField *colTF;
@property (weak, nonatomic) IBOutlet UIButton *autoGaming;
@property (strong, nonatomic) NSMutableArray *cellDataSource;

@property (assign, nonatomic) BOOL showNo;//显示编号
@property (assign, nonatomic) BOOL isAutoGaming;//是否正在拼图

@property (strong, nonatomic) NSTimer *timer;
#pragma mark - 状态
/// 当前游戏状态
@property (nonatomic, strong) PiecesStatus *currentStatus;
/// 完成时的游戏状态
@property (nonatomic, strong) PiecesStatus *completedStatus;

@property (strong, nonatomic) NSMutableArray <PiecesStatus *>*path;
@property (strong, nonatomic) JXPathSearcher *searcher;
@property (strong, nonatomic)  SZcollectionViewDelegate *collectionViewDelegate;


@end

@implementation ViewController

NSInteger totalCols = 4;
NSInteger totalRows = 4;


- (void)viewDidLoad {
    [super viewDidLoad];
   
    //初始某些操作
    [self initialSth];
 
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.whiteBlock_width.constant = self.originalImg.frame.size.width/totalCols;
    self.whiteBlock_height.constant = self.originalImg.frame.size.height/totalRows;

}

#pragma mark -初始设置
- (void)initialSth {
    
    if (self.rowTF.text.length) {
        totalRows = [self.rowTF.text  integerValue];
    }
    if (self.colTF.text.length) {
        totalCols = [self.colTF.text integerValue];
    }
    
    self.whiteBlock_width.constant = self.originalImg.frame.size.width/totalCols;
    self.whiteBlock_height.constant = self.originalImg.frame.size.height/totalRows;
    
    _currentStatus = [PiecesStatus statusWithCols:totalCols Rows:totalRows image:self.originalImg.image];
    _completedStatus = [_currentStatus copyStatus];
//  打乱图块
    self.cellDataSource = [_currentStatus disorganize];
//  设置代理
    [self  collectionViewDelegate];
    
    self.collectionViewDelegate.status = [_currentStatus copyStatus];    
}

#pragma mark -collectionViewDelegate
- (SZcollectionViewDelegate *)collectionViewDelegate {
    if (_collectionViewDelegate == nil) {
        _collectionViewDelegate = [SZcollectionViewDelegate createCollectionViewDelegateWithDataSource: self.cellDataSource selectBlock:^(NSIndexPath *indexPath) {
            NSLog(@"点击了%ld行cell", (long)indexPath.row);
            _currentStatus.indexOfWhite = indexPath.item;
            _currentStatus.pieceArrayModel = self.cellDataSource;
            _currentStatus.pieceArray =  _currentStatus.currentIndexs ;
            
            //自动拼图暂停后如果手动拼图要重置
            [self resetAutoGaming];

            [self.collectionView reloadData];
            
            if ([_currentStatus isSuccess: self.cellDataSource]) {
                [self showAlert:@"恭喜！你牛逼啊"];
            } ;
        }];
        
        self.collectionView.delegate = _collectionViewDelegate;
        self.collectionView.dataSource = _collectionViewDelegate;
    }
    return _collectionViewDelegate;
}



-(void) resetAutoGaming {
    _searcher = nil;
    [_timer invalidate];
    _timer = nil;
}


#pragma mark -searcher

-(JXPathSearcher *)searcher {
    if (_searcher == nil) {
        _searcher = [[JXAStarSearcher alloc] init];
        
        _searcher.startStatus = [self.currentStatus copyStatus];
        _searcher.targetStatus = [self.completedStatus copyStatus];
        
        [_searcher setEqualComparator:^BOOL(PiecesStatus *status1, PiecesStatus *status2) {
            
            return [status1 equalWithStatus:status2];
        }];
       
    }
    return _searcher;
}

#pragma mark -自动拼图
- (IBAction)help:(UIButton *)sender {

    if ([_currentStatus isSuccess: self.cellDataSource]) {
        return;
    }

    if (_isAutoGaming) {
        [sender setTitle:@"自动拼图" forState:0];
        [_timer setFireDate:[NSDate distantFuture]];
         _isAutoGaming = !_isAutoGaming;
        return;
    } else {
        [sender setTitle:@"暂停" forState:0];
        [_timer setFireDate:[NSDate date]];
    }
    
    
    if (self.currentStatus.indexOfWhite < 0) {
        return;
    }

    
    if (!_searcher) {
        
        // 开始搜索
        NSDate *startDate = [NSDate date];
        _path = [self.searcher search];
        
        NSInteger pathCount = _path.count;
        NSLog(@"耗时：%.3f秒", [[NSDate date] timeIntervalSince1970] - [startDate timeIntervalSince1970]);
        NSLog(@"需要移动：%@步", @(pathCount));
        if (!_path || pathCount == 0) {
            return  ;
        }
        
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(timerAction:) userInfo:sema repeats:YES];
//        _timer = [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:YES block:^(NSTimer * _Nonnull timer) {
//            dispatch_semaphore_signal(sema);
//        }];
        
                      // 开始自动拼图
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [_path enumerateObjectsUsingBlock:^(PiecesStatus * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
 
                        // 等待信号
                        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
                        // 刷新UI
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // 显示排列

                            [self.cellDataSource removeAllObjects];
                            [obj.pieceArrayModel enumerateObjectsUsingBlock:^(SZSquareModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                [self.cellDataSource addObject: obj];
                                
                            }];
                            self.collectionViewDelegate.status.indexOfWhite = obj.indexOfWhite;
                            _currentStatus = [obj copyStatus];
                            
                            NSLog(@"xxxxxxxx-----%lu",(unsigned long)idx);
                            [self.collectionView reloadData];
        
                        });
                    }];
        
                    // 拼图完成
                    [_timer invalidate];
                    _searcher = nil;
                    self.currentStatus = [_path lastObject];
                    self.isAutoGaming = NO;
               
        
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [sender setTitle:@"自动拼图" forState:0];
                    });
        
                });
    }
    _isAutoGaming = !_isAutoGaming;
  
}

-(void)timerAction:(id)sender  {
 dispatch_semaphore_signal([sender userInfo]);
}

#pragma mark -重来一盘
- (IBAction)reStart:(UIButton *)sender {
   [self.autoGaming setTitle: @"自动拼图" forState:0];
    [self resetAutoGaming];

    if (self.isAutoGaming) {
        _isAutoGaming = NO;
     }

    _collectionViewDelegate = nil;
  
    totalRows = 4;
    totalCols = 4;
    
    [self initialSth];
    self.collectionViewDelegate.showNo = _showNo;
    [self.collectionView reloadData];
}

#pragma mark -显示编号
- (IBAction)showBlockNo:(id)sender {
    
    _showNo = !_showNo;
    self.collectionViewDelegate.showNo = _showNo;
     [self.collectionView reloadData];
}

#pragma mark - 提示框
- (void)showAlert:(NSString *)text {
    //显示提示框
   
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:text
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //响应事件
                                                              NSLog(@"action = %@", action);
                                                          }];

    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
