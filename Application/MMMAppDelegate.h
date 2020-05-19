#import <UIKit/UIKit.h>
#import "MMMNavigationController.h"

@interface MMMAppDelegate : UIResponder<UIApplicationDelegate>
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong, readonly) MMMNavigationController *rootViewController;
@end