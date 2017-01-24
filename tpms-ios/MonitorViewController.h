//
//  MonitorViewController.h
//  tpms-ios
//
//  Created by ttonway on 2017/1/17.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TireStatusView.h"

@interface MonitorViewController : UIViewController

@property (nonatomic) UIImageView *carImageView;

@property (nonatomic) TireStatusView *board1;
@property (nonatomic) TireStatusView *board2;
@property (nonatomic) TireStatusView *board3;
@property (nonatomic) TireStatusView *board4;

@end
