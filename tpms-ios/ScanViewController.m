//
//  ScanViewController.m
//  tpms-ios
//
//  Created by ttonway on 2017/1/23.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import "ScanViewController.h"

#import "Common.h"
#import "TpmsDevice.h"

static NSString *cellIdentifier = @"cell-identifier";

@interface ScanViewController () <ScanDelegate> {
    BleDriver *driver;
    
    BOOL navigationBarHidden;
}

@property (nonatomic) UIImageView *backgroundView;
@property (nonatomic) UILabel *emptyLabel;

@property (nonatomic) NSMutableArray *foundDevice;

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = FGLocalizedString(@"activity_scan");
    
    driver = [TpmsDevice sharedInstance].dirver;
    self.foundDevice = [NSMutableArray array];
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_plain"]];
    self.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    self.tableView.backgroundView = self.backgroundView;
    self.emptyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.emptyLabel.text = FGLocalizedString(@"error_bluetooth_not_supported");
    self.emptyLabel.textColor = [UIColor lightTextColor];
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.emptyLabel.frame = self.tableView.bounds;
}

- (void)driver:(BleDriver *)service didDiscoverPeripheral:(CBPeripheral *)peripheral {
    if (![self.foundDevice containsObject:peripheral]) {
        [self.foundDevice addObject:peripheral];
        [self.tableView reloadData];
    }
}

- (void)driverDidPowerOn:(BleDriver *)service {
    [self.emptyLabel removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    navigationBarHidden = self.navigationController.navigationBarHidden;
    self.navigationController.navigationBarHidden = NO;
    
    [driver startScan:self];
    if (driver.centralManager.state == CBCentralManagerStatePoweredOn) {
        [self.emptyLabel removeFromSuperview];
    } else {
        [self.tableView addSubview:self.emptyLabel];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = navigationBarHidden;
    [driver stopScan];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.foundDevice.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    UIView *indicator = [cell.contentView viewWithTag:5];
    if (!indicator) {
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        
        indicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 44)];
        indicator.backgroundColor = [UIColor commonGreenColor];
        indicator.tag = 5;
        [cell.contentView addSubview:indicator];
    }
    
    CBPeripheral *peripheral = [self.foundDevice objectAtIndex:indexPath.row];
    NSString *name = peripheral.name;
    if (name.length == 0) {
        name = FGLocalizedString(@"unknown_device");
    }
    cell.textLabel.text = name;
    indicator.hidden = ![peripheral isEqual:driver.currentPeripheral];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CBPeripheral *peripheral = [self.foundDevice objectAtIndex:indexPath.row];
    [driver connect:peripheral];
    [self.tableView reloadData];
}

@end
