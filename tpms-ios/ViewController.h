//
//  ViewController.h
//  tpms-ios
//
//  Created by ttonway on 2017/1/12.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MonitorViewController.h"
#import "LearnViewController.h"
#import "ExchangeViewController.h"
#import "SettingViewController.h"

@interface ViewController : UIViewController

@property (nonatomic) IBOutlet UIView *container;
@property (nonatomic) IBOutlet UIButton *monitorButton;
@property (nonatomic) IBOutlet UIButton *learnButton;
@property (nonatomic) IBOutlet UIButton *exchangeButton;
@property (nonatomic) IBOutlet UIButton *settingButton;
@property (nonatomic) IBOutlet UIButton *bluetoothButton;

@property (nonatomic) MonitorViewController *monitorController;
@property (nonatomic) LearnViewController *learnController;
@property (nonatomic) ExchangeViewController *exchangeController;
@property (nonatomic) SettingViewController *settingController;
@property (nonatomic) UIViewController *currentController;

@end

