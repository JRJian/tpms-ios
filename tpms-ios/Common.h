//
//  Common.h
//  tpms-ios
//
//  Created by ttonway on 2017/1/12.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "FGLanguageTool.h"

#define UNIT_BAR 0
#define UNIT_PSI 1
#define UNIT_KPA 2
#define UNIT_KG  3

#define TEMP_UNIT_CELSIUS     0
#define TEMP_UNIT_FAHRENHEIT  1

#define THEME_PLAIN  0
#define THEME_STAR   1
#define THEME_MODERN 2

#define PRESSURE_UPPER_LIMIT_MIN     2.5f
#define PRESSURE_UPPER_LIMIT_MAX     4.5f
#define PRESSURE_UPPER_LIMIT_DEFAULT 3.2f
#define PRESSURE_LOWER_LIMIT_MIN     1.0f
#define PRESSURE_LOWER_LIMIT_MAX     2.5f
#define PRESSURE_LOWER_LIMIT_DEFAULT 1.8f
#define TEMP_UPPER_LIMIT_MIN         60
#define TEMP_UPPER_LIMIT_MAX         99
#define TEMP_UPPER_LIMIT_DEFAULT     70

@interface Preferences : NSObject

@property (nonatomic) BOOL voiceOpen;
@property (nonatomic) NSInteger pressureUnit;
@property (nonatomic) NSInteger temperatureUnit;
@property (nonatomic) NSInteger theme;

+ (Preferences *)sharedInstance;

- (void)clear;

@end


@interface Utils : NSObject

+ (NSString *)formatPressure:(float)bar;
+ (NSString *)formatTemperature:(int)celsiusDegree;

@end


@interface UIColor (Custom)

+ (UIColor *)commonGreenColor;
+ (UIColor *)commonOrangeColor;
+ (UIColor *)commonYellowColor;

@end

typedef NS_ENUM(NSUInteger, MKButtonEdgeInsetsStyle) {
    MKButtonEdgeInsetsStyleTop, // image在上，label在下
    MKButtonEdgeInsetsStyleLeft, // image在左，label在右
    MKButtonEdgeInsetsStyleBottom, // image在下，label在上
    MKButtonEdgeInsetsStyleRight // image在右，label在左
};

@interface UIButton (ImageTitleSpacing)

/**
 *  设置button的titleLabel和imageView的布局样式，及间距
 *
 *  @param style titleLabel和imageView的布局样式
 *  @param space titleLabel和imageView的间距
 */
- (void)layoutButtonWithEdgeInsetsStyle:(MKButtonEdgeInsetsStyle)style imageTitleSpace:(CGFloat)space;

- (void)positiveStyle;
- (void)negativeStyle;

@end


@interface UIImage (Custom)

- (UIImage *)imageWithColor:(UIColor *)color;

@end
