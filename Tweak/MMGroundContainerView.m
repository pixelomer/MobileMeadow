#import "MMGroundContainerView.h"
#import "MMAssets.h"
#import "MMBirdView.h"
#import "MMAirLayerWindow.h"
#import "MMMailBoxView.h"

@implementation MMGroundContainerView

static MMGroundContainerView *_springboardSingleton;

+ (MMGroundContainerView *)springboardSingleton {
	return _springboardSingleton;
}

- (instancetype)init {
	if ((self = [super init])) {
		self.translatesAutoresizingMaskIntoConstraints = NO;
		_lastUpdateX = 1.0;
		if ([NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
			if (_springboardSingleton) {
				[NSException
					raise:NSInvalidArgumentException
					format:@"There can only be one ground instance in SpringBoard."
				];
			}
			_springboardSingleton = self;
			_mailBoxView = [MMMailBoxView new];
			_mailBoxView.translatesAutoresizingMaskIntoConstraints = NO;
			[self addSubview:_mailBoxView];
			[self addConstraints:@[
				[NSLayoutConstraint
					constraintWithItem:_mailBoxView
					attribute:NSLayoutAttributeRight
					relatedBy:NSLayoutRelationEqual
					toItem:self
					attribute:NSLayoutAttributeRight
					multiplier:1.0
					constant:-30.0
				],
				[NSLayoutConstraint
					constraintWithItem:_mailBoxView
					attribute:NSLayoutAttributeBottom
					relatedBy:NSLayoutRelationEqual
					toItem:self
					attribute:NSLayoutAttributeBottom
					multiplier:1.0
					constant:0.0
				]
			]];
		}
	}
	return self;
}

- (void)animateDeliveryBirdLeavingWithCompletion:(void(^)(BOOL finished))completion {
	[MMMailBoxView setIsFull:NO];
	MMBirdView *birdView = [[MMBirdView alloc] initWithBirdName:@"deliverybird"];
	birdView.translatesAutoresizingMaskIntoConstraints = NO;
	birdView.horizontallyMirrored = NO;
	[self addSubview:birdView];
	NSArray *targetConstraints = @[
		[NSLayoutConstraint
			constraintWithItem:birdView
			attribute:NSLayoutAttributeLeft
			relatedBy:NSLayoutRelationEqual
			toItem:self
			attribute:NSLayoutAttributeRight
			multiplier:1.0
			constant:0.0
		],
		[NSLayoutConstraint
			constraintWithItem:birdView
			attribute:NSLayoutAttributeBottom
			relatedBy:NSLayoutRelationEqual
			toItem:self
			attribute:NSLayoutAttributeBottom
			multiplier:1.0
			constant:-125.0
		]
	];
	NSArray *initialConstraints = @[
		[NSLayoutConstraint
			constraintWithItem:birdView
			attribute:NSLayoutAttributeBottom
			relatedBy:NSLayoutRelationEqual
			toItem:_mailBoxView
			attribute:NSLayoutAttributeBottom
			multiplier:1.0
			constant:-36.0
		],
		[NSLayoutConstraint
			constraintWithItem:birdView
			attribute:NSLayoutAttributeCenterX
			relatedBy:NSLayoutRelationEqual
			toItem:_mailBoxView
			attribute:NSLayoutAttributeCenterX
			multiplier:1.0
			constant:0.0
		]
	];
	[self addConstraints:initialConstraints];
	[self setNeedsLayout];
	[self layoutIfNeeded];
	[UIView
		animateWithDuration:2.0
		delay:0.0
		options:UIViewAnimationOptionCurveLinear
		animations:^{
			[self removeConstraints:initialConstraints];
			[self addConstraints:targetConstraints];
			[self setNeedsLayout];
			[self layoutIfNeeded];
		}
		completion:^(BOOL finished){
			[birdView removeFromSuperview];
			if (completion) completion(finished);
		}
	];
}

- (void)animateDeliveryBirdLandingWithCompletion:(void(^)(BOOL finished))completion {
	MMBirdView *birdView = [[MMBirdView alloc] initWithBirdName:@"deliverybird"];
	birdView.translatesAutoresizingMaskIntoConstraints = NO;
	birdView.horizontallyMirrored = YES;
	[self addSubview:birdView];
	NSArray *initialConstraints = @[
		[NSLayoutConstraint
			constraintWithItem:birdView
			attribute:NSLayoutAttributeLeft
			relatedBy:NSLayoutRelationEqual
			toItem:self
			attribute:NSLayoutAttributeRight
			multiplier:1.0
			constant:0.0
		],
		[NSLayoutConstraint
			constraintWithItem:birdView
			attribute:NSLayoutAttributeBottom
			relatedBy:NSLayoutRelationEqual
			toItem:self
			attribute:NSLayoutAttributeBottom
			multiplier:1.0
			constant:-125.0
		]
	];
	NSArray *targetConstraints = @[
		[NSLayoutConstraint
			constraintWithItem:birdView
			attribute:NSLayoutAttributeBottom
			relatedBy:NSLayoutRelationEqual
			toItem:_mailBoxView
			attribute:NSLayoutAttributeBottom
			multiplier:1.0
			constant:-36.0
		],
		[NSLayoutConstraint
			constraintWithItem:birdView
			attribute:NSLayoutAttributeCenterX
			relatedBy:NSLayoutRelationEqual
			toItem:_mailBoxView
			attribute:NSLayoutAttributeCenterX
			multiplier:1.0
			constant:0.0
		]
	];
	[self addConstraints:initialConstraints];
	[self setNeedsLayout];
	[self layoutIfNeeded];
	[UIView
		animateWithDuration:2.0
		delay:0.0
		options:UIViewAnimationOptionCurveLinear
		animations:^{
			[self removeConstraints:initialConstraints];
			[self addConstraints:targetConstraints];
			[self setNeedsLayout];
			[self layoutIfNeeded];
		}
		completion:^(BOOL finished){
			[MMMailBoxView setIsFull:YES];
			[birdView removeFromSuperview];
			if (completion) completion(finished);
		}
	];
}

- (void)updatePlants {
	while ([self pointInside:CGPointMake(_lastUpdateX, 1) withEvent:nil]) {
		UIImage *image = [MMAssets randomImageWithPrefix:@"plant"];
		UIImageView *imageView = [UIImageView new];
		imageView.image = image;
		imageView.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:imageView];
		[self addConstraints:@[
			[NSLayoutConstraint
				constraintWithItem:imageView
				attribute:NSLayoutAttributeHeight
				relatedBy:NSLayoutRelationEqual
				toItem:nil
				attribute:NSLayoutAttributeNotAnAttribute
				multiplier:0.0
				constant:image.size.height
			],
			[NSLayoutConstraint
				constraintWithItem:imageView
				attribute:NSLayoutAttributeWidth
				relatedBy:NSLayoutRelationEqual
				toItem:nil
				attribute:NSLayoutAttributeNotAnAttribute
				multiplier:0.0
				constant:image.size.width
			],
			[NSLayoutConstraint
				constraintWithItem:imageView
				attribute:NSLayoutAttributeBottom
				relatedBy:NSLayoutRelationEqual
				toItem:self
				attribute:NSLayoutAttributeBottom
				multiplier:1.0
				constant:0.0
			],
			[NSLayoutConstraint
				constraintWithItem:imageView
				attribute:NSLayoutAttributeLeft
				relatedBy:NSLayoutRelationEqual
				toItem:self
				attribute:NSLayoutAttributeLeft
				multiplier:1.0
				constant:_lastUpdateX
			],
		]];
		_lastUpdateX += image.size.width + arc4random_uniform(20) + 10;
		UIImageView *__weak weakImageView = imageView;
		CGFloat initialDegrees = (CGFloat)((int)arc4random_uniform(31) - 15);
		__block BOOL isLeftToRight = arc4random_uniform(2);
		CGAffineTransform transform = CGAffineTransformIdentity;
		transform = CGAffineTransformTranslate(transform, 0.0, imageView.image.size.height);
		transform = CGAffineTransformRotate(transform, initialDegrees * M_PI/180);
		transform = CGAffineTransformTranslate(transform, 0.0, -imageView.image.size.height);
		initialDegrees += 20.0;
		if (isLeftToRight) initialDegrees = 40.0 - initialDegrees;
		__block NSTimeInterval interval = initialDegrees/12.0;
		void(^__block animate)(BOOL) = ^(BOOL finished){
			isLeftToRight = !isLeftToRight;
			if (!weakImageView) {
				animate = nil;
			}
			[UIView
				animateWithDuration:interval
				delay:0.0
				options:UIViewAnimationOptionCurveEaseInOut
				animations:^{
					CGAffineTransform transform = CGAffineTransformIdentity;
					transform = CGAffineTransformTranslate(transform, 0.0, weakImageView.image.size.height);
					transform = CGAffineTransformRotate(transform, (isLeftToRight ? 20.0 : -20.0) * M_PI/180);
					transform = CGAffineTransformTranslate(transform, 0.0, -weakImageView.image.size.height);
					weakImageView.transform = transform;
					interval = (40.0/12.0);
				}
				completion:animate
			];
		};
		animate(YES);
	}
}

