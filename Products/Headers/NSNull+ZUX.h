//
//  NSNull+ZUX.h
//  ZUtilsX
//
//  Created by Char Aznable on 15/11/13.
//  Copyright © 2015年 org.cuc.n3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZUXCategory.h"

#ifndef ZUtilsX_NSNull_ZUX_h
#define ZUtilsX_NSNull_ZUX_h

ZUX_CATEGORY_H(ZUX_NSNull)

@interface NSNull (ZUX)

+ (BOOL)isNull:(id)obj;
+ (BOOL)isNotNull:(id)obj;

@end

#endif /* ZUtilsX_NSNull_ZUX_h */
