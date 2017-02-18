//
//  TpmsDevice.m
//  tpms-ios
//
//  Created by ttonway on 2017/1/23.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import "TpmsDevice.h"

#import "Common.h"

NSString * const NotificationTpmsError = @"Notification_TpmsError";
NSString * const NotificationTireStatusUpdated = @"Notification_TireStatusUpdated";
NSString * const NotificationTireMatched = @"Notification_TireMatched";


@implementation TpmsDevice {
    NSUserDefaults *defaults;
    
    NSMutableArray<WriteCommand *> *commands;
    
    NSString *alertSound;
    NSString *alertMessage;
}

+ (TpmsDevice *)sharedInstance
{
    static  TpmsDevice *sharedInstance = nil;
    static  dispatch_once_t onceToken;
    dispatch_once (& onceToken, ^ {
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dirver = [[BleDriver alloc] init];
        self.dirver.delegate = self;
        commands = [NSMutableArray array];
        
        self.leftFront = [[TireStatus alloc] initWithName:@"left-front"];
        self.rightFront = [[TireStatus alloc] initWithName:@"right-front"];
        self.leftEnd = [[TireStatus alloc] initWithName:@"left-end"];
        self.rightEnd = [[TireStatus alloc] initWithName:@"right-end"];
        
        defaults = [NSUserDefaults standardUserDefaults];
        [self initStatus];
        
//        self.leftFront.inited = YES;
//        self.leftFront.battery = 2700;
//        self.leftFront.temperature = 28;
//        self.leftFront.pressure = 2.5f;
//        self.leftEnd.inited = YES;
//        self.leftEnd.battery = 2700;
//        self.leftEnd.temperature = 28;
//        self.leftEnd.pressure = 3.0f;
//        self.leftEnd.pressureStatus = PRESSURE_HIGH;
//        self.rightFront.inited = YES;
//        self.rightFront.battery = 2700;
//        self.rightFront.temperature = 28;
//        self.rightFront.pressure = 2.5f;
//        self.rightEnd.inited = YES;
//        self.rightEnd.battery = 2700;
//        self.rightEnd.temperature = 28;
//        self.rightEnd.pressure = 2.5f;
    }
    return self;
}

- (void)initStatus {
    NSNumber *num = [defaults objectForKey:@"pressure-low-limit"];
    self.pressureLowLimit = num ? [num floatValue] : PRESSURE_LOWER_LIMIT_DEFAULT;
    num = [defaults objectForKey:@"pressure-high-limit"];
    self.pressureHighLimit = num ? [num floatValue] : PRESSURE_UPPER_LIMIT_DEFAULT;
    num = [defaults objectForKey:@"temperature-high-limit"];
    self.temperatureLimit = num ? [num intValue] : TEMP_UPPER_LIMIT_DEFAULT;
    [self readTireStatus:self.leftFront];
    [self readTireStatus:self.rightFront];
    [self readTireStatus:self.leftEnd];
    [self readTireStatus:self.rightEnd];
}

- (void)readTireStatus:(TireStatus *)status {
    NSString *prefix = status.name;
    NSNumber *num = [defaults objectForKey:[prefix stringByAppendingString:@"-pressure-status"]];
    if (num) {
        status.inited = YES;
    } else {
        status.inited = NO;
        return;
    }
    status.pressureStatus = [num intValue];
    num = [defaults objectForKey:[prefix stringByAppendingString:@"-battery-status"]];
    status.batteryStatus = [num intValue];
    num = [defaults objectForKey:[prefix stringByAppendingString:@"-temperature-status"]];
    status.temperatureStatus = [num intValue];
    num = [defaults objectForKey:[prefix stringByAppendingString:@"-pressure"]];
    status.pressure = [num floatValue];
    num = [defaults objectForKey:[prefix stringByAppendingString:@"-battery"]];
    status.battery = [num floatValue];
    num = [defaults objectForKey:[prefix stringByAppendingString:@"-temperature"]];
    status.temperature = [num floatValue];
}

- (void)writeTireStatus:(TireStatus *)status {
    NSString *prefix = status.name;
    if (status.inited) {
        [defaults setInteger:status.pressureStatus forKey:[prefix stringByAppendingString:@"-pressure-status"]];
        [defaults setInteger:status.batteryStatus forKey:[prefix stringByAppendingString:@"-battery-status"]];
        [defaults setInteger:status.temperatureStatus forKey:[prefix stringByAppendingString:@"-temperature-status"]];
        [defaults setFloat:status.pressure forKey:[prefix stringByAppendingString:@"-pressure"]];
        [defaults setFloat:status.battery forKey:[prefix stringByAppendingString:@"-battery"]];
        [defaults setFloat:status.temperature forKey:[prefix stringByAppendingString:@"-temperature"]];
    } else {
        [defaults removeObjectForKey:[prefix stringByAppendingString:@"-pressure-status"]];
        [defaults removeObjectForKey:[prefix stringByAppendingString:@"-battery-status"]];
        [defaults removeObjectForKey:[prefix stringByAppendingString:@"-temperature-status"]];
        [defaults removeObjectForKey:[prefix stringByAppendingString:@"-pressure"]];
        [defaults removeObjectForKey:[prefix stringByAppendingString:@"-battery"]];
        [defaults removeObjectForKey:[prefix stringByAppendingString:@"-temperature"]];
    }
}

- (void)clearData {
    [defaults removeObjectForKey:@"pressure-low-limit"];
    [defaults removeObjectForKey:@"pressure-high-limit"];
    [defaults removeObjectForKey:@"temperature-high-limit"];
    self.leftFront.inited = NO;
    self.rightFront.inited = NO;
    self.leftEnd.inited = NO;
    self.rightEnd.inited = NO;
    [self writeTireStatus:self.leftFront];
    [self writeTireStatus:self.rightFront];
    [self writeTireStatus:self.leftEnd];
    [self writeTireStatus:self.rightEnd];
    
    [self initStatus];
}

- (BOOL)openDevice {
    NSLog(@"openDevice");
    CBPeripheral *peripheral = self.dirver.currentPeripheral;
    if (peripheral && [self.dirver connect:peripheral]) {
        self.hasError = NO;
        return YES;
    }
    return NO;
}

- (void)closeDevice {
    NSLog(@"closeDevice");
    [self.dirver disconnect];
    
    self.hasError = NO;
    for (WriteCommand *command in commands) {
        [TpmsDevice cancelPreviousPerformRequestsWithTarget:self selector:@selector(runCommand:) object:command];
    }
    [commands removeAllObjects];
}

- (Byte)makeParity:(Byte *)buf length:(NSInteger)length {
    Byte parity = 0;
    for (NSInteger i = 0; i < length; i++) {
        parity = (Byte) (parity ^ buf[i]);
    }
    return parity;
}

- (BOOL)writeCommand:(Byte)cmd payload:(NSData *)payload {
    Byte buf[64];
    NSInteger index = 0;
    buf[index++] = (Byte) 0xFC;
    buf[index++] = (Byte) (1 + payload.length + 2);
    buf[index++] = cmd;
    [payload getBytes:(buf + index) length:payload.length];
    index += payload.length;
    buf[index] = [self makeParity:buf length:index];
    index++;//remove warning
    buf[index++] = (Byte) 0xAA;
    
    NSData *data = [NSData dataWithBytes:buf length:index];
    NSLog(@"[WriteData] %@", data);
    return [self. dirver writeData:data];
}

- (void)queueCommand:(WriteCommand *)command {
    [commands addObject:command];
    [self runCommand:command];
}

- (void)runCommand:(WriteCommand *)command {
    if (command.tryCount < 3) {
        command.tryCount = command.tryCount + 1;
        if (![self writeCommand:command.command payload:command.payload]) {
            NSLog(@"writeData fail.");
        }
        [self performSelector:@selector(runCommand:) withObject:command afterDelay:1.0];
    } else {
        [commands removeObject:command];
        self.hasError = YES;
        NSLog(@"command %@ timeout", command);
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationTpmsError object:nil userInfo:nil];
    }
}

