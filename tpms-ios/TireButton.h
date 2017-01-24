//
//  TireButton.h
//  tpms-ios
//
//  Created by ttonway on 2017/1/22.
//  Copyright © 2017年 ttonway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TireButton : UIButton

@property (nonatomic) UILabel *label;
@property (nonatomic) UIView *underLine;
@property (nonatomic) UIImageView *selectedIcon;

@property (nonatomic) NSString *title;

@end
