//
//  SettingViewController.m
//  tpms-ios
//
//  Created by ttonway on 2017/1/15.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import "SettingViewController.h"

#import "Common.h"
#import "TpmsDevice.h"
#import "RadioGroup.h"
#import "NumberPicker.h"
#import "ViewController.h"

@interface SettingViewController () <RadioGroupDelegate> {
    NSArray * tableCells;
    
    RadioGroup *voiceGroup;
    RadioGroup *languageGroup;
    RadioGroup *pressureUnitGroup;
    RadioGroup *temperatureUnitGroup;
    RadioGroup *themeGroup;
    NumberPicker *upperLimitPicker;
    NumberPicker *lowerLimitPicker;
    NumberPicker *tempLimitPicker;
    
    TpmsDevice *device;
    Preferences *preference;
}

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(16, 0, 16, 0);
    [self buildTableCells];
    
    device = [TpmsDevice sharedInstance];
    preference = [Preferences sharedInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buildTableCells) name:NotificationLanguageChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveSetting) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    upperLimitPicker.value = device.pressureHighLimit;
    lowerLimitPicker.value = device.pressureLowLimit;
    tempLimitPicker.value = device.temperatureLimit;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self saveSetting];
}

- (void)buildTableCells {
    
    UITableViewCell *cell1 = [self cellOfRadioGroup:FGLocalizedString(@"label_voice")];
    voiceGroup = (RadioGroup *)[cell1.contentView viewWithTag:222];
    [voiceGroup addRadioButton:1 title:nil image:[UIImage imageNamed:@"ic_voice_on"]];
    [voiceGroup addRadioButton:2 title:nil image:[UIImage imageNamed:@"ic_voice_off"]];
    voiceGroup.delegate = self;
    voiceGroup.checkedTag = preference.voiceOpen ? 1 : 2;
    
    UITableViewCell *cell2 = [self cellOfRadioGroup:FGLocalizedString(@"label_language")];
    languageGroup = (RadioGroup *)[cell2.contentView viewWithTag:222];
    [languageGroup addRadioButton:1 title:@"中文简体" image:nil];
    [languageGroup addRadioButton:2 title:@"中文繁體" image:nil];
    [languageGroup addRadioButton:3 title:@"English" image:nil];
    languageGroup.delegate = self;
    NSString *lan = [FGLanguageTool sharedInstance].language;
    if ([lan isEqualToString:CNS_SIMPLIFIED]) {
        languageGroup.checkedTag = 1;
    } else if ([lan isEqualToString:CNS_TRADITIONAL]) {
        languageGroup.checkedTag = 2;
    } else if ([lan isEqualToString:EN]) {
        languageGroup.checkedTag = 3;
    }
    
    UITableViewCell *cell3 = [self cellOfRadioGroup:FGLocalizedString(@"label_unit")];
    pressureUnitGroup = (RadioGroup *)[cell3.contentView viewWithTag:222];
    [pressureUnitGroup addRadioButton:1 title:@"Bar" image:nil];
    [pressureUnitGroup addRadioButton:2 title:@"PSI" image:nil];
    [pressureUnitGroup addRadioButton:3 title:@"Kpa" image:nil];
    [pressureUnitGroup addRadioButton:4 title:@"Kg" image:nil];
    pressureUnitGroup.delegate = self;
    pressureUnitGroup.checkedTag = preference.pressureUnit + 1;
    
    UITableViewCell *cell4 = [self cellOfRadioGroup:FGLocalizedString(@"label_degree")];
    temperatureUnitGroup = (RadioGroup *)[cell4.contentView viewWithTag:222];
    [temperatureUnitGroup addRadioButton:1 title:@"℃" image:nil];
    [temperatureUnitGroup addRadioButton:2 title:@"℉" image:nil];
    temperatureUnitGroup.delegate = self;
    temperatureUnitGroup.checkedTag = preference.temperatureUnit + 1;
    
    UITableViewCell *cell5 = [self cellOfRadioGroup:FGLocalizedString(@"label_theme")];
    themeGroup = (RadioGroup *)[cell5.contentView viewWithTag:222];
    [themeGroup addRadioButton:1 title:FGLocalizedString(@"theme_plain") image:nil];
    [themeGroup addRadioButton:2 title:FGLocalizedString(@"theme_star") image:nil];
    [themeGroup addRadioButton:3 title:FGLocalizedString(@"theme_modern") image:nil];
    themeGroup.delegate = self;
    themeGroup.checkedTag = preference.theme + 1;
    
    UITableViewCell *cell6 = [self cellOfNumberPicker:FGLocalizedString(@"label_pressure_max")];
    upperLimitPicker = (NumberPicker *)[cell6.contentView viewWithTag:333];
    upperLimitPicker.minValue = PRESSURE_UPPER_LIMIT_MIN;
    upperLimitPicker.maxValue = PRESSURE_UPPER_LIMIT_MAX;
    upperLimitPicker.deltaValue = 0.1f;
    upperLimitPicker.value = PRESSURE_UPPER_LIMIT_DEFAULT;
    upperLimitPicker.formatter = ^(float v) { return [Utils formatPressure:v]; };
    UITableViewCell *cell7 = [self cellOfNumberPicker:FGLocalizedString(@"label_pressure_min")];
    lowerLimitPicker = (NumberPicker *)[cell7.contentView viewWithTag:333];
    lowerLimitPicker.minValue = PRESSURE_LOWER_LIMIT_MIN;
    lowerLimitPicker.maxValue = PRESSURE_LOWER_LIMIT_MAX;
    lowerLimitPicker.deltaValue = 0.1f;
    lowerLimitPicker.value = PRESSURE_LOWER_LIMIT_DEFAULT;
    lowerLimitPicker.formatter = ^(float v) { return [Utils formatPressure:v]; };
    UITableViewCell *cell8 = [self cellOfNumberPicker:FGLocalizedString(@"label_temperature_max")];
    tempLimitPicker = (NumberPicker *)[cell8.contentView viewWithTag:333];
    tempLimitPicker.minValue = TEMP_UPPER_LIMIT_MIN;
    tempLimitPicker.maxValue = TEMP_UPPER_LIMIT_MAX;
    tempLimitPicker.deltaValue = 1.f;
    tempLimitPicker.value = TEMP_UPPER_LIMIT_DEFAULT;
    tempLimitPicker.formatter = ^(float v) { return [Utils formatTemperature:(int)v]; };

    UITableViewCell *cell9 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell9.backgroundColor = [UIColor clearColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = 444;
    button.frame = CGRectMake(0, 0, 200, 32);
    [button positiveStyle];
    [button setTitle:FGLocalizedString(@"btn_reset") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(resetSetting:) forControlEvents:UIControlEventTouchUpInside];
    [cell9.contentView addSubview:button];
    
    tableCells = @[cell1, cell2, cell3, cell4, cell5, cell6, cell7, cell8, cell9];
    [self.tableView reloadData];
}

- (UITableViewCell *)cellOfRadioGroup:(NSString *)title {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 110, 44)];
    label.tag = 111;
    label.font = [UIFont systemFontOfSize:15.f];
    label.textColor = [UIColor commonGreenColor];
    label.textAlignment = NSTextAlignmentRight;
    label.numberOfLines = 0;
    label.text = title;
    [cell.contentView addSubview:label];
    RadioGroup *group = [[RadioGroup alloc] initWithFrame:CGRectMake(126, 0, 300, 44)];
    group.tag = 222;
    [cell.contentView addSubview:group];
    return cell;
}

