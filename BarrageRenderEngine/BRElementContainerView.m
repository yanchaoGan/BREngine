//
//  BRElementContainerView.m
//  yuyou
//
//  Created by ganyanchao on 12/09/2017.
//

#import "BRElementContainerView.h"

@interface BRElementContainerView ()

@property (nonatomic, assign) NSTimeInterval lastClickTime;

@end

@implementation BRElementContainerView

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

// 去重写这个有些问题
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    if (self.elementView == nil || self.elementView.hidden == YES || self.elementView.alpha <= 0.1) {
//        return nil;
//    }
//    //point 相对于 self.layer； 是已经结束动画的
//    //转为相对于 画布的
//    CGPoint canvasPoint = [self.layer convertPoint:point toLayer:self.superview.layer];
//    CGRect  canvasframe = self.layer.presentationLayer.frame; //相对于画布
//    BOOL contain = CGRectContainsPoint(canvasframe, canvasPoint);
//    if (contain) {
//        //转化为 被点击了 动画元素位置
//       CGPoint elementClick = [self.superview.layer  convertPoint:canvasPoint toLayer:self.layer.presentationLayer];
////        NSLog(@"touch- type %zi ,time %f, point %@, touch status %zi", event.type,event.timestamp,NSStringFromCGPoint(elementClick),[[event.allTouches.allObjects safeObjectAtIndex:0] phase]);
//        NSTimeInterval curtime = event.timestamp;
//        if (fabs(curtime - self.lastClickTime) <= 0.3) {
//            return  self.elementView; //时间间距太小
//        }
//        self.lastClickTime = event.timestamp;
//        return [self.elementView  hitTest:elementClick withEvent:event]; //不确定原因,被调用2次
//    }
//    else {
//        return [super hitTest:point withEvent:event]; //可能是nil,被调用多次
//    }
//
//}

@end
