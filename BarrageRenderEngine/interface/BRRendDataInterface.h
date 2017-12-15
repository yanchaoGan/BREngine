//
//  BRRendDataInterface.h
//  yuyou
//
//  Created by ganyanchao on 14/09/2017.
//

#import <Foundation/Foundation.h>

/**< 动画类型。 */
typedef NS_ENUM(NSUInteger, BRRendAnimateType) {
    BRRendAnimateTypeRTL, //默认，从右到左 过场动画
    BRRendAnimateTypeCenterBreathe, //un implement 心跳动画
};


typedef NS_ENUM(NSUInteger, BRRendWeight) {
    BRRendWeightNormal, /**< FIFO*/
    BRRendWeightHigh,  /**< LIFO*/
};

/**< 动画元素 填充数据协议*/
@protocol BRRendDataInterface <NSObject>

@optional
- (BRRendWeight)BR_weight; /**< 数据显示权重。 影响添加缓存顺序*/

- (NSArray <NSNumber *> *)BR_bindLines; /**< 固定在画布某几行。  画布行数。默认|不实现：不固定*/

/* BR_bindLine  BR_rejectLine 返回的数字 不可相等， 实现了BR_bindLine，将忽略BR_rejectLine */
- (NSArray <NSNumber *> *)BR_rejectLines; /**< 排斥 画布中某几行。 默认 不排斥。*/


- (BOOL)BR_disBlockLine; /**< 出现之后，不阻塞画布某一行。默认阻塞。YES 不阻塞，NO 阻塞*/

@end
