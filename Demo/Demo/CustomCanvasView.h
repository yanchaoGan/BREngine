//
//  CustomCanvasView.h
//  Demo
//
//  Created by ganyanchao on 15/12/2017.
//  Copyright © 2017 G.Y. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCanvasView : UIView

/**< 收到一个弹幕model*/
- (void)onNewBarrageComing:(id)model;

@end
