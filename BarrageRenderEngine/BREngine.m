//
//  BREngine.m
//  yuyou
//
//  Created by ganyanchao on 12/09/2017.
//

#import "BREngine.h"
#import "BRCanvas.h"
#import "BRElementContainerView.h"
#import <objc/runtime.h>


static const int LineNum_key;  /**< 行号*/
static const int EleDataModel_key; /**< 元素 data*/

@interface BREngine ()
{
    //    NSMutableArray <id<BRElementInterface>> * _elementReuseQueue; /**< 已经消失可以复用的 弹幕元素*/  //复用没什么意义
    //
    //    NSMutableArray<BRElementContainerView *> * _elementContainerReuseQueue;/**< 已经消失可以复用的 弹幕元素容器*/
    
    NSMutableArray<id<BRElementInterface>> *_showingQueue; /**< 正在展示的 弹幕元素*/
    
    NSMutableArray<id<BRRendDataInterface>> *_waitingQueue; /**< 等待中的弹幕数据model*/
    
    BOOL _reversion; /**< YES, 从下到上排，NO，从上到下数*/
    
    NSTimer * _checkTimer; /**< 枚举遍历显示数组, 每0.3秒 检查一次是否有可用行*/
    
    NSInteger _lineMark ;  /**< 1 << 1 */
    
    NSMutableArray<NSNumber *> * _lineHeight; /**< 行高数组*/
    
    Class<BRElementInterface> _aEleClass;
    __weak id<BRCanvasInterface> _canvas;
    
    id<BRCanvasInterface> _canvasDefault;
}

@property (nonatomic, assign) NSInteger lineCount; /**< 行数*/


@end




@implementation BREngine

- (void)dealloc
{
    NSLog(@"%s",__func__);
    [self stopCheckTimer];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configInit];
    }
    return self;
}

#pragma mark - Life Cycle
- (void)configInit
{
    _showingQueue = [@[] mutableCopy];
    _waitingQueue = [@[] mutableCopy];
    _lineHeight = [@[] mutableCopy];
    
    _checkDuration = 0.3;
}

#pragma mark - Public
- (NSArray *)animatingElements
{
    return [_showingQueue copy];
}

/**< 弹幕数据模型 统一调度。 按需，batch 派发，有缓存策略*/
- (void)addBarrageResource:(id<BRRendDataInterface> _Nonnull )model
{
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (_waitingQueue.count > MAXGrounderSuperViewCount) {
            //太多了。抛弃其中100
            [_waitingQueue removeObjectsInRange:NSMakeRange(500, 100)];
        }
        
        BRRendWeight weight = BRRendWeightNormal;
        if ([model respondsToSelector:@selector(BR_weight)]) {
            weight = [model BR_weight];
        }
        if (weight == BRRendWeightNormal) {
            [_waitingQueue addObject:model];
        }
        else {
            [_waitingQueue insertObject:model atIndex:0];
        }
        [self patchResourceModel];
    });
}

- (void)refreshCanvas /**< 画布发生变化时，主动调用刷新。将触发
                       BR_updateLayout*/
{
    
    [_showingQueue enumerateObjectsUsingBlock:^(id<BRElementInterface>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if([obj respondsToSelector:@selector(BR_updateLayout)]) {
            [obj BR_updateLayout];
        }
    }];
}

- (void)registerElementClass:(Class<BRElementInterface>)aclass/**< 注册动画元素类*/
{
    _aEleClass = aclass;
}


#pragma mark - Private
- (void)patchResourceModel /**< can overwrite*/
{
    NSArray<NSNumber *> *canUseLines = [self findCurrentCanUseLines];
    if (canUseLines.count <= 0 ) {
        return;
    }
    @weakify(self);
    [canUseLines enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        [self dealCanUseLine:[obj integerValue]];
    }];
}

