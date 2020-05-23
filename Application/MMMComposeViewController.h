#import <UIKit/UIKit.h>

@interface MMMComposeViewController : UIViewController {
	UIView *_separatorView;
}
@property (nonatomic, strong, readonly) UITextField *titleTextField;
@property (nonatomic, strong, readonly) UITextView *messageTextView;
@end