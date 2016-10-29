//
//  UIColor+expand.h
//  JazzhandsDemo
//
//  Created by qiang on 10/29/16.
//  Copyright © 2016 akite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (expand)

+ (UIColor *)colorWithRGBHex:(UInt32)hex ;
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert ;
@end