- (void)layoutSubviews {
	[self updatePlants];
	[super layoutSubviews];
}

- (void)didMoveToSuperview {
	[super didMoveToSuperview];
	if (!self.superview) return;
	[self.superview addConstraints:@[
		[NSLayoutConstraint
			constraintWithItem:self
			attribute:NSLayoutAttributeHeight
			relatedBy:NSLayoutRelationEqual
			toItem:nil
			attribute:NSLayoutAttributeNotAnAttribute
			multiplier:0.0
			constant:30.0
		],
		[NSLayoutConstraint
			constraintWithItem:self
			attribute:NSLayoutAttributeWidth
			relatedBy:NSLayoutRelationEqual
			toItem:self.superview
			attribute:NSLayoutAttributeWidth
			multiplier:1.0
			constant:0.0
		],
		[NSLayoutConstraint
			constraintWithItem:self
			attribute:NSLayoutAttributeTop
			relatedBy:NSLayoutRelationEqual
			toItem:self.superview
			attribute:NSLayoutAttributeTop
			multiplier:1.0
			constant:-25.0 + ([NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.springboard"] ? 0.0 : -3.0)
		],
		[NSLayoutConstraint
			constraintWithItem:self
			attribute:NSLayoutAttributeLeft
			relatedBy:NSLayoutRelationEqual
			toItem:self.superview
			attribute:NSLayoutAttributeLeft
			multiplier:1.0
			constant:0.0
		],
		[NSLayoutConstraint
			constraintWithItem:self
			attribute:NSLayoutAttributeRight
			relatedBy:NSLayoutRelationEqual
			toItem:self.superview
			attribute:NSLayoutAttributeRight
			multiplier:1.0
			constant:0.0
		]
	]];
	[self updatePlants];
}

@end