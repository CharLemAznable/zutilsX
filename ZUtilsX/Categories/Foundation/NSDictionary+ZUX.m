//
//  NSDictionary+ZUX.m
//  ZUtilsX
//
//  Created by Char Aznable on 15/11/13.
//  Copyright © 2015年 org.cuc.n3. All rights reserved.
//

#import "NSDictionary+ZUX.h"
#import "NSNull+ZUX.h"
#import "ZUXBundle.h"
#import "zarc.h"

ZUX_CATEGORY_M(ZUX_NSDictionary)

@implementation NSDictionary (ZUX)

- (NSDictionary *)deepCopy {
    return [[NSDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:
                                                     [NSKeyedArchiver archivedDataWithRootObject:self]]];
}

- (NSMutableDictionary *)deepMutableCopy {
    return [[NSMutableDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:
                                                            [NSKeyedArchiver archivedDataWithRootObject:self]]];
}

- (id)objectForKey:(id)key defaultValue:(id)defaultValue {
    ZUX_ENABLE_CATEGORY(ZUX_NSNull);
    return [NSNull isNull:[self objectForKey:key]] ? defaultValue : [self objectForKey:key];
}

- (NSDictionary *)subDictionaryForKeys:(NSArray *)keys {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([keys containsObject:key]) [dict setValue:obj forKey:key];
    }];
    return ZUX_AUTORELEASE([dict copy]);
}

@end

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
@implementation NSDictionary (ZUXSubscript)

- (id)objectForKeyedSubscript:(id)key {
    return [self objectForKey:key];
}

@end

@implementation NSMutableDictionary (ZUXSubscript)

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    [self setObject:obj forKey:key];
}

@end
#endif

@implementation NSDictionary (ZUXDirectory)

- (BOOL)writeToUserFile:(NSString *)filePath {
    return [self writeToUserFile:filePath inDirectory:ZUXDocument];
}

+ (NSDictionary *)dictionaryWithContentsOfUserFile:(NSString *)filePath {
    return [self dictionaryWithContentsOfUserFile:filePath inDirectory:ZUXDocument];
}

- (BOOL)writeToUserFile:(NSString *)filePath inDirectory:(ZUXDirectoryType)directory {
    if (ZUX_EXPECT_F(![ZUXDirectory createDirectory:[filePath stringByDeletingLastPathComponent]
                                        inDirectory:directory])) return NO;
    return [self writeToFile:[ZUXDirectory fullFilePath:filePath inDirectory:directory]
                  atomically:YES];
}

+ (NSDictionary *)dictionaryWithContentsOfUserFile:(NSString *)filePath inDirectory:(ZUXDirectoryType)directory {
    if (ZUX_EXPECT_F(![ZUXDirectory fileExists:filePath inDirectory:directory])) return nil;
    return [NSDictionary dictionaryWithContentsOfFile:[ZUXDirectory fullFilePath:filePath inDirectory:directory]];
}

@end

@implementation NSDictionary (ZUXBundle)

+ (NSDictionary *)dictionaryWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName {
    return [self dictionaryWithContentsOfUserFile:fileName bundle:bundleName subpath:nil];
}

+ (NSDictionary *)dictionaryWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName subpath:(NSString *)subpath {
    return [self dictionaryWithContentsOfFile:[ZUXBundle plistPathWithName:fileName bundle:bundleName subpath:subpath]];
}

@end
