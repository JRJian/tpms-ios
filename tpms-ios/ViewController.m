//
//  ViewController.m
//  tpms-ios
//
//  Created by ttonway on 2017/1/12.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import "ViewController.h"

#import "Common.h"
#import "TpmsDevice.h"
#import "CustomIOS7AlertView.h"
#import "ScanViewController.h"

UIEdgeInsets UIEdgeInsetsOffset(UIEdgeInsets insets, CGFloat dx, CGFloat dy) {
    insets.left += dx;
    insets.right -=dx;
    insets.top += dy;
    insets.bottom -= dy;
    return insets;
}

@interface ViewController () <CustomIOS7AlertViewDelegate> {
    NSArray *tabButtons;
    
    Preferences *preference;
    
    TpmsDevice *device;
}

@property (nonatomic) CustomIOS7AlertView *errorAlertView;

@end

@implementation ViewController
@synthesize currentController = _currentController;
@synthesize errorAlertView = _errorAlertView;

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
    [self.bluetoothButton addTarget:self action:@selector(gotoLeScan:) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoLeScan:)];
    [self.indicatorView addGestureRecognizer:tapGesture];

    [self addSubControllers];
    
    [self updateLocalizedStrings];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocalizedStrings) name:NotificationLanguageChange object:nil];
    
    preference = [Preferences sharedInstance];
    [preference addObserver:self forKeyPath:@"theme" options:0 context:nil];
    [self updateBackground];
    
    device = [TpmsDevice sharedInstance];
    [device addObserver:self forKeyPath:@"state" options:0 context:nil];
    [self updateDeviceState];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onError:) name:NotificationTpmsError object:nil];
}

- (void)dealloc {
    [preference removeObserver:self forKeyPath:@"theme"];
    [device removeObserver:self forKeyPath:@"state"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"theme"]) {
        [self updateBackground];
    } else if([keyPath isEqualToString:@"state"]) {
        [self updateDeviceState];
    }
}

- (void)updateBackground {
    NSInteger theme = preference.theme;
    if (theme == THEME_PLAIN) {
        self.backgroundView.image = [UIImage imageNamed:@"background_plain"];
    } else if (theme == THEME_MODERN) {
        self.backgroundView.image = [UIImage imageNamed:@"background_modern"];
    } else if (theme == THEME_STAR) {
        self.backgroundView.image = [UIImage imageNamed:@"background_star"];
    }
}

- (void)updateDeviceState {
    TpmsDriverState state = device.state;
    switch (state) {
        case TpmsStateOpen:
            self.bluetoothButton.hidden = NO;
            [self.bluetoothButton setImage:[UIImage imageNamed:@"ic_bluetooth"] forState:UIControlStateNormal];
            self.indicatorView.hidden = YES;
            [self.indicatorView stopAnimating];
            break;
        case TpmsStateClose:
            self.bluetoothButton.hidden = NO;
            [self.bluetoothButton setImage:[UIImage imageNamed:@"ic_bluetooth_off"] forState:UIControlStateNormal];
            self.indicatorView.hidden = YES;
            [self.indicatorView stopAnimating];
            break;
        case TpmsStateOpenging:
        case TpmsStateClosing:
            self.bluetoothButton.hidden = YES;
            self.indicatorView.hidden = NO;
            [self.indicatorView startAnimating];
            break;
        default:
            break;
    }
}

- (void)updateLocalizedStrings {
    self.titleLabel.text = FGLocalizedString(@"activity_main");
    [self.monitorButton setTitle:FGLocalizedString(@"tab_monitor") forState:UIControlStateNormal];
    [self.learnButton setTitle:FGLocalizedString(@"tab_learn") forState:UIControlStateNormal];
    [self.exchangeButton setTitle:FGLocalizedString(@"tab_exchange") forState:UIControlStateNormal];
    [self.settingButton setTitle:FGLocalizedString(@"tab_setting") forState:UIControlStateNormal];
    
    for (UIButton *button in tabButtons) {
        [button layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:0];
    }
    self.monitorButton.titleEdgeInsets =  UIEdgeInsetsOffset(self.monitorButton.titleEdgeInsets, 0, -4);
    self.monitorButton.imageEdgeInsets = UIEdgeInsetsOffset(self.monitorButton.imageEdgeInsets, 0, -4);
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
- (IBAction)gotoLeScan:(id)sender {
    ScanViewController *controller = [[ScanViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}


- (void)onError:(NSNotification *)notification {
    self.errorAlertView.message = FGLocalizedString(@"alert_message_usb_io_error");
    self.errorAlertView.okBtnTitle = FGLocalizedString(@"btn_ok");
    [self.errorAlertView show];
}

- (CustomIOS7AlertView *)errorAlertView {
    if (!_errorAlertView) {
        _errorAlertView = [[CustomIOS7AlertView alloc] init];
        _errorAlertView.delegate = self;
    }
    return _errorAlertView;
}

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView close];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
