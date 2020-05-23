#import "MMMErrorRootViewController.h"

@implementation MMMErrorRootViewController

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	NSString *title = @"Error";
	NSString *message = @"MobileMeadow wasn't loaded into this application. Make sure that MobileMeadow is installed and isn't disabled.";
	MobileMeadowShowError(title, message, self);
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor blackColor];
}

@end