#import <UIKit/UIKit.h>
#import "MMMailBoxView.h"

// Sits on top of tab bars and the dock. This is used in both SpringBoard and
// other apps.

@class MMBirdView;

@interface MMGroundContainerView : UIView {
	CGFloat _lastUpdateX;
	MMBirdView *_birdView;
}
@property (nonatomic, strong) MMMailBoxView *mailBoxView;
+ (MMGroundContainerView *)springboardSingleton;
@end