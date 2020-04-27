#import "MMAssets.h"

@implementation MMAssets

static NSString * const assetsPath = @"/Library/MobileMeadow/Assets";
static NSMutableDictionary<NSString *, UIImage *> *cachedImages;
static NSMutableDictionary<NSString *, NSNumber *> *imageCountsForPrefixes;

+ (void)load {
	if (self == [MMAssets class]) {
		cachedImages = [NSMutableDictionary new];
		imageCountsForPrefixes = [NSMutableDictionary new];
	}
}

+ (instancetype)alloc {
	[NSException
		raise:NSInvalidArgumentException
		format:@"Don't use +alloc for this class."
	];
	return nil;
}

- (instancetype)init {
	[NSException
		raise:NSInvalidArgumentException
		format:@"Don't use -init for this class."
	];
	return nil;
}

+ (UIImage *)imageNamed:(NSString *)name {
	if (cachedImages[name]) return cachedImages[name];
	UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.png", assetsPath, name]];
	if (!image) return nil;
	return cachedImages[name] = image;
}

+ (UIImage *)randomImageWithPrefix:(NSString *)prefix {
	NSNumber *imageCount = imageCountsForPrefixes[prefix];
	if (!imageCount) {
		unsigned long imageCountRaw = 0;
		BOOL isDir;
		NSString *path;
		do {
			path = [NSString stringWithFormat:@"%@/%@_%lu.png", assetsPath, prefix, (unsigned long)imageCountRaw];
			imageCountRaw++;
		}
		while ([NSFileManager.defaultManager fileExistsAtPath:path isDirectory:&isDir] && !isDir);
		imageCountRaw--;
		imageCount = imageCountsForPrefixes[prefix] = @(imageCountRaw);
	}
	if (![imageCount boolValue]) return nil;
	unsigned long random = arc4random_uniform([imageCount unsignedLongValue]);
	return [self imageNamed:[NSString stringWithFormat:@"%@_%lu", prefix, random]];
}

@end