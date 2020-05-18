#import <UIKit/UIKit.h>

@interface SpringBoard : UIApplication
- (BOOL)isLocked;
- (void)addActiveOrientationObserver:(id)observer;
@end

@interface SBApplication : NSObject
@end

@interface SBUIController : NSObject
+ (instancetype)sharedInstanceIfExists;
- (void)activateApplication:(SBApplication *)app;
@end

@interface SBApplicationController : NSObject
+ (instancetype)sharedInstance;
- (SBApplication *)applicationWithBundleIdentifier:(NSString *)identifier;
@end