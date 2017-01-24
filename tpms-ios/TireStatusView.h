//
//  TireStatusView.h
//  tpms-ios
//
//  Created by ttonway on 2017/1/22.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TireStatus.h"

@interface TireStatusView : UIView

@property (nonatomic) UIImageView *batteryView;
@property (nonatomic) UILabel *pressureLabel;
@property (nonatomic) UIView *underLine;
@property (nonatomic) UILabel *temperatureLabel;

- (void)setTireStatus:(TireStatus *)status;

@end
