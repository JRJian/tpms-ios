//
//  TireStatus.m
//  tpms-ios
//
//  Created by ttonway on 2017/1/22.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import "TireStatus.h"

@implementation TireStatus
@synthesize name = _name;

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
    }
    return self;
}

- (void)setValues:(TireStatus *)status {
    self.inited = status.inited;
    
    self.pressureStatus = status.pressureStatus;
    self.batteryStatus = status.batteryStatus;
    self.temperatureStatus = status.temperatureStatus;
    
    self.pressure = status.pressure;
    self.battery = status.battery;
    self.temperature = status.temperature;
}

@end
