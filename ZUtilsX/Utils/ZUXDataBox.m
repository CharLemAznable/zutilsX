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

#define AppKeyFormat(key)               [NSString stringWithFormat:@"%@."@#key, appIdentifier]
#define ClassKeyFormat(className, key)  [NSString stringWithFormat:@"%@."@#className@"."@#key, appIdentifier]

ZUX_STATIC NSString *const DataBoxDefaultShareKey = @"DataBoxDefaultShareKey";
ZUX_STATIC NSString *const DataBoxKeychainShareKey = @"DataBoxKeychainShareKey";
ZUX_STATIC NSString *const DataBoxKeychainShareDomain = @"DataBoxKeychainShareDomain";
ZUX_STATIC NSString *const DataBoxGeisKeychainShareKey = @"DataBoxGeisKeychainShareKey";
ZUX_STATIC NSString *const DataBoxGeisKeychainShareDomain = @"DataBoxGeisKeychainShareDomain";
ZUX_STATIC NSString *const DataBoxDefaultUsersKey = @"DataBoxDefaultUsersKey";
ZUX_STATIC NSString *const DataBoxKeychainUsersKey = @"DataBoxKeychainUsersKey";
ZUX_STATIC NSString *const DataBoxKeychainUsersDomain = @"DataBoxKeychainUsersDomain";
ZUX_STATIC NSString *const DataBoxGeisKeychainUsersKey = @"DataBoxGeisKeychainUsersKey";
ZUX_STATIC NSString *const DataBoxGeisKeychainUsersDomain = @"DataBoxGeisKeychainUsersDomain";

ZUX_STATIC void defaultDataSynchronize(id instance, NSString *key);
ZUX_STATIC void keychainDataSynchronize(id instance, NSString *key, NSString *domain);
ZUX_STATIC void geisKeychainDataSynchronize(id instance, NSString *key, NSString *domain);

ZUX_STATIC NSDictionary *defaultData(id instance, NSString *key);
ZUX_STATIC NSDictionary *keychainData(id instance, NSString *key, NSString *domain);
ZUX_STATIC NSDictionary *geisKeychainData(id instance, NSString *key, NSString *domain);

ZUX_STATIC NSDictionary *userDataRef(NSDictionary *dataRef, id userId);

NSString *ZUXAppEverLaunchedKey = nil;
NSString *ZUXAppFirstLaunchKey = nil;

void constructZUXDataBox(const char *className) {
    Class cls = objc_getClass(className);
    
    [cls setProperty:[cls respondsToSelector:@selector(defaultShareKey)] ?
     [cls defaultShareKey] : ClassKeyFormat(className, DefaultShare)
     forAssociateKey:DataBoxDefaultShareKey];
    [cls setProperty:[cls respondsToSelector:@selector(keychainShareKey)] ?
     [cls keychainShareKey] : ClassKeyFormat(className, KeychainShare)
     forAssociateKey:DataBoxKeychainShareKey];
    [cls setProperty:[cls respondsToSelector:@selector(keychainShareDomain)] ?
     [cls keychainShareDomain] : ClassKeyFormat(className, KeychainShareDomain)
     forAssociateKey:DataBoxKeychainShareDomain];
    [cls setProperty:[cls respondsToSelector:@selector(geisKeychainShareKey)] ?
     [cls geisKeychainShareKey] : ClassKeyFormat(className, GeisKeychainShare)
     forAssociateKey:DataBoxGeisKeychainShareKey];
    [cls setProperty:[cls respondsToSelector:@selector(geisKeychainShareDomain)] ?
     [cls geisKeychainShareDomain] : ClassKeyFormat(className, GeisKeychainShareDomain)
     forAssociateKey:DataBoxGeisKeychainShareDomain];
    
    [cls setProperty:[cls respondsToSelector:@selector(defaultUsersKey)] ?
     [cls defaultUsersKey] : ClassKeyFormat(className, DefaultUsers)
     forAssociateKey:DataBoxDefaultUsersKey];
    [cls setProperty:[cls respondsToSelector:@selector(keychainUsersKey)] ?
     [cls keychainUsersKey] : ClassKeyFormat(className, KeychainUsers)
     forAssociateKey:DataBoxKeychainUsersKey];
    [cls setProperty:[cls respondsToSelector:@selector(keychainUsersDomain)] ?
     [cls keychainUsersDomain] : ClassKeyFormat(className, KeychainUsersDomain)
     forAssociateKey:DataBoxKeychainUsersDomain];
    [cls setProperty:[cls respondsToSelector:@selector(geisKeychainUsersKey)] ?
     [cls geisKeychainUsersKey] : ClassKeyFormat(className, GeisKeychainUsers)
     forAssociateKey:DataBoxGeisKeychainUsersKey];
    [cls setProperty:[cls respondsToSelector:@selector(geisKeychainUsersDomain)] ?
     [cls geisKeychainUsersDomain] : ClassKeyFormat(className, GeisKeychainUsersDomain)
     forAssociateKey:DataBoxGeisKeychainUsersDomain];
}

