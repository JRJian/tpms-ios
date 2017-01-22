//
//  RadioGroup.m
//  tpms-ios
//
//  Created by ttonway on 2017/1/20.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import "RadioGroup.h"

#define BUTTON_WIDTH 72
#define BUTTON_HEIGHT 32
#define BUTTON_SPACING 8

@implementation RadioGroup
@synthesize checkedTag = _checkedTag;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)addRadioButton:(NSInteger)tag title:(NSString *)title image:(UIImage *)image {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setImage:image forState:UIControlStateNormal];
    UIEdgeInsets insets = UIEdgeInsetsMake(5.f, 5.f, 5.f, 5.f);
    UIImage *image1 = [UIImage imageNamed:@"radio_background_normal"];
    UIImage *background1 = [image1 resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    UIImage *image2 = [UIImage imageNamed:@"radio_background_checked"];
    UIImage *background2 = [image2 resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    [btn setBackgroundImage:background1 forState:UIControlStateNormal];
    [btn setBackgroundImage:background2 forState:UIControlStateSelected];
    
    btn.tag = tag;
    btn.selected = tag == _checkedTag;
    
    [btn addTarget:self action:@selector(onCheckedChange:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:btn];
    if (!radioButtons) {
        radioButtons = [NSMutableArray arrayWithObject:btn];
    } else {
        [radioButtons addObject:btn];
    }
}

- (CGFloat)configBoundsWidth:(CGFloat)width {
    CGFloat height = 44;
    if (radioButtons) {
        CGRect rect = CGRectMake(-BUTTON_SPACING - BUTTON_WIDTH, 4, BUTTON_WIDTH, BUTTON_HEIGHT);
        for (UIButton *btn in radioButtons) {
            if (CGRectGetMaxX(rect) + BUTTON_SPACING + BUTTON_WIDTH < width) {
                rect.origin.x += BUTTON_SPACING + BUTTON_WIDTH;
            } else {
                rect.origin.x = 0;
                rect.origin.y += 44;
                height += 44;
            }
            btn.frame = rect;
        }
    }
    
    return height;
}

- (void)setCheckedTag:(NSInteger)tag {
    _checkedTag = tag;
    for (UIButton *btn in radioButtons) {
        btn.selected = btn.tag == tag;
    }
}

- (IBAction)onCheckedChange:(id)sender {
    for (UIButton *btn in radioButtons) {
        if (sender == btn) {
            btn.selected = YES;
            _checkedTag = btn.tag;
            [self.delegate radioGroup:self didCheckedChange:_checkedTag];
        } else {
            btn.selected = NO;
        }
    }
}

@end
