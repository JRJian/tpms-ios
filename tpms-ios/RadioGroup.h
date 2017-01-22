//
//  RadioGroup.h
//  tpms-ios
//
//  Created by ttonway on 2017/1/20.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RadioGroupDelegate;

@interface RadioGroup : UIView {
    NSMutableArray *radioButtons;
}

@property (nonatomic) NSInteger checkedTag;
@property (nonatomic, assign)  id<RadioGroupDelegate> delegate;

- (void)addRadioButton:(NSInteger)tag title:(NSString *)title image:(UIImage *)image;

- (CGFloat)configBoundsWidth:(CGFloat)width;

@end


@protocol RadioGroupDelegate

- (void)radioGroup:(RadioGroup *)group didCheckedChange:(NSInteger)tag;

@end
