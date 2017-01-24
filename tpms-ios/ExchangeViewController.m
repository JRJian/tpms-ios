//
//  ExchangeViewController.m
//  tpms-ios
//
//  Created by ttonway on 2017/1/17.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import "ExchangeViewController.h"

#import "Common.h"
#import "TpmsDevice.h"
#import "CustomIOS7AlertView.h"

@interface ExchangeViewController () <CustomIOS7AlertViewDelegate> {
    UIImage *carImage;
    
    TireButton *selectedBorad1;
    TireButton *selectedBorad2;
}

@property (nonatomic) CustomIOS7AlertView *exchangeAlertView;

@end

@implementation ExchangeViewController
@synthesize exchangeAlertView = _exchangeAlertView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    carImage = [UIImage imageNamed:@"car"];
    self.carImageView = [[UIImageView alloc] initWithImage:carImage];
    self.board1 = [[TireButton alloc] initWithFrame:CGRectZero];
    self.board2 = [[TireButton alloc] initWithFrame:CGRectZero];
    self.board3 = [[TireButton alloc] initWithFrame:CGRectZero];
    self.board4 = [[TireButton alloc] initWithFrame:CGRectZero];
    self.board1.tag = TIRE_LEFT_FRONT;
    self.board2.tag = TIRE_LEFT_END;
    self.board3.tag = TIRE_RIGHT_FRONT;
    self.board4.tag = TIRE_RIGHT_END;
    [self.board1 addTarget:self action:@selector(toggleSelectTire:) forControlEvents:UIControlEventTouchUpInside];
    [self.board2 addTarget:self action:@selector(toggleSelectTire:) forControlEvents:UIControlEventTouchUpInside];
    [self.board3 addTarget:self action:@selector(toggleSelectTire:) forControlEvents:UIControlEventTouchUpInside];
    [self.board4 addTarget:self action:@selector(toggleSelectTire:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.carImageView];
    [self.view addSubview:self.board1];
    [self.view addSubview:self.board2];
    [self.view addSubview:self.board3];
    [self.view addSubview:self.board4];
    
    [self updateLocalizedStrings];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocalizedStrings) name:NotificationLanguageChange object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)updateLocalizedStrings {
    self.board1.title = FGLocalizedString(@"btn_tire1");
    self.board2.title = FGLocalizedString(@"btn_tire2");
    self.board3.title = FGLocalizedString(@"btn_tire3");
    self.board4.title = FGLocalizedString(@"btn_tire4");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleSelectTire:(id)sender {
    TireButton *btn = (TireButton *)sender;
    btn.selected = !btn.selected;
    
    selectedBorad1 = nil;
    selectedBorad2 = nil;
    for (TireButton *board in @[self.board1, self.board2, self.board3, self.board4]) {
        if (board.isSelected) {
            if (!selectedBorad1) {
                selectedBorad1 = board;
            } else if (!selectedBorad2) {
                selectedBorad2 = board;
                break;
            }
        }
    }
    
    if (selectedBorad1 && selectedBorad2) {
        NSString *name1 = selectedBorad1.title;
        NSString *name2 = selectedBorad2.title;
        NSString *str = [NSString stringWithFormat:FGLocalizedString(@"alert_message_exchange"), name1, name2];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:[UIColor commonGreenColor]
                        range:[str rangeOfString:name1]];
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:[UIColor commonGreenColor]
                        range:[str rangeOfString:name2]];
        
        self.exchangeAlertView.attributedMessage = attrStr;
        self.exchangeAlertView.okBtnTitle = FGLocalizedString(@"btn_ok");
        self.exchangeAlertView.cancelBtnTitle = FGLocalizedString(@"btn_cancel");
        [self.exchangeAlertView show];
    }
}

- (CustomIOS7AlertView *)exchangeAlertView {
    if (!_exchangeAlertView) {
        _exchangeAlertView = [[CustomIOS7AlertView alloc] init];
        _exchangeAlertView.delegate = self;
    }
    return _exchangeAlertView;
}

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView close];
    for (TireButton *board in @[self.board1, self.board2, self.board3, self.board4]) {
        board.selected = NO;
    }
    
    if (buttonIndex == 0) {
        if (selectedBorad1 && selectedBorad2) {
            Byte tire1 = selectedBorad1.tag;
            Byte tire2 = selectedBorad2.tag;
            [[TpmsDevice sharedInstance] exchangeTire:tire1 andTire:tire2];
        }
    }
}

@end
