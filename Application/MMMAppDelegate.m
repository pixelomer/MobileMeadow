#import "MMMAppDelegate.h"
#import "MMMRootViewController.h"
#import "MMMMailListViewController.h"

@implementation MMMAppDelegate

static NSArray *_URLPaths;

+ (void)initialize {
	if ([MMMAppDelegate class] == self) {
		NSMutableArray<NSString *> *titles = [MMMRootViewController rowTitles].mutableCopy;
		for (NSUInteger i=0; i<titles.count; i++) {
			titles[i] = [[titles[i] componentsSeparatedByString:@" "][0] lowercaseString];
		}
		_URLPaths = titles.copy;
	}
}

- (BOOL)application:(UIApplication *)application
	didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey, id> *)options
{
	_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_rootViewController = [[MMMNavigationController alloc] initWithRootViewController:[MMMRootViewController new]];
	_rootViewController.sharedToolbarItems = @[
		[[UIBarButtonItem alloc]
			initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
			target:nil
			action:nil
		],
		[[UIBarButtonItem alloc]
			initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
			target:nil
			action:nil
		]
	];
	_rootViewController.toolbarHidden = NO;
	_rootViewController.topViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
	_rootViewController.navigationBar.prefersLargeTitles = NO;
	_window.rootViewController = _rootViewController;
	if (!options[UIApplicationLaunchOptionsURLKey]) {
		NSNumber *lastViewControllerIndexNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastVCIndex"];
		if (lastViewControllerIndexNumber) {
			NSUInteger index = lastViewControllerIndexNumber.unsignedIntegerValue;
			if (index < [MMMRootViewController rowTitles].count) {
				MMMMailListViewController *vc = [[MMMMailListViewController alloc]
					initWithFilter:[MMMRootViewController rowFilters][index]
				];
				vc.title = [MMMRootViewController rowTitles][index];
				[_rootViewController
					pushViewController:vc
					animated:NO
				];
			}
		}
	}
	[_window makeKeyAndVisible];
	return YES;
}

- (BOOL)application:(UIApplication *)app
	openURL:(NSURL *)url
	options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
	// If the URL is valid, pop to the first view controller and push the wanted view controller
	if (!url.host) return NO;
	if (![url.scheme isEqualToString:@"meadowmail"]) return NO;
	NSUInteger index = [_URLPaths indexOfObject:url.host];
	if (index == NSNotFound) return NO;
	[_rootViewController popToRootViewControllerAnimated:NO];
	MMMMailListViewController *vc = [[MMMMailListViewController alloc]
		initWithFilter:[MMMRootViewController rowFilters][index]
	];
	vc.title = [MMMRootViewController rowTitles][index];
	[_rootViewController
		pushViewController:vc
		animated:NO
	];
	return YES;
}

@end
