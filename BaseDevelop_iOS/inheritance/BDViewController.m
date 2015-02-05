//
//  BDViewController.m
//  BaseDevelop
//
//  Created by leikun on 15-2-3.
//  Copyright (c) 2015年 leikun. All rights reserved.
//

#import "BDViewController.h"
#import "UIView+Util.h"
#import "BDCommonUtil.h"
#import "BDViewControllerCommonConfig.h"

static BOOL BDVCIsPresentAndDismissAnimated = NO;

@interface BDViewController () {
    BDViewControllerCommonConfig *_commonConfig;
}

@end

@implementation BDViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // init common config for view controller
        _commonConfig = [[BDViewControllerCommonConfig alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


#pragma mark
#pragma mark - push method
- (void)willPush:(BDViewController *)pushedViewController animated:(BOOL)animated {
    
}

- (void)didPush:(BDViewController *)pushedViewController animated:(BOOL)animated {
    
}

- (void)willPushedBy:(BDViewController *)pushingViewController animated:(BOOL)animated {
    
}

- (void)didPushedBy:(BDViewController *)pushingViewController animated:(BOOL)animated {
    
}

#pragma mark
#pragma mark - pop method
- (void)willPopTo:(BDViewController *)pushingViewController animated:(BOOL)animated {
    
}

- (void)didPopTo:(BDViewController *)pushingViewController animated:(BOOL)animated {
    
}

- (void)willPopFrom:(BDViewController *)pushedViewController animated:(BOOL)animated {
    
}

- (void)didPopFrom:(BDViewController *)pushedViewController animated:(BOOL)animated {
    
}

#pragma mark
#pragma mark - present method
- (void)willPresent:(BDViewController *)presentedViewController animated:(BOOL)animated {
    
}

- (void)didPresent:(BDViewController *)presentedViewController animated:(BOOL)animated {
    
}

- (void)willPresentedBy:(BDViewController *)presentingViewController animated:(BOOL)animated {
    
}

- (void)didPresentedBy:(BDViewController *)presentingViewController animated:(BOOL)animated {
    
}

#pragma mark
#pragma mark - dismiss method
- (void)willDismissTo:(BDViewController *)presentingViewController animated:(BOOL)animated {
    
}

- (void)didDismissTo:(BDViewController *)presentingViewController animated:(BOOL)animated {
    
}

- (void)willDismissedFrom:(BDViewController *)dismissedViewController animated:(BOOL)animated {
    
}

- (void)didDismissedFrom:(BDViewController *)dismissedViewController animated:(BOOL)animated {
    
}

#pragma mark
#pragma mark - statusBar
- (void)setStatusBarHidden:(BOOL)hidden {
    [self setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationNone];
}

- (void)setStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation {
    _commonConfig.isStatusBarHidden = hidden;
    [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animation];
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    [self setStatusBarStyle:statusBarStyle animated:NO];
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated {
    _commonConfig.statusBarStyle = statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle animated:animated];
}

#pragma mark
#pragma mark - override present && dismiss method
- (UIViewController *)getTopViewControllerOrSelfFromNavigationController:(UIViewController *)navigation {
    if ([navigation isKindOfClass:UINavigationController.class]) {
        return [((UINavigationController *)navigation) topViewController];
    } else {
        return navigation;
    }
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    UIViewController *topVC = self.presentedViewController ?[self getTopViewControllerOrSelfFromNavigationController:[[self presentedViewControllers] lastObject]]: self;
    UIViewController *bottomVC = self.presentedViewController ? self :[self getTopViewControllerOrSelfFromNavigationController:self.presentingViewController];
    
    BDViewController *fromVC = ChangeToBDViewController(topVC);
    BDViewController *toVC = ChangeToBDViewController(bottomVC);
    
    [fromVC willDismissTo:toVC animated:flag];
    [toVC willDismissedFrom:fromVC animated:flag];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [fromVC didDismissTo:toVC animated:flag];
        [toVC didDismissedFrom:fromVC animated:flag];
    }];
    [self dismissViewControllerDirectlyAnimated:flag completion:completion];
    [CATransaction commit];
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    BDViewController *fromVC = nil;
    BDViewController *toVC = nil;
    if (viewControllerToPresent && ![[self presentedViewControllers] containsObject:viewControllerToPresent] && self != viewControllerToPresent && self.navigationController != viewControllerToPresent) {
        fromVC = self;
        toVC = ChangeToBDViewController([self getTopViewControllerOrSelfFromNavigationController:viewControllerToPresent]);
    }
    
    [fromVC willPresent:toVC animated:flag];
    [toVC willPresentedBy:fromVC animated:flag];
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [fromVC didPresent:toVC animated:flag];
        [toVC didPresentedBy:fromVC animated:flag];
    }];
    [self presentViewControllerDirectly:viewControllerToPresent animated:flag completion:completion];
    [CATransaction commit];
}

- (void)dismissViewControllerDirectlyAnimated:(BOOL)flag completion:(void (^)(void))completion {
    if (flag && SystemVersionHigherThanOrEqualTo(@"8.0") && ([[self presentedViewControllers] count] > 1)) {
        UIViewController *topPresentedViewController = [[self presentedViewControllers] lastObject];
        UIView *topPresentedView = [topPresentedViewController.view getSnapshotView];
        [self.presentedViewController.view addSubview:topPresentedView];
    }
    
    if (BDVCIsPresentAndDismissAnimated) {
        NSAssert(NO, @"Application tried to dismiss a modal view controller while a presentation or dismiss is in progress!");
        return;
    }
    
    BDVCIsPresentAndDismissAnimated = YES;
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        BDVCIsPresentAndDismissAnimated = NO;
    }];
    [super dismissViewControllerAnimated:flag completion:completion];
    [CATransaction commit];
}

- (void)presentViewControllerDirectly:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if (viewControllerToPresent == nil) {
        NSAssert(NO, @"Application tried to present a nil modal view controller on target %@", self);
        return;
    }
    
    if (BDVCIsPresentAndDismissAnimated) {
        NSAssert(NO, @"Application tried to present a modal view controller while a presentation or dismiss is in progress!");
        return;
    }
    
    //if viewControllerToPresent have been presented, return
    if ([[self presentedViewControllers] containsObject:viewControllerToPresent] || self == viewControllerToPresent || self.navigationController == viewControllerToPresent) {
        NSAssert(NO, @"Application tried to present modally an active controller %@", viewControllerToPresent);
        return;
    }
    
    BDVCIsPresentAndDismissAnimated = YES;
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        BDVCIsPresentAndDismissAnimated = NO;
    }];
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
    [CATransaction commit];
}

- (NSArray *)presentedViewControllers {
    NSMutableArray *presentedVCs = [NSMutableArray array];
    
    for (UIViewController *presentedVC = self.presentedViewController; presentedVC != nil; presentedVC = presentedVC.presentedViewController) {
        [presentedVCs addObject:presentedVC];
    }
    if (presentedVCs.count) {
        return presentedVCs;
    } else {
        return nil;
    }
}

- (NSArray *)presentingViewControllers {
    NSMutableArray *presentingVCs = [NSMutableArray array];
    
    for (UIViewController *presentingVC = self.presentingViewController; presentingVC != nil; presentingVC = presentingVC.presentingViewController) {
        [presentingVCs addObject:presentingVC];
    }
    if (presentingVCs.count) {
        return presentingVCs;
    } else {
        return nil;
    }
}

@end
