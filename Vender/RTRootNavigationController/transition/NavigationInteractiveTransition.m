//
//  NavigationInteractiveTransition.m
//  InteractiveTransitionTest
//
//  Created by 曾凡旭 on 16/9/28.
//  Copyright © 2016年 youpin. All rights reserved.
//

#import "NavigationInteractiveTransition.h"
#import "PopAnimation.h"
#import "PushAnimation.h"

@interface NavigationInteractiveTransition()

@property (nonatomic, weak) UINavigationController *vc;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactivePopTransition;

@end

@implementation NavigationInteractiveTransition

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if(self){
        self.vc = (UINavigationController *)vc;
        self.vc.delegate = self;
    }
    return self;
}

- (void)handleControllerPop:(UIPanGestureRecognizer *)recognizer{
    CGFloat progress = [recognizer translationInView:recognizer.view].x / recognizer.view.bounds.size.width;

    /**
     *  稳定进度区间，让它在0.0（未完成）～1.0（已完成）之间
     */
    progress = MIN(1.0, MAX(0.0, progress));
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        /**
         *  手势开始，新建一个监控对象
         */
        self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        /**
         *  告诉控制器开始执行pop的动画
         */
        [self.vc popViewControllerAnimated:YES];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        /**
         *  更新手势的完成进度
         */
        [self.interactivePopTransition updateInteractiveTransition:progress];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        
        /**
         *  手势结束时如果进度大于一半，那么就完成pop操作，否则重新来过。
         */
        if (progress > 0.5) {
            [self.interactivePopTransition finishInteractiveTransition];
        }
        else {
            [self.interactivePopTransition cancelInteractiveTransition];
        }
        
        self.interactivePopTransition = nil;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    /**
     *  方法1中判断如果当前执行的是Pop操作，就返回我们自定义的Pop动画对象。
     */
    if (operation == UINavigationControllerOperationPop){
        return [[PopAnimation alloc] init];
    }
    else{
        return [PushAnimation new];
    }
    
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    
    /**
     *  方法2会传给你当前的动画对象animationController，判断如果是我们自定义的Pop动画对象，那么就返回interactivePopTransition来监控动画完成度。
     */
    if ([animationController isKindOfClass:[PopAnimation class]])
        return self.interactivePopTransition;
    
    return nil;
}


@end