- (void)removeCommands:(Byte)cmd payload:(NSData *)payload {
    NSMutableArray *array = [NSMutableArray array];
    for (WriteCommand *command in commands) {
        if (command.command == cmd && [command.payload isEqual:payload]) {
            [array addObject:command];
            [TpmsDevice cancelPreviousPerformRequestsWithTarget:self selector:@selector(runCommand:) object:command];
        }
    }
    [commands removeObjectsInArray:array];
}

- (void)startTireMatch:(Byte)tire {
    WriteCommand *cmd = [[WriteCommand alloc] init];
    cmd.command = CMD_START_TIRE_MATCH;
    Byte paylod[] = { tire };
    cmd.payload = [NSData dataWithBytes:paylod length:1];
    [self queueCommand:cmd];
}
- (void)stopTireMatch {
    WriteCommand *cmd = [[WriteCommand alloc] init];
    cmd.command = CMD_STOP_TIRE_MATCH;
    cmd.payload = [NSData data];
    [self queueCommand:cmd];
}
- (void)exchangeTire:(Byte)tire1 andTire:(Byte)tire2 {
    WriteCommand *cmd = [[WriteCommand alloc] init];
    cmd.command = CMD_EXCHANGE_TIRE;
    Byte paylod[] = { tire1, tire2 };
    cmd.payload = [NSData dataWithBytes:paylod length:2];
    [self queueCommand:cmd];
}
- (void)saveSettings:(float)lowLimit high:(float)highLimit temp:(int)tempLimit {
    Byte paylod[3];
    paylod[0] = (Byte) (lowLimit / 0.1f + 0.5f);
    paylod[1] = (Byte) (highLimit / 0.1f + 0.5f);
    paylod[2] = (Byte) tempLimit;
    
    WriteCommand *cmd = [[WriteCommand alloc] init];
    cmd.command = CMD_SAVE_SETTING;
    cmd.payload = [NSData dataWithBytes:paylod length:3];
    [self queueCommand:cmd];
}

