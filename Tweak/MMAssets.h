#import <UIKit/UIKit.h>

@interface MMAssets : NSObject
+ (UIImage *)imageNamed:(NSString *)name;
+ (UIImage *)randomImageWithPrefix:(NSString *)prefix;
@end