- (void)dealCanUseLine:(NSInteger)line
{
    if (line < 0 || line > _lineCount ) {
        return;
    }
    
    id<BRRendDataInterface> dataModel = [self readDataFitLine:line];
    if (!dataModel) {
        return; //没有可适配 data model
    }
    
    //处理一个element 元素
    id<BRElementInterface> element = [self  dequeueReusableElement];
    UIView *elementView = element.BR_element;
    
    //生成一个弹幕容器
    BRElementContainerView *containerView = [self readReuseContainerView];
    containerView.lineNum = line;
    containerView.elementView = elementView;
    
    if ([elementView isKindOfClass:[UIView class]] == NO || containerView == nil) {
        return;
    }
    
    [self  bindLine:line toElement:element];
    // 将其添加到 showing 队列
    [_showingQueue addObject:element];
    
    //立即将航道标记为不可用
    BOOL dis = NO;
    if ([dataModel respondsToSelector:@selector(BR_disBlockLine)]) {
        dis = [dataModel BR_disBlockLine];
    }
    if (dis == NO) {
        [self markLineUnableUse:line];
    }
    
    //todo container layout
    [self  startCheckTimer];
    
    @weakify(self);
    [element BR_batchResourceModel:dataModel finish:^{
        @strongify(self);
        [self normalWalkAnimateLayout:element withElementView:elementView toContainerView:containerView inLine:line];
    }];

}

- (void)checkShowingElement //can overrite
{
    /**< 检查航道是否可用。
     我们认为，任何一个航道，只要有一个element，刚开始，都不可用
     刚开始定位为：elment 元素 frame.x > 1/2(canvas width)
     */
    if (!(_showingQueue.count > 0 || _waitingQueue.count > 0)) {
        [self stopCheckTimer];
        return;
    }
    
    UIView *canvas = self.canvas.BR_canvas;
    
    //默认每行都可用了
    NSMutableDictionary *markDic = [@{} mutableCopy];
    /*key number, value bool*/
    
    [_showingQueue enumerateObjectsUsingBlock:^(id<BRElementInterface>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        BRElementContainerView *cv = (BRElementContainerView *)obj.BR_element.superview;
        if (!cv) {
            //刚添加到跑道，还没渲染出来
            //需要将其跑道标记为不可用
            NSInteger lineNum = [self elementLineNum:obj];
            markDic[@(lineNum)] = @(1);
        }
        else if (cv.layer.presentationLayer){
            //在动画过程中
            CGRect frame = cv.layer.presentationLayer.frame;
            if (frame.origin.x > canvas.width/2.0) {
                //认为此航道不可用
                NSInteger line = cv.lineNum;
                markDic[@(line)] = @(1);
            }
        }
        else {
            //动画已经结束
        }
    }];
    
    //针对所有航道标记可用状态、非可用状态
    for (int i = 0; i < _lineCount; i++) {
        
        NSNumber *markUnable = [markDic objectForKey:@(i)];
        if (markUnable) {
            [self markLineUnableUse:i];
        }
        else {
            [self markLineIdle:i];
        }
    }
    
    //有可用行道, 就去派发弹幕
    if (markDic.count < _lineCount) {
        [self patchResourceModel];
    }
}

#pragma mark - Extension Layout

- (void)normalWalkAnimateLayout:(id<BRElementInterface>)element
                withElementView:(UIView *)elementView
                toContainerView:(BRElementContainerView *)containerView
                         inLine:(NSInteger)line /**< 普通从右到左 过场动画*/
{
    [containerView  addSubview:elementView]; /**< 添加元素到容器*/
    
    CGRect eleframe = elementView.frame;
    eleframe.origin = CGPointZero;
    elementView.frame = eleframe;
    
    UIView *cavas = self.canvas.BR_canvas;
    [cavas addSubview:containerView]; /**< 添加容器到画布*/
    
    CGFloat bottom = [self disBottomCanvasLine:line];
    CGFloat width = element.BR_width;
    CGFloat height = eleframe.size.height;
    
    
    if (cavas == nil) { //被释放掉
        return;
    }
    __block MASConstraint *leftConstraint;
    //left var
    [containerView  mas_makeConstraints:^(MASConstraintMaker *make) {
        leftConstraint = make.left.equalTo(cavas.mas_right);
        make.bottom.equalTo(cavas).offset(-bottom);
        make.width.equalTo(@(width));
        make.height.equalTo(@(height));
    }];
    
    [cavas  layoutIfNeeded];
    CGFloat dura = self.duration;
    if ([element respondsToSelector:@selector(BR_duration)]) {
        dura = element.BR_duration;
    }
    //must in main thread
    [UIView animateWithDuration:dura delay:0 options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction  animations:^{
        [leftConstraint uninstall];
        [containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cavas.mas_left).offset(-width);
        }];
        [cavas layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        [self removeShowingElement:element];
    }];
    
}


