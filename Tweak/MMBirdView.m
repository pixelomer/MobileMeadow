#import "MMBirdView.h"
#import "MMAssets.h"

@implementation MMBirdView

- (instancetype)initWithBirdName:(NSString *)name {
	NSMutableArray<UIImage *> *animationImages = [NSMutableArray new];
	NSUInteger i=0, j=0;
	while (1) {
		UIImage *image = [MMAssets imageNamed:[NSString stringWithFormat:@"%@_%lu", name, (unsigned long)i]];
		if (!image) break;
		[animationImages addObject:image];
		i++;
	}
	if (!i) {
		[NSException
			raise:NSInvalidArgumentException
			format:@"The specified bird (%@) does not exist.", name
		];
	}
	if (i <= 2) {
		[NSException
			raise:NSInvalidArgumentException
			format:@"A bird must have at least 3 frames for animation. The specified bird (%@) has only %lu frames.", name, (unsigned long)i
		];
	}
	for (j=0; j<animationImages.count; j++) {
		for (i=0; i<animationImages.count; i++) {
			if (i==j) continue;
			if (!CGSizeEqualToSize(animationImages[j].size, animationImages[i].size)) {
				[NSException
					raise:NSInvalidArgumentException
					format:@"The images for this bird (%@) are not the same size.", name
				];
			}
		}
	}
	UIImage *groundImage = [MMAssets imageNamed:[NSString stringWithFormat:@"%@_ground", name]];
	if (groundImage && !CGSizeEqualToSize(animationImages[0].size, groundImage.size)) {
		[NSException
			raise:NSInternalInconsistencyException
			format:@"The ground image for this bird (%@) is not the same size as the animation frames.", name
		];
	}
	for (i=animationImages.count-2; i>=1; i--) {
		[animationImages addObject:animationImages[i]];
	}
	if ((self = [super init])) {
		_groundImage = groundImage;
		_animationImages = animationImages.copy;
		_imageView = [UIImageView new];
		_name = name;
		_size = CGSizeMake(animationImages[0].size.width, animationImages[0].size.height);
		_imageView.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:_imageView];
		[self addConstraints:@[
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
				attribute:NSLayoutAttributeTop
				relatedBy:NSLayoutRelationEqual
				toItem:self
				attribute:NSLayoutAttributeTop
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
			[NSLayoutConstraint
				constraintWithItem:_imageView
				attribute:NSLayoutAttributeHeight
				relatedBy:NSLayoutRelationEqual
				toItem:nil
				attribute:NSLayoutAttributeNotAnAttribute
				multiplier:0.0
				constant:_size.height
			],
			[NSLayoutConstraint
				constraintWithItem:_imageView
				attribute:NSLayoutAttributeWidth
				relatedBy:NSLayoutRelationEqual
				toItem:nil
				attribute:NSLayoutAttributeNotAnAttribute
				multiplier:0.0
				constant:_size.width
			]
		]];
		[self startAnimating];
	}
	return self;
}

- (void)startAnimating {
	_imageView.image = nil;
	self.userInteractionEnabled = NO;
	_imageView.animationImages = _animationImages;
	_imageView.animationDuration = (NSTimeInterval)_animationImages.count * 0.1;
	[_imageView startAnimating];
}

- (void)stopAnimating {
	if (!_groundImage) {
		[NSException
			raise:NSInvalidArgumentException
			format:@"You cannot stop the animation for a bird which doesn't have a ground image, such as \"%@\".", _name
		];
	}
	self.userInteractionEnabled = YES;
	[_imageView stopAnimating];
	_imageView.animationImages = nil;
	_imageView.image = _groundImage;
	[_imageView setNeedsDisplay];
}

- (CGSize)sizeThatFits:(CGSize)size {
	return _size;
}

- (BOOL)isAnimating {
	return _imageView.isAnimating;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	return [self isAnimating] ? NO : [super pointInside:point withEvent:event];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	return [self isAnimating] ? nil : [super hitTest:point withEvent:event];
}

- (void)updateTransform {
	CGAffineTransform transform = CGAffineTransformIdentity;
	transform = CGAffineTransformRotate(transform, DEG_TO_RAD(_rotationInDegrees));
	transform = CGAffineTransformScale(
		transform,
		_horizontallyMirrored ? -1.0 : 1.0, 
		1.0
	);
	self.transform = transform;
}

- (void)setHorizontallyMirrored:(BOOL)horizontallyMirrored {
	_horizontallyMirrored = horizontallyMirrored;
	[self updateTransform];
}

- (void)setRotationInDegrees:(CGFloat)degrees {
	_rotationInDegrees = degrees;
	[self updateTransform];
}

@end