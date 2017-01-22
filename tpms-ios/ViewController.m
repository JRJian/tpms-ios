//
//  ViewController.m
//  tpms-ios
//
//  Created by ttonway on 2017/1/12.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import "ViewController.h"

#import "Common.h"

UIEdgeInsets UIEdgeInsetsOffset(UIEdgeInsets insets, CGFloat dx, CGFloat dy) {
    insets.left += dx;
    insets.right -=dx;
    insets.top += dy;
    insets.bottom -= dy;
    return insets;
}

@interface ViewController () {
    NSArray *tabButtons;
}

@end

@implementation ViewController
@synthesize currentController = _currentController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    tabButtons = @[self.monitorButton, self.learnButton, self.exchangeButton,
                   self.settingButton];
    NSInteger index = 0;
    for (UIButton *button in tabButtons) {
        [button setTitleColor:[UIColor commonGreenColor] forState:UIControlStateSelected];
        UIImage *image = button.currentImage;
        UIImage *selectedImage = [image imageWithColor:[UIColor commonGreenColor]];
        [button setImage:selectedImage forState:UIControlStateSelected];
        
        index++;
    }
    [self.monitorButton setBackgroundImage:[UIImage imageNamed:@"tab_background_bottom"] forState:UIControlStateSelected];
    [self.learnButton setBackgroundImage:[UIImage imageNamed:@"tab_background_bottom"] forState:UIControlStateSelected];
    [self.exchangeButton setBackgroundImage:[UIImage imageNamed:@"tab_background_bottom"] forState:UIControlStateSelected];
    self.learnButton.hidden = YES;
    self.exchangeButton.hidden = YES;
    
    [self.monitorButton addTarget:self action:@selector(viewMonitorController:) forControlEvents:UIControlEventTouchUpInside];
    [self.learnButton addTarget:self action:@selector(viewLearnController:) forControlEvents:UIControlEventTouchUpInside];
    [self.exchangeButton addTarget:self action:@selector(viewExchangeController:) forControlEvents:UIControlEventTouchUpInside];
    [self.settingButton addTarget:self action:@selector(viewSettingController:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bluetoothButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:0];


    [self addSubControllers];
    
    [self updateLocalizedStrings];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocalizedStrings) name:NotificationLanguageChange object:nil];
}

- (void)updateLocalizedStrings {
    [self.monitorButton setTitle:FGLocalizedString(@"tab_monitor") forState:UIControlStateNormal];
    [self.learnButton setTitle:FGLocalizedString(@"tab_learn") forState:UIControlStateNormal];
    [self.exchangeButton setTitle:FGLocalizedString(@"tab_exchange") forState:UIControlStateNormal];
    [self.settingButton setTitle:FGLocalizedString(@"tab_setting") forState:UIControlStateNormal];
    
    for (UIButton *button in tabButtons) {
        [button layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:0];
    }
    self.monitorButton.titleEdgeInsets =  UIEdgeInsetsOffset(self.monitorButton.titleEdgeInsets, 0, -5);
    self.monitorButton.imageEdgeInsets = UIEdgeInsetsOffset(self.monitorButton.imageEdgeInsets, 0, -5);
    self.learnButton.titleEdgeInsets =  UIEdgeInsetsOffset(self.learnButton.titleEdgeInsets, 0, -4);
    self.learnButton.imageEdgeInsets = UIEdgeInsetsOffset(self.learnButton.imageEdgeInsets, 0, -4);
    self.exchangeButton.titleEdgeInsets =  UIEdgeInsetsOffset(self.exchangeButton.titleEdgeInsets, 0, -4);
    self.exchangeButton.imageEdgeInsets = UIEdgeInsetsOffset(self.exchangeButton.imageEdgeInsets, 0, -4);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addSubControllers {
    self.monitorController = [[MonitorViewController alloc] init];
    [self addChildViewController:self.monitorController];
    self.learnController = [[LearnViewController alloc] init];
    [self addChildViewController:self.learnController];
    self.exchangeController = [[ExchangeViewController alloc] init];
    [self addChildViewController:self.exchangeController];
    self.settingController = [[SettingViewController alloc] init];
    [self addChildViewController:self.settingController];
    
    [self fitFrameForChildViewController:self.monitorController];
    [self.container addSubview:self.monitorController.view];
    [self.monitorController didMoveToParentViewController:self];
    self.currentController = self.monitorController;
    self.monitorButton.selected = YES;
}

- (void)showChildViewController:(UIViewController *)childViewController {
    if (childViewController == _currentController) {
        return;
    }
    
    [self fitFrameForChildViewController:childViewController];
    [self transitionFromOldViewController:_currentController toNewViewController:childViewController];
}

- (void)selectButton:(UIButton *)button {
    for (UIButton *btn in tabButtons) {
        btn.selected = btn == button;
    }
}

- (void)fitFrameForChildViewController:(UIViewController *)childViewController {
    childViewController.view.frame = self.container.bounds;
}

//转换子视图控制器
- (void)transitionFromOldViewController:(UIViewController *)oldViewController toNewViewController:(UIViewController *)newViewController {
    [oldViewController willMoveToParentViewController:nil];
    [self transitionFromViewController:oldViewController toViewController:newViewController duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        if (finished) {
            [newViewController didMoveToParentViewController:self];
            _currentController = newViewController;
        }else{
            _currentController = oldViewController;
        }
    }];
    [newViewController didMoveToParentViewController:self];
}

//移除所有子视图控制器
- (void)removeAllChildViewControllers{
    for (UIViewController *vc in self.childViewControllers) {
        [vc willMoveToParentViewController:nil];
        [vc removeFromParentViewController];
    }
}

- (IBAction)viewMonitorController:(id)sender {
    BOOL visiable = !self.learnButton.hidden && !self.exchangeButton.hidden;
    if (visiable) {
        self.learnButton.hidden = YES;
        self.exchangeButton.hidden = YES;
    } else if (self.monitorButton.isSelected) {
        self.learnButton.hidden = NO;
        self.exchangeButton.hidden = NO;
    }
    
    [self showChildViewController:self.monitorController];
    [self selectButton:self.monitorButton];
}
- (IBAction)viewLearnController:(id)sender {
    [self showChildViewController:self.learnController];
    [self selectButton:self.learnButton];
}
- (IBAction)viewExchangeController:(id)sender {
    [self showChildViewController:self.exchangeController];
    [self selectButton:self.exchangeButton];
}
- (IBAction)viewSettingController:(id)sender {
    [self showChildViewController:self.settingController];
    [self selectButton:self.settingButton];
    
    self.learnButton.hidden = YES;
    self.exchangeButton.hidden = YES;
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
