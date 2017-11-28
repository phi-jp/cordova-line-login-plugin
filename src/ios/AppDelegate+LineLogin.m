//
//  AppDelegate+LineLogin.m
//  Line Login
//
//  Created by nrikiji inc on 2017/09/01.
//
//

#import "AppDelegate+LineLogin.h"
#import <objc/runtime.h>    
#import <LineSDK/LineSDK.h>


@implementation AppDelegate (LineLogin)

void LineMethodSwizzle(Class c, SEL originalSelector) {
    NSString *selectorString = NSStringFromSelector(originalSelector);
    SEL newSelector = NSSelectorFromString([@"swizzled_" stringByAppendingString:selectorString]);
    SEL noopSelector = NSSelectorFromString([@"noop_" stringByAppendingString:selectorString]);
    Method originalMethod, newMethod, noop;
    originalMethod = class_getInstanceMethod(c, originalSelector);
    newMethod = class_getInstanceMethod(c, newSelector);
    noop = class_getInstanceMethod(c, noopSelector);
    if (class_addMethod(c, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(c, newSelector, method_getImplementation(originalMethod) ?: method_getImplementation(noop), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

+ (void)load
{
    LineMethodSwizzle([self class], @selector(application:openURL:options:));
    LineMethodSwizzle([self class], @selector(application:openURL:sourceApplication:annotation:));
}


- (void)noop_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
}

- (void)swizzled_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    
    if (!url) {
        return ;
    }

    [[LineSDKLogin sharedInstance] handleOpenURL:url];
    [self swizzled_application:app openURL:url options:options];
}

@end
