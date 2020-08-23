#import "PXMMPRootListController.h"
#import <Preferences/PSSpecifier.h>

@implementation PXMMPRootListController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"MobileMeadow";
}

- (NSMutableArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [NSMutableArray new];
		NSArray *contents = ABOUT_CONTENT_ARRAY;
		for (NSArray *group in contents) {
			NSString *header = group[0];
			NSString *footer = group[1];
			PSSpecifier *groupSpecifier = [PSSpecifier preferenceSpecifierNamed:header
				target:nil
				set:nil
				get:nil
				detail:nil
				cell:PSGroupCell
				edit:nil
			];
			[groupSpecifier setProperty:footer forKey:@"footerText"];
			[_specifiers addObject:groupSpecifier];
			for (NSArray *button in group[2]) {
				PSSpecifier *buttonSpecifier = [PSSpecifier preferenceSpecifierNamed:button[0]
					target:self
					set:nil
					get:nil
					detail:nil
					cell:PSButtonCell
					edit:nil
				];
				[buttonSpecifier setProperty:button[1] forKey:@"meadowURL"];
				[buttonSpecifier setProperty:@YES forKey:@"enabled"];
				buttonSpecifier.buttonAction = @selector(handleButtonPress:);
				[_specifiers addObject:buttonSpecifier];
			}
		}
	}
	return _specifiers;
}

- (void)handleButtonPress:(PSSpecifier *)specifier {
	NSURL *URL = [NSURL URLWithString:[specifier propertyForKey:@"meadowURL"]];
	[UIApplication.sharedApplication openURL:URL];
}

@end
