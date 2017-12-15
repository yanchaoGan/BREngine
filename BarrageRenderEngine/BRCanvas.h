//
//  BRCanvas.h
//  yuyou
//
//  Created by ganyanchao on 12/09/2017.
//

#import <UIKit/UIKit.h>
#import "BRCanvasInterface.h"


@interface BRCanvas : UIView <BRCanvasInterface>

- (UIView *)BR_canvas;

/**< 我们假设 元素 ，从上向下渲染。if yes, 将从下向上。*/
- (BOOL)BR_reversion;

/**
 我们假设元素，均匀分割画布高度。
 @return
 */
- (NSInteger)BR_numberLines; /**< 画布 几行弹幕。 default 1*/


/**< num 从0开始。哪行先渲染，哪行就是0。 default 30*/
- (CGFloat)BR_heightInLineNum:(NSInteger)num;


@end
