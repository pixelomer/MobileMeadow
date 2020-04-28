#import "MMMailBoxView.h"
#import "MMAssets.h"
#import "MMGroundContainerView.h"

@implementation MMMailBoxView

static BOOL _isFull;

+ (void)setIsFull:(BOOL)isFull {
	_isFull = isFull;
	[NSNotificationCenter.defaultCenter
		postNotificationName:@"MMMailBoxView/StateChange"
		object:nil
		userInfo:@{ @"isFull" : @(isFull) }
	];
}

+ (BOOL)isFull {
	return _isFull;
}

- (void)mailBoxStateChanged:(NSNotification *)notif {
	[self setIsFull:[notif.userInfo[@"isFull"] boolValue]];
}

- (instancetype)init {
	if ((self = [super init])) {
		[NSNotificationCenter.defaultCenter
			addObserver:self
			selector:@selector(mailBoxStateChanged:)
			name:@"MMMailBoxView/StateChange"
			object:nil
		];
		UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
			initWithTarget:self
			action:@selector(handleTap:)
		];
		[self addGestureRecognizer:tapRecognizer];
		_birdView = [[MMBirdView alloc] initWithBirdName:@"deliverybird"];
		_birdView.horizontallyMirrored = YES;
		[_birdView stopAnimating];
		_birdView.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:_birdView];
		_mailAlertImageView = [UIImageView new];
		_mailAlertImageView.translatesAutoresizingMaskIntoConstraints = NO;
		_mailAlertImageView.image = [MMAssets imageNamed:@"mail_icon"];
		[self addSubview:_mailAlertImageView];
		_imageView = [UIImageView new];
		_imageView.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:_imageView];
		[self addConstraints:@[
			[NSLayoutConstraint
				constraintWithItem:_birdView
				attribute:NSLayoutAttributeCenterX
				relatedBy:NSLayoutRelationEqual
				toItem:self
				attribute:NSLayoutAttributeCenterX
				multiplier:1.0
				constant:0.0
			],
			[NSLayoutConstraint
				constraintWithItem:_birdView
				attribute:NSLayoutAttributeBottom
				relatedBy:NSLayoutRelationEqual
				toItem:_imageView
				attribute:NSLayoutAttributeTop
				multiplier:1.0
				constant:0.0
			],
			[NSLayoutConstraint
				constraintWithItem:_mailAlertImageView
				attribute:NSLayoutAttributeBottom
				relatedBy:NSLayoutRelationEqual
				toItem:_birdView
				attribute:NSLayoutAttributeTop
				multiplier:1.0
				constant:6.0
			],
			[NSLayoutConstraint
				constraintWithItem:_mailAlertImageView
				attribute:NSLayoutAttributeTop
				relatedBy:NSLayoutRelationEqual
				toItem:self
				attribute:NSLayoutAttributeTop
				multiplier:1.0
				constant:0.0
			],
			[NSLayoutConstraint
				constraintWithItem:_mailAlertImageView
				attribute:NSLayoutAttributeCenterX
				relatedBy:NSLayoutRelationEqual
				toItem:self
				attribute:NSLayoutAttributeCenterX
				multiplier:1.0
				constant:0.0
			],
			[NSLayoutConstraint
				constraintWithItem:_imageView
				attribute:NSLayoutAttributeHeight
				relatedBy:NSLayoutRelationEqual
				toItem:nil
				attribute:NSLayoutAttributeNotAnAttribute
				multiplier:0.0
				constant:36.0
			],
			[NSLayoutConstraint
				constraintWithItem:_imageView
				attribute:NSLayoutAttributeWidth
				relatedBy:NSLayoutRelationEqual
				toItem:nil
				attribute:NSLayoutAttributeNotAnAttribute
				multiplier:0.0
				constant:27.0
			],
			[NSLayoutConstraint
				constraintWithItem:_imageView
				attribute:NSLayoutAttributeLeft
				relatedBy:NSLayoutRelationEqual
				toItem:self
				attribute:NSLayoutAttributeLeft
				multiplier:1.0
				constant:0.0
			],
			[NSLayoutConstraint
				constraintWithItem:_imageView
				attribute:NSLayoutAttributeRight
				relatedBy:NSLayoutRelationEqual
				toItem:self
				attribute:NSLayoutAttributeRight
				multiplier:1.0
				constant:0.0
			],
			[NSLayoutConstraint
				constraintWithItem:_imageView
				attribute:NSLayoutAttributeBottom
				relatedBy:NSLayoutRelationEqual
				toItem:self
				attribute:NSLayoutAttributeBottom
				multiplier:1.0
				constant:0.0
			],
		]];
		_imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
		self.isFull = _isFull;
	}
	return self;
}

- (void)handleTap:(id)sender {
	if (_isFull) {
		[[MMGroundContainerView springboardSingleton] animateDeliveryBirdLeavingWithCompletion:nil];
	}
}

- (void)dealloc {
	[NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)setIsFull:(BOOL)isFull {
	_imageView.image = [MMAssets imageNamed:(isFull ? @"mailbox_full" : @"mailbox_empty")];
	_birdView.hidden = !isFull;
	_mailAlertImageView.hidden = !isFull;
}

@end