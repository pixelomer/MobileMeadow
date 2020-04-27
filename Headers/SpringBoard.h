#import <UIKit/UIKit.h>

@interface SpringBoard : UIApplication
- (BOOL)isLocked;
- (void)addActiveOrientationObserver:(id)observer;
@end