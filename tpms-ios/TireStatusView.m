//
//  TireStatusView.m
//  tpms-ios
//
//  Created by ttonway on 2017/1/22.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import "TireStatusView.h"

#import "Common.h"

@implementation TireStatusView {
    UIImage *battery0;
    UIImage *battery1;
    UIImage *battery2;
    UIImage *battery3;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    battery0 = [[UIImage imageNamed:@"battery0"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    battery1 = [[UIImage imageNamed:@"battery1"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    battery2 = [[UIImage imageNamed:@"battery2"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    battery3 = [[UIImage imageNamed:@"battery3"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.batteryView = [[UIImageView alloc] initWithImage:battery0];
    self.underLine = [[UIView alloc] initWithFrame:CGRectZero];
    self.underLine.backgroundColor = [UIColor whiteColor];
    self.pressureLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.pressureLabel.font = [UIFont fontWithName:@"CenturyGothic-BoldItalic" size:22.f];
    self.temperatureLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.temperatureLabel.font = [UIFont systemFontOfSize:18.f];
    
    [self addSubview:self.batteryView];
    [self addSubview:self.pressureLabel];
    [self addSubview:self.underLine];
    [self addSubview:self.temperatureLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height;
    
    CGRect rect1 = self.batteryView.frame;
    CGRect rect2 = [self sizeOfLabel:self.pressureLabel width:width];
    CGRect rect3 = [self sizeOfLabel:self.temperatureLabel width:width];
    CGFloat totalH = CGRectGetHeight(rect1) + CGRectGetHeight(rect2) + CGRectGetHeight(rect3) + 4;
    CGFloat maxW = MAX(CGRectGetWidth(rect2), CGRectGetWidth(rect3));
    CGFloat x = (width - maxW) / 2;
    CGFloat y = (height - totalH) / 2;
    
    rect1.origin.x = x;
    rect1.origin.y = y;
    self.batteryView.frame = rect1;
    rect2.origin.x = x;
    rect2.origin.y = CGRectGetMaxY(rect1) + 2;
    self.pressureLabel.frame = rect2;
    rect2.origin.y = CGRectGetMaxY(rect2) + 2;
    rect2.size.height = 2;
    self.underLine.frame = rect2;
    rect3.origin.x = x;
    rect3.origin.y = CGRectGetMaxY(rect2) + 2;
    self.temperatureLabel.frame = rect3;
}

- (CGRect)sizeOfLabel:(UILabel *)label width:(CGFloat)width {
    NSString *str = label.text;
    if (!str) str = @"";
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSRange allRange = [str rangeOfString:str];
    [attrStr addAttribute:NSFontAttributeName
                    value:label.font
                    range:allRange];
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:label.textColor
                    range:allRange];
    
    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                        context:nil];
    rect.size.height += 2;
    return rect;
}

- (void)setTireStatus:(TireStatus *)status {
    NSString * NO_VALUE = @"------";
    if (status.inited) {
        self.pressureLabel.text = status.pressureStatus == PRESSURE_ERROR ? NO_VALUE : [Utils formatPressure:status.pressure];
        self.pressureLabel.textColor = status.pressureStatus == PRESSURE_NORMAL ? [UIColor commonYellowColor] : [UIColor commonOrangeColor];
        self.temperatureLabel.text = [Utils formatTemperature:status.temperature];
        self.temperatureLabel.textColor = status.temperatureStatus == TEMPERATURE_NORMAL ? [UIColor whiteColor] : [UIColor commonOrangeColor];
        if (status.battery < 2500) {
            self.batteryView.image = battery0;
        } else if (status.battery < 2700) {
            self.batteryView.image = battery1;
        } else if (status.battery < 2800) {
            self.batteryView.image = battery2;
        } else {
            self.batteryView.image = battery3;
        }
        self.batteryView.tintColor = status.batteryStatus == BATTERY_NORMAL ? [UIColor whiteColor] : [UIColor commonOrangeColor];
    } else {
        self.pressureLabel.text = NO_VALUE;
        self.pressureLabel.textColor = [UIColor commonYellowColor];
        self.temperatureLabel.text = NO_VALUE;
        self.temperatureLabel.textColor = [UIColor whiteColor];
        self.batteryView.image = battery0;
        self.batteryView.tintColor = [UIColor whiteColor];
    }
    
    [self setNeedsLayout];
}


@end
