#import "MMAirLayerView.h"
#import "MMAirLayerViewController.h"
#import "MMBirdView.h"

@interface UIView(Private)
- (__kindof UIViewController *)_viewControllerForAncestor;
@end

@implementation MMAirLayerView

- (void)didAddSubview:(MMBirdView *)bird {
	[super didAddSubview:bird];
	if (![bird isKindOfClass:[MMBirdView class]]) return;
	MMAirLayerViewController *vc = [self _viewControllerForAncestor];
	[vc updateBird:bird];
}

@end