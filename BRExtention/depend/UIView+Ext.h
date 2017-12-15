//
//  UIView+Ext.h
//  69Show
//
//

#import <UIKit/UIKit.h>

@interface UIView (Ext)
CGRect  CGRectMoveToCenter(CGRect rect, CGPoint center);

@property CGPoint origin;
@property CGSize size;

@property (readonly) CGPoint bottomLeft;
@property (readonly) CGPoint bottomRight;
@property (readonly) CGPoint topRight;

@property CGFloat height;
@property CGFloat width;

@property CGFloat top;
@property CGFloat left;

@property CGFloat bottom;
@property CGFloat right;

- (void) moveBy: (CGPoint) delta;
- (void) scaleBy: (CGFloat) scaleFactor;
- (void) fitInSize: (CGSize) aSize;

-(void)autoResizeAllMask;
/**
 UIView背景渐变颜色
 
 @param colors 渐变颜色（必须是id类型）
 @param startPoint 渐变开始
 @param endPoint 渐变结束
 */
- (void)viewAddGradientRampWithColors:(NSArray *)colors rect:(CGRect)rect startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

/**
 UIView背景透明度渐变

 @param colors 渐变颜色（必须是id类型）
 @param startPoint 渐变开始
 @param endPoint 渐变结束
 */
- (void)viewAddAlphaGradientRampWithColors:(NSArray *)colors rect:(CGRect)rect startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

/**
 UIView添加圆角

 @param corners 圆角位置
 @param cornerRadii 圆角半角
 */
- (void)viewCirclePathByRoundingCorners:(UIRectCorner)corners corner:(CGSize)cornerRadii;
/**
 UIView添加圆角
 
 @param corners 圆角位置
 @param cornerRadii 圆角半角
 @param rect   控件frame
 */
- (void)viewCirclePathByRoundingCorners:(UIRectCorner)corners rect:(CGRect)rect corner:(CGSize)cornerRadii;
@end
