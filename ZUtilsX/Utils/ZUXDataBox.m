//
//  ZUXDataBox.m
//  ZUtilsX
//
//  Created by Char Aznable on 16/1/15.
//  Copyright © 2016年 org.cuc.n3. All rights reserved.
//

#import "ZUXDataBox.h"
#import "NSObject+ZUX.h"
#import "ZUXProperty.h"
#import "ZUXKeychain.h"
#import "ZUXJson.h"

#define ShareUserDefaults               [NSUserDefaults standardUserDefaults]
#define AppKeyFormat(key)               [NSString stringWithFormat:@"%@."@#key, appIdentifier]
#define ClassKeyFormat(className, key)  [NSString stringWithFormat:@"%@."@#className@"."@#key, appIdentifier]

NSString *ZUXAppEverLaunchedKey = nil;
NSString *ZUXAppFirstLaunchKey = nil;

@implementation ZUXDataBox

ZUX_CONSTRUCTOR void construct_ZUX_DATABOX_launchData() {
    ZUXAppEverLaunchedKey = ZUXAppEverLaunchedKey ?: ZUX_RETAIN(AppKeyFormat(AppEverLaunched));
    ZUXAppFirstLaunchKey = ZUXAppFirstLaunchKey ?: ZUX_RETAIN(AppKeyFormat(AppFirstLaunch));
    
    if (![ShareUserDefaults boolForKey:ZUXAppEverLaunchedKey]) {
        [ShareUserDefaults setBool:YES forKey:ZUXAppEverLaunchedKey];
        [ShareUserDefaults setBool:YES forKey:ZUXAppFirstLaunchKey];
    } else [ShareUserDefaults setBool:NO forKey:ZUXAppFirstLaunchKey];
    NSLog(@"%@: %d", ZUXAppEverLaunchedKey, [ShareUserDefaults boolForKey:ZUXAppEverLaunchedKey]);
    NSLog(@"%@: %d", ZUXAppFirstLaunchKey, [ShareUserDefaults boolForKey:ZUXAppFirstLaunchKey]);
    [ShareUserDefaults synchronize];
}

+ (BOOL)appEverLaunched {
    return [ShareUserDefaults boolForKey:ZUXAppEverLaunchedKey];
}

+ (BOOL)appFirstLaunch {
    return [ShareUserDefaults boolForKey:ZUXAppFirstLaunchKey];
}

@end

#pragma mark -

ZUX_STATIC NSString *const DataBoxDefaultShareKey = @"DataBoxDefaultShareKey";
ZUX_STATIC NSString *const DataBoxKeychainShareKey = @"DataBoxKeychainShareKey";
ZUX_STATIC NSString *const DataBoxKeychainShareDomainKey = @"DataBoxKeychainShareDomainKey";
ZUX_STATIC NSString *const DataBoxGeisKeychainShareKey = @"DataBoxGeisKeychainShareKey";
ZUX_STATIC NSString *const DataBoxGeisKeychainShareDomainKey = @"DataBoxGeisKeychainShareDomainKey";
ZUX_STATIC NSString *const DataBoxDefaultUsersKey = @"DataBoxDefaultUsersKey";
ZUX_STATIC NSString *const DataBoxKeychainUsersKey = @"DataBoxKeychainUsersKey";
ZUX_STATIC NSString *const DataBoxKeychainUsersDomainKey = @"DataBoxKeychainUsersDomainKey";
ZUX_STATIC NSString *const DataBoxGeisKeychainUsersKey = @"DataBoxGeisKeychainUsersKey";
ZUX_STATIC NSString *const DataBoxGeisKeychainUsersDomainKey = @"DataBoxGeisKeychainUsersDomainKey";

ZUX_STATIC void defaultDataSynchronize(id instance, NSString *key);
ZUX_STATIC void keychainDataSynchronize(id instance, NSString *key, NSString *domain);
ZUX_STATIC void geisKeychainDataSynchronize(id instance, NSString *key, NSString *domain);

