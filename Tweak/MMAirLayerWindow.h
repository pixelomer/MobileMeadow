#import <UIKit/UIKit.h>

// This is a window that stays on top of SpringBoard at all times. This
// is where the birds fly.

@class MMBirdView;

@interface MMAirLayerWindow : UIWindow {
	NSMutableArray<MMBirdView *> *_birds;
	NSTimer *_newBirdTimer;
}
+ (instancetype)sharedInstance;
- (void)animateBirdWithName:(NSString *)birdName
	initialPosition:(CGPoint)initialPoint
	finalPoisition:(CGPoint)finalPoint
	completion:(void(^)(BOOL))completion
	speed:(CGFloat)speed;
@end