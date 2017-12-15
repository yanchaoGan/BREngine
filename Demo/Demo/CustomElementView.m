//
//  GrounderView.m
//  GrounderDemo
//

#import "CustomElementView.h"

@interface CustomElementView()
{
    float viewWidth;
    UILabel *_messageLabel;
}
@end

@implementation CustomElementView

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        /**< 消息*/
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.font = [UIFont boldSystemFontOfSize:14];
        _messageLabel.clipsToBounds = YES;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_messageLabel];
    }
    return self;
}


#pragma mark -  Layout
//不同弹幕
- (void)setContent:(id)model
{
    [self setTextModel:model];
}


/**< 只显示文本*/
- (void)setTextModel:(id)model
{
    NSString *body = [NSString stringWithFormat:@"%@",model];
    _messageLabel.text = body;
    _messageLabel.textColor = [UIColor whiteColor];
    _messageLabel.font = [UIFont systemFontOfSize:16];
    //计算文字宽度
    _messageLabel.frame = CGRectMake(5, 6, 130, 20);
    viewWidth = _messageLabel.frame.size.width + 10;
    
    self.frame = CGRectMake(0, 0, viewWidth, 30);
}


#pragma mark - Action
- (void)userClickAction
{
    
}

#pragma mark - BRElementInterface
/**< 动画元素 */
- (UIView *)BR_element
{
    return self;
}
/**< 可以在此处 异步线程处理 展示数据。 主线程回调 layoutFinish, must call finish*/
- (void)BR_batchResourceModel:(id)model finish:(layoutFinish)complete
{
    if ([model isKindOfClass:[NSString class]]) {
        self.hidden = NO;
        [self setContent:model];
    }
    else {
        self.hidden = YES;
    }
    complete();
}

/**< 动画元素 宽度， after batch*/
- (CGFloat)BR_width
{
    return  viewWidth;
}

- (void)BR_updateLayout
{
    // 可以去检查新的东西 和 回调了
}

#pragma mark - Getter Setter
- (void)setType:(GrounderType)type
{
    if (_type == type) {
        return;
    }
    _type = type;
}

@end
