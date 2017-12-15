//
//  CustomCanvasView.m
//  Demo
//
//  Created by ganyanchao on 15/12/2017.
//  Copyright © 2017 G.Y. All rights reserved.
//

#import "CustomCanvasView.h"
#import "CustomElementView.h"

#import "BREngine.h"

@interface CustomCanvasView () <BRCanvasInterface>
{
    BREngine *_brengine;
}
@end

@implementation CustomCanvasView


- (void)dealloc
{
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        _brengine = [[BREngine alloc] init];
        _brengine.canvas = self;
        [_brengine registerElementClass:[CustomElementView class]];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}


#pragma mark - Public

/**< 普通弹幕 横幅数据都调用这个*/
- (void)onNewBarrageComing:(id)model
{
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [_brengine  addBarrageResource:model];
    });
}

#pragma mark - BRCanvasInterface
- (BOOL)BR_reversion {
    return NO;
}

- (UIView *)BR_canvas
{
    return self;
}

- (NSInteger)BR_numberLines /**< 画布 几行弹幕。 default 1*/
{
    return 3;
}

#pragma mark - Action
- (void)click:(UITapGestureRecognizer *)tapGesture
{
    CGPoint touchPoint = [tapGesture locationInView:self];
    
    NSArray <id<BRElementInterface>> *elements = _brengine.animatingElements;
    
    for (id<BRElementInterface> ele in elements) {
        if ([ele respondsToSelector:@selector(BR_element)] == NO) {
            continue;
        }
        UIView *view = [ele.BR_element superview]; //brcontainerView
        if (!view) {
            continue;
        }
        
        if ([view.layer.presentationLayer hitTest:touchPoint]) {
            CustomElementView *gv = ele.BR_element;
            if ([gv isKindOfClass:[CustomElementView class]]) {
                [gv userClickAction];
            }
            break;
        }
    }
}

@end