ZUX_STATIC NSDictionary *defaultData(id instance, NSString *key);
ZUX_STATIC NSDictionary *keychainData(id instance, NSString *key, NSString *domain);
ZUX_STATIC NSDictionary *geisKeychainData(id instance, NSString *key, NSString *domain);

ZUX_STATIC NSDictionary *userDataRef(NSDictionary *dataRef, id userId);

#pragma mark -

void constructZUXDataBox(const char *className) {
    Class cls = objc_getClass(className);
    
#define setKeyProperty(sel, key)                            \
[cls setProperty:[cls respondsToSelector:@selector(sel)] ?  \
 [cls sel] : ClassKeyFormat(className, key)                 \
 forAssociateKey:DataBox##key##Key]
    setKeyProperty(defaultShareKey, DefaultShare);
    setKeyProperty(keychainShareKey, KeychainShare);
    setKeyProperty(keychainShareDomain, KeychainShareDomain);
    setKeyProperty(geisKeychainShareKey, GeisKeychainShare);
    setKeyProperty(geisKeychainShareDomain, GeisKeychainShareDomain);
    setKeyProperty(defaultUsersKey, DefaultUsers);
    setKeyProperty(keychainUsersKey, KeychainUsers);
    setKeyProperty(keychainUsersDomain, KeychainUsersDomain);
    setKeyProperty(geisKeychainUsersKey, GeisKeychainUsers);
    setKeyProperty(geisKeychainUsersDomain, GeisKeychainUsersDomain);
}

#define keyProperty(key) [[instance class] propertyForAssociateKey:DataBox##key##Key]

void defaultShareDataSynchronize(id instance) {
    defaultDataSynchronize(instance, keyProperty(DefaultShare));
}

void keychainShareDataSynchronize(id instance) {
    keychainDataSynchronize(instance, keyProperty(KeychainShare), keyProperty(KeychainShareDomain));
}

void geisKeychainShareDataSynchronize(id instance) {
    geisKeychainDataSynchronize(instance, keyProperty(GeisKeychainShare), keyProperty(GeisKeychainShareDomain));
}

void defaultUsersDataSynchronize(id instance) {
    defaultDataSynchronize(instance, keyProperty(DefaultUsers));
}

void keychainUsersDataSynchronize(id instance) {
    keychainDataSynchronize(instance, keyProperty(KeychainUsers), keyProperty(KeychainUsersDomain));
}

void geisKeychainUsersDataSynchronize(id instance) {
    geisKeychainDataSynchronize(instance, keyProperty(GeisKeychainUsers), keyProperty(GeisKeychainUsersDomain));
}

NSDictionary *defaultShareData(id instance) {
    return defaultData(instance, keyProperty(DefaultShare));
}

NSDictionary *keychainShareData(id instance) {
    return keychainData(instance, keyProperty(KeychainShare), keyProperty(KeychainShareDomain));
}

NSDictionary *geisKeychainShareData(id instance) {
    return geisKeychainData(instance, keyProperty(GeisKeychainShare), keyProperty(GeisKeychainShareDomain));
}

NSDictionary *defaultUsersData(id instance, NSString *userIdKey) {
    return userDataRef(defaultData(instance, keyProperty(DefaultUsers)),
                       [instance valueForKey:userIdKey]);
}

NSDictionary *keychainUsersData(id instance, NSString *userIdKey) {
    return userDataRef(keychainData(instance, keyProperty(KeychainUsers), keyProperty(KeychainUsersDomain)),
                       [instance valueForKey:userIdKey]);
}

NSDictionary *geisKeychainUsersData(id instance, NSString *userIdKey) {
    return userDataRef(geisKeychainData(instance, keyProperty(GeisKeychainUsers), keyProperty(GeisKeychainUsersDomain)),
                       [instance valueForKey:userIdKey]);
}

void synthesizeProperty(NSString *className, NSString *propertyName, NSDictionary *(^dataRef)(id instance)) {
    Class cls = objc_getClass(className.UTF8String);
    ZUXProperty *property = [ZUXProperty propertyWithName:propertyName inClass:cls];
    NSCAssert(property.property, @"Could not find property %@.%@", className, propertyName);
    NSCAssert(property.attributes.count != 0, @"Could not fetch property attributes for %@.%@", className, propertyName);
    NSCAssert(property.memoryManagementPolicy == ZUXPropertyMemoryManagementPolicyRetain,
              @"Does not support un-strong-reference property %@.%@", className, propertyName);
    
    id getter = ^(id self) { return [dataRef(self) objectForKey:propertyName]; };
    id setter = ^(id self, id value) { [(NSMutableDictionary *)dataRef(self) setObject:value forKey:propertyName]; };
    if (!class_addMethod(cls, property.getter, imp_implementationWithBlock(getter), "@@:"))
        NSCAssert(NO, @"Could not add getter %s for property %@.%@",
                  sel_getName(property.getter), className, propertyName);
    if (!property.isReadOnly)
        if (!class_addMethod(cls, property.setter, imp_implementationWithBlock(setter), "v@:@"))
            NSCAssert(NO, @"Could not add setter %s for property %@.%@",
                      sel_getName(property.setter), className, propertyName);
}

#pragma mark -

ZUX_STATIC void defaultDataSynchronize(id instance, NSString *key) {
    [ShareUserDefaults setObject:defaultData(instance, key) forKey:key];
    [ShareUserDefaults synchronize];
}

ZUX_STATIC void keychainDataSynchronize(id instance, NSString *key, NSString *domain) {
    NSString *dataStr = [ZUXJson jsonStringFromObject:keychainData(instance, key, domain)];
    if (!dataStr) return;
    NSError *error = nil;
    [ZUXKeychain storePassword:dataStr forUsername:key andService:domain updateExisting:YES error:&error];
    if (error) ZLog(@"Keychain Synchronize Error: %@", error);
}

ZUX_STATIC void geisKeychainDataSynchronize(id instance, NSString *key, NSString *domain) {
    NSString *dataStr = [ZUXJson jsonStringFromObject:geisKeychainData(instance, key, domain)];
    if (!dataStr) return;
    NSError *error = nil;
    [ZUXKeychain storePassword:dataStr forUsername:key andService:domain updateExisting:YES error:&error];
    if (error) ZLog(@"Geis Keychain Synchronize Error: %@", error);
}

ZUX_STATIC NSDictionary *defaultData(id instance, NSString *key) {
    if (ZUX_EXPECT_F(![instance propertyForAssociateKey:key]))
        [instance setProperty:[NSMutableDictionary dictionaryWithDictionary:
                               [ShareUserDefaults objectForKey:key]]
              forAssociateKey:key];
    return [instance propertyForAssociateKey:key];
}

ZUX_STATIC NSDictionary *keychainData(id instance, NSString *key, NSString *domain) {
    if (ZUX_EXPECT_F(![instance propertyForAssociateKey:key])) {
        NSError *error = nil;
        NSString *dataStr = [ZUXKeychain passwordForUsername:key andService:domain error:&error] ?: @"{}";
        if (error) ZLog(@"Keychain Error: %@", error);
        [instance setProperty:[NSMutableDictionary dictionaryWithDictionary:
                               [ZUXJson objectFromJsonString:dataStr]]
              forAssociateKey:key];
    }
    return [instance propertyForAssociateKey:key];
}

ZUX_STATIC NSDictionary *geisKeychainData(id instance, NSString *key, NSString *domain) {
    if (ZUX_EXPECT_F(![instance propertyForAssociateKey:key])) {
        if ([ZUXDataBox appFirstLaunch]) {
            [ZUXKeychain deletePasswordForUsername:key andService:domain error:NULL];
            [instance setProperty:[NSMutableDictionary dictionary] forAssociateKey:key];
        }
    }
    return keychainData(instance, key, domain);
}

ZUX_STATIC NSDictionary *userDataRef(NSDictionary *dataRef, id userId) {
    if (![[dataRef objectForKey:userId] isKindOfClass:NSClassFromString(@"__NSDictionaryM")])
        [(NSMutableDictionary *)dataRef setObject:[NSMutableDictionary dictionaryWithDictionary:
                                                   [dataRef objectForKey:userId]] forKey:userId];
    return [dataRef objectForKey:userId];
}
