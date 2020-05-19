#import "UIFont+MeadowFont.h"
#import <CoreText/CoreText.h>

@implementation UIFont(MeadowFont)

+ (instancetype)meadow_mailFont {
	static dispatch_once_t onceToken;
	static UIFont *font;
	dispatch_once(&onceToken, ^{
		CGDataProviderRef fontDataRef = CGDataProviderCreateWithFilename(
			[NSBundle.mainBundle
				pathForResource:@"OpenDyslexic3-Regular"
				ofType:@"ttf"
			].UTF8String
		);
		CGFontRef fontRef = CGFontCreateWithDataProvider(fontDataRef);
		CFRelease(fontDataRef);
		CTFontRef graphicsFontRef = CTFontCreateWithGraphicsFont(fontRef, 15.5, NULL, NULL);
		CFRelease(fontRef);
		if (!(font = [(__bridge UIFont *)graphicsFontRef copy])) {
			[NSException
				raise:NSInternalInconsistencyException
				format:@"Font was null."
			];
		}
		CFRelease(graphicsFontRef);
	});
	return font;
}

@end