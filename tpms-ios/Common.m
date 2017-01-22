//
//  Common.m
//  tpms-ios
//
//  Created by ttonway on 2017/1/12.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import "Common.h"

#define KEY_VOICE_OPEN    @"app.voice-open"
#define KEY_PRESSURE_UNIT @"app.pressure-unit"
#define KEY_TEMP_UNIT     @"app.temp-unit"
#define KEY_THEME         @"app.theme"

@implementation Preferences
@synthesize voiceOpen = _voiceOpen;
@synthesize pressureUnit = _pressureUnit;
@synthesize temperatureUnit = _temperatureUnit;
@synthesize theme = _theme;

+ (Preferences *)sharedInstance
{
    static  Preferences *sharedInstance = nil;
    static  dispatch_once_t onceToken;
    dispatch_once (& onceToken, ^ {
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSNumber *num = [defaults objectForKey:KEY_VOICE_OPEN];
        _voiceOpen = num ? [num boolValue] : YES;
        
        _pressureUnit = [defaults integerForKey:KEY_PRESSURE_UNIT];
        _temperatureUnit = [defaults integerForKey:KEY_TEMP_UNIT];
        _theme = [defaults integerForKey:KEY_THEME];
    }
    return self;
}

- (void)setVoiceOpen:(BOOL)voiceOpen {
    _voiceOpen = voiceOpen;
    [[NSUserDefaults standardUserDefaults] setBool:voiceOpen forKey:KEY_VOICE_OPEN];
}

- (void)setPressureUnit:(NSInteger)pressureUnit {
    _pressureUnit = pressureUnit;
    [[NSUserDefaults standardUserDefaults] setInteger:pressureUnit forKey:KEY_PRESSURE_UNIT];
}

- (void)setTemperatureUnit:(NSInteger)temperatureUnit {
    _temperatureUnit = temperatureUnit;
    [[NSUserDefaults standardUserDefaults] setInteger:temperatureUnit forKey:KEY_TEMP_UNIT];
}

- (void)setTheme:(NSInteger)theme {
    _theme = theme;
    [[NSUserDefaults standardUserDefaults] setInteger:theme forKey:KEY_THEME];
}

@end


@implementation Utils

+ (NSString *)formatPressure:(float)bar {
    NSInteger unit = [Preferences sharedInstance].pressureUnit;
    switch (unit) {
        case UNIT_BAR:
            return [NSString stringWithFormat:@"%.1fBar", bar];
        case UNIT_PSI:
            return [NSString stringWithFormat:@"%.1fPSI", (bar * 14.5f)];
        case UNIT_KPA:
            return [NSString stringWithFormat:@"%.1fKpa", bar * 100];
        case UNIT_KG:
            return [NSString stringWithFormat:@"%.1fKg", bar];
    }
    return nil;
}

+ (NSString *)formatTemperature:(int)celsiusDegree {
    NSInteger unit = [Preferences sharedInstance].temperatureUnit;
    switch (unit) {
        case TEMP_UNIT_CELSIUS:
            return [NSString stringWithFormat:@"%d℃", celsiusDegree];
        case TEMP_UNIT_FAHRENHEIT:
            // 摄氏度×9/5+32=华氏度
            return [NSString stringWithFormat:@"%d℉", (celsiusDegree * 9 / 5 + 32)];
    }
    return nil;
}

@end


@implementation UIColor (Custom)

+ (UIColor *)commonGreenColor {
    return [UIColor colorWithRed:40.0f/255.0f green:183.0f/255.0f blue:143.0f/255.0f alpha:1.0f];
}

+ (UIColor *)commonOrangeColor {
    return [UIColor colorWithRed:255.0f/255.0f green:104.0f/255.0f blue:22.0f/255.0f alpha:1.0f];
}

@end


@implementation UIButton (ImageTitleSpacing)

- (void)layoutButtonWithEdgeInsetsStyle:(MKButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space
{
    // 1. 得到imageView和titleLabel的宽、高
    CGFloat imageWith = self.imageView.frame.size.width;
    CGFloat imageHeight = self.imageView.frame.size.height;
    
    CGFloat labelWidth = 0.0;
    CGFloat labelHeight = 0.0;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        // 由于iOS8中titleLabel的size为0，用下面的这种设置
        labelWidth = self.titleLabel.intrinsicContentSize.width;
        labelHeight = self.titleLabel.intrinsicContentSize.height;
    } else {
        labelWidth = self.titleLabel.frame.size.width;
        labelHeight = self.titleLabel.frame.size.height;
    }
    
    // 2. 声明全局的imageEdgeInsets和labelEdgeInsets
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets labelEdgeInsets = UIEdgeInsetsZero;
    
    // 3. 根据style和space得到imageEdgeInsets和labelEdgeInsets的值
    switch (style) {
        case MKButtonEdgeInsetsStyleTop:
        {
            imageEdgeInsets = UIEdgeInsetsMake(-labelHeight-space/2.0, 0, 0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight-space/2.0, 0);
        }
            break;
        case MKButtonEdgeInsetsStyleLeft:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, -space/2.0, 0, space/2.0);
            labelEdgeInsets = UIEdgeInsetsMake(0, space/2.0, 0, -space/2.0);
        }
            break;
        case MKButtonEdgeInsetsStyleBottom:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight-space/2.0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(-imageHeight-space/2.0, -imageWith, 0, 0);
        }
            break;
        case MKButtonEdgeInsetsStyleRight:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth+space/2.0, 0, -labelWidth-space/2.0);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith-space/2.0, 0, imageWith+space/2.0);
        }
            break;
        default:
            break;
    }
    // 4. 赋值
    self.titleEdgeInsets = labelEdgeInsets;
    self.imageEdgeInsets = imageEdgeInsets;
}

- (void)positiveStyle {
    self.layer.borderWidth = 1.f;
    self.layer.borderColor = [UIColor commonGreenColor].CGColor;
    self.layer.cornerRadius = 5.f;
    [self setTitleColor:[UIColor commonGreenColor] forState:UIControlStateNormal];
}

- (void)negativeStyle {
    self.layer.borderWidth = 1.f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.cornerRadius = 5.f;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

}

@end


@implementation UIImage (Custom)

- (UIImage *)imageWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end

