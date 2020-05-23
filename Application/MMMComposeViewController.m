#import "MMMComposeViewController.h"
#import "UIColor+MeadowMail.h"
#import "UIFont+MeadowFont.h"

@implementation MMMComposeViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor meadow_systemBackgroundColor];
	[self.view addSubview:_separatorView];
	[self.view addSubview:_titleTextField];
	[self.view addSubview:_messageTextView];
	[self.view addConstraints:@[
		[NSLayoutConstraint
			constraintWithItem:_titleTextField
			attribute:NSLayoutAttributeTop
			relatedBy:NSLayoutRelationEqual
			toItem:self.topLayoutGuide
			attribute:NSLayoutAttributeBottom
			multiplier:1.0
			constant:10.0
		],
		[NSLayoutConstraint
			constraintWithItem:_titleTextField
			attribute:NSLayoutAttributeLeft
			relatedBy:NSLayoutRelationEqual
			toItem:self.view
			attribute:NSLayoutAttributeLeft
			multiplier:1.0
			constant:20.0
		],
		[NSLayoutConstraint
			constraintWithItem:_titleTextField
			attribute:NSLayoutAttributeRight
			relatedBy:NSLayoutRelationEqual
			toItem:self.view
			attribute:NSLayoutAttributeRight
			multiplier:1.0
			constant:-10.0
		],
		[NSLayoutConstraint
			constraintWithItem:_separatorView
			attribute:NSLayoutAttributeTop
			relatedBy:NSLayoutRelationEqual
			toItem:_titleTextField
			attribute:NSLayoutAttributeBottom
			multiplier:1.0
			constant:10.0
		],
		[NSLayoutConstraint
			constraintWithItem:_separatorView
			attribute:NSLayoutAttributeHeight
			relatedBy:NSLayoutRelationEqual
			toItem:nil
			attribute:NSLayoutAttributeNotAnAttribute
			multiplier:0.0
			constant:1.0
		],
		[NSLayoutConstraint
			constraintWithItem:_separatorView
			attribute:NSLayoutAttributeLeft
			relatedBy:NSLayoutRelationEqual
			toItem:self.view
			attribute:NSLayoutAttributeLeft
			multiplier:1.0
			constant:0.0
		],
		[NSLayoutConstraint
			constraintWithItem:_separatorView
			attribute:NSLayoutAttributeRight
			relatedBy:NSLayoutRelationEqual
			toItem:self.view
			attribute:NSLayoutAttributeRight
			multiplier:1.0
			constant:0.0
		],
		[NSLayoutConstraint
			constraintWithItem:_titleTextField
			attribute:NSLayoutAttributeHeight
			relatedBy:NSLayoutRelationGreaterThanOrEqual
			toItem:nil
			attribute:NSLayoutAttributeNotAnAttribute
			multiplier:0.0
			constant:0.0
		],
		[NSLayoutConstraint
			constraintWithItem:_messageTextView
			attribute:NSLayoutAttributeTop
			relatedBy:NSLayoutRelationEqual
			toItem:_separatorView
			attribute:NSLayoutAttributeBottom
			multiplier:1.0
			constant:0.0
		],
		[NSLayoutConstraint
			constraintWithItem:_messageTextView
			attribute:NSLayoutAttributeBottom
			relatedBy:NSLayoutRelationEqual
			toItem:self.bottomLayoutGuide
			attribute:NSLayoutAttributeTop
			multiplier:1.0
			constant:0.0
		],
		[NSLayoutConstraint
			constraintWithItem:_messageTextView
			attribute:NSLayoutAttributeLeft
			relatedBy:NSLayoutRelationEqual
			toItem:self.view
			attribute:NSLayoutAttributeLeft
			multiplier:1.0
			constant:0.0
		],
		[NSLayoutConstraint
			constraintWithItem:_messageTextView
			attribute:NSLayoutAttributeRight
			relatedBy:NSLayoutRelationEqual
			toItem:self.view
			attribute:NSLayoutAttributeRight
			multiplier:1.0
			constant:0.0
		]
	]];
}

- (instancetype)init {
	if ((self = [super init])) {
		self.title = @"New letter";
		_separatorView = [UIView new];
		_separatorView.backgroundColor = [UIColor lightGrayColor];
		_separatorView.translatesAutoresizingMaskIntoConstraints = NO;
		_titleTextField = [UITextField new];
		_titleTextField.placeholder = @"Title";
		_titleTextField.translatesAutoresizingMaskIntoConstraints = NO;
		_messageTextView = [UITextView new];
		_messageTextView.translatesAutoresizingMaskIntoConstraints = NO;
		_messageTextView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mail_background_tile"]];
		_messageTextView.contentInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
		_messageTextView.font = [UIFont meadow_mailFont];
		[_messageTextView setValue:@YES forKey:@"meadow_verticalOnly"];
		_messageTextView.alwaysBounceVertical = YES;
	}
	return self;
}

@end