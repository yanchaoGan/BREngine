//
//  BREngine.h
//  yuyou
//
//  Created by ganyanchao on 12/09/2017.
//

#import <Foundation/Foundation.h>

#import "BRCanvasInterface.h"
#import "BRElementInterface.h"
#import "BRRendDataInterface.h"

/**< 
 弹幕渲染调度中心
 欢迎一起玩。加入实现
 */
@interface BREngine : NSObject

@property (nonatomic, strong, readonly) NSArray<id<BRElementInterface>> * animatingElements; /**< 正在显示的弹幕数组*/

/**< 默认使用 BRCanvas。自定义时候，赋值即可 */
@property (nonatomic, weak, readwrite) id<BRCanvasInterface> canvas; /**< 画布*/

/**< 默认使用 目前项目中 @see: GrounderView */
- (void)registerElementClass:(Class<BRElementInterface>)aclass; /**< 注册动画元素类*/

@property (nonatomic, assign, readwrite) NSTimeInterval duration; /**< 默认动画持续时长s : 6.0s。不影响自定义时长。*/

@property (nonatomic, assign, readwrite) NSTimeInterval checkDuration; /**< 检查屏幕显示弹幕 移动的位置，超过一半屏幕可以复用航道。timer. 默认0.3*/


/**< 弹幕数据模型 统一调度。 按需，batch 派发，有缓存策略*/
- (void)addBarrageResource:(id<BRRendDataInterface> _Nonnull )model; /**< 添加弹幕资源， 队尾*/

- (void)refreshCanvas; /**< 画布发生变化时，主动调用刷新。将触发
                        BR_updateLayout*/

@end
