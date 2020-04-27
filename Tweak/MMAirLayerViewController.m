#import "MMAirLayerViewController.h"
#import "MMAirLayerView.h"
#import "MMBirdView.h"
#import <Headers/SpringBoard.h>

@implementation MMAirLayerViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[(SpringBoard *)UIApplication.sharedApplication addActiveOrientationObserver:self];
}

- (void)loadView {
	self.view = [MMAirLayerView new];
}

- (void)updateBird:(MMBirdView *)bird {
	if (![bird isKindOfClass:[MMBirdView class]]) {
		[NSException
			raise:NSInvalidArgumentException
			format:@"-[%@ %@] expects an MMBird instance, got %@ instead",
				NSStringFromClass(self.class),
				NSStringFromSelector(_cmd),
				bird
		];
		return;
	}
	UIOffset offset = [bird.userInfo[@"animationOffset"] UIOffsetValue];
	BOOL mirrored;
	if (_isLandscape) mirrored = (offset.vertical < 0.0);
	else mirrored = (offset.horizontal < 0.0);
	switch (_orientation) {
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationPortraitUpsideDown:
			mirrored = !mirrored;
		default:
			break;
	}
	bird.horizontallyMirrored = mirrored;
	bird.rotationInDegrees = _degrees;
}

- (void)updateAllBirds {
	for (MMBirdView *bird in self.view.subviews) {
		if (![bird isKindOfClass:[MMBirdView class]]) continue;
		[self updateBird:bird];
	}
}

- (void)activeInterfaceOrientationDidChangeToOrientation:(UIInterfaceOrientation)newOrientation willAnimateWithDuration:(double)arg2 fromOrientation:(UIInterfaceOrientation)oldOrientation {

}

- (void)activeInterfaceOrientationWillChangeToOrientation:(UIInterfaceOrientation)orientation {
	_isLandscape = NO;
	switch (_orientation = orientation) {
		case UIInterfaceOrientationLandscapeLeft:
			_degrees = -90; _isLandscape = YES; break;
		case UIInterfaceOrientationLandscapeRight:
			_degrees = 90; _isLandscape = YES; break;
		case UIInterfaceOrientationPortraitUpsideDown:
			_degrees = 180; break;
		case UIInterfaceOrientationPortrait:
		default: _degrees = 0; break;
	}
	[self updateAllBirds];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
	return NO;
}

@end