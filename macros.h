#import <Foundation/Foundation.h>

#define min(x,y) ((x>y)?y:x)
#define max(x,y) ((x>y)?x:y)
#define DEG_TO_RAD(degress) ((degress) * M_PI / 180.0)
#define NSLog(args...) NSLog(@"[MobileMeadow] "args)

@interface NSUserDefaults(Private)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)reverseDomain;
- (void)setObject:(id)obj forKey:(NSString *)key inDomain:(NSString *)reverseDomain;
@end 