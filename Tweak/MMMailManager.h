#if ENABLE_MAIL_FUNCTIONALITY
#import <Foundation/Foundation.h>

@interface MMMailManager : NSObject
+ (void)startMailThread;
@end
#endif