#pragma mark - Helper

//当前可用所有line
- (NSArray <NSNumber *> *)findCurrentCanUseLines
{
    BOOL findOnce = YES;
    //我们认为累计到一定时候,需要批量遍历
    if (_waitingQueue.count > _lineCount * 3) {
        findOnce = NO;
    }
    NSMutableArray<NSNumber *> *lineArr = [@[] mutableCopy];
    for (int i = 0; i < _lineCount; i ++) {
        BOOL can = [self lineCanUse:i];
        if (can) {
            [lineArr addObject:@(i)];
            if (findOnce) {
                break;
            }
        }
    }
    return  lineArr;
}

- (id<BRRendDataInterface>)readDataFitLine:(NSInteger)toFitLine
{
    //每次尽可能查找一个可用datamodel 填充
    __block id<BRRendDataInterface> dataModel = nil;
    __block short step = 0; /**< 最多走5步，防止无穷遍历.*/
    __block BOOL isFit = NO;
    __block BOOL arrayMatch = NO;
    @weakify(self);
    [_waitingQueue enumerateObjectsUsingBlock:^(id<BRRendDataInterface>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        isFit = YES; //默认适合
        //如果制定了绑定
        if ([obj respondsToSelector:@selector(BR_bindLines)]) {
            NSArray<NSNumber *> *bindArr = [obj BR_bindLines];
            arrayMatch = NO;
            [bindArr enumerateObjectsUsingBlock:^(NSNumber * _Nonnull bindLine, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([bindLine integerValue] == toFitLine) {
                    *stop = YES;
                    arrayMatch = YES;
                }
            }];
            if (arrayMatch == NO) {
                isFit = NO;
            }
        }
        //如果制定了排斥
        else if ([obj respondsToSelector:@selector(BR_rejectLines)]) {
            NSArray<NSNumber *> *rejectArr = [obj BR_rejectLines];
            arrayMatch = NO;
            [rejectArr enumerateObjectsUsingBlock:^(NSNumber * _Nonnull rejectLine, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([rejectLine integerValue] == toFitLine) {
                    *stop = YES;
                    arrayMatch = YES;
                }
            }];
            if (arrayMatch == YES) {
                isFit = NO;
            }
        }
        
        if (isFit) {
            //找到了 立即停止
            *stop = YES;
            dataModel = obj;
        }
        else {
            step += 1;
            if (step >= 5) {
                *stop = YES;
                //真的都找不可适应的data
            }
        }
    }];
    
    [_waitingQueue removeObject:dataModel];
    return dataModel;
}

