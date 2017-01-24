//
//  LearnViewController.m
//  tpms-ios
//
//  Created by ttonway on 2017/1/17.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import "LearnViewController.h"

#import "Common.h"
#import "TpmsDevice.h"
#import "CustomIOS7AlertView.h"


@interface LearnViewController () <CustomIOS7AlertViewDelegate> {
    UIImage *carImage;
    
    TpmsDevice *device;
    Byte matchingTire;
    NSTimeInterval matchTimeout;
}

@property (nonatomic) CustomIOS7AlertView *learnAlertView;
@property (nonatomic) CustomIOS7AlertView *successAlertView;

@end

@implementation LearnViewController
@synthesize learnAlertView = _learnAlertView;
@synthesize successAlertView = _successAlertView;

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
    [self.board1 addTarget:self action:@selector(startMatch:) forControlEvents:UIControlEventTouchUpInside];
    [self.board2 addTarget:self action:@selector(startMatch:) forControlEvents:UIControlEventTouchUpInside];
    [self.board3 addTarget:self action:@selector(startMatch:) forControlEvents:UIControlEventTouchUpInside];
    [self.board4 addTarget:self action:@selector(startMatch:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.carImageView];
    [self.view addSubview:self.board1];
    [self.view addSubview:self.board2];
    [self.view addSubview:self.board3];
    [self.view addSubview:self.board4];
    
    [self updateLocalizedStrings];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocalizedStrings) name:NotificationLanguageChange object:nil];
    
    device = [TpmsDevice sharedInstance];
    matchingTire = TIRE_NONE;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMatchedSuccess:) name:NotificationTireMatched object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetTireMatch) name:NotificationTpmsError object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelTireMatch) name:UIApplicationWillResignActiveNotification object:nil];
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
    self.board1.title = FGLocalizedString(@"btn_tire1_match");
    self.board2.title = FGLocalizedString(@"btn_tire2_match");
    self.board3.title = FGLocalizedString(@"btn_tire3_match");
    self.board4.title = FGLocalizedString(@"btn_tire4_match");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startMatch:(id)sender {
    
    TireButton *board = (TireButton *)sender;
    matchingTire = board.tag;
    [device startTireMatch:matchingTire];
    matchTimeout = 120;
    self.learnAlertView.message = [NSString stringWithFormat:FGLocalizedString(@"alert_message_learn"), (int)matchTimeout];
    self.learnAlertView.okBtnTitle = FGLocalizedString(@"btn_ok");
    self.learnAlertView.cancelBtnTitle = FGLocalizedString(@"btn_cancel");
    [self.learnAlertView show];
    [LearnViewController cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateTimeout) object:nil];
    [self performSelector:@selector(updateTimeout) withObject:nil afterDelay:1];
}

- (void)updateTimeout {
    matchTimeout = matchTimeout - 1;
    if (matchTimeout < 0) {
        [self cancelTireMatch];
    } else {
        self.learnAlertView.message = [NSString stringWithFormat:FGLocalizedString(@"alert_message_learn"), (int)matchTimeout];
        [self performSelector:@selector(updateTimeout) withObject:nil afterDelay:1];
    }
    
}

- (void)cancelTireMatch {
    [self.learnAlertView close];
    [LearnViewController cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateTimeout) object:nil];
    if (matchingTire != TIRE_NONE) {
        [device startTireMatch:matchingTire];
        matchingTire = TIRE_NONE;
    }
}

- (void)resetTireMatch {
    [LearnViewController cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateTimeout) object:nil];
    matchingTire = TIRE_NONE;
    [self.learnAlertView close];
}

- (void)onMatchedSuccess:(NSNotification *)notification {
    NSNumber *num = notification.object;
    Byte tire = [num unsignedCharValue];
    if (tire == matchingTire) {
        [self resetTireMatch];
        
        NSBundle *bundle = [NSBundle mainBundle];
        switch (tire) {
            case TIRE_LEFT_FRONT:
                self.successAlertView.message = FGLocalizedString(@"alert_message_tire1_matched");
                [device playAudio:[bundle URLForResource:@"R.raw.voice_tire1_match_success" withExtension:@"wav"]];
                break;
            case TIRE_LEFT_END:
                self.successAlertView.message = FGLocalizedString(@"alert_message_tire2_matched");
                [device playAudio:[bundle URLForResource:@"R.raw.voice_tire2_match_success" withExtension:@"wav"]];
                break;
            case TIRE_RIGHT_FRONT:
                self.successAlertView.message = FGLocalizedString(@"alert_message_tire3_matched");
                [device playAudio:[bundle URLForResource:@"R.raw.voice_tire3_match_success" withExtension:@"wav"]];
                break;
            case TIRE_RIGHT_END:
                self.successAlertView.message = FGLocalizedString(@"alert_message_tire4_matched");
                [device playAudio:[bundle URLForResource:@"R.raw.voice_tire4_match_success" withExtension:@"wav"]];
                break;
                
        }
        self.successAlertView.okBtnTitle = FGLocalizedString(@"btn_ok");
        [self.successAlertView show];
    }
}

- (CustomIOS7AlertView *)learnAlertView {
    if (!_learnAlertView) {
        _learnAlertView = [[CustomIOS7AlertView alloc] init];
        _learnAlertView.delegate = self;
    }
    return _learnAlertView;
}
- (CustomIOS7AlertView *)successAlertView {
    if (!_successAlertView) {
        _successAlertView = [[CustomIOS7AlertView alloc] init];
        _successAlertView.delegate = self;
    }
    return _successAlertView;
}

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.learnAlertView) {
        [alertView close];
        [self cancelTireMatch];
    } else if (alertView == self.successAlertView) {
        [alertView close];
    }
}

@end
