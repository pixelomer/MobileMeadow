#import <UIKit/UIKit.h>
#import "MMMAppDelegate.h"

int main(int argc, char *argv[]) {
	@autoreleasepool {
		return UIApplicationMain(argc, argv, nil, NSStringFromClass(MMMAppDelegate.class));
	}
}

void MobileMeadowShowError(NSString *title, NSString *message, UIViewController *vc) {
	if (@available(iOS 9.0, *)) {
		UIAlertController *alert = [UIAlertController
			alertControllerWithTitle:title
			message:message
			preferredStyle:UIAlertControllerStyleAlert
		];
		[vc presentViewController:alert animated:YES completion:nil];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc]
			initWithTitle:title
			message:message
			delegate:nil
			cancelButtonTitle:nil
			otherButtonTitles:nil
		];
		[alert show];
	}
}
