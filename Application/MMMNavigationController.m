#import "MMMNavigationController.h"

@implementation MMMNavigationController

- (void)pushViewController:(__kindof UIViewController *)vc animated:(BOOL)animated {
	vc.toolbarItems = _sharedToolbarItems;
	[super pushViewController:vc animated:animated];
}

- (void)setSharedToolbarItems:(NSArray *)newItems {
	_sharedToolbarItems = newItems;
	for (UIViewController *vc in self.viewControllers) {
		vc.toolbarItems = newItems;
	}
}

@end