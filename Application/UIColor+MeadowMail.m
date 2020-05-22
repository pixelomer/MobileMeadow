#import "UIColor+MeadowMail.h"

@implementation UIColor(MeadowMail)

static UIColor *secondaryLabelColor;

+ (instancetype)meadow_labelColor {
	if (@available(iOS 13.0, *)) {
		return [self labelColor];
	}
	return [UIColor blackColor];
}

+ (instancetype)meadow_secondaryLabelColor {
	if (@available(iOS 13.0, *)) {
		return [self secondaryLabelColor];
	}
	static dispatch_once_t onceToken;
	static UIColor *secondaryLabelColor;
	dispatch_once(&onceToken, ^{
		secondaryLabelColor = [UIColor
			colorWithRed:0.235
			green:0.235
			blue:0.235
			alpha:0.6
		];
	});
	return secondaryLabelColor;
}

+ (instancetype)meadow_systemBackgroundColor {
	if (@available(iOS 13.0, *)) {
		return [self systemBackgroundColor];
	}
	return [UIColor whiteColor];
}

@end