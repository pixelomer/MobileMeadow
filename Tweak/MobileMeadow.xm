#import <UIKit/UIKit.h>
#import "MobileMeadow.h"

static MMGroundContainerView *_dockGround;

@interface SBDockIconListView : UIView
- (void)meadow_createDockGround;
@end

@interface MTMaterialView : UIView
@end

@interface SBIconListPageControl : UIView
@end

@interface _UIBarBackground : UIView
@property (nonatomic, strong) MMGroundContainerView *groundContainer;
@end

@interface SpringBoard : UIApplication
@property (nonatomic, strong) MMAirLayerWindow *meadow_airLayer;
@end

@interface UIView(Private)
- (UIViewController *)_viewControllerForAncestor;
@end

@interface _WGWidgetListScrollView : UIScrollView
@end

%group SpringBoard
%hook _WGWidgetListScrollView

- (void)setContentInset:(UIEdgeInsets)insets {
	%orig(UIEdgeInsetsMake(
		insets.top,
		insets.left,
		insets.bottom + 70.0,
		insets.right
	));
}

%end

%hook SpringBoard
%property (nonatomic, strong) MMAirLayerWindow *meadow_airLayer;

- (void)applicationDidFinishLaunching:(SpringBoard *)springboard {
	%orig;
	self.meadow_airLayer = [MMAirLayerWindow new];
	self.meadow_airLayer.windowLevel = CGFLOAT_MAX / 2.0;
	[self.meadow_airLayer makeKeyAndVisible];
}

%end

// iOS 4.0 -> Present
%hook SBDockIconListView

%new
- (void)meadow_createDockGround {
	if (_dockGround) return;
	_dockGround = [MMGroundContainerView new];
	[self.superview addSubview:_dockGround];
}

- (void)didMoveToWindow {
	%orig;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[self meadow_createDockGround];
	});
}

%end

%hook SBIconListPageControl

- (void)setHidden:(BOOL)hidden {
	%orig(YES);
}

- (void)didMoveToWindow {
	[self setHidden:YES];
}

%end

%hook MTMaterialView

- (void)setAlpha:(CGFloat)alpha {
	if (self.superview.class == %c(SBDockView)) %orig(1.0);
	else %orig;
}

- (void)setHidden:(BOOL)hidden {
	if (self.superview.class == %c(SBDockView)) %orig(NO);
	else %orig;
}

%end
%end

%group App
%hook _UIBarBackground
%property (nonatomic, strong) MMGroundContainerView *groundContainer;

- (void)didMoveToSuperview {
	%orig;
	if (!self.groundContainer) {
		if ([self.superview isKindOfClass:[UITabBar class]]) {
			if (![self._viewControllerForAncestor isKindOfClass:[UITabBarController class]]) {
				return;
			}
			if (self.superview != [(UITabBarController *)self._viewControllerForAncestor tabBar]) {
				return;
			}
		}
		else if ([self.superview isKindOfClass:[UIToolbar class]]) {
			CGPoint convertedPoint = [self.superview convertPoint:CGPointZero toView:nil];
			if ((convertedPoint.y + self.superview.frame.size.height) != UIScreen.mainScreen.bounds.size.height) {
				return;
			}
		}
		else return;
		self.groundContainer = [MMGroundContainerView new];
		[self addSubview:self.groundContainer];
	}
}

%end
%end

%ctor {
	if ([NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
		%init(SpringBoard);
	}
	else {
		%init(App);
	}
}