//
//  UIImage+tools.h
//  智能拼图
//
//  Created by Yjt on 2017/12/15.
//  Copyright © 2017年 shizhi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (tools)
/**
 *  从图片中按指定的位置大小截取图片的一部分
 *
 *  @param rect  CGRect rect 要截取的区域
 *
 *  @return UIImage
 */
- (UIImage *)cutImageInRect:(CGRect)rect;

/**
 *  将文字添加到图片上
 *
 *
 *  @param text  NSString * text 要绘制的文字
 *
 *  @return UIImage
 */
//修改自 林同 的方法
//作者：林同
//链接：http://www.jianshu.com/p/10c072c1b4d7
//來源：简书
//著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

- (UIImage*)addTextToView:(NSString*)text;

@end
