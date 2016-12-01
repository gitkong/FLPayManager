//
//  AppDelegate.m
//  FLPayManagerDemo
//
//  Created by clarence on 16/11/30.
//  Copyright © 2016年 gitKong. All rights reserved.
//

#import "AppDelegate.h"
#import "FLPayManager.h"
@interface AppDelegate ()

@end

@implementation AppDelegate
/**
 *  @author gitKong
 *
 *  最老的版本，最好也写上
 */
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    return [FLPAYMANAGER fl_handleUrl:url];
}
/**
 *  @author gitKong
 *
 *  iOS 9.0 之前 会调用
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    return [FLPAYMANAGER fl_handleUrl:url];
}
/**
 *  @author gitKong
 *
 *  iOS 9.0 以上（包括iOS9.0）
 */

- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options{
    
    return [FLPAYMANAGER fl_handleUrl:url];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [FLPAYMANAGER fl_registerApp];
    
    return YES;
}


@end