- (void)querySettings {
    WriteCommand *cmd = [[WriteCommand alloc] init];
    cmd.command = CMD_QUERY_SETTING;
    cmd.payload = [NSData data];
    [self queueCommand:cmd];
}

- (BOOL)isSettingsChanged:(float)lowLimit high:(float)highLimit temp:(int)tempLimit {
    Byte buf[3];
    buf[0] = (Byte) (lowLimit / 0.1f + 0.5f);
    buf[1] = (Byte) (highLimit / 0.1f + 0.5f);
    buf[2] = (Byte) tempLimit;
    
    Byte buf2[3];
    buf2[0] = (Byte) (self.pressureLowLimit / 0.1f + 0.5f);
    buf2[1] = (Byte) (self.pressureHighLimit / 0.1f + 0.5f);
    buf2[2] = (Byte) self.temperatureLimit;
    
    return memcmp(buf, buf2, 3) != 0;
}

- (TireStatus *)getTireStatus:(Byte)tire {
    switch (tire) {
        case TIRE_LEFT_FRONT:
            return self.leftFront;
        case TIRE_RIGHT_FRONT:
            return self.rightFront;
        case TIRE_RIGHT_END:
            return self.rightEnd;
        case TIRE_LEFT_END:
            return self.leftEnd;
        default:
            return nil;
    }
}

