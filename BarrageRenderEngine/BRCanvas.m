//
//  BRCanvas.m
//  yuyou
//
//  Created by ganyanchao on 12/09/2017.
//

#import "BRCanvas.h"

@implementation BRCanvas


#pragma mark - Public



#pragma mark - BRCanvasInterface
- (UIView *)BR_canvas
{
    return self;
}
- (NSInteger)BR_numberLines /**< 画布 几行弹幕。 default 1*/
{
    return 3;
}

/**< 我们假设 元素 ，从上向下渲染。if yes, 将从下向上。*/
- (BOOL)BR_reversion
{
    return YES;
}

/**< num 从0开始。哪行先渲染，哪行就是0。 default 30*/
- (CGFloat)BR_heightInLineNum:(NSInteger)num
{
    return 30;
}

@end
