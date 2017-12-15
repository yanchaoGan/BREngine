//
//  ViewController.m
//  Demo
//
//  Created by ganyanchao on 15/12/2017.
//  Copyright © 2017 G.Y. All rights reserved.
//

#import "ViewController.h"
#import "BREngine.h"
#import "CustomCanvasView.h"

@interface ViewController ()

@property (nonatomic, strong) CustomCanvasView *canvas;
@property (nonatomic, strong)  dispatch_source_t timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.canvas = [[CustomCanvasView alloc] initWithFrame:(CGRect){0,120,ScreenWidth,100}];
    [self.view addSubview:self.canvas];
    
    __block NSInteger index = 0;
    __block NSString *indexName = nil;
    @weakify(self);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_timer,  dispatch_walltime(NULL, 0), 0.1, 0);
    dispatch_source_set_event_handler(_timer, ^{
        @strongify(self);
        index += 1;
        indexName = [NSString stringWithFormat:@"我是%zi条弹幕",index];
        [self.canvas onNewBarrageComing:indexName];
    });
    dispatch_resume(_timer);
    
    self.view.backgroundColor = [UIColor blackColor];
}



@end
