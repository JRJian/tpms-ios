//
//  NumberPicker.h
//  tpms-ios
//
//  Created by ttonway on 2017/1/20.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSString *(^formatValue)(float v);


@interface NumberPicker : UIView

@property (nonatomic) UIButton *addButton;
@property (nonatomic) UIImageView *labelBackground;
@property (nonatomic) UILabel *label;
@property (nonatomic) UIButton *minusButton;

@property (nonatomic, copy) formatValue formatter;
@property (nonatomic) float value;
@property (nonatomic) float deltaValue;
@property (nonatomic) float minValue;
@property (nonatomic) float maxValue;

@end
