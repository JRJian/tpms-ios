//
//  TireStatus.h
//  tpms-ios
//
//  Created by ttonway on 2017/1/22.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PRESSURE_NORMAL    0
#define PRESSURE_LOW       1
#define PRESSURE_HIGH      2
#define PRESSURE_ERROR     3
#define PRESSURE_NO_SIGNAL 21// custom
#define PRESSURE_LEAKING   22// custom

#define BATTERY_NORMAL     0
#define BATTERY_LOW        1

#define TEMPERATURE_NORMAL 0
#define TEMPERATURE_HIGH   1

@interface TireStatus : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic) BOOL inited;

@property (nonatomic) int pressureStatus;
@property (nonatomic) int batteryStatus;
@property (nonatomic) int temperatureStatus;
@property (nonatomic) float pressure;//Bar
@property (nonatomic) int battery;//mV
@property (nonatomic) int temperature;//摄氏度

@property (nonatomic) BOOL pressureBreak;
@property (nonatomic) BOOL batteryBreak;
@property (nonatomic) BOOL temperatureBreak;
@property (nonatomic) NSMutableArray *pressureHistories;
@property (nonatomic) NSDate *lastUpdateTime;

- (instancetype)initWithName:(NSString *)name;

- (BOOL)isLeaking;
- (void)setValues:(TireStatus *)status;

@end
