//
//  UIBarItem+ZUX.m
//  ZUtilsX
//
//  Created by Char Aznable on 15/12/14.
//  Copyright © 2015年 org.cuc.n3. All rights reserved.
//

#import "UIBarItem+ZUX.h"
#import "ZUXGeometry.h"
#import "zadapt.h"
#import "zappearance.h"

ZUX_CATEGORY_M(ZUX_UIBarItem)

@implementation UIBarItem (ZUX)

+ (UIFont *)textFontForState:(UIControlState)state {
    return TitleTextAttributeForKeyForState(ZUXFontAttributeName, state);
}

+ (void)setTextFont:(UIFont *)textFont forState:(UIControlState)state {
    SetTitleTextAttributeForKeyForState(ZUXFontAttributeName, textFont, state);
}

+ (UIColor *)textColorForState:(UIControlState)state {
    return TitleTextAttributeForKeyForState(ZUXForegroundColorAttributeName, state);
}

+ (void)setTextColor:(UIColor *)textColor forState:(UIControlState)state {
    SetTitleTextAttributeForKeyForState(ZUXForegroundColorAttributeName, textColor, state);
}

+ (UIColor *)textShadowColorForState:(UIControlState)state {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
    return TitleShadowAttributeForState(state).shadowColor;
#else
    return TitleTextAttributeForKeyForState(UITextAttributeTextShadowColor, state);
#endif
}

+ (void)setTextShadowColor:(UIColor *)textShadowColor forState:(UIControlState)state {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
    NSShadow *shadow = DefaultTitleShadowAttributeForState(state);
    [shadow setShadowColor:textShadowColor];
    SetTitleShadowAttributeForState(shadow, state);
#else
    SetTitleTextAttributeForKeyForState(UITextAttributeTextShadowColor, textShadowColor, state);
#endif
}

+ (CGSize)textShadowOffsetForState:(UIControlState)state {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
    return TitleShadowAttributeForState(state).shadowOffset;
#else
    return ZUX_CGSizeFromUIOffset([TitleTextAttributeForKeyForState(UITextAttributeTextShadowOffset, state) UIOffsetValue]);
#endif
}

+ (void)setTextShadowOffset:(CGSize)textShadowOffset forState:(UIControlState)state {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
    NSShadow *shadow = DefaultTitleShadowAttributeForState(state);
    [shadow setShadowOffset:textShadowOffset];
    SetTitleShadowAttributeForState(shadow, state);
#else
    NSValue *offsetValue = [NSValue valueWithUIOffset:ZUX_UIOffsetFromCGSize(textShadowOffset)];
    SetTitleTextAttributeForKeyForState(UITextAttributeTextShadowOffset, offsetValue, state);
#endif
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
+ (CGFloat)textShadowSizeForState:(UIControlState)state {
    return TitleShadowAttributeForState(state).shadowBlurRadius;
}

+ (void)setTextShadowSize:(CGFloat)textShadowSize forState:(UIControlState)state {
    NSShadow *shadow = DefaultTitleShadowAttributeForState(state);
    [shadow setShadowBlurRadius:textShadowSize];
    SetTitleShadowAttributeForState(shadow, state);
}
#endif // __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000

@end