- (UITableViewCell *)cellOfNumberPicker:(NSString *)title {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 110, 44)];
    label.tag = 111;
    label.font = [UIFont systemFontOfSize:15.f];
    label.textColor = [UIColor commonGreenColor];
    label.textAlignment = NSTextAlignmentRight;
    label.numberOfLines = 0;
    label.text = title;
    [cell.contentView addSubview:label];
    NumberPicker *picker = [[NumberPicker alloc] initWithFrame:CGRectMake(126, 6, 300, 32)];
    picker.tag = 333;
    [cell.contentView addSubview:picker];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)radioGroup:(RadioGroup *)group didCheckedChange:(NSInteger)tag {
    if (group == voiceGroup) {
        preference.voiceOpen = tag == 1;
        
    } else if (group == languageGroup) {
        if (tag == 1) {
            [[FGLanguageTool sharedInstance] setNewLanguage:CNS_SIMPLIFIED];
        } else if (tag == 2) {
            [[FGLanguageTool sharedInstance] setNewLanguage:CNS_TRADITIONAL];
        } else if (tag == 3) {
            [[FGLanguageTool sharedInstance] setNewLanguage:EN];
        }
    } else if (group == pressureUnitGroup) {
        preference.pressureUnit = tag - 1;
        
        upperLimitPicker.formatter = ^(float v) { return [Utils formatPressure:v]; };
        lowerLimitPicker.formatter = ^(float v) { return [Utils formatPressure:v]; };
        
    } else if (group == temperatureUnitGroup) {
        preference.temperatureUnit = tag - 1;
        
        tempLimitPicker.formatter = ^(float v) { return [Utils formatTemperature:(int)v]; };
        
    } else if (group == themeGroup) {
        preference.theme = tag - 1;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableCells.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableCells objectAtIndex:indexPath.row];
    RadioGroup *group = [cell.contentView viewWithTag:222];
    CGFloat h = 44;
    if (group) {
        CGFloat w = tableView.bounds.size.width - group.frame.origin.x - 8;
        h = [group configBoundsWidth:w];
        CGRect frame = group.frame;
        frame.size.width = w;
        frame.size.height = h;
        group.frame = frame;
    }
    
    NumberPicker *picker = [cell.contentView viewWithTag:333];
    if (picker) {
        CGRect frame = picker.frame;
        frame.size.width = tableView.bounds.size.width - picker.frame.origin.x - 8;
        picker.frame = frame;
    }
    
    UIView *centerView = [cell.contentView viewWithTag:444];
    if (centerView) {
        centerView.center = CGPointMake(tableView.bounds.size.width / 2, 22);
    }
    
    return h;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableCells objectAtIndex:indexPath.row];
    return cell;
}

- (void)saveSetting {
    float bar1 = upperLimitPicker.value;
    float bar2 = lowerLimitPicker.value;
    int degree = (int) tempLimitPicker.value;
    
    if ([device isSettingsChanged:bar2 high:bar1 temp:degree]) {
        [device saveSettings:bar2 high:bar1 temp:degree];
    }
}

- (IBAction)resetSetting:(id)sender {
    [device saveSettings:PRESSURE_LOWER_LIMIT_DEFAULT high:PRESSURE_UPPER_LIMIT_DEFAULT temp:TEMP_UPPER_LIMIT_DEFAULT];
    [device clearData];
    
    [preference clear];
    
    ViewController *mainController = (ViewController *)self.parentViewController;
    [mainController viewMonitorController:nil];
}

@end