#pragma mark - DriverDelegate
static Byte ReadBuf[64];
- (void)driver:(BleDriver *)driver didReadData:(NSData *)data {
    NSLog(@"[ReadData] %@", data);
    NSUInteger length = data.length;
    [data getBytes:ReadBuf length:length];
    Byte *buf = ReadBuf;
    if (length < 5) {
        NSLog(@"[onReadData] length too short.");
        return;
    }
    if (buf[0] != (Byte) 0xFC || buf[length - 1] != (Byte) 0xAA) {
        NSLog(@"[onReadData] wrong tags.");
        return;
    }
    if (buf[1] != length - 2) {
        NSLog(@"[onReadData] wrong frame length.");
        return;
    }
    Byte parity = [self makeParity:buf length:length - 2];
    if (buf[length - 2] != parity) {
        NSLog(@"[onReadData] wrong parity.");
        return;
    }
    
    Byte cmd = buf[2];
    Byte *payload = buf + 3;
    NSData *payData = [NSData dataWithBytes:payload length:length - 5];
    switch (cmd) {
        // 数据帧
        case 0x01: {
            Byte tire = payload[0];
            Byte alarm = payload[1];
            Byte temp = payload[2];
            Byte pressure = payload[3];
            Byte battery = payload[4];
            TireStatus *status = [self getTireStatus:tire];
            status.inited = YES;
            status.pressureStatus = alarm & 0x03;
            status.batteryStatus = (alarm >> 2) & 0x01;
            status.temperatureStatus = (alarm >> 3) & 0x01;
            status.pressure = 0.1f * (int) pressure;
            status.temperature = (int) temp;
            if (status.temperature > 100) {
                status.temperature = 0;
            }
            status.battery = 100 * (int) battery;
            
            [self writeTireStatus:status];
            
            NSString *msg = [self reportAlert:tire status:status];
            
            if (msg && [UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.alertBody = msg;
                notification.soundName = UILocalNotificationDefaultSoundName;
                [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationTireStatusUpdated object:msg userInfo:nil];
            break;
        }
        // 学习配对(ACK)
        case 0x02: {
            [self removeCommands:cmd payload:payData];
            break;
        }
        // 退出学习配对(ACK)
        case 0x03: {
            [self removeCommands:cmd payload:payData];
            break;
        }
        // 学习成功
        case 0x04: {
            Byte tire = payload[0];
//            byte[] array = Arrays.copyOfRange(data, 1, 5);
//            String str = Utils.toHexString(array, 4);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationTireMatched object:[NSNumber numberWithUnsignedChar:tire] userInfo:nil];
            break;
        }
        // 换轮模式(ACK)
        case 0x05: {
            Byte tire1 = payload[0];
            Byte tire2 = payload[1];
            TireStatus *status1 = [self getTireStatus:tire1];
            TireStatus *status2 = [self getTireStatus:tire2];
            TireStatus *statusTemp = [[TireStatus alloc] initWithName:@"temp"];
            [statusTemp setValues:status1];
            [status1 setValues:status2];
            [status2 setValues:statusTemp];
            [self removeCommands:cmd payload:payData];
            
            [self writeTireStatus:status1];
            [self writeTireStatus:status2];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationTireStatusUpdated object:nil userInfo:nil];
            break;
        }
        // 参数设置(ACK)
        case 0x06: {
            self.pressureLowLimit = 0.1f * (int) payload[0];
            self.pressureHighLimit = 0.1f * (int) payload[1];
            self.temperatureLimit = (int) payload[2];
            [self removeCommands:cmd payload:payData];
            
            [defaults setFloat:self.pressureLowLimit forKey:@"pressure-low-limit"];
            [defaults setFloat:self.pressureHighLimit forKey:@"pressure-high-limit"];
            [defaults setFloat:self.temperatureLimit forKey:@"temperature-high-limit"];
            
            break;
        }
        // 查询应答
        case 0x08: {
            self.pressureLowLimit = 0.1f * (int) payload[0];
            self.pressureHighLimit = 0.1f * (int) payload[1];
            self.temperatureLimit = (int) payload[2];
            [self removeCommands:CMD_QUERY_SETTING payload:[NSData data]];
            
            [defaults setFloat:self.pressureLowLimit forKey:@"pressure-low-limit"];
            [defaults setFloat:self.pressureHighLimit forKey:@"pressure-high-limit"];
            [defaults setFloat:self.temperatureLimit forKey:@"temperature-high-limit"];
            
            break;
        }
        default: {
            NSLog(@"Unhandled frame.");
            break;
        }
    }
}

- (void)driver:(BleDriver *)driver onError:(NSError *)error {
    NSLog(@"BleDriver error %@", error);
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationTpmsError object:error userInfo:nil];
    
    [self closeDevice];
}

