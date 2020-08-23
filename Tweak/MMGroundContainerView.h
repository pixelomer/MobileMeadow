#import <UIKit/UIKit.h>
#import "MMMailBoxView.h"

// Sits on top of tab bars and the dock. This is used in both SpringBoard and
// other apps.

@class MMBirdView;

@interface MMGroundContainerView : UIView {
	CGFloat _lastUpdateX;
	NSMutableArray<UIImageView *> *_imageViews;
#if ENABLE_MAIL_FUNCTIONALITY
	MMBirdView *_birdView;
#endif
}
#if ENABLE_MAIL_FUNCTIONALITY
@property (nonatomic, strong, readonly) MMMailBoxView *mailBoxView;
- (void)animateDeliveryBirdLandingWithCompletion:(void(^)(BOOL finished))completion;
- (void)animateDeliveryBirdLeavingWithCompletion:(void(^)(BOOL finished))completion;
#endif
+ (MMGroundContainerView *)springboardSingleton;
@end