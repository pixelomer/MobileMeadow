#if ENABLE_MAIL_FUNCTIONALITY
#import <Foundation/Foundation.h>

@interface MMUserDefaultsServer : NSObject
+ (BOOL)isCurrentProcessServer;
+ (void)runServerInMainThread;
+ (void)handleNotification:(NSNotification *)notif;
@end
#endif