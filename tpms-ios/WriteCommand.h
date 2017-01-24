//
//  WriteCommand.h
//  tpms-ios
//
//  Created by ttonway on 2017/1/23.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import <Foundation/Foundation.h>


#define TIRE_NONE                        ((Byte)0xFF)
#define TIRE_LEFT_FRONT                  ((Byte)0x00)
#define TIRE_RIGHT_FRONT                 ((Byte)0x01)
#define TIRE_RIGHT_END                   ((Byte)0x02)
#define TIRE_LEFT_END                    ((Byte)0x03)


#define CMD_START_TIRE_MATCH             ((Byte)0x02)
#define CMD_STOP_TIRE_MATCH              ((Byte)0x03)
#define CMD_EXCHANGE_TIRE                ((Byte)0x05)
#define CMD_SAVE_SETTING                 ((Byte)0x06)
#define CMD_QUERY_SETTING                ((Byte)0x07)

@interface WriteCommand : NSObject

@property (nonatomic) Byte command;
@property (nonatomic) NSData* payload;
@property (nonatomic) int tryCount;

@end
