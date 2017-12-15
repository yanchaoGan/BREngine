//
//  BRElement.h
//  yuyou
//
//  Created by ganyanchao on 12/09/2017.
//

#import <Foundation/Foundation.h>

typedef void(^layoutFinish)(void);


/**< 动画协议*/
@protocol BRElementInterface <NSObject>

@required
- (UIView *)BR_element; /**< 动画元素 */

/**< 可以在此处 异步线程处理 展示数据。 主线程回调 layoutFinish, must call finish*/
- (void)BR_batchResourceModel:(id)model finish:(layoutFinish)complete;

- (CGFloat)BR_width; /**< 动画元素 宽度， after batch*/

@optional
- (CGFloat)BR_duration; /**< 自定义 元素动画时长*/

/**< 当画布 发生frame 变化时候 || 或者其他需要刷新的事件，可能会被触发。
 已经在显示的元素 在这里可以 可以做一些额外操作*/
- (void)BR_updateLayout;


@end
