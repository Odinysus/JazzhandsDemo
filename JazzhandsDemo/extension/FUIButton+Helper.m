//
//  FUIButton+Helper.m
//  isigoyi
//
//  Created by qiang on 16/7/18.
//  Copyright © 2016年 akite. All rights reserved.
//

#import "FUIButton+Helper.h"

@implementation FUIButton (Helper)

+ (FUIButton *)defaultBtn
{
    UIColor *tinColor = [UIColor cyanColor];
    FUIButton *dButton  = [[FUIButton alloc] initWithFrame:CGRectZero];
    [dButton setButtonColor:tinColor];
    [dButton setShadowColor:[UIColor greenSeaColor]];
    [dButton setShadowHeight:3.0f];
    [dButton setCornerRadius:6.0f];
    dButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    UIColor *titleColor = [UIColor whiteColor];
    [dButton setTitleColor:titleColor forState:UIControlStateNormal];
    [dButton setTitleColor:titleColor forState:UIControlStateHighlighted];
    [dButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    return dButton;
}
@end
