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

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[MMUserDefaults checkIfServerIsAliveWithCompletion:^(BOOL isAlive){
		if (!isAlive) {
			NSString *title = @"Error";
			NSString *message = @"The MobileMeadow user defaults server isn't responding. Make sure that MobileMeadow is loaded into SpringBoard.";
			MobileMeadowShowError(title, message, self);
		}
	}];
}

@end