void synchronizeAppLaunchData() {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        ZUXAppEverLaunchedKey = ZUXAppEverLaunchedKey ?: ZUX_RETAIN(AppKeyFormat(AppEverLaunched));
        ZUXAppFirstLaunchKey = ZUXAppFirstLaunchKey ?: ZUX_RETAIN(AppKeyFormat(AppFirstLaunch));
        
        if (![ShareUserDefaults boolForKey:ZUXAppEverLaunchedKey]) {
            [ShareUserDefaults setBool:YES forKey:ZUXAppEverLaunchedKey];
            [ShareUserDefaults setBool:YES forKey:ZUXAppFirstLaunchKey];
        } else [ShareUserDefaults setBool:NO forKey:ZUXAppFirstLaunchKey];
        NSLog(@"%@: %d", ZUXAppEverLaunchedKey, [ShareUserDefaults boolForKey:ZUXAppEverLaunchedKey]);
        NSLog(@"%@: %d", ZUXAppFirstLaunchKey, [ShareUserDefaults boolForKey:ZUXAppFirstLaunchKey]);
        [ShareUserDefaults synchronize];
    });
}

void defaultShareDataSynchronize(id instance) {
    defaultDataSynchronize(instance, [[instance class] propertyForAssociateKey:DataBoxDefaultShareKey]);
}

void keychainShareDataSynchronize(id instance) {
    keychainDataSynchronize(instance, [[instance class] propertyForAssociateKey:DataBoxKeychainShareKey],
                            [[instance class] propertyForAssociateKey:DataBoxKeychainShareDomain]);
}

void geisKeychainShareDataSynchronize(id instance) {
    geisKeychainDataSynchronize(instance, [[instance class] propertyForAssociateKey:DataBoxGeisKeychainShareKey],
                                [[instance class] propertyForAssociateKey:DataBoxGeisKeychainShareDomain]);
}

void defaultUsersDataSynchronize(id instance) {
    defaultDataSynchronize(instance, [[instance class] propertyForAssociateKey:DataBoxDefaultUsersKey]);
}

void keychainUsersDataSynchronize(id instance) {
    keychainDataSynchronize(instance, [[instance class] propertyForAssociateKey:DataBoxKeychainUsersKey],
                            [[instance class] propertyForAssociateKey:DataBoxKeychainUsersDomain]);
}

void geisKeychainUsersDataSynchronize(id instance) {
    geisKeychainDataSynchronize(instance, [[instance class] propertyForAssociateKey:DataBoxGeisKeychainUsersKey],
                                [[instance class] propertyForAssociateKey:DataBoxGeisKeychainUsersDomain]);
}

NSDictionary *defaultShareData(id instance) {
    return defaultData(instance, [[instance class] propertyForAssociateKey:DataBoxDefaultShareKey]);
}

NSDictionary *keychainShareData(id instance) {
    return keychainData(instance, [[instance class] propertyForAssociateKey:DataBoxKeychainShareKey],
                        [[instance class] propertyForAssociateKey:DataBoxKeychainShareDomain]);
}

NSDictionary *geisKeychainShareData(id instance) {
    return geisKeychainData(instance, [[instance class] propertyForAssociateKey:DataBoxGeisKeychainShareKey],
                            [[instance class] propertyForAssociateKey:DataBoxGeisKeychainShareDomain]);
}

NSDictionary *defaultUsersData(id instance, NSString *userIdKey) {
    return userDataRef(defaultData(instance, [[instance class] propertyForAssociateKey:DataBoxDefaultUsersKey]),
                       [instance valueForKey:userIdKey]);
}

NSDictionary *keychainUsersData(id instance, NSString *userIdKey) {
    return userDataRef(keychainData(instance, [[instance class] propertyForAssociateKey:DataBoxKeychainUsersKey],
                                    [[instance class] propertyForAssociateKey:DataBoxKeychainUsersDomain]),
                       [instance valueForKey:userIdKey]);
}

NSDictionary *geisKeychainUsersData(id instance, NSString *userIdKey) {
    return userDataRef(geisKeychainData(instance, [[instance class] propertyForAssociateKey:DataBoxGeisKeychainUsersKey],
                                        [[instance class] propertyForAssociateKey:DataBoxGeisKeychainUsersDomain]),
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
        if ([instance appFirstLaunch]) {
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
