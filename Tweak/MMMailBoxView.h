#import <UIKit/UIKit.h>
#import "MMBirdView.h"

@interface MMMailBoxView : UIView {
	UIImageView *_imageView;
	MMBirdView *_birdView;
}
+ (BOOL)isFull;
+ (void)setIsFull:(BOOL)isFull;
@end