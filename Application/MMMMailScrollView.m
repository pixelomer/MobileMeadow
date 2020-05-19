#import "MMMMailScrollView.h"

@implementation MMMMailScrollView

static UIFont *_font;

- (void)layoutSubviews {
	if (!_topLeftImageView || !_bottomRightImageView || !_letterTextLabel) return;
	CGFloat contentHeight = [_letterTextLabel sizeThatFits:CGSizeMake(
		self.frame.size.width - 60.0,
		CGFLOAT_MAX
	)].height + 60.0;
	self.contentSize = CGSizeMake(
		self.frame.size.width,
		(contentHeight < self.frame.size.height) ? self.frame.size.height : contentHeight
	);
	_letterTextLabel.frame = CGRectMake(
		30.0, 30.0, self.frame.size.width - 60.0, contentHeight-60.0
	);
	_topLeftImageView.frame = CGRectMake(
		0.0, 0.0, 60.0, 30.0
	);
	if (contentHeight < self.frame.size.height) {
		_bottomRightImageView.frame = CGRectMake(
			self.frame.size.width - 60.0,
			self.frame.size.height - 30.0,
			60.0, 30.0
		);
	}
	else {
		_bottomRightImageView.frame = CGRectMake(
			self.frame.size.width - 60.0,
			contentHeight - 30.0,
			60.0, 30.0
		);
	}
	[super layoutSubviews];
}

@end