// +build !ci
// +build !ios

extern void themeChanged();

#import <Foundation/Foundation.h>

#if (__MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_11_0)
#import <UserNotifications/UNUserNotificationCenter.h>
#import <UserNotifications/UNNotificationContent.h>
#import <UserNotifications/UNNotificationRequest.h>

BOOL bFyneAlertGranted = NO;

#endif

#if (__MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_11_0)

@interface FyneUserNotificationCenterDelegate : NSObject<NSUserNotificationCenterDelegate>

- (BOOL)userNotificationCenter:(NSUserNotificationCenter*)center
    shouldPresentNotification:(NSUserNotification*)notification;

@end

@implementation FyneUserNotificationCenterDelegate

- (BOOL)userNotificationCenter:(NSUserNotificationCenter*)center
    shouldPresentNotification:(NSUserNotification*)notification
{
    return YES;
}

@end
#endif // < MACOS_11

void sendNSUserNotification(const char *, const char *);

bool isBundled() {
    return [[NSBundle mainBundle] bundleIdentifier] != nil;
}

bool isDarkMode() {
    NSString *style = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"];
    return [@"Dark" isEqualToString:style];
}

void sendNotification(const char *title, const char *body) {
#if (__MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_11_0)
    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
    if (center.delegate == nil) {
        center.delegate = [[FyneUserNotificationCenterDelegate new] autorelease];
    }

    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSUserNotification *notification = [[NSUserNotification new] autorelease];
    notification.title = [NSString stringWithUTF8String:title];
    notification.informativeText = [NSString stringWithUTF8String:body];
    notification.identifier = [NSString stringWithFormat:@"%@-fyne-notify-%@", [[NSBundle mainBundle] bundleIdentifier], uuid];
    [center scheduleNotification:notification];
#else
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert)
        completionHandler:^(BOOL granted, NSError * _Nullable error) {
        bFyneAlertGranted = granted;
    }];

    if( bFyneAlertGranted )
    {
        NSString *uuid = [[NSUUID UUID] UUIDString];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.targetContentIdentifier = [NSString stringWithFormat:@"%@-fyne-notify-%@", [[NSBundle mainBundle] bundleIdentifier], uuid];
        content.title = [NSString stringWithUTF8String:title];
        content.body = [NSString stringWithUTF8String:body];

        UNNotificationRequest* request = [[UNNotificationRequest requestWithIdentifier:uuid content:content trigger:nil] autorelease];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
           if (error != nil) {
               NSLog(@"%@", error.localizedDescription);
           }
        }];
    }
#endif // < MACOS_11
}

void watchTheme() {
    [[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"AppleInterfaceThemeChangedNotification" object:nil queue:nil
        usingBlock:^(NSNotification *note) {
        themeChanged(); // calls back into Go
    }];
}
