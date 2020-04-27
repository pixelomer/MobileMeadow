#import "MMMailBoxView.h"
#import "MMAssets.h"

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
		_birdView = [[MMBirdView alloc] initWithBirdName:@"deliverybird"];
		_birdView.horizontallyMirrored = YES;
		[_birdView stopAnimating];
		_birdView.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:_birdView];
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
				toItem:self
				attribute:NSLayoutAttributeTop
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
				attribute:NSLayoutAttributeTop
				relatedBy:NSLayoutRelationEqual
				toItem:self
				attribute:NSLayoutAttributeTop
				multiplier:1.0
				constant:0.0
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

- (void)dealloc {
	[NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)setIsFull:(BOOL)isFull {
	_imageView.image = [MMAssets imageNamed:(isFull ? @"mailbox_full" : @"mailbox_empty")];
	_birdView.hidden = !isFull;
}

@end