#import <UIKit/UIKit.h>
#import "MMMMailScrollView.h"

@interface MMMMailViewController : UIViewController {
	UILabel *_letterTextLabel;
	NSDate *_date;
	UIImageView *_topLeftImageView;
	MMMMailScrollView *_scrollView;
	UIImageView *_bottomRightImageView;
	BOOL _starred;
}
@property (nonatomic, readonly) NSUInteger mailIndex;
- (instancetype)initWithMailIndex:(NSUInteger)index;
@end