//
//  FGLanguageTool.m
//  tpms-ios
//
//  Created by ttonway on 2017/1/20.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import "FGLanguageTool.h"

#define LANGUAGE_SET @"langeuageset"

NSString * const NotificationLanguageChange = @"Notification_LanguageChange";
NSString * const CNS_SIMPLIFIED = @"zh-Hans";
NSString * const CNS_TRADITIONAL = @"zh-Hant";
NSString * const EN = @"en";


static FGLanguageTool *sharedModel;

@interface FGLanguageTool()

@property (nonatomic,strong) NSBundle *bundle;

@end

@implementation FGLanguageTool

+ (FGLanguageTool *)sharedInstance {
    if (!sharedModel) {
        sharedModel = [[FGLanguageTool alloc] init];
    }
    
    return sharedModel;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initLanguage];
    }
    
    return self;
}

- (void)initLanguage {
    NSString *tmp = [[NSUserDefaults standardUserDefaults] objectForKey:LANGUAGE_SET];
    if (!tmp) {
        tmp = CNS_SIMPLIFIED;
    }
    
    self.language = tmp;
    NSString *path = [[NSBundle mainBundle]pathForResource:self.language ofType:@"lproj"];
    self.bundle = [NSBundle bundleWithPath:path];
}

- (NSString *)getStringForKey:(NSString *)key withTable:(NSString *)table {
    if (self.bundle) {
        return NSLocalizedStringFromTableInBundle(key, table, self.bundle, @"");
    }
    
    return NSLocalizedStringFromTable(key, table, @"");
}

- (void)setNewLanguage:(NSString *)language {
    if ([language isEqualToString:self.language]) {
        return;
    }
    
    self.language = language;
    NSString *path = [[NSBundle mainBundle]pathForResource:language ofType:@"lproj"];
    self.bundle = [NSBundle bundleWithPath:path];
    
    [[NSUserDefaults standardUserDefaults] setObject:language forKey:LANGUAGE_SET];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationLanguageChange object:nil userInfo:nil];
}

@end
