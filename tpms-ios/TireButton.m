//
//  TireButton.m
//  tpms-ios
//
//  Created by ttonway on 2017/1/22.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import "TireButton.h"

#import "Common.h"

@implementation TireButton
@synthesize title = _title;

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
    self.label = [[UILabel alloc] initWithFrame:CGRectZero];
    self.label.backgroundColor = [UIColor clearColor];
    self.label.textColor = [UIColor whiteColor];
    self.label.font = [UIFont boldSystemFontOfSize:17.f];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.numberOfLines = 0;
    self.label.text = self.title;
    self.underLine = [[UIView alloc] initWithFrame:CGRectZero];
    self.underLine.backgroundColor = [UIColor whiteColor];
    self.selectedIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_tire_off"]];
    self.selectedIcon.hidden = YES;
    
    [self addSubview:self.label];
    [self addSubview:self.underLine];
    [self addSubview:self.selectedIcon];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height;
    
    NSString *str = self.title;
    if (!str) str = @"";
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSRange allRange = [str rangeOfString:str];
    [attrStr addAttribute:NSFontAttributeName
                    value:self.label.font
                    range:allRange];
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:self.label.textColor
                    range:allRange];
    
    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                        context:nil];
    rect.size.height += 2;

    rect.origin.x = (width - rect.size.width) / 2;
    rect.origin.y = (height - rect.size.height) / 2;
    self.label.frame = rect;
    rect.origin.y = CGRectGetMaxY(rect) + 2;
    rect.size.height = 2;
    self.underLine.frame = rect;
    self.selectedIcon.frame = CGRectMake((width - 25) / 2, CGRectGetMaxY(rect) + 8, 25, 25);
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.label.text = title;
    [self setNeedsLayout];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    UIColor *color = self.isSelected ? [UIColor commonOrangeColor] : [UIColor whiteColor];
    self.label.textColor = color;
    self.underLine.backgroundColor = color;
    self.selectedIcon.hidden = !self.isSelected;
}

@end
