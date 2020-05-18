#import <Foundation/Foundation.h>
#import "Tweak/MMUserDefaults.h"

#define min(x,y) ((x>y)?y:x)
#define max(x,y) ((x>y)?x:y)
#define DEG_TO_RAD(degress) ((degress) * M_PI / 180.0)
#define NSLog(args...) NSLog(@"[MobileMeadow] "args)
#if DEBUG
#define __debug_unused __unused
#else
#define __debug_unused
#endif
#define kNewMailNotification CFSTR("com.pixelomer.mobilemeadow/ReceivedMail")

@interface NSUserDefaults(Private)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)reverseDomain;
- (void)setObject:(id)obj forKey:(NSString *)key inDomain:(NSString *)reverseDomain;
@end 

typedef enum NSNotificationSuspensionBehavior : NSUInteger {
	NSNotificationSuspensionBehaviorDrop = 1,
	NSNotificationSuspensionBehaviorCoalesce = 2,
	NSNotificationSuspensionBehaviorHold = 3,
	NSNotificationSuspensionBehaviorDeliverImmediately = 4
} NSNotificationSuspensionBehavior;

@interface NSDistributedNotificationCenter : NSNotificationCenter
+ (id)defaultCenter;
- (void)postNotification:(id)arg1;
- (void)postNotificationName:(id)arg1 object:(id)arg2;
- (void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3;
- (void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3 deliverImmediately:(bool)arg4;
- (void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3 options:(unsigned long long)arg4;
- (void)addObserver:(id)arg1 selector:(SEL)arg2 name:(id)arg3 object:(id)arg4;
- (void)addObserver:(id)arg1 selector:(SEL)arg2 name:(id)arg3 object:(id)arg4 suspensionBehavior:(unsigned long long)arg5;
@end