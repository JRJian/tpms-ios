//
//  TireStatus.m
//  tpms-ios
//
//  Created by ttonway on 2017/1/22.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import "TireStatus.h"

@interface PressureEntry : NSObject
@property (nonatomic) NSDate *date;
@property (nonatomic) float pressure;
@end
@implementation PressureEntry
@end


@implementation TireStatus
@synthesize name = _name;
@synthesize pressure = _pressure;
@synthesize battery = _battery;
@synthesize temperature = _temperature;

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
        
        _pressure = MAXFLOAT;
        _battery = INT_MIN;
        _temperature = INT_MIN;
        self.pressureHistories = [NSMutableArray array];
    }
    return self;
}

- (void)setPressure:(float)pressure {
    
    if (pressure > 4.5) {
        // ignored
    } else {
        if (_pressure == MAXFLOAT) {
            // goon
        } else if (self.pressureBreak) {
            self.pressureBreak = NO;
            // goon
        } else {
            if (fabs(_pressure - pressure) > 0.5f) {
                self.pressureBreak = YES;
                return;
            } else {
                self.pressureBreak = NO;
                // goon
            }
        }
        
        _pressure = pressure;
        
        NSDate *now = [NSDate date];
        PressureEntry *entry = [[PressureEntry alloc] init];
        entry.date = now;
        entry.pressure = pressure;
        [self.pressureHistories addObject:entry];
        NSMutableArray *deletes = [NSMutableArray array];
        for (PressureEntry *e in self.pressureHistories) {
            if ([now timeIntervalSinceDate:e.date] > /* 1min */ 60) {
                [deletes addObject:e];
            } else {
                break;
            }
        }
        [self.pressureHistories removeObjectsInArray:deletes];
    }

}

- (void)setTemperature:(int)temperature {
    if (temperature > 100) {
        temperature = 0;
    }
    
    if (_temperature == INT_MIN) {
        // goon
    } else if (self.temperatureBreak) {
        self.temperatureBreak = NO;
        // goon
    } else {
        if (abs(_temperature - temperature) > 20) {
            self.temperatureBreak = YES;
            return;
        } else {
            self.temperatureBreak = NO;
            // goon
        }
    }
    
    _temperature = temperature;
}

- (void)setBattery:(int)battery {
    if (_battery == INT_MIN) {
        // goon
    } else if (self.batteryBreak) {
        self.batteryBreak = NO;
        // goon
    } else {
        if (abs(_battery - battery) > 200) {
            self.batteryBreak = YES;
            return;
        } else {
            self.batteryBreak = NO;
            // goon
        }
    }
    
    _battery = battery;
}


- (BOOL)isLeaking {
    
    PressureEntry *first = self.pressureHistories.firstObject;
    if (first.pressure - _pressure > 0.3f) {
        BOOL leaking = YES;
        float lastValue = MAXFLOAT;
        for (PressureEntry *e in self.pressureHistories) {
            if (e.pressure <= lastValue) {
                lastValue = e.pressure;
            } else {
                leaking = NO;
                break;
            }
        }
        if (leaking) {
            return YES;
        }
    }
    return NO;
}

- (void)setValues:(TireStatus *)status {
    self.inited = status.inited;
    
    self.pressureStatus = status.pressureStatus;
    self.batteryStatus = status.batteryStatus;
    self.temperatureStatus = status.temperatureStatus;
    self.pressure = status.pressure;
    self.battery = status.battery;
    self.temperature = status.temperature;
    
    self.pressureBreak = status.pressureBreak;
    self.batteryBreak = status.batteryBreak;
    self.temperatureBreak = status.temperatureBreak;
    NSArray *tempList = [NSArray arrayWithArray:self.pressureHistories];
    [self.pressureHistories setArray:status.pressureHistories];
    [status.pressureHistories setArray:tempList];
    self.lastUpdateTime = status.lastUpdateTime;
}



@end
