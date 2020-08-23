#import <Foundation/Foundation.h>
#import "Tweak/MMUserDefaults.h"

#define min(x,y) ((x>y)?y:x)
#define max(x,y) ((x>y)?x:y)
#define DEG_TO_RAD(degress) ((degress) * M_PI / 180.0)
#if DEBUG || MEADOW_TESTER_BUILD
#define NSLog(args...) NSLog(@"[MobileMeadow] "args)
#else
#define NSLog(args...)
#endif
#if DEBUG
#define __debug_unused __unused
#else
#define __debug_unused
#endif

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

#define ABOUT_CONTENT_ARRAY @[ \
	@[@"Credits", @"MeadowMail was an app that allowed MeadowMail users to send anonymous mails to each other. Because of low usage, it has been discontinued and removed in MobileMeadow v1.0.", @[ \
		@[@"@pixelomer (Developer)", @"https://twitter.com/pixelomer"], \
		@[@"@TheOnlyKef (MeadowMail Moderator)", @"https://twitter.com/TheOnlyKef"], \
		@[@"@Skittyblock (Tester)", @"https://twitter.com/Skittyblock"], \
		@[@"@ConorTheDev (Tester)", @"https://twitter.com/ConorTheDev"], \
		@[@"@SamNChiet (Assets and Idea)", @"https://twitter.com/SamNChiet"], \
		@[@"OpenDyslexic (Letter Font)", @"https://opendyslexic.org"], \
		@[@"Google (Star Icon)", @"https://material.io"] \
	]], \
	@[@"Additional Links", @"If you downloaded MobileMeadow from a repository other than the official repository, please switch to the official repository.", @[ \
		@[@"Official Repository", @"https://repo.pixelomer.com"], \
		@[@"Source Code", @"https://github.com/pixelomer/MobileMeadow"], \
		@[@"Desktop Meadow by @SamNChiet", @"https://samperson.itch.io/meadow"] \
	]] \
]