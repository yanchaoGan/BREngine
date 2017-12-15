//
//  GrounderView.h
//  GrounderDemo
//


#import <UIKit/UIKit.h>
#import "BREngine.h"


typedef NS_ENUM(NSInteger, GrounderType) {
    GrounderTypeDefault = 0,    /**< 默认*/
    GrounderTypePublic,          /**< 全站广播,banner ,一些 ui 需要隐藏*/
    GrounderTypeText,           /**< 纯文本*/
    GrounderTypeGlobalNotify,   /**< 全局通知文本*/
};

@interface CustomElementView : UIView <BRElementInterface>

@property (nonatomic, assign) GrounderType type;/**< 类型*/

/**< 去显示这个弹幕*/
- (void)setContent:(id)model;       /**< 普通弹幕*/

/**< 用户点击了此弹幕*/
- (void)userClickAction;

@end