- (void)driver:(BleDriver *)driver didStateChanged:(TpmsDriverState)state {
    self.state = state;
    
    if (state == TpmsStateOpen) {
        [self querySettings];
    }
}

- (NSString *)reportAlert:(Byte)tire status:(TireStatus *)status {
    NSString *prefix;
    NSString *prefix2;
    switch (tire) {
        case TIRE_LEFT_FRONT:
            prefix = @"voice_tire1_";
            prefix2 = @"alert_message_tire1_";
            break;
        case TIRE_RIGHT_FRONT:
            prefix = @"voice_tire3_";
            prefix2 = @"alert_message_tire3_";
            break;
        case TIRE_RIGHT_END:
            prefix = @"voice_tire4_";
            prefix2 = @"alert_message_tire4_";
            break;
        case TIRE_LEFT_END:
            prefix = @"voice_tire2_";
            prefix2 = @"alert_message_tire2_";
            break;
        default:
            return nil;
    }
    
    NSString *bundleName = [[FGLanguageTool sharedInstance].language isEqualToString:EN] ? @"voices-en" : @"voices";
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *voice;
    NSMutableString *result = [[NSMutableString alloc] initWithString:@""];
    NSString *key;
    switch (status.pressureStatus) {
        case PRESSURE_HIGH:
            voice = [prefix stringByAppendingString:@"pressure_high"];
            [self playAudio:[bundle URLForResource:voice withExtension:@"wav"]];
            key = [prefix2 stringByAppendingString:@"pressure_high"];
            [result appendString:FGLocalizedString(key)];
            break;
        case PRESSURE_LOW:
            voice = [prefix stringByAppendingString:@"pressure_low"];
            [self playAudio:[bundle URLForResource:voice withExtension:@"wav"]];
            key = [prefix2 stringByAppendingString:@"pressure_low"];
            [result appendString:FGLocalizedString(key)];
            break;
        case PRESSURE_ERROR:
            voice = [prefix stringByAppendingString:@"pressure_error"];
            [self playAudio:[bundle URLForResource:voice withExtension:@"wav"]];
            key = [prefix2 stringByAppendingString:@"pressure_error"];
            [result appendString:FGLocalizedString(key)];
            break;
    }
    if (status.temperatureStatus == TEMPERATURE_HIGH) {
        voice = [prefix stringByAppendingString:@"temp_high"];
        [self playAudio:[bundle URLForResource:voice withExtension:@"wav"]];
        key = [prefix2 stringByAppendingString:@"temp_high"];
        [result appendString:FGLocalizedString(key)];
    }
    if (status.batteryStatus == BATTERY_LOW) {
        voice = [prefix stringByAppendingString:@"battery_low"];
        [self playAudio:[bundle URLForResource:voice withExtension:@"wav"]];
        key = [prefix2 stringByAppendingString:@"battery_low"];
        [result appendString:FGLocalizedString(key)];
    }
    
    return result;
}

#pragma mark - Audio Player
- (void)playAudio:(NSURL *)url {
    BOOL voiceOpen = [Preferences sharedInstance].voiceOpen;
    if (!voiceOpen) {
        NSLog(@"voice closed");
        return;
    }
    if (self.audioPlayer) {
        if (!trackQueue) {
            trackQueue = [NSMutableArray arrayWithObject:url];
        } else {
            if (trackQueue.count < 3) {
                [trackQueue addObject:url];
            } else {
                NSLog(@"too much resources in the queue");
            }
        }
    } else {
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        self.audioPlayer.delegate = self;
        if (![self.audioPlayer play]) {
            NSLog(@"audioPlayer play failed");
            [trackQueue removeAllObjects];
        }
    }
}
- (void)playNextAudio {
    if (trackQueue.count > 0) {
        NSURL *url = trackQueue.firstObject;
        [trackQueue removeObjectAtIndex:0];
        [self playAudio:url];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"audioPlayerDidFinishPlaying %@", [NSNumber numberWithBool:flag]);
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    [self playNextAudio];
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    NSLog(@"audioPlayerDecodeErrorDidOccur %@", error);
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    [self playNextAudio];
}

@end
