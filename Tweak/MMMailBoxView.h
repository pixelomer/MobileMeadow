#if ENABLE_MAIL_FUNCTIONALITY
#import <UIKit/UIKit.h>
#import "MMBirdView.h"

@interface MMMailBoxView : UIView {
	UIImageView *_imageView;
	MMBirdView *_birdView;
	UIImageView *_mailAlertImageView;
}
+ (BOOL)isFull;
+ (void)setIsFull:(BOOL)isFull;
@end
#endif