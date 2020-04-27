#import <UIKit/UIKit.h>

@protocol SBUIActiveOrientationObserver<NSObject>
- (void)activeInterfaceOrientationDidChangeToOrientation:(UIInterfaceOrientation)arg1 willAnimateWithDuration:(double)arg2 fromOrientation:(UIInterfaceOrientation)arg3;
- (void)activeInterfaceOrientationWillChangeToOrientation:(UIInterfaceOrientation)arg1;
@end

@class MMBirdView;

@interface MMAirLayerViewController : UIViewController<SBUIActiveOrientationObserver> {
	CGFloat _degrees;
	UIInterfaceOrientation _orientation;
}
@property (nonatomic, assign, readonly) BOOL isLandscape;
- (void)updateBird:(MMBirdView *)bird;
@end