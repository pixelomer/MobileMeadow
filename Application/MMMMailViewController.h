#import <UIKit/UIKit.h>

@interface MMMMailViewController : UIViewController {
	UILabel *_letterTextLabel;
	NSDate *_date;
}
@property (nonatomic, readonly) NSUInteger mailIndex;
- (instancetype)initWithMailIndex:(NSUInteger)index;
@end