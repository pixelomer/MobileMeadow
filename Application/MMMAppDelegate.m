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
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{ @"mails": @[] }];
	[[NSUserDefaults standardUserDefaults] synchronize];
	_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_rootViewController = [[UINavigationController alloc] initWithRootViewController:[MMMRootViewController new]];
	_rootViewController.navigationBar.prefersLargeTitles = NO;
	_window.rootViewController = _rootViewController;
	if (!options[UIApplicationLaunchOptionsURLKey]) {
		// Open the last viewed view controller
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
