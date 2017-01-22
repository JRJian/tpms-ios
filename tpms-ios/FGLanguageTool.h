//
//  FGLanguageTool.h
//  tpms-ios
//
//  Created by ttonway on 2017/1/20.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import <Foundation/Foundation.h>


#define FGLocalizedString(key) [[FGLanguageTool sharedInstance] getStringForKey:key withTable:@"Localizable"]

extern NSString * const NotificationLanguageChange;

extern NSString * const CNS_SIMPLIFIED;
extern NSString * const CNS_TRADITIONAL;
extern NSString * const EN;


@interface FGLanguageTool : NSObject

@property (nonatomic) NSString *language;

+ (FGLanguageTool *)sharedInstance;

/**
 *  返回table中指定的key的值
 *
 *  @param key   key
 *  @param table table
 *
 *  @return 返回table中指定的key的值
 */
- (NSString *)getStringForKey:(NSString *)key withTable:(NSString *)table;

/**
 *  设置新的语言
 *
 *  @param language 新语言
 */
- (void)setNewLanguage:(NSString*)language;

@end
