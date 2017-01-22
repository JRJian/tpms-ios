//
//  LearnViewController.m
//  tpms-ios
//
//  Created by ttonway on 2017/1/17.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import "LearnViewController.h"

@interface LearnViewController () {
    UIImage *carImage;
}

@end

@implementation LearnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    carImage = [UIImage imageNamed:@"car"];
    self.carImageView = [[UIImageView alloc] initWithImage:carImage];
    
    [self.view addSubview:self.carImageView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    CGFloat carHeight = height;
    CGFloat carWidth = carHeight / carImage.size.height * carImage.size.width;
    self.carImageView.frame = CGRectMake((width - carWidth) / 2.f, (height - carHeight) / 2.f, carWidth, carHeight);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
