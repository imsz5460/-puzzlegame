//
//  UIImage+tools.m
//  智能拼图
//
//  Created by Yjt on 2017/12/15.
//  Copyright © 2017年 shizhi. All rights reserved.
//

#import "UIImage+tools.h"

@implementation UIImage (tools)

/**
 *  从图片中按指定的位置大小截取图片的一部分
 *
 *
 *  @param rect  CGRect rect 要截取的区域
 *
 *  @return UIImage
 */
- (UIImage *)cutImageInRect:(CGRect)rect {
    
    //把像 素rect 转化为 点rect（如无转化则按原图像素取部分图片）
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat x= rect.origin.x*scale,y=rect.origin.y*scale,w=rect.size.width*scale,h=rect.size.height*scale;
    CGRect dianRect = CGRectMake(x, y, w, h);
    
    //截取部分图片并生成新图片
    CGImageRef sourceImageRef = [self CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, dianRect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    return newImage;
}


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

- (UIImage*)addTextToView:(NSString*)text {
    
    //设置字体样式
    
    UIFont*font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:20];
    
    NSDictionary*dict =@{NSFontAttributeName:font,NSForegroundColorAttributeName:[UIColor redColor]};
    
    CGSize textSize = [text sizeWithAttributes:dict];
    
    //绘制上下文
    
    UIGraphicsBeginImageContext(self.size);
    
    [self drawInRect:CGRectMake(0,0, self.size.width, self.size.height)];
    
    int border = 6;
    
    CGRect re = {CGPointMake(self.size.width- textSize.width- border, self.size.height- textSize.height- border), textSize};
    
    //此方法必须写在上下文才生效
    [text drawInRect:re withAttributes:dict];
    
    UIImage*newImage =UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

@end
