//
//  NumberPicker.m
//  tpms-ios
//
//  Created by ttonway on 2017/1/20.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import "NumberPicker.h"

@implementation NumberPicker
@synthesize formatter = _formatter;
@synthesize value = _value;

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
    self.minusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backgroundLeft = [[UIImage imageNamed:@"picker_background_left"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.f, 5.f, 5.f, 0.f) resizingMode:UIImageResizingModeStretch];
    UIImage *imageMinus = [UIImage imageNamed:@"ic_minus"];
    [self.minusButton setImage:imageMinus forState:UIControlStateNormal];
    [self.minusButton setBackgroundImage:backgroundLeft forState:UIControlStateNormal];
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backgroundRight = [[UIImage imageNamed:@"picker_background_right"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.f, 0.f, 5.f, 5.f) resizingMode:UIImageResizingModeStretch];
    UIImage *imageAdd = [UIImage imageNamed:@"ic_add"];
    [self.addButton setImage:imageAdd forState:UIControlStateNormal];
    [self.addButton setBackgroundImage:backgroundRight forState:UIControlStateNormal];
    UIImage *backgroundCenter = [[UIImage imageNamed:@"picker_background_center"] resizableImageWithCapInsets:UIEdgeInsetsMake(1.f, 1.f, 1.f, 1.f) resizingMode:UIImageResizingModeStretch];
    self.labelBackground = [[UIImageView alloc] initWithImage:backgroundCenter];
    self.label = [[UILabel alloc] initWithFrame:CGRectZero];
    self.label.font = [UIFont systemFontOfSize:15.f];
    self.label.textColor = [UIColor whiteColor];
    self.label.textAlignment = NSTextAlignmentCenter;
    
    [self.addButton addTarget:self action:@selector(increaseValue:) forControlEvents:UIControlEventTouchUpInside];
    [self.minusButton addTarget:self action:@selector(decreaseValue:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.minusButton];
    [self addSubview:self.addButton];
    [self addSubview:self.labelBackground];
    [self addSubview:self.label];
    
    self.maxValue = 10.f;
    self.minValue = 0.f;
    self.deltaValue = 1.f;
    self.value = 0.f;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGRect rect = bounds;
    rect.size.width = 39;
    self.minusButton.frame = rect;
    rect.origin.x = 39;
    rect.size.width = bounds.size.width - 78;
    self.labelBackground.frame = rect;
    self.label.frame = rect;
    rect.origin.x = bounds.size.width - 39;
    rect.size.width = 39;
    self.addButton.frame = rect;
}



- (void)updateLabel {
    if (self.formatter) {
        self.label.text = self.formatter(_value);
    } else {
        self.label.text = [NSString stringWithFormat:@"%f", _value];
    }
}

- (void)setFormatter:(formatValue)formatter {
    _formatter = formatter;
    
    [self updateLabel];
}

- (void)setValue:(float)value {
    _value = value;
    
    [self updateLabel];
}

- (IBAction)increaseValue:(id)sender {
    float v = _value + self.deltaValue;
    v = MIN(v, self.maxValue);
    self.value = v;
}

- (IBAction)decreaseValue:(id)sender {
    float v = _value - self.deltaValue;
    v = MAX(v, self.minValue);
    self.value = v;
}

@end
