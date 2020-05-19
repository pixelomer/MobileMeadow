#import "MMMNavigationController.h"
#import "MMMAppDelegate.h"

@implementation MMMNavigationController

- (void)pushViewController:(__kindof UIViewController *)vc animated:(BOOL)animated {
	[vc setToolbarItems:@[
		[[UIBarButtonItem alloc]
			initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
			target:nil
			action:nil
		],
		[[UIBarButtonItem alloc]
			initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
			target:[MMMAppDelegate sharedInstance]
			action:@selector(handleComposeButton)
		]
	] animated:NO];
	[super pushViewController:vc animated:animated];
}

@end