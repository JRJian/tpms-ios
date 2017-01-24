//
//  MonitorViewController.m
//  tpms-ios
//
//  Created by ttonway on 2017/1/17.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import "MonitorViewController.h"

#import "Common.h"
#import "TpmsDevice.h"
#import "CustomIOS7AlertView.h"

@interface MonitorViewController () <CustomIOS7AlertViewDelegate> {
    UIImage *carImage;
}

@property (nonatomic) CustomIOS7AlertView *alertView;

@end

@implementation MonitorViewController
@synthesize alertView = _alertView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    carImage = [UIImage imageNamed:@"car"];
    self.carImageView = [[UIImageView alloc] initWithImage:carImage];
    self.board1 = [[TireStatusView alloc] initWithFrame:CGRectZero];
    self.board2 = [[TireStatusView alloc] initWithFrame:CGRectZero];
    self.board3 = [[TireStatusView alloc] initWithFrame:CGRectZero];
    self.board4 = [[TireStatusView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:self.carImageView];
    [self.view addSubview:self.board1];
    [self.view addSubview:self.board2];
    [self.view addSubview:self.board3];
    [self.view addSubview:self.board4];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTireStatus:) name:NotificationTireStatusUpdated object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateTireStatus:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    CGFloat carHeight = height - 80;
    CGFloat carWidth = carHeight / carImage.size.height * carImage.size.width;
    CGFloat carX = (width - carWidth) / 2.f;
    CGFloat carY = (height - carHeight) / 2.f;
    self.carImageView.frame = CGRectMake(carX, carY, carWidth, carHeight);
    
    carWidth  = carWidth * 374 / 472;
    carX = (width - carWidth) / 2.f;
    CGFloat boardWidth = carX - 16;
    CGFloat boardHeight = 150.f;
    CGFloat spacing = (carHeight - 150 * 2) / 3;
    CGRect rect = CGRectMake(8, carY + spacing, boardWidth, boardHeight);
    self.board1.frame = rect;
    rect.origin.y += boardHeight + spacing;
    self.board2.frame = rect;
    rect.origin.y = carY + spacing;
    rect.origin.x = carX + carWidth + 8;
    self.board3.frame = rect;
    rect.origin.y += boardHeight + spacing;
    self.board4.frame = rect;
}

- (void)updateTireStatus:(NSNotification *)notification {
    TpmsDevice *device = [TpmsDevice sharedInstance];
    [self.board1 setTireStatus:device.leftFront];
    [self.board2 setTireStatus:device.leftEnd];
    [self.board3 setTireStatus:device.rightFront];
    [self.board4 setTireStatus:device.rightEnd];
    
    NSString *msg = notification.object;
    if (msg.length > 0) {
        self.alertView.message = msg;
        self.alertView.okBtnTitle = FGLocalizedString(@"btn_ok");
        [self.alertView show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CustomIOS7AlertView *)alertView {
    if (!_alertView) {
        _alertView = [[CustomIOS7AlertView alloc] init];
        _alertView.delegate = self;
    }
    return _alertView;
}

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView close];
}

@end