- (void)exeInMainThreadBlock:(dispatch_block_t)block
{
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

- (nullable id<BRElementInterface>)dequeueReusableElement /**< */
{
    id<BRElementInterface> element = [[[_aEleClass class] alloc] init];
    return element;
}

/**< 按照顶部对齐， 距离画布顶部*/
- (CGFloat)disTopCanvasLine:(NSInteger)line
{
    CGFloat height = 0.0;
    if (_reversion) {
        for (int i = line + 1; i < _lineCount; i++) {
            height += [_lineHeight[i] floatValue];
        }
    }
    else {
        for (int i = 0; i < line; i ++) {
            height += [_lineHeight[i] floatValue];
        }
    }
    return height;
}

/**< 按照底部对其， 距离画布底部*/
- (CGFloat)disBottomCanvasLine:(NSInteger)line
{
    CGFloat height = 0.0;
    if (_reversion) {
        for (int i = 0; i < line; i ++) {
            height += [_lineHeight[i] floatValue];
        }
    }
    else {
        for (int i = line +1; i < _lineCount; i++) {
            height += [_lineHeight[i] floatValue];
        }
    }
    return height;
}


/**< 0 可用， 1 不可用*/
- (void)markLineIdle:(NSInteger)lineNum
{
    _lineMark &=  ~(1<<lineNum);
}

/**< 标记此航道 处于繁忙状态，不可用*/
- (void)markLineUnableUse:(NSInteger)lineNum
{
    _lineMark |= (1<<lineNum);
}

- (BOOL)lineCanUse:(NSInteger)lineNum
{
    return  (_lineMark & (1<<lineNum)) == 0;
}


- (void)removeShowingElement:(id<BRElementInterface>)ele
{
    BRElementContainerView *eleContainerView = ele.BR_element.superview;
    [ele.BR_element removeFromSuperview];
    [eleContainerView removeFromSuperview];
    [_showingQueue removeObject:ele];
}

- (nonnull BRElementContainerView *)readReuseContainerView
{
    BRElementContainerView *view = [[BRElementContainerView alloc] init];
    return view;
}



#pragma mark Check Timer
- (void)startCheckTimer
{
    if ([_checkTimer isValid]) {
        return;
    }
    @weakify(self);
    NSTimeInterval val = self.checkDuration;
    _checkTimer = [NSTimer scheduledTimerWithTimeInterval:val block:^(NSTimer * _Nonnull timer) {
        @strongify(self);
        [self checkShowingElement];
    } repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_checkTimer forMode:NSRunLoopCommonModes];
}

- (void)stopCheckTimer
{
    [_checkTimer invalidate];
}





#pragma mark - Getter Setter

- (void)bindLine:(NSInteger)num toElement:(id<BRElementInterface>)ele
{
    //添加行号
    objc_setAssociatedObject(ele, &LineNum_key, @(num), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSInteger)elementLineNum:(id<BRElementInterface>)ele
{
    NSNumber *line = objc_getAssociatedObject(ele, &LineNum_key);
    return [line  integerValue];
}

- (void)bindDataModel:(id)dataModel toElement:(id<BRElementInterface>)ele
{
    //添加元素
    objc_setAssociatedObject(ele, &EleDataModel_key, dataModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)elementDataModel:(id<BRElementInterface>)ele
{
    id dataModel = objc_getAssociatedObject(ele, &EleDataModel_key);
    return dataModel;
}


- (void)setCanvas:(id<BRCanvasInterface>)canvas
{
    _canvas = canvas;
    [self setNumLine];
}

- (id<BRCanvasInterface>)canvas
{
    if (!_canvas) {
        _canvasDefault = [[BRCanvas alloc] init];
        _canvas = _canvasDefault;
        [self setNumLine];
    }
    return _canvas;
}

- (void)setNumLine
{
    if (_lineCount == 0) {
        if ([_canvas respondsToSelector:@selector(BR_numberLines)]) {
            _lineCount = _canvas.BR_numberLines;
        }
        _lineCount = _lineCount?:1;
        _reversion = YES;
        if ([_canvas respondsToSelector:@selector(BR_reversion)]) {
            _reversion = [_canvas BR_reversion];
        }
        
        for (int i = 0; i < _lineCount; i ++) {
            CGFloat height = 30;
            if([_canvas respondsToSelector:@selector(BR_heightInLineNum:)]) {
                height = [_canvas BR_heightInLineNum:i];
            };
            [_lineHeight addObject:@(height)];
        }
    }
}

- (NSTimeInterval)duration
{
    if (_duration == 0.0) {
        return 6.0;
    }
    return _duration;
}

@end
