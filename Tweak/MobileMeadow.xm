#import <UIKit/UIKit.h>
#import "MobileMeadow.h"
#import "MMMailManager.h"
#import "MMUserDefaultsServer.h"
#import "MMGroundContainerView.h"

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

@interface SBDockView : UIView
@end

@interface _WGWidgetListScrollView : UIScrollView
@end

%group SpringBoardMail

#if ENABLE_MAIL_FUNCTIONALITY

// iOS 7.0 -> Present
%hook SBDockView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	if (%orig) return YES;
	if (!_dockGround.mailBoxView.userInteractionEnabled) return NO;
	CGPoint converted = [self convertPoint:point toView:_dockGround.mailBoxView];
	return [_dockGround.mailBoxView pointInside:converted withEvent:event];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	UIView *view;
	if ((view = %orig)) return view;
	CGPoint converted = [self convertPoint:point toView:_dockGround.mailBoxView];
	return [_dockGround.mailBoxView hitTest:converted withEvent:event];
}

%end

#endif

%end

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
	#if ENABLE_MAIL_FUNCTIONALITY
	[MMMailManager startMailThread];
	#endif
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
%hook UITextView
%property (nonatomic, assign) BOOL meadow_verticalOnly;

- (void)layoutSubviews {
	if ([self valueForKey:@"meadow_verticalOnly"]) {
		UIEdgeInsets insets;
		if (@available(iOS 11.0, *)) {
			insets = self.adjustedContentInset;
		}
		else {
			insets = self.contentInset;
		}
		self.contentOffset = CGPointMake(-insets.left, self.contentOffset.y);
	}
	%orig;
}

%end

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
			if (((convertedPoint.y + self.superview.frame.size.height) != UIScreen.mainScreen.bounds.size.height) &&
				(self._viewControllerForAncestor.navigationController.toolbar != self.superview))
			{
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
		#if ENABLE_MAIL_FUNCTIONALITY
		[MMUserDefaultsServer runServerInMainThread];
		%init(SpringBoardMail);
		#endif
		%init(SpringBoard);
	}
	else {
		%init(App);
	}
}