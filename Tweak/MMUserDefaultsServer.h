#import <Foundation/Foundation.h>

@interface MMUserDefaultsServer : NSObject
+ (BOOL)isCurrentProcessServer;
+ (void)runServerInMainThread;
@end