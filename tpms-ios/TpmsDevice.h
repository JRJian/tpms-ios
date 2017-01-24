//
//  TpmsDevice.h
//  tpms-ios
//
//  Created by ttonway on 2017/1/23.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "TireStatus.h"
#import "BleDriver.h"
#import "WriteCommand.h"

extern NSString * const NotificationTpmsError;
extern NSString * const NotificationTireStatusUpdated;
extern NSString * const NotificationTireMatched;

@interface TpmsDevice : NSObject <DriverDelegate, AVAudioPlayerDelegate> {
    NSMutableArray *trackQueue;
}

@property (nonatomic) AVAudioPlayer *audioPlayer;

@property (nonatomic) BleDriver *dirver;

@property (nonatomic) TpmsDriverState state;
@property (nonatomic) BOOL hasError;

@property (nonatomic) float pressureLowLimit;
@property (nonatomic) float pressureHighLimit;
@property (nonatomic) int temperatureLimit;

@property (nonatomic) TireStatus *leftFront;
@property (nonatomic) TireStatus *rightFront;
@property (nonatomic) TireStatus *leftEnd;
@property (nonatomic) TireStatus *rightEnd;

+ (TpmsDevice *)sharedInstance;

- (void)clearData;

- (BOOL)openDevice;
- (void)closeDevice;

- (void)startTireMatch:(Byte)tire;
- (void)stopTireMatch;
- (void)exchangeTire:(Byte)tire1 andTire:(Byte)tire2;
- (void)saveSettings:(float)lowLimit high:(float)highLimit temp:(int)tempLimit;
- (void)querySettings;
- (BOOL)isSettingsChanged:(float)lowLimit high:(float)highLimit temp:(int)tempLimit;

- (void)playAudio:(NSURL *)url;

@end
